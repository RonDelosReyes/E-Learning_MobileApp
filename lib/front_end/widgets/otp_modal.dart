import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../back_end/controllers/profile/otp_controller.dart';
import '../../back_end/controllers/profile/email_request_controller.dart';

class OtpModal extends StatefulWidget {
  final String newEmail;
  const OtpModal({super.key, required this.newEmail});

  static Future<void> show(BuildContext context, String newEmail) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OtpModal(newEmail: newEmail),
    );
  }

  @override
  State<OtpModal> createState() => _OtpModalState();
}

class _OtpModalState extends State<OtpModal> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final OtpController _controller = OtpController();
  final EmailRequestController _requestController = EmailRequestController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
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
      // 1. Verify Ownership (Silent Verification)
      // This uses the controller to verify ownership without logging out the current user.
      await _controller.verifyOtp(widget.newEmail, _otpCode);

      // Get the current user AFTER verification
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw "Session expired. Please login again.";
      
      final authId = user.id;

      // 2. Record the request in tbl_temp_user
      await _requestController.submitRequest(authId, widget.newEmail);

      // 3. Update status (Confirming user is Active)
      await _controller.updateStatusToActive(authId);

      if (mounted) {
        Navigator.pop(context); // Close OTP Modal
        _showSuccessDialog();
      }
    } on AuthException catch (e) {
      debugPrint("OTP_DEBUG AuthException: ${e.message}");
      setState(() {
        _isLoading = false;
        _errorText = e.message;
      });
    } catch (e) {
      debugPrint("OTP_DEBUG Error: $e");
      setState(() {
        _isLoading = false;
        _errorText = "Verification failed. Please check the code and try again.";
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Ownership Verified", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Your email ownership has been verified. The change request is now pending administrator approval."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
            Text(_errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
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
                  : const Text("Verify & Submit Request", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : () async {
              try {
                await _controller.sendOtp(widget.newEmail);
                if (mounted) {
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
            child: const Text("Resend Code", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 45,
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
