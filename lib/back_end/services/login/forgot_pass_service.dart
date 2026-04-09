import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_learning_app/back_end/connection/db_connect.dart';

class ForgotPassService {
  /// Sends a password reset email via Supabase Auth with a custom redirect URL for the mobile app
  Future<void> sendResetEmail({
    required BuildContext context,
    required String email,
  }) async {
    try {
      await supabase.auth.resetPasswordForEmail(
        email.trim(),
        // This matches the scheme and host we added to AndroidManifest.xml
        redirectTo: 'io.supabase.elearning://reset-callback/',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password reset email sent! Please check your inbox."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on AuthException catch (error) {
      debugPrint("Forgot Password Auth Error: ${error.message}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to send reset email. Please try again later."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      debugPrint("Unexpected Forgot Password Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong. Please try again later."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
