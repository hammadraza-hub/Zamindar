import 'dart:io';

import 'package:flutter/foundation.dart';

import '../services/auth/auth_service.dart';

/// Tells the whole app whether the user is logged in (and who).
class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _initialized = false;

  String? _photoUrl;
  int? _photoMediaId;

  Map<String, dynamic>? get user => _user;

  String? get photoUrl => _photoUrl;
  int? get photoMediaId => _photoMediaId;

  /// Debug logging helper (avoid_print warning fix!)
  void _log(String msg) {
    if (kDebugMode) debugPrint(msg);
  }

  /// Display name — warna email ka pehla hissa.
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

    final photo = await AuthService.getProfilePhotoData();
    _photoUrl = photo.url;
    _photoMediaId = photo.mediaId;

    _initialized = true;
    notifyListeners();
  }

  /// JWT login — success par user set ho jata hai.
  Future<void> login(String username, String password) async {
    final data = await AuthService.login(username, password);

    final stored = await AuthService.getStoredUser();

    _user =
        stored ??
        {
          'display_name': data['user_display_name']?.toString() ?? '',
          'email': data['user_email']?.toString() ?? '',
          'username': data['user_nicename']?.toString() ?? '',
        };

    // After login, load avatar info from cloud meta
    final photo = await AuthService.getProfilePhotoData();
    _photoUrl = photo.url;
    _photoMediaId = photo.mediaId;

    notifyListeners();
  }

  /// Profile naam update — website + local dono.
  Future<void> updateDisplayName(String displayName) async {
    await AuthService.updateDisplayName(displayName);

    _user?['display_name'] = displayName.trim();
    notifyListeners();
  }

  /// Profile photo upload → server set (old auto-delete) → app update
  ///
  /// Flow:
  ///   1. Upload to WordPress media (id + url)
  ///   2. Server plugin: purani photo DELETE + new meta save
  ///   3. App state update
  Future<void> uploadProfilePhoto(File imageFile) async {
    // (1) Upload to WordPress media
    final uploaded = await AuthService.uploadProfilePhotoWithId(imageFile.path);

    _log("Avatar upload: newMediaId=${uploaded.id}, url=${uploaded.url}");

    // (2) Server: old photo delete + meta save (plugin handles!)
    await AuthService.setAvatarOnServer(
      mediaId: uploaded.id,
      url: uploaded.url,
    );

    _log("Avatar upload: server set complete (old deleted + meta saved)");

    // (3) Update app state
    _photoUrl = uploaded.url;
    _photoMediaId = uploaded.id;
    notifyListeners();
  }

  /// Logout — session delete, guest mode.
  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _photoUrl = null;
    _photoMediaId = null;
    notifyListeners();
  }

  /// Signup → account banao → turant LOGIN bhi!
  Future<void> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
  }) async {
    await AuthService.signup(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      phone: phone,
    );

    await login(email, password);
  }
}
