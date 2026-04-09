import 'package:supabase_flutter/supabase_flutter.dart';
import '../../connection/db_connect.dart';

class RegistrationService {
  /// Registers a student by creating a Supabase Auth user and then
  /// populating the public.tbl_user and public.tbl_student tables.
  Future<void> registerStudent({
    required String firstName,
    required String middleInitial,
    required String lastName,
    required String contactNo,
    required String email,
    required String password,
    required String studentNum,
    required String yearLevel,
  }) async {
    // 1. Sign up using Supabase Auth
    // This will trigger the confirmation email.
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
      // 2. Insert into public.tbl_user using the auth_id from Supabase Auth
      final userRes = await supabase.from('tbl_user').insert({
        'auth_id': user.id,
        'firstName': firstName,
        'middleInitial': middleInitial.isEmpty ? null : middleInitial,
        'lastName': lastName,
        'contact_no': contactNo,
        'status_no': 1, // Set to Active directly as verification is via Supabase
      }).select().single();

      final int userId = userRes['user_id'];

      // 3. Insert into public.tbl_student
      await supabase.from('tbl_student').insert({
        'user_no': userId,
        'student_num': studentNum,
        'year_level': yearLevel,
      });
    } catch (e) {
      // Let the UI handle the exceptions specifically
      rethrow;
    }
  }
}
