import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_learning_app/theme/app_theme.dart';
import '../../back_end/controllers/profile/otp_controller.dart';
import '../login/login_page.dart';

import 'dialog/success_dialog.dart';

class OtpModal extends StatefulWidget {
  final String newEmail;
  final String? originalAuthId;
  final bool isFromLink;

  const OtpModal({
    super.key, 
    required this.newEmail,
    this.originalAuthId,
    this.isFromLink = false,
  });

  static Future<void> show(BuildContext context, String newEmail, {String? originalAuthId, bool isFromLink = false}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpModal(newEmail: newEmail, originalAuthId: originalAuthId, isFromLink: isFromLink),
    );
  }

  @override
  State<OtpModal> createState() => _OtpModalState();
}

class _OtpModalState extends State<OtpModal> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final OtpController _controller = OtpController();
  
  bool _isLoading = false;
  String? _errorText;

  // Rate Limiter variables
  Timer? _timer;
  int _secondsRemaining = 60; // Initial 1 min
  int _resendAttempts = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Automatically send the direct OTP code when the modal opens, 
    // but only if we didn't just come from a magic link verification.
    if (!widget.isFromLink) {
      _sendInitialOtp();
    }
  }

  Future<void> _sendInitialOtp() async {
    try {
      await _controller.sendDirectOtp(widget.newEmail);
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
    if (_resendAttempts == 0) return 120; // After 1st resend: 2 mins
    if (_resendAttempts == 1) return 300; // After 2nd resend: 5 mins
    return 600; // After 3rd+ resend: 10 mins
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _handleVerify() async {
    if (_otpCode.length < 6) {
      setState(() => _errorText = "Please enter the full 6-digit code");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      // Use the provided originalAuthId, or fallback to current user
      final targetId = widget.originalAuthId ?? Supabase.instance.client.auth.currentUser?.id;
      
      if (targetId == null) throw "Authentication session lost.";

      // Correct call to verifyAndChangeEmail on the controller
      await _controller.verifyAndChangeEmail(
        newEmail: widget.newEmail, 
        token: _otpCode,
        targetAuthId: targetId,
        isFromLink: widget.isFromLink,
      );

      if (mounted) {
        Navigator.pop(context); // Close OTP Modal
        _showLogoutNotification();
      }
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorText = "$e";
      });
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
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final scale = (screenWidth / 375.0).clamp(0.85, 1.2);

    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24 * scale,
        left: 24 * scale,
        right: 24 * scale,
        top: 12 * scale,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40 * scale,
            height: 4 * scale,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2 * scale),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Verify Ownership",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 12),
          Text(
            "Enter the 6-digit code sent to ${widget.newEmail} to verify you own this address.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) => _buildOtpField(index)),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: 16),
            Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _isLoading ? null : _handleVerify,
              child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Verify & Authorize Change", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: (_isLoading || _secondsRemaining > 0) ? null : () async {
              try {
                await _controller.sendDirectOtp(widget.newEmail);
                if (mounted) {
                  setState(() {
                    _secondsRemaining = _getCooldown();
                    _resendAttempts++;
                  });
                  _startTimer();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Verification code resent")),
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
                color: (_isLoading || _secondsRemaining > 0) ? subTextColor : AppColors.loginButtonBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          counterText: "",
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
          if (_otpCode.length == 6) {
            FocusScope.of(context).unfocus();
          }
        },
      ),
    );
  }
}
