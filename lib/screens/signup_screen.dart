import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Back Button
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
                icon: const Icon(
                  Icons.arrow_back,
                  size: 22,
                  color: Color(0xFF1B1C1C),
                ),
              ),

              const SizedBox(height: 5),

              // Logo
              Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      // Main circular logo
                      Container(
                        width: 88,
                        height: 88,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/zamindar_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Green leaf badge
                      Positioned(
                        right: 0,
                        bottom: 3,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            color: const Color(0xFF218C3A),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFFFCF9F9),
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.eco_outlined,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Heading
              Center(
                child: Text(
                  'Create Account',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1B1C1C),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Subtitle
              Center(
                child: Text(
                  'Join Zamindar for genuine agri\nproducts delivered to your farm.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: const Color(0xFF616161),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Full Name
              _label('Full Name'),

              const SizedBox(height: 6),

              _normalField(
                hint: 'Enter your full name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 13),

              // Phone
              _label('Phone Number'),

              const SizedBox(height: 6),

              _phoneField(),

              const SizedBox(height: 13),

              // Email
              _label('Email (optional)'),

              const SizedBox(height: 6),

              _normalField(
                hint: 'example@mail.com',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 13),

              // Password
              _label('Password'),

              const SizedBox(height: 6),

              _passwordField(
                hint: 'Min. 8 characters',
                obscure: _obscurePassword,
                onEyeTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),

              const SizedBox(height: 13),

              // Confirm Password
              _label('Confirm Password'),

              const SizedBox(height: 6),

              _passwordField(
                hint: 'Repeat your password',
                obscure: _obscureConfirmPassword,
                onEyeTap: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),

              const SizedBox(height: 14),

              // Terms & Conditions
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _termsAccepted,
                      activeColor: const Color(0xFF087524),
                      side: const BorderSide(color: Color(0xFFA8BCA8)),
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value ?? false;
                        });
                      },
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFF555555),
                        ),
                        children: [
                          const TextSpan(text: 'I agree to the '),
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF087524),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Privacy Policy',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: const Color(0xFF087524),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // Create Account Button
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Create Account',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 17),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 27),

              // Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF666666),
                    ),
                  ),
                  Text(
                    'Login',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF087524),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // Label
  Widget _label(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF3D3D3D),
      ),
    );
  }

  // Normal Input Field
  Widget _normalField({
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextField(
        keyboardType: keyboardType,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: const Color(0xFF333333),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          prefixIcon: Icon(icon, size: 17, color: const Color(0xFF758675)),
          hintText: hint,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: const Color(0xFFBCC7BC),
          ),
        ),
      ),
    );
  }

  // Phone Field
  Widget _phoneField() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.phone_android_outlined,
            size: 17,
            color: Color(0xFF758675),
          ),

          const SizedBox(width: 8),

          Text(
            '+92',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF333333),
            ),
          ),

          const SizedBox(width: 9),

          Container(width: 1, height: 20, color: const Color(0xFFD7D7D7)),

          const SizedBox(width: 9),

          Expanded(
            child: TextField(
              keyboardType: TextInputType.phone,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF333333),
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: '300 1234567',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFFBCC7BC),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Password Field
  Widget _passwordField({
    required String hint,
    required bool obscure,
    required VoidCallback onEyeTap,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextField(
        obscureText: obscure,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: const Color(0xFF333333),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,

          prefixIcon: const Icon(
            Icons.lock_outline,
            size: 17,
            color: Color(0xFF758675),
          ),

          hintText: hint,

          hintStyle: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: const Color(0xFFBCC7BC),
          ),

          suffixIcon: IconButton(
            onPressed: onEyeTap,
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              size: 18,
              color: const Color(0xFF71816F),
            ),
          ),
        ),
      ),
    );
  }
}
