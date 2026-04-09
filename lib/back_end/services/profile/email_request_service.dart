import 'package:supabase_flutter/supabase_flutter.dart';
import '../../connection/db_connect.dart';
import '../../../models/profile/email_request_model.dart';

class EmailRequestService {
  final SupabaseClient _supabase = supabase;

  /// Records the email change request. 
  /// Checks for an existing pending request first to avoid constraint errors.
  Future<void> submitEmailRequest(EmailRequestModel model) async {
    try {
      // 1. Check if a pending request already exists for this user
      final existing = await getPendingRequest(model.authId);
      
      if (existing != null) {
        // 2. If it exists, update it
        await updateEmailRequest(model.authId, model.newEmail);
      } else {
        // 3. If it doesn't exist, insert a new record
        await _supabase.from('tbl_temp_user').insert(model.toJson());
      }
    } catch (e) {
      throw Exception('Failed to record email change request: $e');
    }
  }

  Future<void> updateEmailRequest(String authId, String newEmail) async {
    try {
      await _supabase
          .from('tbl_temp_user')
          .update({'new_email': newEmail, 'status': 'pending'})
          .eq('auth_id', authId);
    } catch (e) {
      throw Exception('Failed to update email change request: $e');
    }
  }

  Future<Map<String, dynamic>?> getPendingRequest(String authId) async {
    try {
      final response = await _supabase
          .from('tbl_temp_user')
          .select()
          .eq('auth_id', authId)
          .eq('status', 'pending')
          .maybeSingle();
      return response;
    } catch (e) {
      return null;
    }
  }
}
