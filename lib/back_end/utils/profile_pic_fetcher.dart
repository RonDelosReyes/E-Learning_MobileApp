import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePicFetcher {
  static final SupabaseClient _supabase = Supabase.instance.client;
  
  // Signed URL expiry (in seconds). 2 hours for security.
  static const int _expirySeconds = 7200; 
  // Refresh if the URL is older than this (1 hour 50 mins) to avoid expiration during use.
  static const int _refreshThreshold = 6600; 

  static final Map<int, String> _urlCache = {};

  /// Fetches the profile picture URL for a given user using tbl_profile.
  /// Uses Signed URLs for security and persistent caching for performance.
  /// Refreshes the URL only if the image was replaced in DB or if the signed URL is about to expire.
  static Future<String?> fetch(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final String urlKey = 'profile_signed_url_$userId';
    final String pathKey = 'profile_path_$userId';
    final String timeKey = 'profile_fetched_at_$userId';

    // 1. Check in-memory cache first for the current session
    if (_urlCache.containsKey(userId)) {
      final int? fetchedAt = prefs.getInt(timeKey);
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // If it's still fresh in memory, return it
      if (fetchedAt != null && (now - fetchedAt) < _refreshThreshold) {
        return _urlCache[userId];
      }
    }

    try {
      // 2. Check DB for current filePath to see if image was replaced
      final data = await _supabase
          .from('tbl_profile')
          .select('filePath')
          .eq('user_no', userId)
          .maybeSingle();

      if (data == null) {
        debugPrint("ProfilePicFetcher: No record found for user $userId");
        return null;
      }

      final String? dbPath = data['filePath'];
      if (dbPath == null || dbPath.isEmpty || dbPath == "null") return null;

      // 3. Check persistent cache validity
      final String? cachedPath = prefs.getString(pathKey);
      final String? cachedUrl = prefs.getString(urlKey);
      final int? fetchedAt = prefs.getInt(timeKey);

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      bool isSameImage = (dbPath == cachedPath);
      bool isUrlFresh = (fetchedAt != null && (now - fetchedAt) < _refreshThreshold);

      // If it's the same image AND the signed URL hasn't expired, return cache
      if (isSameImage && isUrlFresh && cachedUrl != null) {
        debugPrint("ProfilePicFetcher: Cache valid and fresh. Reusing signed URL.");
        _urlCache[userId] = cachedUrl;
        return cachedUrl;
      }

      // 4. Either image replaced or URL expired, generate a new signed URL
      debugPrint("ProfilePicFetcher: ${!isSameImage ? 'Image changed' : 'URL expired'}. Fetching new signed URL.");
      
      String relativePath = dbPath;
      if (dbPath.contains('/ProfilePictures/')) {
        relativePath = dbPath.split('/ProfilePictures/').last.split('?')[0];
      }

      final signedUrl = await _supabase.storage
          .from('ProfilePictures')
          .createSignedUrl(relativePath, _expirySeconds);

      // Update both memory and persistent cache
      await prefs.setString(urlKey, signedUrl);
      await prefs.setString(pathKey, dbPath);
      await prefs.setInt(timeKey, now);
      _urlCache[userId] = signedUrl;

      return signedUrl;
    } catch (e) {
      debugPrint("ProfilePicFetcher ERROR: $e");
      // If fetching new URL fails (e.g. timeout), fallback to the cached one if it exists
      final String? cachedUrl = prefs.getString(urlKey);
      if (cachedUrl != null) {
        _urlCache[userId] = cachedUrl;
        return cachedUrl;
      }
      return null;
    }
  }

  /// Clears the cache. Call this if a user updates their profile picture.
  static Future<void> clearCache({int? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      _urlCache.remove(userId);
      await prefs.remove('profile_signed_url_$userId');
      await prefs.remove('profile_path_$userId');
      await prefs.remove('profile_fetched_at_$userId');
    } else {
      _urlCache.clear();
      final keys = prefs.getKeys().where((k) => k.startsWith('profile_')).toList();
      for (var key in keys) {
        await prefs.remove(key);
      }
    }
  }
}
