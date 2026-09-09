import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/app_colors.dart';

// import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // Dots animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Splash ke baad next screen
    // Future.delayed(const Duration(seconds: 3), () {
    //   if (!mounted) return;

    //   Navigator.pushReplacement(
    //     context,
    //     MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    //   );
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryGreen,
              AppColors.lightGreen,
              AppColors.cream,
            ],
            stops: [0.0, 0.48, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo
              Container(
                width: 168,
                height: 108,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(55),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Image.asset(
                    'assets/images/zamindar_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              Text(
                'Zamindar',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                  color: AppColors.titleColor,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Trusted Solutions for Modern\nAgriculture',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  height: 1.55,
                  color: AppColors.subtitleColor,
                ),
              ),

              const Spacer(flex: 2),

              // Animated loading dots
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  int activeDot = (_controller.value * 3).floor() % 3;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final bool isActive = index == activeDot;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 10 : 7,
                        height: isActive ? 10 : 7,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.dotColor
                              : AppColors.dotColor.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  );
                },
              ),

              const SizedBox(height: 18),

              Text(
                'CULTIVATING EXCELLENCE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                  color: const Color(0xFF4E9A58),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
