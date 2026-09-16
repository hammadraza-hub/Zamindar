import 'package:flutter/foundation.dart';

import '../services/auth/auth_service.dart';

/// Tells the whole app whether the user is logged in (and who).
class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _initialized = false;

  Map<String, dynamic>? get user => _user;

  /// Display name — warna email ka pehla hissa.
  /// (Naam mein email na aaye!)
  String get userName {
    final name = _user?['display_name']?.toString() ?? '';
    if (name.isNotEmpty && !name.contains('@')) return name;

    final email = _user?['email']?.toString() ?? '';
    if (email.isNotEmpty) return email.split('@').first;

    return 'User';
  }

  String get userEmail => _user?['email']?.toString() ?? '';

  bool get isLoggedIn => _user != null;
  bool get isInitialized => _initialized;

  /// App start par saved session load karta hai.
  Future<void> loadSession() async {
    _user = await AuthService.getStoredUser();
    _initialized = true;
    notifyListeners();
  }

  /// JWT login — success par user set ho jata hai.
  Future<void> login(String username, String password) async {
    final data = await AuthService.login(username, password);

    // AuthService ne display name pehle hi theek kar ke
    // saveSession mein likha hai — wahi dobara parho
    final stored = await AuthService.getStoredUser();

    _user =
        stored ??
        {
          'display_name': data['user_display_name']?.toString() ?? '',
          'email': data['user_email']?.toString() ?? '',
          'username': data['user_nicename']?.toString() ?? '',
        };

    notifyListeners();
  }

  /// Profile naam update — website + local dono.
  Future<void> updateDisplayName(String displayName) async {
    // (1) Website par update
    await AuthService.updateDisplayName(displayName);

    // (2) App state update (turant sab jagah naya naam!)
    _user?['display_name'] = displayName.trim();
    notifyListeners();
  }

  /// Logout — session delete, guest mode.
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    notifyListeners();
  }

  /// Signup → account banao → turant LOGIN bhi!
  /// (user ko dobara login form nahi bharna parta)
  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    // (1) WordPress par account banao
    await AuthService.signup(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    // (2) Turant login — token le lo
    await login(email, password);
  }
}
