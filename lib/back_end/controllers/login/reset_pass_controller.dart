import 'package:flutter/material.dart';
import '../../services/login/reset_pass_service.dart';
import '../../../models/login/reset_pass_model.dart';

class ResetPassController {
  final ResetPassService _service = ResetPassService();

  Future<bool> handleResetPassword({
    required BuildContext context,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final request = ResetPasswordRequest(
      newPassword: newPassword,
      confirmPassword: confirmPassword,
    );

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showError(context, "Please fill in all fields.");
      return false;
    }

    if (newPassword.length < 6) {
      _showError(context, "Password must be at least 6 characters.");
      return false;
    }

    if (!request.passwordsMatch) {
      _showError(context, "Passwords do not match.");
      return false;
    }

    try {
      await _service.updatePassword(
        context: context,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
