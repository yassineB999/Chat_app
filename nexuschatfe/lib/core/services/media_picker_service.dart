import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nexuschatfe/core/constants/app_constants.dart';
import 'package:nexuschatfe/core/error/failures.dart';
import 'package:nexuschatfe/core/utils/logger.dart';

/// Media picker service for handling image and document selection
class MediaPickerService {
  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from the specified source (camera or gallery)
  /// Returns Either<Failure, File?> for proper error handling
  static Future<Either<Failure, File?>> pickImage(ImageSource source) async {
    try {
      AppLogger.debug(
        'Attempting to pick image from ${source.name}',
        tag: 'MediaPicker',
      );

      final XFile? pickedImage = await _imagePicker.pickImage(
        source: source,
        imageQuality: AppConstants.imageQuality,
      );

      if (pickedImage != null) {
        final file = File(pickedImage.path);
        AppLogger.success(
          'Image picked successfully: ${file.path}',
          tag: 'MediaPicker',
        );
        return Right(file);
      }

      AppLogger.info('Image selection cancelled', tag: 'MediaPicker');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error picking image', tag: 'MediaPicker', error: e);
      return Left(CacheFailure('Failed to pick image: ${e.toString()}'));
    }
  }

  /// Pick multiple images from gallery
  static Future<Either<Failure, List<File>>> pickMultipleImages({
    int? maxImages,
  }) async {
    try {
      AppLogger.debug('Attempting to pick multiple images', tag: 'MediaPicker');

      final List<XFile> pickedImages = await _imagePicker.pickMultiImage(
        imageQuality: AppConstants.imageQuality,
      );

      if (pickedImages.isEmpty) {
        AppLogger.info('No images selected', tag: 'MediaPicker');
        return const Right([]);
      }

      // Limit images if maxImages is specified
      final imagesToProcess =
          maxImages != null && pickedImages.length > maxImages
          ? pickedImages.take(maxImages).toList()
          : pickedImages;

      final files = imagesToProcess.map((xFile) => File(xFile.path)).toList();

      AppLogger.success(
        '${files.length} images picked successfully',
        tag: 'MediaPicker',
      );
      return Right(files);
    } catch (e) {
      AppLogger.error(
        'Error picking multiple images',
        tag: 'MediaPicker',
        error: e,
      );
      return Left(CacheFailure('Failed to pick images: ${e.toString()}'));
    }
  }

  /// Pick a document file (PDF, DOC, DOCX)
  static Future<Either<Failure, File?>> pickDocument() async {
    try {
      AppLogger.debug('Attempting to pick document', tag: 'MediaPicker');

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: AppConstants.documentExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          final file = File(filePath);
          AppLogger.success(
            'Document picked successfully: ${file.path}',
            tag: 'MediaPicker',
          );
          return Right(file);
        }
      }

      AppLogger.info('Document selection cancelled', tag: 'MediaPicker');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error picking document', tag: 'MediaPicker', error: e);
      return Left(CacheFailure('Failed to pick document: ${e.toString()}'));
    }
  }

  /// Pick any type of file
  static Future<Either<Failure, File?>> pickFile({
    FileType fileType = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      AppLogger.debug(
        'Attempting to pick file of type: $fileType',
        tag: 'MediaPicker',
      );

      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: fileType,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.first.path;
        if (filePath != null) {
          final file = File(filePath);
          AppLogger.success(
            'File picked successfully: ${file.path}',
            tag: 'MediaPicker',
          );
          return Right(file);
        }
      }

      AppLogger.info('File selection cancelled', tag: 'MediaPicker');
      return const Right(null);
    } catch (e) {
      AppLogger.error('Error picking file', tag: 'MediaPicker', error: e);
      return Left(CacheFailure('Failed to pick file: ${e.toString()}'));
    }
  }
}
