import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/login_screen.dart';

/// Guest user ko login karne ka full-screen prompt.
/// Din mein sirf 1 dafa dikhata hai (annoying na ho!).
Future<void> showGuestLoginPrompt(BuildContext context) async {
  // // ---- Aaj already dikhaya to skip ----
  // final prefs = await SharedPreferences.getInstance();

  // final now = DateTime.now();
  // final String todayKey = '${now.year}-${now.month}-${now.day}';

  // if (prefs.getString('guest_prompt_date') == todayKey) return;

  // await prefs.setString('guest_prompt_date', todayKey);

  if (!context.mounted) return;

  await showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: const _GuestPromptContent(),
      );
    },
  );
}

// ============================================================================
// PROMPT CONTENT — welcome + benefits + buttons
// ============================================================================

class _GuestPromptContent extends StatelessWidget {
  const _GuestPromptContent();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ---- Logo ----
          Image.asset(
            'assets/images/zamindar_logo.png',
            width: 90,
            height: 60,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 12),

          // ---- Title ----
          Text(
            'Welcome to Zamindar!',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B1C1C),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Login kar ke behtar experience lo:',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: const Color(0xFF777777),
            ),
          ),

          const SizedBox(height: 20),

          // ---- Benefits ----
          _benefit(
            icon: Icons.local_shipping_outlined,
            title: 'Orders Track Karo',
            subtitle: 'Apni har order ki status dekho',
          ),

          const SizedBox(height: 12),

          _benefit(
            icon: Icons.save_outlined,
            title: 'Info Save Rahe',
            subtitle: 'Naam, phone, address — sab yaad rahe',
          ),

          const SizedBox(height: 12),

          _benefit(
            icon: Icons.bolt_outlined,
            title: '1-Tap Fast Checkout',
            subtitle: 'Har baar address nahi bharna parega',
          ),

          const SizedBox(height: 24),

          // ---- LOGIN button ----
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // dialog band
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087524),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'LOGIN Now',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ---- Continue as Guest ----
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Continue as Guest',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF999999),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Ek benefit row ----
  Widget _benefit({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Builder(
      builder: (context) {
        return Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFDCE8DA),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: const Color(0xFF087524)),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF303030),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.check_circle_outline,
              size: 20,
              color: Color(0xFF087524),
            ),
          ],
        );
      },
    );
  }
}
