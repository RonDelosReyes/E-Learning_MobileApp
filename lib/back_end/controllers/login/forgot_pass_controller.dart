import 'package:flutter/material.dart';
import '../../services/login/forgot_pass_service.dart';

class ForgotPassController {
  final ForgotPassService _service = ForgotPassService();

  Future<void> handleForgotPassword({
    required BuildContext context,
    required String email,
  }) async {
    // Basic validation
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email address")),
      );
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    // Call service to send reset email
    await _service.sendResetEmail(
      context: context,
      email: email,
    );
  }
}
