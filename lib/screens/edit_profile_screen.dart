import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ============================================================================
// EDIT PROFILE SCREEN
//
// User apna naam aur phone number change karta hai:
//   - Fields current values se pre-filled hoti hain
//   - DP (initials) typing ke saath LIVE update hota hai
//   - SAVE → nayi values AccountScreen ko mil jaati hain
//     (Navigator.pop ke result ke saath)
//   - BACK → koi change nahi hota
// ============================================================================

class EditProfileScreen extends StatefulWidget {
  /// Account screen ki current name
  final String currentName;

  /// Account screen ka current phone
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
  // 1. CONTROLLERS (current values se pre-filled)
  // ==========================================================================

  late final TextEditingController _nameController = TextEditingController(
    text: widget.currentName,
  );

  late final TextEditingController _phoneController = TextEditingController(
    text: widget.currentPhone,
  );

  /// Form validation ke liye
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();

    super.dispose();
  }

  // ==========================================================================
  // 2. HELPER — "Ahmed Raza" → "AR"
  // ==========================================================================

  String _initialsFrom(String name) {
    final parts = name.trim().split(' ');

    String initials = '';

    for (final p in parts) {
      if (p.isNotEmpty) initials += p[0];
    }

    return initials.toUpperCase();
  }

  // ==========================================================================
  // 3. SAVE
  //
  // Validate → nayi values result ke tor par wapas bhejo
  // ==========================================================================

  void _save() {
    // Validation fail → error messages dikhao
    if (!_formKey.currentState!.validate()) return;

    final String newName = _nameController.text.trim();
    final String newPhone = _phoneController.text.trim();

    // Ye result AccountScreen receive karega
    Navigator.pop(context, {'name': newName, 'phone': newPhone});
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
  //
  // Structure: [Header] → [Live DP Preview] → [Name Field] →
  //             [Phone Field] → [SAVE BUTTON]
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),

          // Form — validation handle karta hai
          child: Form(
            key: _formKey,

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ==============================================================
                // HEADER — Back + Title
                // ==============================================================
                Row(
                  children: [
                    // Back = cancel (koi change nahi hoga)
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

                // ==============================================================
                // LIVE DP PREVIEW
                //
                // ValueListenableBuilder: naam type karne par
                // initials foran badal jate hain
                // ==============================================================
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
                    'Edit your profile',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF999999),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ==============================================================
                // FULL NAME FIELD
                // ==============================================================
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

                // ==============================================================
                // PHONE NUMBER FIELD
                // ==============================================================
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

                // ==============================================================
                // SAVE BUTTON
                // ==============================================================
                SizedBox(
                  width: double.infinity,
                  height: 52,

                  child: ElevatedButton(
                    onPressed: _save,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF087524),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: Text(
                      'SAVE CHANGES',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
