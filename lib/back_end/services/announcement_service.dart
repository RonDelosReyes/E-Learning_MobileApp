import 'package:supabase_flutter/supabase_flutter.dart';
import '../connection/db_connect.dart';
import '../../models/announcement_model.dart';

class AnnouncementService {
  final SupabaseClient _supabase = supabase;

  /// Fetches the latest announcements for the dashboard.
  /// Currently strictly chronological as per previous instruction.
  Future<List<AnnouncementModel>> getLatestAnnouncements({int limit = 3}) async {
    try {
      final response = await _supabase
          .from('tbl_post')
          .select('*, tbl_user(firstName, lastName)')
          .eq('post_type', 'announcement')
          .eq('status_no', 1) // Active
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => AnnouncementModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch latest announcements: $e');
    }
  }

  /// Fetches all announcements for the modal, prioritizing Pinned posts.
  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    try {
      final response = await _supabase
          .from('tbl_post')
          .select('*, tbl_user(firstName, lastName)')
          .eq('post_type', 'announcement')
          .eq('status_no', 1)
          .order('is_pinned', ascending: false) // 1. Pinned first
          .order('created_at', ascending: false); // 2. Latest next

      return (response as List)
          .map((json) => AnnouncementModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all announcements: $e');
    }
  }
}
