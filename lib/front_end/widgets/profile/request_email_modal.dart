import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_learning_app/back_end/controllers/profile/otp_controller.dart';
import 'package:e_learning_app/back_end/utils/email_validator.dart';
import 'package:e_learning_app/back_end/providers/user_provider.dart';
import 'package:e_learning_app/back_end/utils/app_entry.dart';
import 'otp_modal.dart';
import 'waiting_verification_modal.dart';

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
  final TextEditingController _passController = TextEditingController();
  final OtpController _otpController = OtpController();
  
  String? _emailError;
  String? _passError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

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
            width: 40, height: 4,
            decoration: BoxDecoration(color: theme.dividerColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          const Text("Security Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          const Text(
            "Enter a new email, a new password, or both to update your account security.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 24),
          
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: "New Email Address (Optional)",
              hintText: userProvider.email,
              errorText: _emailError,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          const SizedBox(height: 16),
          
          TextField(
            controller: _passController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "New Password (Optional)",
              errorText: _passError,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("Continue"),
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
    final newPass = _passController.text.trim();
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (newEmail.isEmpty && newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a new email or password to update.")));
      return;
    }

    if (newEmail.isNotEmpty && !EmailValidator.isValidFormat(newEmail)) {
      setState(() => _emailError = "Invalid email format");
      return;
    }

    if (newPass.isNotEmpty && newPass.length < 6) {
      setState(() => _passError = "Password must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (newEmail.isNotEmpty) {
        // Case A: Email is being changed (may include password)
        final bool isDirectOtp = await _otpController.requestEmailVerification(newEmail);
        if (mounted) {
          Navigator.pop(context);
          if (isDirectOtp) {
            OtpModal.show(context, newEmail, newPassword: newPass.isNotEmpty ? newPass : null);
          } else {
            AppEntry.pendingEmailChange = newEmail;
            AppEntry.requestingAuthId = userProvider.userId?.toString(); // Need this for the link flow
            // Store the password globally or in AppEntry for the redirect flow
            // For now, let's pass it to Waiting modal if needed or assume user re-enters
            WaitingVerificationModal.show(context, newEmail, () {
              AppEntry.pendingEmailChange = null;
              Navigator.pop(context);
            });
          }
        }
      } else {
        // Case B: Only Password is being changed
        await _otpController.sendPasswordResetOtp(userProvider.email!);
        if (mounted) {
          Navigator.pop(context);
          OtpModal.show(context, userProvider.email!, newPassword: newPass);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
