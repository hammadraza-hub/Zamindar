import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'orders_screen.dart';
import '../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import 'policy_screen.dart';
import 'settings_screen.dart';
import 'payment_methods_screen.dart';
import '../providers/account_stats_provider.dart';

// ============================================================================
// ACCOUNT SCREEN — CLOUD SYNC!
//
// Photo ab WordPress par upload hoti hai (multi-device!)
// Naam/email website se (AuthProvider)
// Orders count live (AccountStatsProvider)
// ============================================================================

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();

    // Logged-in ho to orders count load karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isLoggedIn) {
        context.read<AccountStatsProvider>().loadStats();
      }
    });
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
  // 3. PROFILE PHOTO — CLOUD UPLOAD!
  //
  // Photo pick → WordPress media upload → customer profile save
  // Multi-device support! 🌐
  // ==========================================================================

  Future<void> _pickImage(ImageSource source) async {
    if (_isUploadingPhoto) return;

    try {
      final picker = ImagePicker();

      final XFile? picked = await picker.pickImage(
        source: source,
        maxWidth: 600,
        imageQuality: 85,
      );

      if (picked == null) return;
      if (!mounted) return;

      setState(() => _isUploadingPhoto = true);

      // ---- CLOUD UPLOAD! (WordPress media + customer profile) ----
      await context.read<AuthProvider>().uploadProfilePhoto(File(picked.path));
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        _showMessage('Profile photo updated & synced! 🎉');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
        _showMessage('Photo upload failed: $e', isError: true);
      }
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

              const SizedBox(height: 4),

              Text(
                'Syncs to your account (cloud)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  color: const Color(0xFF999999),
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
      _showMessage('Profile updated');
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

      if (!mounted) return;

      context.read<AccountStatsProvider>().reset();
      _showMessage('Logged out');
    }
  }

  // ==========================================================================
  // 5. AVATAR WIDGET — Cloud photo + upload indicator!
  // ==========================================================================

  Widget _initialsWidget(String name) {
    return Text(
      _userInitials(name),
      style: GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAvatar(String name) {
    final auth = context.watch<AuthProvider>();
    final String? photoUrl = auth.photoUrl;

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

            child: _isUploadingPhoto
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : photoUrl != null && photoUrl.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => _initialsWidget(name),
                      errorWidget: (_, _, _) => _initialsWidget(name),
                    ),
                  )
                : _initialsWidget(name),
          ),

          // Camera badge (upload ke waqt hide)
          if (!_isUploadingPhoto)
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
                    Row(
                      children: [
                        _buildAvatar(displayName),

                        const SizedBox(width: 16),

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
                    Builder(
                      builder: (context) {
                        final stats = context.watch<AccountStatsProvider>();

                        return Row(
                          children: [
                            _buildStatItem(
                              icon: Icons.shopping_bag_outlined,
                              value: '${stats.ordersCount}',
                              label: 'Orders',
                            ),

                            _buildStatItem(
                              icon: Icons.star_rounded,
                              value: isLoggedIn
                                  ? (stats.isLoading ? '...' : '✓')
                                  : '—',
                              label: 'Verified',
                            ),

                            _buildStatItem(
                              icon: Icons.verified_outlined,
                              value: isLoggedIn ? 'Active' : 'Guest',
                              label: 'Status',
                            ),
                          ],
                        );
                      },
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
                icon: Icons.credit_card_outlined,
                title: 'Payment Methods',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PaymentMethodsScreen(),
                    ),
                  );
                },
              ),

              _buildMenuItem(
                icon: Icons.settings_outlined,
                title: 'Settings',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ================================================================
              // LOGIN / LOGOUT
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
                  'App Version 1.0.0',
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
