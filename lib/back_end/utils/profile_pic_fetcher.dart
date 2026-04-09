import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePicFetcher {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetches the profile picture URL for a given user.
  /// It attempts to generate a signed URL if possible (for private buckets),
  /// otherwise falls back to the public URL.
  static Future<String?> fetch(int userId) async {
    try {
      final data = await _supabase
          .from('tbl_profile')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) return null;

      final String? rawPath = data['filePath'] ?? data['filepath'];
      if (rawPath == null || rawPath.isEmpty || rawPath == "null") return null;

      String relativePath = rawPath;

      // Extract relative path if it's a full URL
      if (rawPath.contains('/public/ProfilePictures/')) {
        relativePath = rawPath.split('/public/ProfilePictures/')[1];
      } else if (rawPath.contains('/ProfilePictures/')) {
        relativePath = rawPath.split('/ProfilePictures/').last;
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
      try {
        final signedUrl = await _supabase.storage
            .from('ProfilePictures')
            .createSignedUrl(relativePath, 3600);
        return signedUrl;
      } catch (e) {
        // Fallback to Public URL if signing fails
        return _supabase.storage.from('ProfilePictures').getPublicUrl(relativePath);
      }
    } catch (e) {
      return null;
    }
  }
}
