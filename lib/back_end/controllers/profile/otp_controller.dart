import '../../services/profile/otp_service.dart';

class OtpController {
  final OtpService _service = OtpService();

  Future<void> sendOtp(String newEmail) async {
    return await _service.sendEmailChangeOtp(newEmail);
  }

  Future<void> verifyOtp(String newEmail, String token) async {
    return await _service.verifyEmailChangeOtp(newEmail, token);
  }

  Future<void> updateStatusToActive(String authId) async {
    return await _service.updateUserStatusToActive(authId);
  }
  
  // For Resend functionality in OtpModal
  Future<void> sendVerificationOtp(String email) async {
    return await _service.sendEmailChangeOtp(email);
  }
}
