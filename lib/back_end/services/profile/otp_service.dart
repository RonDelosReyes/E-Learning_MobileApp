import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../connection/db_connect.dart';

class OtpService {
  final SupabaseClient _supabase = supabase;

  /// Sends a direct 6-digit OTP code to the email for ownership verification.
  Future<void> sendDirectOtp(String email) async {
    try {
      debugPrint("OTP_DEBUG: Sending direct OTP to: $email");
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: false,
      );
    } catch (e) {
      debugPrint("OTP_DEBUG Error sending direct OTP: $e");
      rethrow;
    }
  }

  /// Sends a Magic Link (Verification Link) for new emails.
  Future<void> sendVerificationLink(String email) async {
    try {
      debugPrint("OTP_DEBUG: Sending verification link to: $email");
      await _supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,
        emailRedirectTo: 'io.supabase.elearning://signup-callback/',
      );
    } catch (e) {
      debugPrint("OTP_DEBUG Error sending link: $e");
      rethrow;
    }
  }

  /// Sends the password reset OTP to the user's CURRENT email.
  Future<void> sendPasswordResetOtp(String currentEmail) async {
    try {
      await _supabase.auth.resetPasswordForEmail(currentEmail);
    } catch (e) {
      rethrow;
    }
  }

  /// Finalizes the email and/or password change via Edge Function.
  /// It verifies the new email ownership first if a new email is provided.
  Future<void> verifyAndApplyAccountChanges({
    String? newEmail, 
    String? emailToken,
    String? newPassword,
    required String targetAuthId,
    bool isFromLink = false,
  }) async {
    try {
      String? tempAuthId;

      // 1. If changing email, verify the new email ownership OTP/Link first
      if (newEmail != null && emailToken != null) {
        debugPrint("OTP_DEBUG: Verifying New Email OTP...");
        final tempClient = SupabaseClient(supabaseUrl, supabaseAnonKey);
        final verifyRes = await tempClient.auth.verifyOTP(
          type: OtpType.magiclink,
          token: emailToken,
          email: newEmail,
        );
        tempAuthId = verifyRes.user?.id;
      }
      
      debugPrint("OTP_DEBUG: Calling admin_update_user...");

      // 2. Call the Edge Function to apply changes (email, password, or both)
      final response = await _supabase.functions.invoke(
        'admin_update_user',
        body: {
          'auth_id': targetAuthId,
          'new_email': newEmail,
          'new_password': newPassword,
          'temp_auth_id': isFromLink ? tempAuthId : null,
          'action': 'update_account'
        },
      );

      if (response.status != 200) {
        throw response.data['error'] ?? 'Server update failed';
      }
    } catch (e) {
      rethrow;
    }
  }
}
