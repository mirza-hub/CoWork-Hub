import 'dart:convert';
import 'dart:typed_data';
import '../user.dart';

extension UserImage on User {
  Uint8List? getImageBytes() {
    if (profileImageBase64 == null || profileImageBase64!.isEmpty) return null;

    String base64Data = profileImageBase64!;
    if (base64Data.contains(',')) {
      base64Data = base64Data.split(',').last;
    }

    return base64Decode(base64Data);
  }
}
