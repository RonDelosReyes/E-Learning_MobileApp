import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_learning_app/back_end/connection/db_connect.dart';

class AuthService {
  Future<Map<String, dynamic>?> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      debugPrint("DEBUG: [AuthService] Attempting login for: $email");
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = res.user;
      if (user == null) return null;

      debugPrint("DEBUG: [AuthService] Auth successful. User ID: ${user.id}");

      // Explicitly check for tbl_student relationship
      final response = await supabase
          .from('tbl_user')
          .select('''
            *,
            tbl_student!tbl_student_user_id_fkey (
              *,
              tbl_program!tbl_student_program_id_fkey (
                program_name
              )
            )
          ''')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint("DEBUG: [AuthService] Record not found in tbl_user for auth_id: ${user.id}");
        await supabase.auth.signOut();
        throw 'User profile not found.';
      }

      final userData = Map<String, dynamic>.from(response);

      // MANDATORY STUDENT CHECK:
      // If the account exists in tbl_user but NOT in tbl_student, deny login.
      final studentData = userData['tbl_student'];
      final bool hasStudentProfile = studentData != null && 
          (studentData is Map || (studentData is List && studentData.isNotEmpty));

      if (!hasStudentProfile) {
        debugPrint("DEBUG: [AuthService] User found but NO record in tbl_student. Denying access.");
        await supabase.auth.signOut();
        throw 'Access denied. Only student accounts are permitted.';
      }

      // Check account status (e.g., 3 = Pending)
      // If the user is pending, but successfully logged in, it means they've verified their account.
      if (userData['status_no'] == 3) {
        debugPrint("DEBUG: [AuthService] Account is pending. Activating now...");
        await supabase
            .from('tbl_user')
            .update({'status_no': 1})
            .eq('auth_id', user.id);
        
        userData['status_no'] = 1; // Update local map for current session
      }

      userData['email'] = user.email;
      return userData;
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
      return null;
    } catch (e) {
      debugPrint("DEBUG: [AuthService] Unexpected Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      return null;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<bool> doesEmailExist(String email) async {
    try {
      return await supabase.rpc('check_email_exists', params: {'email_to_check': email.trim().toLowerCase()});
    } catch (e) { return false; }
  }

  Future<void> sendPasswordResetOTP(String email) async {
    await supabase.auth.resetPasswordForEmail(email.trim());
  }

  Future<void> verifyResetOTP(String email, String token) async {
    await supabase.auth.verifyOTP(email: email.trim(), token: token.trim(), type: OtpType.recovery);
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword.trim()));
  }
}
