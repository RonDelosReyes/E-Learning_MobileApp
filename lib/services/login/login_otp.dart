import 'package:flutter/material.dart';
import '../../db_connect.dart';
import '../../login_pages/otp_modal.dart';
import '../otp_service_email.dart';

class LoginOtpHandler {
  final String email;

  LoginOtpHandler({required this.email});

  //Call this after login attempt
  Future<void> checkAndTriggerOtp(BuildContext context) async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select('status_no')
          .eq('email', email)
          .single();

      if (response == null) return;

      final int statusNo = response['status_no'] as int;

      //Only show OTP modal if status_no == 3
      if (statusNo == 3) {
        final otpService = OtpService(supabase: supabase);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => OtpModal(
            email: email,
            otpService: otpService,
            onVerified: (verified) {
              if (verified) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your account is now verified. Please login again.'),
                  ),
                );
              }
            },
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking OTP status: $e')),
      );
    }
  }
}
