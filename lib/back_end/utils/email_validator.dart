import '../connection/db_connect.dart';

class EmailValidator {
  /// Checks if the given email already exists in Supabase Auth via an RPC call.
  /// Note: Requires 'check_email_exists' function to be created in Supabase SQL Editor.
  static Future<bool> isEmailTaken(String email) async {
    try {
      // Calling the Postgres function via RPC
      final response = await supabase.rpc(
        'check_email_exists',
        params: {'email_to_check': email.trim().toLowerCase()},
      );
      
      return response as bool;
    } catch (e) {
      // If the function doesn't exist yet or fails, we return false to allow 
      // the Auth service to handle it during the actual signup/update.
      return false;
    }
  }

  /// Professional validation message for the UI
  static String getTakenEmailError() {
    return 'This email is already registered';
  }

  /// Basic email format validation
  static bool isValidFormat(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}
