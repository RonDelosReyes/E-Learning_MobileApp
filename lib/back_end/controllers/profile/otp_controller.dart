import '../../services/profile/otp_service.dart';
import '../../utils/email_validator.dart';

class OtpController {
  final OtpService _service = OtpService();

  /// Legacy method
  Future<void> sendOtp(String email) async {
    await requestEmailVerification(email);
  }

  /// Sends password reset OTP to current email
  Future<void> sendPasswordResetOtp(String currentEmail) async {
    return await _service.sendPasswordResetOtp(currentEmail);
  }

  /// Request verification for email change
  Future<bool> requestEmailVerification(String email) async {
    final bool exists = await EmailValidator.isEmailTaken(email);
    if (exists) {
      await _service.sendDirectOtp(email);
      return true;
    } else {
      await _service.sendVerificationLink(email);
      return false;
    }
  }

  Future<void> sendDirectOtp(String email) async {
    return await _service.sendDirectOtp(email);
  }

  /// Consolidated verify and apply for Email, Password, or both
  Future<void> verifyAndApplyAccountChanges({
    String? newEmail, 
    required String token,
    String? newPassword,
    required String targetAuthId,
    bool isFromLink = false,
  }) async {
    return await _service.verifyAndApplyAccountChanges(
      newEmail: newEmail, 
      emailToken: token,
      newPassword: newPassword,
      targetAuthId: targetAuthId,
      isFromLink: isFromLink,
    );
  }

  /// Alias for compatibility
  Future<void> verifyAndChangeEmail({
    required String newEmail, 
    required String token,
    required String targetAuthId,
    bool isFromLink = false,
  }) async {
    return await verifyAndApplyAccountChanges(
      newEmail: newEmail,
      token: token,
      targetAuthId: targetAuthId,
      isFromLink: isFromLink,
    );
  }

  Future<void> sendEmailChangeOtp(String email) async {
    await requestEmailVerification(email);
  }
}
