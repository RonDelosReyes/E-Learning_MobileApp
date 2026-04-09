import 'package:flutter/material.dart';
import 'package:e_learning_app/theme/app_theme.dart';
import '../../../back_end/controllers/login/reset_pass_controller.dart';

class ResetPassModal extends StatefulWidget {
  const ResetPassModal({super.key});

  @override
  State<ResetPassModal> createState() => _ResetPassModalState();
}

class _ResetPassModalState extends State<ResetPassModal> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final ResetPassController _controller = ResetPassController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _inputStyle(String label, double scale) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey[500],
        fontSize: 14 * scale,
        fontFamily: 'Poppins',
      ),
      filled: true,
      fillColor: Colors.grey[50],
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14 * scale),
        borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14 * scale),
        borderSide: BorderSide(color: AppColors.loginButtonBlue, width: 1.5),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 18 * scale,
      ),
      suffixIcon: label.contains('Password') ? IconButton(
        icon: Icon(
          _obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: Colors.grey[400],
          size: 18 * scale,
        ),
        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
      ) : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final scale = (screenWidth / 375.0).clamp(0.85, 1.2);

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24 * scale),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 22 * scale,
                fontWeight: FontWeight.w800,
                fontFamily: 'Poppins',
                color: AppColors.loginTitleBlue,
              ),
            ),
            SizedBox(height: 12 * scale),
            Text(
              "Please enter your new password below.",
              style: TextStyle(
                fontSize: 13 * scale,
                color: Colors.black54,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 28 * scale),

            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(fontSize: 14 * scale),
              decoration: _inputStyle('New Password', scale),
            ),
            SizedBox(height: 16 * scale),
            TextField(
              controller: confirmPasswordController,
              obscureText: _obscurePassword,
              style: TextStyle(fontSize: 14 * scale),
              decoration: _inputStyle('Confirm New Password', scale),
            ),

            SizedBox(height: 32 * scale),

            SizedBox(
              width: double.infinity,
              height: 56 * scale,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginButtonBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                ),
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() => _isLoading = true);
                        final success = await _controller.handleResetPassword(
                          context: context,
                          newPassword: passwordController.text,
                          confirmPassword: confirmPasswordController.text,
                        );
                        if (mounted) {
                          setState(() => _isLoading = false);
                          if (success) Navigator.pop(context);
                        }
                      },
                child: _isLoading
                    ? SizedBox(
                        height: 24 * scale,
                        width: 24 * scale,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5 * scale,
                        ),
                      )
                    : Text(
                        'UPDATE PASSWORD',
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Poppins',
                          letterSpacing: 1,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
