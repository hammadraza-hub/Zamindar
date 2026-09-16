import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/custom_button.dart';

// ============================================================================
// EDIT PROFILE SCREEN — WEBSITE SYNC!
//
// SAVE dabane par:
//   1. WordPress par naam update (API call)
//   2. AuthProvider update (app mein turant naya naam)
//   3. Phone local display ke liye wapas
//
// Fail ho to kuch nahi badalta (data mismatch se bachav!)
// ============================================================================

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentPhone;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentPhone,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ==========================================================================
  // 1. CONTROLLERS
  // ==========================================================================

  late final TextEditingController _nameController = TextEditingController(
    text: widget.currentName,
  );

  late final TextEditingController _phoneController = TextEditingController(
    text: widget.currentPhone,
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 2. HELPERS
  // ==========================================================================

  String _initialsFrom(String name) {
    final parts = name.trim().split(' ');

    String initials = '';

    for (final p in parts) {
      if (p.isNotEmpty && initials.length < 2) initials += p[0];
    }

    return initials.toUpperCase();
  }

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
  // 3. SAVE — WEBSITE + APP dono update!
  // ==========================================================================

  Future<void> _save() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) return;

    // Keyboard band
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);

    final String newName = _nameController.text.trim();
    final String newPhone = _phoneController.text.trim();

    try {
      // ---- (1) WEBSITE par naam update ----
      await context.read<AuthProvider>().updateDisplayName(newName);

      if (!mounted) return;

      // ---- (2) Phone local display ke liye (account screen ko) ----
      Navigator.pop(context, {'name': newName, 'phone': newPhone});
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSaving = false);
      _showMessage(e.toString(), isError: true);
    }
  }

  // ==========================================================================
  // 4. TEXT FIELD BUILDER
  // ==========================================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.plusJakartaSans(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF087524)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD5E2D3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD5E2D3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF087524)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC62828)),
        ),
      ),
    );
  }

  // ==========================================================================
  // 5. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ---- Header ----
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(30),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back,
                          size: 25,
                          color: Color(0xFF087524),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Text(
                      'Edit Profile',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1B1C1C),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ---- Live DP preview ----
                Center(
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _nameController,

                    builder: (context, value, _) {
                      return Container(
                        width: 90,
                        height: 90,
                        alignment: Alignment.center,

                        decoration: const BoxDecoration(
                          color: Color(0xFF087524),
                          shape: BoxShape.circle,
                        ),

                        child: Text(
                          value.text.trim().isEmpty
                              ? '?'
                              : _initialsFrom(value.text),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    'Changes will sync to your account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ---- Full Name ----
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Please enter a valid name (min 3 characters)';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ---- Phone ----
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter phone number';
                    }
                    if (value.trim().length < 10) {
                      return 'Phone number must be at least 10 digits';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // ---- SAVE (CustomButton — loading built-in!) ----
                CustomButton(
                  text: 'SAVE CHANGES',
                  isLoading: _isSaving,
                  onPressed: _save,
                  backgroundColor: const Color(0xFF087524),
                  height: 52,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
