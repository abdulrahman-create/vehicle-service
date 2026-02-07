import 'dart:io';
import 'dart:developer' as developer;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageService {
  static const int maxWidth = 1920;
  static const int maxHeight = 1080;
  static const int quality = 85;

  /// Compress and save an image to the service photos directory
  /// Returns the path to the compressed image
  static Future<String?> compressAndSaveImage(
    String sourcePath,
    String serviceId,
  ) async {
    try {
      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();

      // Create service photos directory
      final servicePhotosDir = Directory(
        path.join(appDir.path, 'service_photos', serviceId),
      );

      if (!await servicePhotosDir.exists()) {
        await servicePhotosDir.create(recursive: true);
      }

      // Generate unique filename
      final uuid = const Uuid();
      final fileName = '${uuid.v4()}.jpg';
      final targetPath = path.join(servicePhotosDir.path, fileName);

      // Compress image
      final compressedData = await FlutterImageCompress.compressWithFile(
        sourcePath,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
      );

      if (compressedData == null) {
        return null;
      }

      // Save compressed image
      final file = File(targetPath);
      await file.writeAsBytes(compressedData);

      return targetPath;
    } catch (e) {
      developer.log('Error compressing image', error: e, name: 'ImageService');
      return null;
    }
  }

  /// Compress and save multiple images
  static Future<List<String>> compressAndSaveMultipleImages(
    List<String> sourcePaths,
    String serviceId,
  ) async {
    final List<String> savedPaths = [];

    for (final sourcePath in sourcePaths) {
      final savedPath = await compressAndSaveImage(sourcePath, serviceId);
      if (savedPath != null) {
        savedPaths.add(savedPath);
      }
    }

    return savedPaths;
  }

  /// Delete a single photo file
  static Future<bool> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      developer.log('Error deleting photo', error: e, name: 'ImageService');
      return false;
    }
  }

  /// Delete all photos for a service
  static Future<void> deleteServicePhotos(String serviceId) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final servicePhotosDir = Directory(
        path.join(appDir.path, 'service_photos', serviceId),
      );

      if (await servicePhotosDir.exists()) {
        await servicePhotosDir.delete(recursive: true);
      }
    } catch (e) {
      developer.log(
        'Error deleting service photos',
        error: e,
        name: 'ImageService',
      );
    }
  }

  /// Delete multiple photos
  static Future<void> deleteMultiplePhotos(List<String> photoPaths) async {
    for (final photoPath in photoPaths) {
      await deletePhoto(photoPath);
    }
  }

  /// Check if a photo file exists
  static Future<bool> photoExists(String photoPath) async {
    try {
      final file = File(photoPath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get all photo paths for a service, filtering out non-existent files
  static Future<List<String>> getValidPhotoPaths(
    List<String>? photoPaths,
  ) async {
    if (photoPaths == null || photoPaths.isEmpty) {
      return [];
    }

    final validPaths = <String>[];
    for (final photoPath in photoPaths) {
      if (await photoExists(photoPath)) {
        validPaths.add(photoPath);
      }
    }

    return validPaths;
  }
}
