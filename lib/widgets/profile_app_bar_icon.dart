import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/account_screen.dart';
import '../screens/login_screen.dart';

/// Reusable profile icon for app bars.
/// Photo ho → photo dikhega!
/// Photo na ho → default person icon.
/// Guest → Login screen | Logged-in → Account screen.
class ProfileAppBarIcon extends StatelessWidget {
  const ProfileAppBarIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final String? photoUrl = auth.photoUrl;
    final bool isLoggedIn = auth.isLoggedIn;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                isLoggedIn ? const AccountScreen() : const LoginScreen(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: Color(0xFF087524),
          shape: BoxShape.circle,
        ),
        child: photoUrl != null && photoUrl.isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: photoUrl,
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Colors.white,
                  ),
                  errorWidget: (_, _, _) => const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              )
            : const Icon(Icons.person_outline, size: 20, color: Colors.white),
      ),
    );
  }
}
