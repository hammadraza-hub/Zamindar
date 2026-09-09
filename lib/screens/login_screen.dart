import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 25),

                // Logo
                Image.asset(
                  'assets/images/zamindar_logo.png',
                  width: 105,
                  height: 65,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 15),

                // Welcome Back
                Text(
                  'Welcome Back',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Login to continue shopping for your\nfarm',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF626262),
                  ),
                ),

                const SizedBox(height: 18),

                // Login form card
                Container(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label('Phone Number'),

                      const SizedBox(height: 5),

                      // Phone field
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F0F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.phone_outlined,
                              size: 18,
                              color: Color(0xFF16762B),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              '+92',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: const Color(0xFF333333),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Container(
                              width: 1,
                              height: 22,
                              color: const Color(0xFFD3D3D3),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: TextField(
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  isCollapsed: true,
                                  hintText: '300 1234567',
                                  hintStyle: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    color: const Color(0xFFCACACA),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      _label('Password'),

                      const SizedBox(height: 5),

                      // Password field
                      Container(
                        height: 48,
                        padding: const EdgeInsets.only(left: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F0F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            border: InputBorder.none,

                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              size: 19,
                              color: Color(0xFF16762B),
                            ),

                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 32,
                            ),

                            hintText: '••••••••',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFB8C9B8),
                              letterSpacing: 2,
                            ),

                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                size: 19,
                                color: const Color(0xFF71816F),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 7),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Forgot Password?',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF087524),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: const Color(0xFFFF7900),
                            foregroundColor: const Color(0xFF202020),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'LOGIN',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // OR divider
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(color: Color(0xFFD7DDD5)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              'OR',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: const Color(0xFF777777),
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(color: Color(0xFFD7DDD5)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Guest button
                      SizedBox(
                        width: double.infinity,
                        height: 45,
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF087524),
                            side: const BorderSide(
                              color: Color(0xFF168333),
                              width: 1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: Text(
                            'Continue as Guest',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Sign up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: const Color(0xFF666666),
                      ),
                    ),
                    Text(
                      'Sign Up',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF087524),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF3D3D3D),
      ),
    );
  }
}
