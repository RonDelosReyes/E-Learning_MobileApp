import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  //Converts a full URL or path to the storage-relative path
  String _getStoragePath(String urlOrPath) {
    if (urlOrPath.startsWith('http')) {
      // e.g., https://xyz.supabase.co/storage/v1/object/public/ProfilePictures/user_36_123.jpg?token=abc
      final uri = Uri.parse(urlOrPath);
      final segments = uri.pathSegments;
      // Find the 'ProfilePictures' folder
      final index = segments.indexOf('ProfilePictures');
      if (index != -1 && segments.length > index + 1) {
        return segments.sublist(index + 1).join('/');
      }
      // fallback to last segment
      return segments.last.split('?')[0];
    }
    return urlOrPath;
  }

  //Uploads a profile image safely: deletes old image if exists,
  //uploads new image, and returns the new file path.
  Future<String?> uploadProfileImage({
    required int userId,
    required File file,
    String? oldFilePath,
  }) async {
    try {
      //Upload new file first
      final fileExt = file.path.split('.').last;
      final newFileName =
          'user_${userId}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      final uploadResponse = await _supabase.storage
          .from('ProfilePictures')
          .upload(newFileName, file, fileOptions: const FileOptions(upsert: true));

      // ignore: dead_code
      if (uploadResponse == null) {
        throw Exception('Upload failed');
      }

      //Delete old file if it exists
      if (oldFilePath != null && oldFilePath.isNotEmpty) {
        final oldFileName = _getStoragePath(oldFilePath);

        try {
          final removeResponse =
          await _supabase.storage.from('ProfilePictures').remove([oldFileName]);

          if (removeResponse.isEmpty) {
            print('No file deleted (file might not exist): $oldFileName');
          } else {
            print('Deleted old profile image: $oldFileName');
          }
        } catch (e) {
          print('Failed to delete old profile image: $e');
        }
      }

      // Return new file name to store in DB
      return newFileName;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  //Generates a signed URL to fetch the image from a private bucket
  Future<String?> getSignedUrl(String filePath, {int expiresInSeconds = 60}) async {
    try {
      final url = await _supabase.storage
          .from('ProfilePictures')
          .createSignedUrl(filePath, expiresInSeconds);
      return url;
    } catch (e) {
      print('Error generating signed URL: $e');
      return null;
    }
  }

  Future<void> deleteProfileImage(String fileName) async {
    try {
      await _supabase.storage.from('ProfilePictures').remove([fileName]);
    } catch (e) {
      throw Exception('Error deleting file $fileName: $e');
    }
  }
}
