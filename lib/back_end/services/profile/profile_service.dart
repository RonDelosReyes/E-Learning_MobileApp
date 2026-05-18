import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch latest profile by user_no
  Future<ProfileFile?> fetchProfileFile({
    required int userId,
  }) async {
    final response = await _supabase
        .from('tbl_profile')
        .select()
        .eq('user_no', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;

    return ProfileFile.fromMap(response);
  }

  /// Uses upsert to handle both first-time uploads and updates
  Future<bool> updateProfileFilePath({
    required int userId,
    required String filePath,
  }) async {
    try {
      final response = await _supabase
          .from('tbl_profile')
          .upsert({
            'user_no': userId,
            'filePath': filePath,
          }, onConflict: 'user_no')
          .select()
          .maybeSingle();

      return response != null;
    } catch (e) {
      // If no unique constraint exists on user_no, fallback to manual check
      // though upsert with onConflict is the standard way.
      try {
        final existing = await fetchProfileFile(userId: userId);
        if (existing != null) {
          await _supabase.from('tbl_profile').update({'filePath': filePath}).eq('user_no', userId);
        } else {
          await _supabase.from('tbl_profile').insert({'user_no': userId, 'filePath': filePath});
        }
        return true;
      } catch (innerE) {
        return false;
      }
    }
  }

  /// Checks if the student is a first-time user
  Future<bool> isFirstTimer(int userId) async {
    try {
      final response = await _supabase
          .from('tbl_student')
          .select('is_first_timer')
          .eq('user_no', userId)
          .maybeSingle();
      return response?['is_first_timer'] ?? true;
    } catch (e) {
      return true;
    }
  }

  /// Fetches ML-generated performance insights for the profile
  Future<List<PerformanceInsight>> fetchPerformanceInsights(int userId) async {
    try {
      final response = await _supabase
          .from('tbl_performance_insight')
          .select('*, tbl_category(category)')
          .eq('user_no', userId)
          .order('mastery_score', ascending: false);

      return (response as List).map((map) => PerformanceInsight.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }
}

/// --------------------
/// Profile File Model
/// --------------------
class ProfileFile {
  final int profileId;
  final int userNo;
  final String filePath;
  final DateTime createdAt;

  ProfileFile({
    required this.profileId,
    required this.userNo,
    required this.filePath,
    required this.createdAt,
  });

  factory ProfileFile.fromMap(Map<String, dynamic> map) {
    return ProfileFile(
      profileId: map['profile_id'],
      userNo: map['user_no'],
      filePath: map['filePath'],
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at']) 
          : DateTime.now(),
    );
  }
}

/// --------------------
/// Performance Insight Model (ML Results)
/// --------------------
class PerformanceInsight {
  final String categoryName;
  final double masteryScore;
  final String masteryLevel;
  final double improvement;
  final bool isStrength;
  final bool isWeakness;

  PerformanceInsight({
    required this.categoryName,
    required this.masteryScore,
    required this.masteryLevel,
    required this.improvement,
    required this.isStrength,
    required this.isWeakness,
  });

  factory PerformanceInsight.fromMap(Map<String, dynamic> map) {
    return PerformanceInsight(
      categoryName: map['tbl_category']?['category'] ?? "Unknown",
      masteryScore: (map['mastery_score'] ?? 0.0).toDouble(),
      masteryLevel: map['mastery_level'] ?? "Beginner",
      improvement: (map['improvement_perc'] ?? 0.0).toDouble(),
      isStrength: map['is_strength'] ?? false,
      isWeakness: map['is_weakness'] ?? false,
    );
  }
}
