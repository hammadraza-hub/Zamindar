import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../config/api_credentials.dart';
import '../../config/app_config.dart';
import '../api/api_client.dart';

/// Returned when uploading media to WordPress.
class UploadedMedia {
  final int id;
  final String url;

  UploadedMedia({required this.id, required this.url});
}

/// Saved profile photo data stored in WooCommerce customer meta.
class ProfilePhotoData {
  final String? url;
  final int? mediaId;

  ProfilePhotoData({required this.url, required this.mediaId});
}

/// All JWT authentication work in one place:
/// login, signup, logout, and stored session access.
class AuthService {
  AuthService._(); // static-only class

  static const String _tokenKey = 'jwt_token';
  static const String _userKey = 'user_data';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // Meta keys (WooCommerce customer meta)
  static const String _metaPhotoUrlKey = 'profile_photo_url';
  static const String _metaPhotoMediaIdKey = 'profile_photo_media_id';

  /// WooCommerce ck/cs keys se Basic Auth header.
  static String _wcBasicAuth() {
    return 'Basic ${base64Encode(utf8.encode('${ApiCredentials.consumerKey}:${ApiCredentials.consumerSecret}'))}';
  }

  // ---------------- LOGIN ----------------

  /// Logs in via WordPress JWT (username or email + password).
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

  // ---------------- SIGNUP ----------------

  /// WordPress par naya CUSTOMER account banata hai.
  static Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/wp-json/wc/v3/customers'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': _wcBasicAuth(),
            },
            body: jsonEncode({
              'email': email,
              'first_name': firstName,
              'last_name': lastName,
              'username': email,
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

    if (response.statusCode == 201) return;

    throw _signupError(response);
  }

  // ---------------- UPDATE PROFILE ----------------

  /// WordPress par user ka naam update karta hai. (JWT se)
  static Future<void> updateDisplayName(String displayName) async {
    final token = await getToken();
    if (token == null) {
      throw const ApiException('Not logged in. Please login again.');
    }

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

    final user = await getStoredUser();
    if (user != null) {
      user['display_name'] = displayName.trim();
      await _storage.write(key: _userKey, value: jsonEncode(user));
    }
  }

  // ---------------- PROFILE PHOTO — UPLOAD (JWT) ----------------

  /// Uploads profile photo and returns BOTH media id + url.
  static Future<UploadedMedia> uploadProfilePhotoWithId(String filePath) async {
    final token = await getToken();
    if (token == null) {
      throw const ApiException('Not logged in. Please login again.');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw const ApiException('Image file not found.');
    }

    final bytes = await file.readAsBytes();

    final ext = filePath.split('.').last.toLowerCase();
    String contentType;
    String fileExt;

    switch (ext) {
      case 'webp':
        contentType = 'image/webp';
        fileExt = 'webp';
        break;
      case 'png':
        contentType = 'image/png';
        fileExt = 'png';
        break;
      case 'jpg':
      case 'jpeg':
      default:
        contentType = 'image/jpeg';
        fileExt = 'jpg';
        break;
    }

    http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/wp-json/wp/v2/media'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': contentType,
              'Content-Disposition':
                  'attachment; filename="profile_${DateTime.now().millisecondsSinceEpoch}.$fileExt"',
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

      final id = (data['id'] as num?)?.toInt() ?? 0;
      final url = data['source_url']?.toString() ?? '';

      if (id <= 0 || url.isEmpty) {
        throw ApiException('Upload succeeded but response missing id/url.');
      }

      return UploadedMedia(id: id, url: url);
    }

    throw ApiException('Photo upload failed (${response.statusCode})');
  }

  /// OLD (compatibility): Returns only URL.
  @Deprecated('Use uploadProfilePhotoWithId()')
  static Future<String> uploadProfilePhoto(String filePath) async {
    final uploaded = await uploadProfilePhotoWithId(filePath);
    return uploaded.url;
  }

  // ---------------- AVATAR SERVER SET (NAYA!) ----------------

  /// Server plugin endpoint: avatar set + old photo auto-delete.
  /// Plugin "Zamindar Avatar Manager" handle karta hai:
  ///   - Purani photo DELETE (server-side — 403 khatam!)
  ///   - New meta save (url + mediaId)
  /// Flutter mein direct delete ki zaroorat NAHI!
  static Future<void> setAvatarOnServer({
    required int mediaId,
    required String url,
  }) async {
    final token = await getToken();
    if (token == null) {
      throw const ApiException('Not logged in. Please login again.');
    }

    http.Response response;

    try {
      response = await http
          .post(
            Uri.parse('${AppConfig.baseUrl}/wp-json/zamindar/v1/avatar/set'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'media_id': mediaId, 'url': url}),
          )
          .timeout(const Duration(seconds: 20));
    } on SocketException {
      throw ApiException('No internet connection. Please check your network.');
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    }

    if (response.statusCode == 200) return;

    throw ApiException('Avatar set failed (${response.statusCode})');
  }

  // ---------------- PROFILE PHOTO — GET (ck/cs) ----------------

  /// Gets saved profile photo url + mediaId from customer meta.
  static Future<ProfilePhotoData> getProfilePhotoData() async {
    final profile = await fetchUserProfile();
    final userId = (profile?['id'] as num?)?.toInt() ?? 0;

    if (userId <= 0) return ProfilePhotoData(url: null, mediaId: null);

    try {
      final response = await http
          .get(
            Uri.parse('${AppConfig.baseUrl}/wp-json/wc/v3/customers/$userId'),
            headers: {'Authorization': _wcBasicAuth()},
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final metaData = data['meta_data'] as List? ?? [];

        String? url;
        int? mediaId;

        for (final meta in metaData) {
          final key = meta['key']?.toString();
          if (key == _metaPhotoUrlKey) {
            url = meta['value']?.toString();
          } else if (key == _metaPhotoMediaIdKey) {
            mediaId = int.tryParse(meta['value']?.toString() ?? '');
          }
        }

        return ProfilePhotoData(url: url, mediaId: mediaId);
      }
    } catch (_) {}

    return ProfilePhotoData(url: null, mediaId: null);
  }

  /// OLD (compatibility): URL only.
  static Future<String?> getProfilePhotoUrl() async {
    final data = await getProfilePhotoData();
    return data.url;
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

  /// JWT token se user ka POORA profile lata hai.
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

    String displayName = data['user_display_name']?.toString() ?? '';

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

      if (code.contains('email-exists')) {
        message = 'An account with this email already exists. Try logging in.';
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        message = 'Server rejected the request (API keys check karen).';
      }
    } catch (_) {}

    return ApiException(message);
  }
}
