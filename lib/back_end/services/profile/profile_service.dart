import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch latest profile by user_id
  Future<ProfileFile?> fetchProfileFile({
    required int userId,
  }) async {
    final response = await _supabase
        .from('tbl_profile')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;

    return ProfileFile.fromMap(response);
  }

  Future<bool> updateProfileFilePath({
    required int userId,
    required String filePath,
  }) async {
    final response = await _supabase
        .from('tbl_profile')
        .update({'filePath': filePath})
        .eq('user_id', userId)
        .select()
        .maybeSingle();

    return response != null;
  }
}

/// --------------------
/// Profile File Model
/// --------------------
class ProfileFile {
  final int profileId;
  final int userId;
  final String filePath;
  final DateTime createdAt;

  ProfileFile({
    required this.profileId,
    required this.userId,
    required this.filePath,
    required this.createdAt,
  });

  factory ProfileFile.fromMap(Map<String, dynamic> map) {
    return ProfileFile(
      profileId: map['profile_id'],
      userId: map['user_id'],
      filePath: map['filePath'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
