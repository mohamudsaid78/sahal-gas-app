import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' show File;

import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImageService {
  static String _keyForUser(String userId) => 'profile_image_base64_$userId';

  /// Opens a file picker for images and saves the selected image to
  /// shared preferences as base64. Returns the image bytes or null.
  static Future<Uint8List?> pickAndSaveImage({required String userId}) async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    Uint8List? bytes = result.files.first.bytes;
    final path = result.files.first.path;
    if (bytes == null && path != null) {
      try {
        bytes = await File(path).readAsBytes();
      } catch (_) {
        bytes = null;
      }
    }

    if (bytes == null) return null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyForUser(userId), base64Encode(bytes));
    return bytes;
  }

  /// Loads the saved profile image bytes, or null if none saved.
  static Future<Uint8List?> loadSavedImage({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    final b64 = prefs.getString(_keyForUser(userId));
    if (b64 == null) return null;
    try {
      return base64Decode(b64);
    } catch (_) {
      return null;
    }
  }

  /// Removes the saved profile image.
  static Future<void> removeSavedImage({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyForUser(userId));
  }
}
