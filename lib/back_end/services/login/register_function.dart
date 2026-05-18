import 'package:supabase_flutter/supabase_flutter.dart';
import '../../connection/db_connect.dart';

class RegistrationService {
  /// Checks if a student number exists in tbl_student and is not yet linked to an auth account.
  Future<Map<String, dynamic>?> verifyStudentNo(String studentNo) async {
    try {
      final res = await supabase
          .from('tbl_student')
          .select('*, tbl_user!inner(*), tbl_program!inner(program_name)')
          .eq('student_no', studentNo)
          .maybeSingle();

      if (res == null) return null;

      final userData = res['tbl_user'];
      if (userData['auth_id'] != null) {
        throw 'This student number is already registered.';
      }

      return {
        'student_id': res['student_id'],
        'user_id': userData['user_id'],
        'firstName': userData['firstName'],
        'middleName': userData['middleName'],
        'lastName': userData['lastName'],
        'program_name': res['tbl_program']['program_name'],
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Registers a student by creating a Supabase Auth user and then
  /// updating the public.tbl_user table with the auth_id.
  Future<void> registerStudent({
    required int userId,
    required String email,
    required String password,
  }) async {
    // 1. Sign up using Supabase Auth
    final AuthResponse res = await supabase.auth.signUp(
      email: email.trim(),
      password: password,
      emailRedirectTo: 'io.supabase.elearning://signup-callback/',
    );

    final user = res.user;
    if (user == null) {
      throw 'Failed to create authentication account.';
    }

    try {
      // 2. Update existing record in public.tbl_user
      await supabase.from('tbl_user').update({
        'auth_id': user.id,
        'status_no': 3, // Set to Pending (3) until email is verified and they log in
      }).eq('user_id', userId);
    } catch (e) {
      rethrow;
    }
  }
}
