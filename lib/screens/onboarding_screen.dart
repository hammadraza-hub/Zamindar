import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_navigation_screen.dart';

// ============================================================================
// ONBOARDING SCREEN
//
// Slide 1: LOTTIE ANIMATION (tractor!) 🚜
// Slide 2: Icon design (products)
// Slide 3: Icon design (delivery)
//
// GET STARTED → save → Main App
// ============================================================================

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // ==========================================================================
  // 1. STATE
  // ==========================================================================

  final PageController _pageController = PageController();

  int _currentPage = 0;

  /// Slides — PEHLI slide mein LOTTIE animation!
  final List<Map<String, dynamic>> _slides = [
    {
      'animation': 'assets/animations/farming.json',
      'icon': Icons.agriculture,
      'title': 'Boost Your Harvest',
      'subtitle':
          'Premium agricultural supplies for modern farming needs — '
          'trusted by thousands of farmers',
    },
    {
      'icon': Icons.grid_view_rounded,
      'title': 'Everything Your Farm Needs',
      'subtitle':
          '700+ certified products — from insecticides to seed care, '
          'from top brands like Bayer & Syngenta',
    },
    {
      'icon': Icons.local_shipping_outlined,
      'title': 'Fast & Free Delivery',
      'subtitle':
          'Certified products delivered to your doorstep. '
          'Free delivery on orders above Rs 2,000',
    },
  ];

  // ==========================================================================
  // 2. FINISH — save karo, phir main app kholo
  // ==========================================================================

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
    );
  }

  // ==========================================================================
  // 3. NEXT — agli slide ya finish
  // ==========================================================================

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  // ==========================================================================
  // 4. SLIDE — LOTTIE ya Icon + title + subtitle
  // ==========================================================================

  Widget _buildSlide(Map<String, dynamic> slide) {
    final String? animPath = slide['animation'] as String?;
    final IconData icon = slide['icon'] as IconData;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // --- Visual (Lottie ya Icon circles) ---
          if (animPath != null)
            // ---- LOTTIE ANIMATION (Slide 1) 🚜 ----
            Lottie.asset(
              animPath,
              width: 280,
              height: 280,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (_, _, _) => _buildIconCircles(icon),
            )
          else
            // ---- ICON CIRCLES (Slide 2, 3) ----
            _buildIconCircles(icon),

          const SizedBox(height: 60),

          // --- Title ---
          Text(
            slide['title'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B1C1C),
            ),
          ),

          const SizedBox(height: 16),

          // --- Subtitle ---
          Text(
            slide['subtitle'] as String,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              height: 1.5,
              color: const Color(0xFF666666),
            ),
          ),
        ],
      ),
    );
  }

  /// Icon circles design (Slide 2, 3 + fallback)
  Widget _buildIconCircles(IconData icon) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Layer 1 — bahut halka green
        Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            color: const Color(0xFFDCE8DA).withValues(alpha: 0.4),
            shape: BoxShape.circle,
          ),
        ),

        // Layer 2 — halka green
        Container(
          width: 190,
          height: 190,
          decoration: const BoxDecoration(
            color: Color(0xFFDCE8DA),
            shape: BoxShape.circle,
          ),
        ),

        // Layer 3 — dark green + shadow
        Container(
          width: 140,
          height: 140,

          decoration: BoxDecoration(
            color: const Color(0xFF087524),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF087524).withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),

          child: Icon(icon, size: 60, color: Colors.white),
        ),
      ],
    );
  }

  // ==========================================================================
  // 5. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final bool isLastSlide = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Column(
          children: [
            // --- Skip ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!isLastSlide)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF999999),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // --- Slides ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,

                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },

                itemBuilder: (context, index) {
                  return _buildSlide(_slides[index]);
                },
              ),
            ),

            // --- Dots + Button ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),

              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,

                    children: List.generate(_slides.length, (index) {
                      final bool isActive = index == _currentPage;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 10,
                        height: 10,

                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF087524)
                              : const Color(0xFFD5E2D3),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 32),

                  // NEXT / GET STARTED
                  SizedBox(
                    width: double.infinity,
                    height: 54,

                    child: ElevatedButton(
                      onPressed: _nextPage,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF087524),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),

                      child: Text(
                        isLastSlide ? 'GET STARTED' : 'NEXT',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
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
