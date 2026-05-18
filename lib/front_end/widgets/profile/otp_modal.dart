import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_learning_app/theme/app_theme.dart';
import 'package:e_learning_app/back_end/controllers/profile/otp_controller.dart';
import 'package:e_learning_app/front_end/login/login_page.dart';

import '../dialog/success_dialog.dart';

class OtpModal extends StatefulWidget {
  final String email; // The email we are verifying ownership of
  final String? newPassword; // The password to be applied after verification
  final String? originalAuthId;
  final bool isFromLink;

  const OtpModal({
    super.key, 
    required this.email,
    this.newPassword,
    this.originalAuthId,
    this.isFromLink = false,
  });

  static Future<void> show(BuildContext context, String email, {String? newPassword, String? originalAuthId, bool isFromLink = false}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpModal(email: email, newPassword: newPassword, originalAuthId: originalAuthId, isFromLink: isFromLink),
    );
  }

  @override
  State<OtpModal> createState() => _OtpModalState();
}

class _OtpModalState extends State<OtpModal> {
  final TextEditingController _otpInputController = TextEditingController();
  final OtpController _controller = OtpController();
  
  bool _isLoading = false;
  String? _errorText;

  Timer? _timer;
  int _secondsRemaining = 60;
  int _resendAttempts = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Only send direct OTP if we AREN'T coming from a link (existing account or password-only flow)
    if (!widget.isFromLink) {
       _sendInitialOtp();
    }
  }

  Future<void> _sendInitialOtp() async {
    try {
      await _controller.sendDirectOtp(widget.email);
    } catch (e) {
      debugPrint("Initial OTP Send Failed: $e");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  int _getCooldown() {
    if (_resendAttempts == 0) return 120;
    if (_resendAttempts == 1) return 300;
    return 600;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpInputController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _otpInputController.text.trim();
    if (code.length < 6) {
      setState(() => _errorText = "Please enter the full 6-digit code");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final targetId = widget.originalAuthId ?? Supabase.instance.client.auth.currentUser?.id;
      if (targetId == null) throw "Authentication session lost.";

      // Apply the account changes (Email, Password, or both)
      await _controller.verifyAndApplyAccountChanges(
        newEmail: widget.isFromLink ? widget.email : null, // If from link, we're changing email
        token: code,
        newPassword: widget.newPassword,
        targetAuthId: targetId,
        isFromLink: widget.isFromLink,
      );

      if (mounted) {
        Navigator.pop(context); 
        _showLogoutNotification();
      }
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = true; // Stay in loading while error is shown
        _errorText = "$e";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showLogoutNotification() {
    SuccessDialog.show(
      context: context,
      title: "Email Updated",
      message: "Your email has been successfully changed. For security reasons, you will be signed out. Please log in again with your new email.",
      onConfirm: () async {
        await Supabase.instance.client.auth.signOut();
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LogInForm()),
            (route) => false,
          );
        }
      },
    );
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final scale = (mediaQuery.size.width / 375.0).clamp(0.85, 1.2);

    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom + 28 * scale,
        left: 28 * scale,
        right: 28 * scale,
        top: 12 * scale,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40 * scale, height: 4 * scale,
              decoration: BoxDecoration(color: theme.dividerColor.withOpacity(0.2), borderRadius: BorderRadius.circular(2 * scale)),
            ),
            SizedBox(height: 32 * scale),
            
            Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.security_rounded, size: 56 * scale, color: theme.colorScheme.primary),
            ),
            
            SizedBox(height: 24 * scale),
            
            Text(
              "Verify Ownership",
              style: TextStyle(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: textColor,
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              "Enter the 6-digit code sent to ${widget.email} to authorize the email change.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13 * scale,
                color: subTextColor,
                fontFamily: 'Poppins',
                height: 1.5,
              ),
            ),
            
            SizedBox(height: 32 * scale),

            TextField(
              controller: _otpInputController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24 * scale,
                fontWeight: FontWeight.bold,
                letterSpacing: 12 * scale,
                color: textColor,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: "000000",
                hintStyle: TextStyle(color: subTextColor.withAlpha(80), letterSpacing: 12 * scale),
                filled: true,
                fillColor: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16 * scale),
                  borderSide: BorderSide(color: isDark ? AppColors.darkInputEnabledBorder : AppColors.lightInputEnabledBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16 * scale),
                  borderSide: const BorderSide(color: AppColors.loginButtonBlue, width: 2),
                ),
              ),
            ),

            if (_errorText != null) ...[
              SizedBox(height: 16 * scale),
              Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 12, fontFamily: 'Poppins'), textAlign: TextAlign.center),
            ],

            SizedBox(height: 32 * scale),

            SizedBox(
              width: double.infinity,
              height: 56 * scale,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.loginButtonBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16 * scale)),
                ),
                onPressed: _isLoading ? null : _handleVerify,
                child: _isLoading
                    ? SizedBox(
                        height: 24 * scale,
                        width: 24 * scale,
                        child: const CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : Text(
                        "AUTHORIZE CHANGES", 
                        style: TextStyle(
                          fontSize: 15 * scale, 
                          fontWeight: FontWeight.bold, 
                          fontFamily: 'Poppins', 
                          letterSpacing: 1.2,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 16 * scale),
            
            TextButton(
              onPressed: (_isLoading || _secondsRemaining > 0) ? null : () async {
                try {
                  await _controller.sendDirectOtp(widget.email);
                  if (mounted) {
                    setState(() {
                      _secondsRemaining = _getCooldown();
                      _resendAttempts++;
                    });
                    _startTimer();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Code resent to your new email")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              },
              child: Text(
                _secondsRemaining > 0 
                    ? "Resend Code in ${_formatDuration(_secondsRemaining)}" 
                    : "Resend Code",
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontFamily: 'Poppins', 
                  color: (_isLoading || _secondsRemaining > 0) ? subTextColor : AppColors.loginButtonBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
