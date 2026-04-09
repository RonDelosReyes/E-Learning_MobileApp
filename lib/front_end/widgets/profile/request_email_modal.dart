import 'package:flutter/material.dart';
import '../../../back_end/controllers/profile/otp_controller.dart';
import '../../../back_end/utils/email_validator.dart';
import '../../../back_end/utils/empty_text_validator.dart';
import 'otp_modal.dart';

class RequestEmailModal extends StatefulWidget {
  const RequestEmailModal({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const RequestEmailModal(),
    );
  }

  @override
  State<RequestEmailModal> createState() => _RequestEmailModalState();
}

class _RequestEmailModalState extends State<RequestEmailModal> {
  final TextEditingController _emailController = TextEditingController();
  final OtpController _otpController = OtpController();
  String? _emailError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Request Email Change",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Enter your new email address. We will send a 6-digit verification code to your new email to confirm your request.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: theme.textTheme.bodyMedium?.color),
            decoration: InputDecoration(
              labelText: "New Email Address",
              errorText: _emailError,
              labelStyle: TextStyle(color: colorScheme.primary.withValues(alpha: 0.8), fontSize: 13),
              filled: true,
              fillColor: theme.cardTheme.color?.withValues(alpha: 0.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", 
                      style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text("Get OTP Code", style: TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Poppins')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final newEmail = _emailController.text.trim();
    
    final emptyError = EmptyTextValidator.validate(newEmail, "Email");
    if (emptyError != null) {
      setState(() => _emailError = emptyError);
      return;
    }

    if (!EmailValidator.isValidFormat(newEmail)) {
      setState(() => _emailError = "Please enter a valid email address");
      return;
    }

    setState(() => _isLoading = true);

    try {
      debugPrint("OTP_DEBUG: Triggering sendOtp for $newEmail...");
      await _otpController.sendOtp(newEmail);
      debugPrint("OTP_DEBUG: sendOtp success. Opening modal...");

      if (mounted) {
        final navigator = Navigator.of(context);
        navigator.pop(); // Close current modal
        
        Future.delayed(const Duration(milliseconds: 100), () {
          if (navigator.mounted) {
            OtpModal.show(navigator.context, newEmail);
          }
        });
      }
    } catch (e) {
      debugPrint("OTP_DEBUG ERROR: $e");
      if (mounted) {
        String errorMessage = "Failed to send code. Please try again.";
        if (e.toString().contains("too_many_requests")) {
          errorMessage = "Too many requests. Please wait a moment.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
