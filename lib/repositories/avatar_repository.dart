import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AvatarRepository {
  Future<String> uploadAvatarBytes(Uint8List bytes) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Fixed path => always ONE avatar in storage
    final ref = FirebaseStorage.instance.ref('users/$uid/avatar.webp');

    // Delete old (if not exists, ignore)
    try {
      await ref.delete();
    } catch (_) {}

    // Upload new compressed bytes
    await ref.putData(
      bytes,
      SettableMetadata(
        contentType: 'image/webp',
        cacheControl: 'no-cache, max-age=0', // helps avoid caching old avatar
      ),
    );

    final url = await ref.getDownloadURL();

    // Save to Firestore (so app can show it)
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'avatarUrl': url,
      'avatarUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return url;
  }
}
