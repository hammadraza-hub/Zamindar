import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';
import 'main_navigation_screen.dart';

// ============================================================================
// SIGNUP SCREEN — ASLI WordPress signup
//
// Account WordPress par banta hai (WooCommerce customer) →
// phir turant LOGIN ho jata hai → main app!
// ============================================================================

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  bool _isSigningUp = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 1. SNACKBAR
  // ==========================================================================

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: isError
            ? const Color(0xFFC62828)
            : const Color(0xFF087524),
      ),
    );
  }

  // ==========================================================================
  // 2. SIGNUP — account banao + auto-login
  // ==========================================================================

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      _showMessage('Please accept Terms & Conditions', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _isSigningUp = true);

    try {
      // ---- Naam ko first/last mein todein ----
      final nameParts = _nameController.text.trim().split(RegExp(r'\s+'));
      final String firstName = nameParts.first;
      final String lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // ---- Signup + auto-login (AuthProvider mein) ----
      await context.read<AuthProvider>().signup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: firstName,
        lastName: lastName,
        phone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      // ---- Success → main app ----
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSigningUp = false);
      _showMessage(e.toString(), isError: true);
    }
  }

  // ==========================================================================
  // 3. FIELD BUILDERS (design same — controllers + validation add)
  // ==========================================================================

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

  Widget _normalField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
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
          errorStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: const Color(0xFFC62828),
          ),
        ),
      ),
    );
  }

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
            child: TextFormField(
              controller: _phoneController,
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
                errorStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  color: const Color(0xFFC62828),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your phone number';
                }
                if (value.trim().length < 10) {
                  return 'Enter a valid phone number';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onEyeTap,
    String? Function(String?)? validator,
  }) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
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

          errorStyle: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: const Color(0xFFC62828),
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

  // ==========================================================================
  // 4. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Back Button
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  icon: const Icon(
                    Icons.arrow_back,
                    size: 22,
                    color: Color(0xFF1B1C1C),
                  ),
                ),

                const SizedBox(height: 5),

                // Logo (design same)
                Center(
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
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

                // ---- Full Name ----
                _label('Full Name'),
                const SizedBox(height: 6),
                _normalField(
                  controller: _nameController,
                  hint: 'Enter your full name',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 13),

                // ---- Phone ----
                _label('Phone Number'),
                const SizedBox(height: 6),
                _phoneField(),

                const SizedBox(height: 13),

                // ---- Email (AB REQUIRED — WordPress ko chahiye) ----
                _label('Email'),
                const SizedBox(height: 6),
                _normalField(
                  controller: _emailController,
                  hint: 'example@mail.com',
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required (for login)';
                    }
                    if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.[\w\.]+$')
                        .hasMatch(value.trim())) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 13),

                // ---- Password ----
                _label('Password'),
                const SizedBox(height: 6),
                _passwordField(
                  controller: _passwordController,
                  hint: 'Min. 8 characters',
                  obscure: _obscurePassword,
                  onEyeTap: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 13),

                // ---- Confirm Password ----
                _label('Confirm Password'),
                const SizedBox(height: 6),
                _passwordField(
                  controller: _confirmController,
                  hint: 'Repeat your password',
                  obscure: _obscureConfirmPassword,
                  onEyeTap: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // ---- Terms & Conditions ----
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
                      child: Text(
                        'I agree to the Terms & Conditions and Privacy Policy',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          color: const Color(0xFF555555),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // ---- Create Account (CustomButton — loading built-in) ----
                CustomButton(
                  text: 'Create Account',
                  isLoading: _isSigningUp,
                  onPressed: _signup,
                  backgroundColor: const Color(0xFFFF7900),
                  textColor: const Color(0xFF202020),
                  height: 48,
                ),

                const SizedBox(height: 27),

                // ---- Login Link ----
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Login',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF087524),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
