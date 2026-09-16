import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'orders_screen.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'policy_screen.dart';
import 'help_support_screen.dart';

// ============================================================================
// ACCOUNT SCREEN (MY ACCOUNT) — LOGIN AWARE
//
// Logged-in:  ASLI naam + email (website se) + LOGOUT
// Guest:      "Guest" + LOGIN button
//
// Profile photo wala system same hai (local storage) —
// bas naam/abhaar ab AuthProvider se aate hain.
// ============================================================================

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // ==========================================================================
  // 1. LOCAL DATA (sirf photo — naam/abhaar ab AuthProvider se)
  // ==========================================================================

  final String _ordersCount = '0';
  final String _userRating = '—';
  final String _memberSince = '—';

  /// User ki profile photo (local feature — same as before)
  File? _profileImage;

  @override
  void initState() {
    super.initState();

    _loadProfileImage();
  }

  /// "Ahmed Raza" → "AR" (avatar initials)
  String _userInitials(String name) {
    final parts = name.trim().split(' ');

    String initials = '';

    for (final p in parts) {
      if (p.isNotEmpty && initials.length < 2) initials += p[0];
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
  // 3. PROFILE PHOTO — Load / Pick / Remove (same as before)
  // ==========================================================================

  Future<void> _loadProfileImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final String? path = prefs.getString('profile_image');

      if (path != null && File(path).existsSync()) {
        if (mounted) {
          setState(() {
            _profileImage = File(path);
          });
        }
      }
    } catch (_) {
      // Load fail → initials use honge
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();

      final XFile? picked = await picker.pickImage(
        source: source,
        maxWidth: 600,
        imageQuality: 85,
      );

      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();

      final String fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final File saved = await File(picked.path)
          .copy('${appDir.path}/$fileName');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', saved.path);

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

              Text(
                'Profile Photo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 8),

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
  // 4. AUTH ACTIONS — Login / Edit / Logout
  // ==========================================================================

  void _openLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  /// EDIT PROFILE — sirf logged-in users ke liye.
  /// (Guest ke liye pehle login.)
  Future<void> _editProfile(String currentName, String currentPhone) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(
          currentName: currentName,
          currentPhone: currentPhone,
        ),
      ),
    );

    if (result != null) {
      // NOTE: Ye abhi local edit hai — website par naam update
      // kaam M8 (Account Sync) mein karenge.
      _showMessage('Profile updated (local)');
    }
  }

  /// LOGOUT — confirm dialog ke sath ASLI logout.
  Future<void> _confirmLogout() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Logout?',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
          ),
          content: Text(
            'You will need to login again to see your orders.',
            style: GoogleFonts.plusJakartaSans(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'Cancel',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF666666),
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'Logout',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFC62828),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();

      if (mounted) {
        _showMessage('Logged out');
      }
    }
  }

  // ==========================================================================
  // 5. AVATAR WIDGET (photo ya initials)
  // ==========================================================================

  Widget _buildAvatar(String name) {
    return InkWell(
      onTap: _showImageOptions,
      borderRadius: BorderRadius.circular(50),

      child: Stack(
        children: [
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
                    _userInitials(name),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          ),

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
  // 6. STATS ITEM
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
    // ---- AUTH STATE (poori app se shared) ----
    final auth = context.watch<AuthProvider>();

    final bool isLoggedIn = auth.isLoggedIn;
    final String displayName = isLoggedIn ? auth.userName : 'Guest';
    final String displayInfo = isLoggedIn
        ? auth.userEmail
        : 'Login to access your orders & profile';

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
              // HEADER
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
              // PROFILE CARD — ASLI DATA (ya Guest)
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
                    Row(
                      children: [
                        // AVATAR
                        _buildAvatar(displayName),

                        const SizedBox(width: 16),

                        // Name + Email/Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1B1C1C),
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                displayInfo,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: const Color(0xFF777777),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ---- Guest: LOGIN button | Logged-in: EDIT ----
                        isLoggedIn
                            ? InkWell(
                                onTap: () =>
                                    _editProfile(displayName, auth.userEmail),
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
                              )
                            : InkWell(
                                onTap: _openLogin,
                                borderRadius: BorderRadius.circular(50),

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),

                                  decoration: BoxDecoration(
                                    color: const Color(0xFF087524),
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: Text(
                                    'LOGIN',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OrdersScreen()),
                  );
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
                onTap: () => _editProfile(displayName, auth.userEmail),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const HelpSupportScreen(),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  _showMessage('Settings — coming soon');
                },
              ),

              _buildMenuItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy & Terms',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PolicyScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ================================================================
              // LOGIN / LOGOUT — state ke mutabiq
              // ================================================================
              SizedBox(
                width: double.infinity,
                height: 52,

                child: isLoggedIn
                    ? OutlinedButton(
                        onPressed: _confirmLogout,

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
                      )
                    : ElevatedButton(
                        onPressed: _openLogin,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF087524),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login, size: 20),

                            const SizedBox(width: 10),

                            Text(
                              'Login to Your Account',
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

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PolicyScreen()),
                  );
                },
                child: Text(
                  'Privacy Policy  •  Terms & Conditions',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: const Color(0xFF087524),
                  ),
                ),
              ),

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
