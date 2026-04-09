import 'package:flutter/material.dart';
import 'package:e_learning_app/theme/app_theme.dart';
import '../../../back_end/controllers/login/forgot_pass_controller.dart';

class ForgotPassModal extends StatefulWidget {
  const ForgotPassModal({super.key});

  @override
  State<ForgotPassModal> createState() => _ForgotPassModalState();
}

class _ForgotPassModalState extends State<ForgotPassModal> {
  final TextEditingController emailController = TextEditingController();
  final ForgotPassController _forgotPassController = ForgotPassController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
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
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Forgot Password',
                  style: TextStyle(
                    fontSize: 22 * scale,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                    color: AppColors.loginTitleBlue,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: Colors.grey[400], size: 24 * scale),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Text(
              "Enter the email address associated with your account and we'll send you a link to reset your password.",
              style: TextStyle(
                fontSize: 13 * scale,
                color: Colors.black54,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            SizedBox(height: 28 * scale),

            // Email Field
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(fontSize: 14 * scale),
              decoration: InputDecoration(
                labelText: 'Email Address',
                labelStyle: TextStyle(
                  color: Colors.grey[50],
                  fontSize: 14 * scale,
                  fontFamily: 'Poppins',
                ),
                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400], size: 20 * scale),
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
              ),
            ),

            SizedBox(height: 32 * scale),

            // Submit Button
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
                        await _forgotPassController.handleForgotPassword(
                          context: context,
                          email: emailController.text.trim(),
                        );
                        if (mounted) {
                          setState(() => _isLoading = false);
                          // We stay on the modal if there's an error, 
                          // the controller handles the snackbar.
                          // But typically we close on success. 
                          // For now, let's just close to keep it simple.
                          Navigator.pop(context);
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
                        'SEND RESET LINK',
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
