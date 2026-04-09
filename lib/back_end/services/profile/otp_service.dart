import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../connection/db_connect.dart';

class OtpService {
  final SupabaseClient _supabase = supabase;

  /// Sends a Magic Link (OTP) to the new email address to verify ownership.
  Future<void> sendEmailChangeOtp(String email) async {
    try {
      debugPrint("OTP_DEBUG: Sending Magic Link OTP to: $email");
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true, // Required for new emails in Supabase Auth
      );
      debugPrint("OTP_DEBUG: Magic Link OTP sent successfully.");
    } on AuthException catch (e) {
      debugPrint("OTP_DEBUG AuthException: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("OTP_DEBUG Unexpected error: $e");
      throw Exception('Failed to send verification code: $e');
    }
  }

  /// Verifies the Magic Link OTP code silently (without logging out current user).
  Future<void> verifyEmailChangeOtp(String email, String token) async {
    try {
      debugPrint("OTP_DEBUG: Verifying Magic Link OTP for: $email (Silent)");
      
      // Separate client instance to prevent session hijacking/logout
      final tempClient = SupabaseClient(
        supabaseUrl,
        supabaseAnonKey,
      );

      await tempClient.auth.verifyOTP(
        type: OtpType.magiclink, // Must match signInWithOtp
        token: token,
        email: email,
      );
      
      debugPrint("OTP_DEBUG: Silent verification successful.");
    } on AuthException catch (e) {
      debugPrint("OTP_DEBUG AuthException: ${e.message}");
      rethrow;
    } catch (e) {
      debugPrint("OTP_DEBUG Unexpected error: $e");
      throw Exception('Invalid or expired OTP');
    }
  }

  /// Updates the user status in tbl_user to Active (1)
  Future<void> updateUserStatusToActive(String authId) async {
    try {
      debugPrint("OTP_DEBUG: Updating status for auth_id: $authId to 1");
      await _supabase
          .from('tbl_user')
          .update({'status_no': 1})
          .eq('auth_id', authId);
      debugPrint("OTP_DEBUG: Status updated successfully.");
    } catch (e) {
      debugPrint("OTP_DEBUG Error updating status: $e");
    }
  }
}
