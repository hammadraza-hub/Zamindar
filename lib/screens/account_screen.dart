import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile_screen.dart';

// ============================================================================
// ACCOUNT SCREEN (MY ACCOUNT)
//
// Structure:
//   [Header] → [Profile Card: Avatar + Name + Phone + Edit + Stats]
//   → [Menu Items] → [Logout] → [Version + Tagline]
//
// PROFILE PHOTO:
//   - Avatar par camera badge → Gallery/Camera se photo
//   - Photo LAGI hai    → photo dikhti hai
//   - Photo NAHI lagayi → name ke initials (fallback)
//   - Photo permanently save (documents folder + SharedPreferences)
//     — app restart ke baad bhi rehti hai
// ============================================================================

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // ==========================================================================
  // 1. USER DATA
  // ==========================================================================

  String _userName = 'Ahmed Raza';
  String _userPhone = '+92 300 1234567';

  final String _ordersCount = '12';
  final String _userRating = '4.8';
  final String _memberSince = '2 yrs';

  /// User ki profile photo
  /// null  → photo nahi lagayi (initials dikhenge)
  /// value → File (user ki photo)
  File? _profileImage;

  /// App start par saved photo load karo
  @override
  void initState() {
    super.initState();

    _loadProfileImage();
  }

  /// "Ahmed Raza" → "AR" (avatar initials)
  String _userInitials() {
    final parts = _userName.trim().split(' ');

    String initials = '';

    for (final p in parts) {
      if (p.isNotEmpty) initials += p[0];
    }

    return initials.toUpperCase();
  }

  // ==========================================================================
  // 2. SNACKBAR MESSAGE
  // ==========================================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFF087524),
      ),
    );
  }

  // ==========================================================================
  // 3. PROFILE PHOTO — Load / Pick / Remove
  // ==========================================================================

  /// LOAD — app start par saved photo ka path dhoondo
  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? path = prefs.getString('profile_image');

      // Path save hai AUR file sach mein exist karti hai
      if (path != null && File(path).existsSync()) {
        if (mounted) {
          setState(() {
            _profileImage = File(path);
          });
        }
      }
    } catch (_) {
      // Load fail → initials use honge (koi error nahi)
    }
  }

  /// PICK — Gallery/Camera se photo lo + permanently save karo
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();

      final XFile? picked = await picker.pickImage(
        source: source,

        // Photo chhoti rakho (performance ke liye)
        maxWidth: 600,
        imageQuality: 85,
      );

      // User ne cancel kiya → kuch nahi karna
      if (picked == null) return;

      // ---- (1) Temp file ko app ke documents folder mein COPY ----
      // (Temp file OS khud delete kar sakta hai — isliye
      //  permanent jagah copy karte hain)
      final appDir = await getApplicationDocumentsDirectory();

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final File saved = await File(picked.path)
          .copy('${appDir.path}/$fileName');

      // ---- (2) Path save karo (restart ke baad bhi yaad rahe) ----
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', saved.path);

      // ---- (3) UI update ----
      if (mounted) {
        setState(() {
          _profileImage = saved;
        });

        _showMessage('Profile photo updated');
      }
    } catch (_) {
      _showMessage('Image select nahi ho saki');
    }
  }

  /// REMOVE — photo hatao, wapas initials
  Future<void> _removeImage() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('profile_image');

    if (mounted) {
      setState(() {
        _profileImage = null;
      });

      _showMessage('Photo removed');
    }
  }

  /// OPTIONS SHEET — Gallery / Camera / Remove
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),

              // Drag handle
              Center(
                child: Container(
                  width: 45,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                'Profile Photo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

              // ---- Gallery ----
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF087524),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.plusJakartaSans(fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.gallery);
                },
              ),

              // ---- Camera ----
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF087524),
                ),
                title: Text(
                  'Take Photo',
                  style: GoogleFonts.plusJakartaSans(fontSize: 15),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _pickImage(ImageSource.camera);
                },
              ),

              // ---- Remove (sirf jab photo lagi ho) ----
              if (_profileImage != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFC62828),
                  ),
                  title: Text(
                    'Remove Photo',
                    style: GoogleFonts.plusJakartaSans(fontSize: 15),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _removeImage();
                  },
                ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // 4. EDIT PROFILE (name/phone) — text wala edit
  // ==========================================================================

  Future<void> _editProfile() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditProfileScreen(currentName: _userName, currentPhone: _userPhone),
      ),
    );

    if (result != null) {
      setState(() {
        _userName = result['name'] as String;
        _userPhone = result['phone'] as String;
      });

      _showMessage('Profile updated');
    }
  }

  // ==========================================================================
  // 5. AVATAR WIDGET
  //
  // Photo lagi hai   → photo (ClipOval)
  // Photo nahi lagayi → name ke initials (fallback)
  // Camera badge      → tap = options sheet
  // ==========================================================================

  Widget _buildAvatar() {
    return InkWell(
      // Poora avatar tappable — photo lagane ke options
      onTap: _showImageOptions,
      borderRadius: BorderRadius.circular(50),

      child: Stack(
        children: [
          // ---- Main circle: photo ya initials ----
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,

            decoration: const BoxDecoration(
              color: Color(0xFF087524),
              shape: BoxShape.circle,
            ),

            child: _profileImage != null
                ? ClipOval(
                    child: Image.file(
                      _profileImage!,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  )
                : Text(
                    _userInitials(),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),

          // ---- Camera badge (bottom-right corner) ----
          Positioned(
            bottom: 0,
            right: 0,

            child: Container(
              width: 24,
              height: 24,

              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Color(0xFFDCE8DA)),
                ),
              ),

              child: const Icon(
                Icons.camera_alt,
                size: 13,
                color: Color(0xFF087524),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 6. STATS ITEM (Orders / Rating / Member)
  // ==========================================================================

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 22, color: const Color(0xFF087524)),

          const SizedBox(height: 6),

          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1B1C1C),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 7. MENU ITEM
  // ==========================================================================

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),

      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 10),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(0xFF087524)),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF303030),
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: Color(0xFFAAAAAA),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // 8. MAIN UI
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F7),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // ================================================================
              // HEADER — Back + Title (tab mode mein back nahi)
              // ================================================================
              Row(
                children: [
                  if (Navigator.canPop(context))
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
                    'My Account',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1B1C1C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ================================================================
              // PROFILE CARD
              // ================================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),

                child: Column(
                  children: [
                    // ---- Avatar (photo/initials) + Name + Edit ----
                    Row(
                      children: [
                        // AVATAR — tap karke photo lagao
                        _buildAvatar(),

                        const SizedBox(width: 16),

                        // Name + Phone
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _userName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1B1C1C),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                _userPhone,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: const Color(0xFF777777),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // EDIT (pencil) — name/phone wala edit
                        InkWell(
                          onTap: _editProfile,
                          borderRadius: BorderRadius.circular(50),

                          child: Container(
                            width: 38,
                            height: 38,

                            decoration: const BoxDecoration(
                              color: Color(0xFFDCE8DA),
                              shape: BoxShape.circle,
                            ),

                            child: const Icon(
                              Icons.edit,
                              size: 18,
                              color: Color(0xFF087524),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const Divider(height: 1, color: Color(0xFFF0EEEE)),

                    const SizedBox(height: 16),

                    // ---- Stats Row ----
                    Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.shopping_bag_outlined,
                          value: _ordersCount,
                          label: 'Orders',
                        ),

                        _buildStatItem(
                          icon: Icons.star_rounded,
                          value: _userRating,
                          label: 'Rating',
                        ),

                        _buildStatItem(
                          icon: Icons.verified_outlined,
                          value: _memberSince,
                          label: 'Member',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================================================================
              // MENU ITEMS
              // ================================================================
              _buildMenuItem(
                icon: Icons.receipt_long_outlined,
                title: 'My Orders',
                onTap: () {
                  _showMessage('My Orders — coming soon');
                },
              ),

              _buildMenuItem(
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                onTap: () {
                  _showMessage('Saved Addresses — coming soon');
                },
              ),

              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Edit Profile',
                onTap: _editProfile,
              ),

              _buildMenuItem(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                onTap: () {
                  _showMessage('Notifications — coming soon');
                },
              ),

              _buildMenuItem(
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                onTap: () {
                  _showMessage('Payment Methods — coming soon');
                },
              ),

              _buildMenuItem(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () {
                  _showMessage('Help & Support — coming soon');
                },
              ),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  _showMessage('Settings — coming soon');
                },
              ),

              const SizedBox(height: 16),

              // ================================================================
              // LOGOUT BUTTON
              // ================================================================
              SizedBox(
                width: double.infinity,
                height: 52,

                child: OutlinedButton(
                  onPressed: () {
                    _showMessage('Logout clicked');
                  },

                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(color: Color(0xFFC62828)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.logout, size: 20),

                      const SizedBox(width: 10),

                      Text(
                        'Logout',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ================================================================
              // APP VERSION + TAGLINE
              // ================================================================
              Center(
                child: Text(
                  'App Version 2.4.0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF999999),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Center(
                child: Text(
                  'Growing the future, one order at a time',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: const Color(0xFF777777),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
