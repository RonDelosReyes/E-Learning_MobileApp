import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_learning_app/back_end/connection/db_connect.dart';

class ResetPassService {
  /// Updates the user's password in Supabase Auth
  Future<void> updatePassword({
    required BuildContext context,
    required String newPassword,
  }) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Password updated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on AuthException catch (error) {
      debugPrint("Reset Password Auth Error: ${error.message}");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to update password. Please try again later."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      rethrow;
    } catch (e) {
      debugPrint("Unexpected Reset Password Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Something went wrong. Please try again later."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      rethrow;
    }
  }
}
