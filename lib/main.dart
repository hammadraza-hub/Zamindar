import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'services/cart_provider.dart';

// Screens
import 'screens/main_navigation_screen.dart';

// import 'screens/order_success_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      // ==================================================
      // SHARED CART STATE
      // ==================================================
      create: (_) => CartProvider(),

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // ==================================================
      // APP THEME
      // ==================================================
      theme: ThemeData(textTheme: GoogleFonts.plusJakartaSansTextTheme()),

      // ==================================================
      // TEMPORARY: ORDER SUCCESS SCREEN PREVIEW
      //
      // Test data ke saath direct success screen khulti hai.
      //
      // ⚠️ YE SIRF PREVIEW KE LIYE HAI!
      // Design check karne ke baad neeche wali
      // MainNavigationScreen line par wapas aana hai.
      // ==================================================
      // home: OrderSuccessScreen(
      //   items: [
      //     CartItem(
      //       id: 'test-1',
      //       name: 'Confidor 200 SL',
      //       price: 1850,
      //       image: 'assets/images/whats_new3img.png',
      //       quantity: 2,
      //     ),
      //     CartItem(
      //       id: 'test-2',
      //       name: 'Belt 480 SC',
      //       price: 1240,
      //       image: 'assets/images/whats_new4img.png',
      //       quantity: 1,
      //     ),
      //     CartItem(
      //       id: 'test-3',
      //       name: 'Movento 240 SC',
      //       price: 980,
      //       image: 'assets/images/whats_new5img.png',
      //       quantity: 1,
      //     ),
      //   ],

      //   // 1850×2 + 1240 + 980 = 5920
      //   totalAmount: 5920,
      // ),

      // ==================================================
      // NORMAL APP START
      //
      // Preview ke baad:
      //   1. Upar wali poori home: OrderSuccessScreen(...) DELETE karo
      //   2. Neeche wali line UNCOMMENT karo
      // ==================================================
      home: const MainNavigationScreen(),
    );
  }
}
