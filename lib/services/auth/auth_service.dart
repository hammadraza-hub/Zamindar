import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../api/api_client.dart';

/// All JWT authentication work in one place:
/// login, logout, and stored session access.
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

  // ---------------- LOGOUT ----------------

  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // ---------------- SESSION ----------------

  static Future<String?> getToken() async {
    return _storage.read(key: _tokenKey);
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

    await _storage.write(
      key: _userKey,
      value: jsonEncode({
        'display_name': data['user_display_name']?.toString() ?? '',
        'email': data['user_email']?.toString() ?? '',
        'username': data['user_nicename']?.toString() ?? '',
      }),
    );
  }

  /// WordPress error JSON ko friendly message mein badalta hai.
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
}
