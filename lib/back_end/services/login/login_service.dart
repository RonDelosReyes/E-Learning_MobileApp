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
      // Use Supabase Auth for login
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      final user = res.user;
      if (user == null) return null;

      // Fetch user profile data from public.tbl_user joined with roles and profile
      final userData = await supabase
          .from('tbl_user')
          .select('''
            *,
            tbl_faculty (*),
            tbl_student (*),
            tbl_profile (filePath)
          ''')
          .eq('auth_id', user.id)
          .maybeSingle();

      if (userData == null) {
        debugPrint("User profile not found in tbl_user for auth_id: ${user.id}");
        throw 'User profile not found.';
      }

      // Add email from Auth
      userData['email'] = user.email;

      return userData;
    } on AuthException catch (error) {
      debugPrint("Login Auth Error: ${error.message}");
      
      String userMessage = "Invalid email or password.";
      if (error.message.toLowerCase().contains("email not confirmed")) {
        userMessage = "Please confirm your email before logging in.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage)),
      );
      return null;
    } catch (e) {
      debugPrint("Unexpected Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Something went wrong. Please try again later.")),
      );
      return null;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  /// Updates the user's email in Supabase Auth.
  /// This will send confirmation emails to both old and new addresses.
  Future<void> updateUserEmail(String newEmail) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(email: newEmail.trim()),
      );
    } on AuthException {
      rethrow;
    } catch (e) {
      throw 'An unexpected error occurred while updating email.';
    }
  }
}
