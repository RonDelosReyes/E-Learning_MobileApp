import 'package:supabase_flutter/supabase_flutter.dart';
import 'debug_logger.dart';

class PostMediaFetcher {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches a signed URL for post media from the PRIVATE 'post' bucket.
  static Future<String?> fetch(String? rawPath) async {
    if (rawPath == null || rawPath.isEmpty || rawPath == "null") return null;

    try {
      String relativePath = rawPath;

      // Extract relative path if it's a full URL
      if (rawPath.contains('/public/post/')) {
        relativePath = rawPath.split('/public/post/')[1];
      } else if (rawPath.contains('/post/')) {
        relativePath = rawPath.split('/post/').last;
      }

      // Clean up relative path if it has query parameters
      if (relativePath.contains('?')) {
        relativePath = relativePath.split('?')[0];
      }

      // If it's a full external URL (not from our bucket), return it directly
      if (relativePath.startsWith('http')) {
        return relativePath;
      }

      // Generate a Signed URL (valid for 1 hour) to support PRIVATE buckets
      final signedUrl = await _supabase.storage
          .from('post')
          .createSignedUrl(relativePath, 3600);
          
      return signedUrl;
    } catch (e) {
      await DebugLogger.log('POST_MEDIA_FETCHER ERROR: $e');
      return null;
    }
  }
}
