import 'package:supabase_flutter/supabase_flutter.dart';
import 'debug_logger.dart';

class PostMediaFetcher {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Cache to store resolved URLs to avoid redundant fetching during scrolling
  static final Map<String, String> _urlCache = {};

  /// Fetches a signed URL for media from PRIVATE buckets.
  /// Standardizes path extraction and supports multiple buckets (post, course-material, etc.)
  static Future<String?> fetch(String? rawPath) async {
    if (rawPath == null || rawPath.isEmpty || rawPath == "null") return null;

    // Check cache first
    if (_urlCache.containsKey(rawPath)) {
      return _urlCache[rawPath];
    }

    try {
      String relativePath = rawPath;
      String bucketName = 'post'; // Default bucket

      // Detect bucket name and extract relative path from various URL formats
      if (rawPath.contains('/storage/v1/object/')) {
        // Handle Supabase storage URLs (public or signed)
        // Format: .../storage/v1/object/[public/|sign/]{bucket}/path/to/file
        final parts = rawPath.split('/');
        int objectIndex = parts.indexOf('object');
        if (objectIndex != -1 && objectIndex + 1 < parts.length) {
          String nextPart = parts[objectIndex + 1];
          if (nextPart == 'public' || nextPart == 'sign') {
            bucketName = parts[objectIndex + 2];
            relativePath = parts.sublist(objectIndex + 3).join('/');
          } else {
            bucketName = nextPart;
            relativePath = parts.sublist(objectIndex + 2).join('/');
          }
        }
      }

      // Clean up relative path if it has query parameters
      if (relativePath.contains('?')) {
        relativePath = relativePath.split('?')[0];
      }

      // If it doesn't look like a bucket path but is a full URL, return it
      if (relativePath.startsWith('http')) {
        _urlCache[rawPath] = relativePath;
        return relativePath;
      }

      // Generate a Signed URL (valid for 1 hour) to support PRIVATE buckets
      final signedUrl = await _supabase.storage
          .from(bucketName)
          .createSignedUrl(relativePath, 3600);
      
      _urlCache[rawPath] = signedUrl;
      return signedUrl;
    } catch (e) {
      await DebugLogger.log('POST_MEDIA_FETCHER ERROR: $e');
      return null;
    }
  }
}
