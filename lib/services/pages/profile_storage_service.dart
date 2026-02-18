import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ProfileStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'ProfilePictures'; // your public bucket name

  /// Converts a full URL or path to the storage-relative path
  String _getStoragePath(String urlOrPath) {
    if (urlOrPath.startsWith('http')) {
      final uri = Uri.parse(urlOrPath);
      final segments = uri.pathSegments;
      final index = segments.indexOf(_bucketName);
      if (index != -1 && segments.length > index + 1) {
        return segments.sublist(index + 1).join('/');
      }
      return segments.last.split('?')[0];
    }
    return urlOrPath;
  }

  /// Uploads a profile image safely:
  /// - Deletes old image if exists
  /// - Uploads new image
  /// - Returns the public URL of the new image
  Future<String?> uploadProfileImage({
    required int userId,
    required File file,
    String? oldFilePath,
  }) async {
    try {
      // Generate a unique filename
      final fileExt = file.path.split('.').last;
      final uniqueId = Uuid().v4();
      final newFileName = 'user_${userId}_$uniqueId.$fileExt';

      // Upload new file
      await _supabase.storage.from(_bucketName).upload(
        newFileName,
        file,
        fileOptions: const FileOptions(upsert: false),
      );

      // Delete old file if provided
      if (oldFilePath != null && oldFilePath.isNotEmpty) {
        final oldFileName = _getStoragePath(oldFilePath);
        try {
          final removed = await _supabase.storage.from(_bucketName).remove([oldFileName]);
          if (removed.isEmpty) {
            print('Old file not found or already deleted: $oldFileName');
          } else {
            print('Deleted old profile image: $oldFileName');
          }
        } catch (e) {
          print('Failed to delete old profile image: $e');
        }
      }

      // Return public URL
      final publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(newFileName);
      return publicUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  /// Deletes a profile image by file path or public URL
  Future<void> deleteProfileImage(String urlOrPath) async {
    try {
      final fileName = _getStoragePath(urlOrPath);
      final removed = await _supabase.storage.from(_bucketName).remove([fileName]);
      if (removed.isEmpty) {
        print('File not found or already deleted: $fileName');
      } else {
        print('Deleted file: $fileName');
      }
    } catch (e) {
      print('Error deleting file $urlOrPath: $e');
    }
  }

  /// Returns the public URL of a file
  String getPublicUrl(String filePath) {
    final path = _getStoragePath(filePath);
    return _supabase.storage.from(_bucketName).getPublicUrl(path);
  }
}
