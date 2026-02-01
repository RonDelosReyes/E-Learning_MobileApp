import 'package:supabase_flutter/supabase_flutter.dart';

class OtpService {
  final SupabaseClient supabase;

  OtpService({required this.supabase});

  //Send OTP to email
  Future<bool> sendOtp(String email) async {
    try {
      await supabase.auth.signInWithOtp(
        email: email,
        emailRedirectTo: 'io.supabase.flutter://login-callback',
      );
      return true;
    } catch (e) {
      print("Error sending OTP: $e");
      return false;
    }
  }

  //Verify OTP
  Future<bool> verifyOtp({required String email, required String otp}) async {
    try {
      final response = await supabase.auth.verifyOTP(
        email: email,
        token: otp, //This is the required parameter
        type: OtpType.email,
      );
      print("OTP verification response: $response");
      return response.user != null;
    } catch (e) {
      print("Error verifying OTP: $e");
      return false;
    }
  }
}