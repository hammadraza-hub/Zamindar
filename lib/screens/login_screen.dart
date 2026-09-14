import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'main_navigation_screen.dart';
import 'signup_screen.dart';

// ============================================================================
// LOGIN SCREEN — ASLI JWT LOGIN
//
// WordPress login username/email + password se hota hai.
// Success → MainNavigationScreen
// ============================================================================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _isLoggingIn = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 1. LOGIN — JWT
  // ==========================================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Keyboard band — race condition se bachav
    FocusScope.of(context).unfocus();

    setState(() => _isLoggingIn = true);

    try {
      await context.read<AuthProvider>().login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      // Success → main app
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoggingIn = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFFC62828),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // ==========================================================================
  // 2. GUEST / SIGNUP / FORGOT
  // ==========================================================================

  void _continueAsGuest() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  void _openSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  Future<void> _forgotPassword() async {
    final url = Uri.parse('https://zamindar.co/my-account/lost-password/');

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please reset your password at zamindar.co',
            style: GoogleFonts.plusJakartaSans(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF087524),
        ),
      );
    }
  }

  // ==========================================================================
  // 3. INPUT FIELD
  // ==========================================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3D3D3D),
          ),
        ),

        const SizedBox(height: 5),

        Container(
          height: 48,
          padding: const EdgeInsets.only(left: 4, right: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F0F0),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextFormField(
            controller: controller,
            obscureText: obscure,
            validator: validator,
            decoration: InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              prefixIcon: Icon(icon, size: 19, color: const Color(0xFF16762B)),
              prefixIconConstraints: const BoxConstraints(minWidth: 40),
              hintText: hint,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFFCACACA),
              ),
              suffixIcon: suffix,
            ),
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // 4. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Form(
              key: _formKey,
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ---- Email / Username ----
                        _buildField(
                          controller: _emailController,
                          label: 'Email or Username',
                          hint: 'you@example.com',
                          icon: Icons.email_outlined,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email or username';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        // ---- Password ----
                        _buildField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: '••••••••',
                          icon: Icons.lock_outline,
                          obscure: _obscurePassword,
                          suffix: IconButton(
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 7),

                        // ---- Forgot password ----
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: _forgotPassword,
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF087524),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ---- LOGIN (M0 wala CustomButton — loading built-in!) ----
                        CustomButton(
                          text: 'LOGIN',
                          isLoading: _isLoggingIn,
                          onPressed: _login,
                          backgroundColor: const Color(0xFFFF7900),
                          textColor: const Color(0xFF202020),
                          height: 48,
                        ),

                        const SizedBox(height: 14),

                        // ---- OR divider ----
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(color: Color(0xFFD7DDD5)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
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

                        // ---- Guest ----
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: OutlinedButton(
                            onPressed: _continueAsGuest,
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

                  // ---- Sign Up ----
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
                      GestureDetector(
                        onTap: _openSignup,
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF087524),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
