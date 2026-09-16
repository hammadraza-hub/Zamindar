import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'help_support_screen.dart';
import 'policy_screen.dart';

// ============================================================================
// SETTINGS SCREEN
//
//   - Notifications toggle (locally saved)
//   - Share App (WhatsApp/friends!)
//   - Help & Support (existing screen)
//   - Privacy & Terms (existing screen)
//   - App Version info
// ============================================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ==========================================================================
  // 1. STATE
  // ==========================================================================

  bool _notificationsEnabled = true;

  static const String _notificationsKey = 'notifications_enabled';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// Saved settings load karo
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (mounted) {
      setState(() {
        _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
      });
    }
  }

  /// Notification toggle — save + update
  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      _notificationsEnabled = value;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
  }

  // ==========================================================================
  // 2. SHARE APP
  // ==========================================================================

  void _shareApp() {
    SharePlus.instance.share(
      ShareParams(
        text:
            '🌱 Zamindar App — Your trusted agricultural companion!\n'
            'Genuine farm supplies delivered to your doorstep.\n'
            'Order now: https://zamindar.co',
        subject: 'Zamindar App',
      ),
    );
  }

  // ==========================================================================
  // 3. UI HELPERS
  // ==========================================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ---- Normal setting row (tap-able) ----
  Widget _settingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF087524)),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF303030),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF999999),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFAAAAAA),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Toggle row (notifications) ----
  Widget _toggleRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_outlined,
            size: 22,
            color: Color(0xFF087524),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF303030),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Order updates and offers',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),

          // ---- Switch ----s
          Switch(
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            activeThumbColor: const Color(0xFF087524),
            inactiveThumbColor: const Color(0xFFBBBBBB),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 4. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Column(
          children: [
            // ---- Header ----
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 24, 14),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(30),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.arrow_back,
                        size: 25,
                        color: Color(0xFF087524),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    'Settings',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1, color: Color(0xFFF0EEEE)),

            // ---- Settings items ----
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
                children: [
                  // ---- Section: General ----
                  Text(
                    'GENERAL',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF999999),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- Notifications toggle ----
                  _toggleRow(),

                  // ---- Share App ----
                  _settingRow(
                    icon: Icons.share_outlined,
                    title: 'Share App',
                    subtitle: 'Recommend to friends & family',
                    onTap: _shareApp,
                  ),

                  const SizedBox(height: 20),

                  // ---- Section: Support ----
                  Text(
                    'SUPPORT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF999999),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- Help & Support ----
                  _settingRow(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    subtitle: 'FAQs and contact us',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpSupportScreen(),
                        ),
                      );
                    },
                  ),

                  // ---- Privacy & Terms ----
                  _settingRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy & Terms',
                    subtitle: 'How we protect your data',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PolicyScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // ---- Section: About ----
                  Text(
                    'ABOUT',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF999999),
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ---- App version ----
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    decoration: _cardDecoration(),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 22,
                          color: Color(0xFF087524),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            'App Version',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF303030),
                            ),
                          ),
                        ),

                        Text(
                          '1.0.0',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            color: const Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---- Tagline ----
                  Center(
                    child: Text(
                      'Growing the future, one order at a time',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: const Color(0xFF777777),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
