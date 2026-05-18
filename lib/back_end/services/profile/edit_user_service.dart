import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_learning_app/back_end/connection/db_connect.dart';
import 'package:e_learning_app/models/profile/edit_user_model.dart';

class EditUserService {
  final SupabaseClient _supabase = supabase;

  Future<void> updateProfile(EditUserModel model) async {
    try {
      // 1. Update tbl_user
      await _supabase.from('tbl_user').update({
        'firstName': model.firstName,
        'lastName': model.lastName,
        'middleName': model.middleName,
      }).eq('user_id', model.userId);

      // 2. Update Role specific tables
      if (model.role == 'Student') {
        await _supabase.from('tbl_student').update({
          'student_no': model.studentNum,
          'program_id': model.programId,
        }).eq('user_no', model.userId);
      }
    } catch (e) {
      debugPrint("Error in EditUserService: $e");
      throw Exception('Failed to update profile: $e');
    }
  }
}
