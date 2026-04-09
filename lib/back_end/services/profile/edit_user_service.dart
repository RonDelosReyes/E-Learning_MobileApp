import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_learning_app/back_end/connection/db_connect.dart';
import '../../../models/profile/edit_user_model.dart';

class EditUserService {
  final SupabaseClient _supabase = supabase;

  Future<void> updateProfile(EditUserModel model) async {
    try {
      // 1. Update tbl_user
      await _supabase.from('tbl_user').update({
        'firstName': model.firstName,
        'lastName': model.lastName,
        'middleInitial': model.middleInitial,
        'contact_no': model.contactNo,
      }).eq('user_id', model.userId);

      // 2. Update Role specific tables
      if (model.role == 'Student' && model.studentId != null) {
        await _supabase.from('tbl_student').update({
          'student_num': model.studentNum,
          'year_level': model.yearLevel,
        }).eq('student_id', model.studentId!);
      } else if (model.role == 'Faculty' && model.facultyId != null) {
        await _supabase.from('tbl_faculty').update({
          'department': model.department,
          'specialization': model.specialization,
        }).eq('faculty_id', model.facultyId!);
      }
    } catch (e) {
      debugPrint("Error in EditUserService: $e");
      throw Exception('Failed to update profile: $e');
    }
  }
}
