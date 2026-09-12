import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/cart_provider.dart';

Future<void> main() async {
  // SharedPreferences async hai — ye zaroori hai
  WidgetsFlutterBinding.ensureInitialized();

  // Kya onboarding pehle ho chuki hai?
  final prefs = await SharedPreferences.getInstance();
  final bool onboardingDone = prefs.getBool('onboarding_done') ?? false;

  // Cart provider banao + purani saved cart load karo
  final cartProvider = CartProvider();
  await cartProvider.ensureLoaded();
  // TEMPORARY: hamesha onboarding dikhti hai (review ke liye)
  // final bool onboardingDone = false;

  runApp(
    ChangeNotifierProvider(
      // Shared cart (pehle se loaded — purani cart ke saath)
      create: (_) => cartProvider,
      // showOnboarding YAHAN pass ho raha hai! ⬇️
      child: MyApp(showOnboarding: !onboardingDone),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // App theme
      theme: ThemeData(textTheme: GoogleFonts.plusJakartaSansTextTheme()),

      // Pehli baar → Onboarding | Dobara → Main App
      home: showOnboarding
          ? const OnboardingScreen()
          : const MainNavigationScreen(),
    );
  }
}
