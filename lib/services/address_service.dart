import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Saved delivery address — permanently phone par rehta hai.
/// Checkout har baar yehi use karta hai (jab tak user change na kare).
class AddressService {
  AddressService._();

  static const String _key = 'saved_address_v1';

  // ---------------- SAVE ----------------

  static Future<void> save({
    required String name,
    required String phone,
    required String email,
    required String addressLine,
    required String city,
    required String state,
    required String postcode,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _key,
        jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'address': addressLine,
          'city': city,
          'state': state,
          'postcode': postcode,
        }),
      );
    } catch (_) {
      // Save fail → koi crash nahi
    }
  }

  // ---------------- LOAD ----------------

  /// Saved address — null matlab kuch save nahi.
  static Future<Map<String, String>?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString(_key);
      if (raw == null || raw.isEmpty) return null;

      final data = jsonDecode(raw) as Map<String, dynamic>;

      return {
        'name': data['name']?.toString() ?? '',
        'phone': data['phone']?.toString() ?? '',
        'email': data['email']?.toString() ?? '',
        'address': data['address']?.toString() ?? '',
        'city': data['city']?.toString() ?? '',
        'state': data['state']?.toString() ?? 'Punjab',
        'postcode': data['postcode']?.toString() ?? '',
      };
    } catch (_) {
      return null;
    }
  }

  // ---------------- CLEAR (logout par) ----------------

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
