import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'debug_logger.dart';

class PostStorageService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final String _bucketName = 'post';
  final String _folderName = 'media';

  /// Uploads a file (image/video) into 'media/' folder and returns its public URL.
  /// NOTE: The 'post' bucket MUST be set to "Public" in the Supabase Dashboard.
  Future<String?> uploadPostMedia({
    required int userId,
    required File file,
  }) async {
    try {
      await DebugLogger.log('STORAGE_DEBUG: Starting upload for user $userId');
      
      final fileExt = file.path.split('.').last.toLowerCase();
      final uniqueId = const Uuid().v4();
      
      // Use forward slashes for storage paths
      final fileName = '$_folderName/user_${userId}_$uniqueId.$fileExt';

      // Determine content type
      String contentType = 'image/$fileExt';
      if (['mp4', 'mov', 'avi'].contains(fileExt)) {
        contentType = 'video/$fileExt';
      }

      await DebugLogger.log('STORAGE_DEBUG: Target path: $fileName with Content-Type: $contentType');

      await _supabase.storage.from(_bucketName).upload(
        fileName,
        file,
        fileOptions: FileOptions(
          upsert: true,
          contentType: contentType,
        ),
      );

      // getPublicUrl works only for Public buckets
      final String publicUrl = _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      
      // Clean URL of any parameters
      final cleanUrl = publicUrl.split('?').first;
      
      await DebugLogger.log('STORAGE_DEBUG: Upload success. URL: $cleanUrl');
      return cleanUrl;
    } catch (e) {
      await DebugLogger.log('STORAGE_DEBUG ERROR: $e');
      print('Error uploading post media: $e');
      return null;
    }
  }

  /// Deletes a post media by its public URL
  Future<void> deletePostMedia(String url) async {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final index = segments.indexOf(_bucketName);
      if (index != -1 && segments.length > index + 1) {
        final fileName = segments.sublist(index + 1).join('/');
        await _supabase.storage.from(_bucketName).remove([fileName]);
      }
    } catch (e) {
      print('Error deleting post media: $e');
    }
  }
}
