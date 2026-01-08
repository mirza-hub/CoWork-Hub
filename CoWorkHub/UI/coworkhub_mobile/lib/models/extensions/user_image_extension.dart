import 'dart:convert';
import 'dart:typed_data';
import '../user.dart';

extension UserImage on User {
  Uint8List? getImageBytes() {
    if (profileImageBase64 == null) return null;
    return base64Decode(profileImageBase64!);
  }
}
