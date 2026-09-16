import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../config/api_credentials.dart';
import '../../config/app_config.dart';
import '../api/api_client.dart';

/// All JWT authentication work in one place:
/// login, signup, logout, and stored session access.
class AuthService {
  AuthService._(); // static-only class

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ---------------- LOGIN ----------------

  /// Logs in via WordPress JWT (username or email + password).
  /// Saves the session on success. Throws [ApiException] on failure.
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/wp-json/jwt-auth/v1/token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 20));
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _saveSession(data);
      return data;
    }

    throw _authError(response);
  }

  // ---------------- SIGNUP (NAYA) ----------------

  /// WordPress par naya CUSTOMER account banata hai
  /// (WooCommerce REST API + keys se).
  static Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ApiCredentials.consumerKey}:${ApiCredentials.consumerSecret}'))}';

    http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/wp-json/wc/v3/customers'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': basicAuth,
            },
            body: jsonEncode({
              'email': email,
              'first_name': firstName,
              'last_name': lastName,
              'username': email, // login email se hoga (simple)
              'password': password,
              'billing': {'phone': phone ?? ''},
            }),
          )
          .timeout(const Duration(seconds: 20));
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    }

    // 201 = Created (success!)
    if (response.statusCode == 201) return;

    throw _signupError(response);
  }
  // ---------------- UPDATE PROFILE (NAYA) ----------------

  /// WordPress par user ka naam update karta hai.
  /// (JWT token se — sirf apna hi account change ho sakta hai!)
  static Future<void> updateDisplayName(String displayName) async {
    final token = await getToken();
    if (token == null) {
      throw const ApiException('Not logged in. Please login again.');
    }

    // Naam ko first/last mein todein
    final parts = displayName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    http.Response response;

    try {
      response = await http
          .post(
            Uri.parse(
              '${AppConfig.baseUrl}/wp-json/wp/v2/users/me?context=edit',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'first_name': firstName,
              'last_name': lastName,
              'name': displayName.trim(),
            }),
          )
          .timeout(const Duration(seconds: 20));
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    }

    if (response.statusCode != 200) {
      throw ApiException('Could not update profile (${response.statusCode})');
    }

    // ---- Local stored session bhi update karo ----
    final user = await getStoredUser();
    if (user != null) {
      user['display_name'] = displayName.trim();
      await _storage.write(key: _userKey, value: jsonEncode(user));
    }
  }
  // ---------------- PROFILE PHOTO (NAYA) ----------------

  /// Profile photo ko WordPress media library mein upload karta hai.
  /// Upload hone par URL wapas deta hai.
  static Future<String> uploadProfilePhoto(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const ApiException('Image file not found.');
    }

    final bytes = await file.readAsBytes();

    // Media upload ke liye ck/cs keys (admin level access)
    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ApiCredentials.consumerKey}:${ApiCredentials.consumerSecret}'))}';

    http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/wp-json/wp/v2/media'),
            headers: {
              'Authorization': basicAuth,
              'Content-Type': 'image/jpeg',
              'Content-Disposition':
                  'attachment; filename="profile_${DateTime.now().millisecondsSinceEpoch}.jpg"',
            },
            body: bytes,
          )
          .timeout(const Duration(seconds: 30));
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Upload timed out. Please try again.');
    }

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['source_url']?.toString() ?? '';
    }

    throw ApiException('Photo upload failed (${response.statusCode})');
  }

  /// Photo URL ko WooCommerce customer profile mein save karta hai.
  static Future<void> saveProfilePhotoUrl(String url) async {
    final profile = await fetchUserProfile();
    final userId = (profile?['id'] as num?)?.toInt() ?? 0;

    if (userId <= 0) {
      throw const ApiException('Could not identify account.');
    }

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ApiCredentials.consumerKey}:${ApiCredentials.consumerSecret}'))}';

    final response = await http
        .post(
          Uri.parse('${AppConfig.baseUrl}/wp-json/wc/v3/customers/$userId'),
          headers: {
            'Authorization': basicAuth,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'meta_data': [
              {'key': 'profile_photo_url', 'value': url},
            ],
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode != 200) {
      throw ApiException('Could not save photo (${response.statusCode})');
    }
  }

  /// User ki saved profile photo URL fetch karta hai.
  static Future<String?> getProfilePhotoUrl() async {
    final profile = await fetchUserProfile();
    final userId = (profile?['id'] as num?)?.toInt() ?? 0;

    if (userId <= 0) return null;

    final String basicAuth =
        'Basic ${base64Encode(utf8.encode('${ApiCredentials.consumerKey}:${ApiCredentials.consumerSecret}'))}';

    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/wp-json/wc/v3/customers/$userId'),
            headers: {'Authorization': basicAuth},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final metaData = data['meta_data'] as List? ?? [];

        for (final meta in metaData) {
          if (meta['key'] == 'profile_photo_url') {
            return meta['value']?.toString();
          }
        }
      }
    } catch (_) {}

    return null;
  }
  // ---------------- LOGOUT ----------------

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // ---------------- SESSION ----------------

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
  }

  /// JWT token se user ka POORA profile lata hai
  /// (first_name/last_name — display ke liye asli naam).
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse(
              '${AppConfig.baseUrl}/wp-json/wp/v2/users/me?context=edit',
            ),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}

    return null;
  }

  static Future<Map<String, dynamic>?> getStoredUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ---------------- HELPERS ----------------
  static Future<void> _saveSession(Map<String, dynamic> data) async {
    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw ApiException('Login failed — no token received.');
    }

    await _storage.write(key: _tokenKey, value: token);

    // ---- Display name theek karo (email ki jagah ASLI naam) ----
    String displayName = data['user_display_name']?.toString() ?? '';

    // Display name email jaisa hai (ya khali) → poora profile mangwao
    if (displayName.isEmpty ||
        displayName.contains('@') ||
        displayName == data['user_email']?.toString().split('@').first) {
      final profile = await fetchUserProfile();

      final first = profile?['first_name']?.toString() ?? '';
      final last = profile?['last_name']?.toString() ?? '';

      final fullName = '$first $last'.trim();
      if (fullName.isNotEmpty) displayName = fullName;
    }

    await _storage.write(
      key: _userKey,
      value: jsonEncode({
        'display_name': displayName,
        'email': data['user_email']?.toString() ?? '',
        'username': data['user_nicename']?.toString() ?? '',
      }),
    );
  }

  /// Login errors — friendly messages.
  static ApiException _authError(http.Response response) {
    String message = 'Login failed. Please check your credentials.';

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final code = data['code']?.toString() ?? '';

      if (code.contains('invalid_username')) {
        message = 'No account found with this email/username.';
      } else if (code.contains('incorrect_password')) {
        message = 'Incorrect password. Please try again.';
      } else if (code.contains('invalid_email')) {
        message = 'Invalid email address.';
      }
    } catch (_) {}

    return ApiException(message);
  }

  /// Signup errors — friendly messages.
  static ApiException _signupError(http.Response response) {
    String message = 'Could not create account. Please try again.';

    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final code = data['code']?.toString() ?? '';

      if (code.contains('email-exists') ||
          code.contains('registration-error-email-exists')) {
        message = 'An account with this email already exists. Try logging in.';
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        message = 'Server rejected the request (API keys check karen).';
      } else if (code.contains('invalid-email')) {
        message = 'Please enter a valid email address.';
      }
    } catch (_) {}

    return ApiException(message);
  }
}
