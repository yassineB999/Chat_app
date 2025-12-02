import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class MediaPickerService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from the specified source (camera or gallery)
  static Future<File?> pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70, // Optimize image size
      );

      if (pickedImage != null) {
        return File(pickedImage.path);
      }
      return null;
    } catch (e) {
      print('❌ Error picking image: $e');
      return null;
    }
  }

  /// Pick a document file (PDF, DOC, DOCX)
  static Future<File?> pickDocument() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.isNotEmpty) {
        return File(result.files.first.path!);
      }
      return null;
    } catch (e) {
      print('❌ Error picking document: $e');
      return null;
    }
  }
}
