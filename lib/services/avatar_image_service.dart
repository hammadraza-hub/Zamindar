import 'dart:typed_data';

import 'package:flutter_compress/flutter_compress.dart';
import 'package:image_picker/image_picker.dart';

class AvatarImageService {
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickAndCompressAvatar({
    ImageSource source = ImageSource.gallery,
    int targetSizeKB = 150,
  }) async {
    final XFile? x = await _picker.pickImage(source: source);
    if (x == null) return null;

    final Uint8List inputBytes = await x.readAsBytes();

    final out = await FlutterCompress.instance.compressImageBytes(
      inputBytes,
      ImageCompressConfig(
        targetSizeKB: targetSizeKB,
        maxWidth: 1024,
        maxHeight: 1024,
        format: ImageFormat.webp,
        keepExif: false,
      ),
    );

    return out.bytes;
  }
}
