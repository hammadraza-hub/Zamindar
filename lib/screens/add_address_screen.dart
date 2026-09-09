import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  // ============================================================
  // 1. FORM KEY
  // ============================================================

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // 2. SCREEN STATE
  // ============================================================

  String selectedCountry = 'Pakistan';
  bool isDefaultAddress = false;

  // ============================================================
  // 3. TEXT FIELD CONTROLLERS
  // ============================================================

  final TextEditingController firstNameController = TextEditingController();

  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController streetController = TextEditingController();

  final TextEditingController townController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final TextEditingController zipController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  // ============================================================
  // 4. COUNTRY + PHONE CONFIGURATION
  // ============================================================

  final Map<String, Map<String, dynamic>> countryPhoneData = {
    'Pakistan': {'code': '+92', 'hint': '300 1234567', 'maxLength': 10},
    'India': {'code': '+91', 'hint': '98765 43210', 'maxLength': 10},
    'UAE': {'code': '+971', 'hint': '50 123 4567', 'maxLength': 9},
    'Saudi Arabia': {'code': '+966', 'hint': '50 123 4567', 'maxLength': 9},
  };

  // ============================================================
  // 5. DISPOSE CONTROLLERS
  // ============================================================

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    streetController.dispose();
    townController.dispose();
    cityController.dispose();
    zipController.dispose();
    phoneController.dispose();
    emailController.dispose();

    super.dispose();
  }

  // ============================================================
  // 6. LABEL WIDGET
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF444444),
      ),
    );
  }

  // ============================================================
  // 7. COMMON TEXT FIELD
  //
  // Used by:
  // - First Name
  // - Last Name
  // - Street Address
  // - Town
  // - City
  // - Zip Code
  // - Email
  // ============================================================

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    IconData? icon,
    TextInputType? keyboardType,
    bool requiredField = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,

      style: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        color: const Color(0xFF333333),
      ),

      // ----------------------------------------------------------
      // VALIDATION
      // ----------------------------------------------------------
      validator:
          validator ??
          (value) {
            if (requiredField && (value == null || value.trim().isEmpty)) {
              return 'Required';
            }

            return null;
          },

      // ----------------------------------------------------------
      // INPUT DESIGN
      // ----------------------------------------------------------
      decoration: InputDecoration(
        hintText: hint,

        hintStyle: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          color: const Color(0xFFAAB1B5),
        ),

        filled: true,
        fillColor: Colors.white,

        // Optional left icon
        prefixIcon: icon != null
            ? Icon(icon, size: 19, color: const Color(0xFF168333))
            : null,

        prefixIconConstraints: icon != null
            ? const BoxConstraints(minWidth: 40)
            : null,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 15,
        ),

        // Normal border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),

        // When field is selected
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Color(0xFF087524), width: 1),
        ),

        // Invalid / empty field
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),

        // Invalid field while focused
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
        ),

        errorStyle: GoogleFonts.plusJakartaSans(fontSize: 9, color: Colors.red),
      ),
    );
  }

  // ============================================================
  // 8. SNACKBAR MESSAGE
  // ============================================================

  void _showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        backgroundColor: error ? Colors.red.shade700 : const Color(0xFF087524),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================================
  // 9. SAVE ADDRESS FUNCTION
  // ============================================================

  void _saveAddress() {
    // Close keyboard before validation
    FocusScope.of(context).unfocus();

    // Validate all TextFormFields
    final bool formIsValid = _formKey.currentState?.validate() ?? false;

    // ----------------------------------------------------------
    // CHECK NORMAL FORM FIELDS
    // ----------------------------------------------------------

    if (!formIsValid) {
      _showMessage('Please check the highlighted fields', error: true);
      return;
    }

    // ----------------------------------------------------------
    // CHECK PHONE NUMBER
    // ----------------------------------------------------------

    final int requiredPhoneLength =
        countryPhoneData[selectedCountry]!['maxLength'] as int;

    if (phoneController.text.trim().length != requiredPhoneLength) {
      setState(() {
        // Rebuild so phone validation updates.
      });

      _showMessage('Please enter a valid phone number', error: true);

      return;
    }

    // ----------------------------------------------------------
    // BUILD FINAL PHONE NUMBER
    // ----------------------------------------------------------

    final String countryCode = countryPhoneData[selectedCountry]!['code'];

    final String fullPhoneNumber = '$countryCode${phoneController.text.trim()}';

    // ----------------------------------------------------------
    // CREATE ADDRESS OBJECT
    //
    // Later this object can be sent to API / Firebase / backend.
    // ----------------------------------------------------------

    final Map<String, dynamic> addressData = {
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'streetAddress': streetController.text.trim(),
      'town': townController.text.trim(),
      'city': cityController.text.trim(),
      'zipCode': zipController.text.trim(),
      'country': selectedCountry,
      'phoneNumber': fullPhoneNumber,
      'email': emailController.text.trim(),
      'isDefault': isDefaultAddress,
    };

    debugPrint('ADDRESS DATA: $addressData');

    // ----------------------------------------------------------
    // SUCCESS MESSAGE
    // ----------------------------------------------------------

    _showMessage('Address saved successfully');
  }

  // ============================================================
  // 10. MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // Current country's phone configuration
    final Map<String, dynamic> currentPhoneData =
        countryPhoneData[selectedCountry]!;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // ==================================================
                // 11. HEADER
                // ==================================================
                Row(
                  children: [
                    // Back Button
                    InkWell(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.arrow_back,
                          size: 22,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Screen Title
                    Text(
                      'Add New Address',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ==================================================
                // 12. PROGRESS INDICATOR
                // ==================================================
                Row(
                  children: [
                    // Active Step
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFF087524),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Step 2
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E0DE),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Step 3
                    Expanded(
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E0DE),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ==================================================
                // 13. FIRST NAME + LAST NAME
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- FIRST NAME ----------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('First Name'),

                          const SizedBox(height: 7),

                          _buildTextField(
                            hint: 'e.g. Ahmed',
                            controller: firstNameController,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ---------------- LAST NAME ----------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Last Name'),

                          const SizedBox(height: 7),

                          _buildTextField(
                            hint: 'e.g. Khan',
                            controller: lastNameController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // 14. STREET ADDRESS
                // ==================================================
                _buildLabel('Street Address'),

                const SizedBox(height: 7),

                _buildTextField(
                  hint: 'House no, Street name, Area',
                  controller: streetController,
                  icon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 18),

                // ==================================================
                // 15. TOWN + CITY
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- TOWN ----------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Town'),

                          const SizedBox(height: 7),

                          _buildTextField(
                            hint: 'e.g. Model Town',
                            controller: townController,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ---------------- CITY ----------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('City'),

                          const SizedBox(height: 7),

                          _buildTextField(
                            hint: 'e.g. Lahore',
                            controller: cityController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // 16. ZIP CODE + COUNTRY
                // ==================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------------- ZIP CODE ----------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Zip Code'),

                          const SizedBox(height: 7),

                          _buildTextField(
                            hint: '54000',
                            controller: zipController,
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 16),

                    // ---------------- COUNTRY ----------------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Country'),

                          const SizedBox(height: 7),

                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(7),
                            ),

                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedCountry,
                                isExpanded: true,

                                icon: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 20,
                                  color: Color(0xFF444444),
                                ),

                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: const Color(0xFF333333),
                                ),

                                items: countryPhoneData.keys
                                    .map(
                                      (country) => DropdownMenuItem<String>(
                                        value: country,
                                        child: Text(country),
                                      ),
                                    )
                                    .toList(),

                                onChanged: (value) {
                                  if (value == null) return;

                                  setState(() {
                                    selectedCountry = value;

                                    // Don't keep another country's
                                    // phone number.
                                    phoneController.clear();
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // 17. PHONE NUMBER
                // ==================================================
                _buildLabel('Phone Number'),

                const SizedBox(height: 7),

                // Phone uses TextFormField so it also receives
                // the red validation border.
                TextFormField(
                  controller: phoneController,

                  keyboardType: TextInputType.phone,

                  // Allow digits only and limit according to country.
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(
                      currentPhoneData['maxLength'] as int,
                    ),
                  ],

                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFF333333),
                  ),

                  // ------------------------------------------------
                  // PHONE VALIDATION
                  // ------------------------------------------------
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }

                    final int requiredLength =
                        currentPhoneData['maxLength'] as int;

                    if (value.trim().length != requiredLength) {
                      return 'Enter $requiredLength digits';
                    }

                    return null;
                  },

                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,

                    // ----------------------------------------------
                    // PHONE ICON
                    // ----------------------------------------------
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.phone_outlined,
                            size: 18,
                            color: Color(0xFF168333),
                          ),

                          const SizedBox(width: 8),

                          // Dynamic calling code
                          Text(
                            currentPhoneData['code'],
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: const Color(0xFF333333),
                            ),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            width: 1,
                            height: 22,
                            color: const Color(0xFFD7D7D7),
                          ),
                        ],
                      ),
                    ),

                    hintText: currentPhoneData['hint'],

                    hintStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFFAAB1B5),
                    ),

                    contentPadding: const EdgeInsets.symmetric(vertical: 15),

                    // Normal
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: BorderSide.none,
                    ),

                    // Focus
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(color: Color(0xFF087524)),
                    ),

                    // Error
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.2,
                      ),
                    ),

                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(7),
                      borderSide: const BorderSide(
                        color: Colors.red,
                        width: 1.4,
                      ),
                    ),

                    errorStyle: GoogleFonts.plusJakartaSans(
                      fontSize: 9,
                      color: Colors.red,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // 18. EMAIL ADDRESS
                // ==================================================
                _buildLabel('Email Address'),

                const SizedBox(height: 7),

                _buildTextField(
                  hint: 'zamindar@example.com',
                  controller: emailController,
                  icon: Icons.mail_outline,
                  keyboardType: TextInputType.emailAddress,

                  // Email is optional.
                  requiredField: false,

                  // But if entered, it must be valid.
                  validator: (value) {
                    final String email = value?.trim() ?? '';

                    if (email.isEmpty) {
                      return null;
                    }

                    final bool validEmail = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                    ).hasMatch(email);

                    if (!validEmail) {
                      return 'Enter a valid email';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 22),

                // ==================================================
                // 19. SET AS DEFAULT ADDRESS
                // ==================================================
                InkWell(
                  onTap: () {
                    setState(() {
                      isDefaultAddress = !isDefaultAddress;
                    });
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: isDefaultAddress,
                          activeColor: const Color(0xFF087524),

                          side: const BorderSide(color: Color(0xFFAABBA8)),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),

                          onChanged: (value) {
                            setState(() {
                              isDefaultAddress = value ?? false;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Text(
                        'Set as default address',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: const Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // ==================================================
                // 20. INFORMATION BOX
                // ==================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE7F1E5),
                    borderRadius: BorderRadius.circular(8),
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 18,
                        color: Color(0xFF087524),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          'Providing an accurate address ensures our '
                          'delivery partners find your farm efficiently.',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            height: 1.5,
                            color: const Color(0xFF5E655E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 36),

                // ==================================================
                // 21. SAVE ADDRESS BUTTON
                // ==================================================
                SizedBox(
                  width: double.infinity,
                  height: 54,

                  child: ElevatedButton(
                    onPressed: _saveAddress,

                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFFF7900),
                      foregroundColor: const Color(0xFF332515),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.save_outlined, size: 18),

                        const SizedBox(width: 8),

                        Text(
                          'SAVE ADDRESS',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
