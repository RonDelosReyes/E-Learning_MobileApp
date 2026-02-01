import 'package:flutter/material.dart';
import '../services/otp_service_email.dart';
import '../db_connect.dart';

class OtpModal extends StatefulWidget {
  final String email;
  final OtpService otpService;
  final Function(bool)? onVerified;

  const OtpModal({
    super.key,
    required this.email,
    required this.otpService,
    this.onVerified,
  });

  @override
  State<OtpModal> createState() => _OtpModalState();
}

class _OtpModalState extends State<OtpModal> {
  final TextEditingController _otpController = TextEditingController();
  bool _loading = false;
  bool _resending = false;

  InputDecoration styledField(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
        color: Color(0xFF33A1E0), fontSize: 14, fontWeight: FontWeight.w500),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 1)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF33A1E0), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  @override
  void initState() {
    super.initState();
    _sendOtp();
  }

  Future<void> _sendOtp() async {
    setState(() => _resending = true);
    final success = await widget.otpService.sendOtp(widget.email);
    setState(() => _resending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? 'OTP sent to your email. Valid for 1 hour.'
            : 'Failed to send OTP. Try again.'),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    setState(() => _loading = true);
    final otp = _otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter OTP')));
      setState(() => _loading = false);
      return;
    }

    try {
      final success = await widget.otpService.verifyOtp(
        email: widget.email,
        otp: otp,
      );

      if (success) {
        // ✅ Update status_no = 1 using email query (bigint user_id)
        await supabase
            .from('tbl_user')
            .update({'status_no': 1})
            .eq('email', widget.email);

        widget.onVerified?.call(true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('OTP Verified! You can now log in.')),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Invalid OTP')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error verifying OTP: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: const Color(0xFFF5F9FF),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "OTP Verification",
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF33A1E0)),
                ),
                const SizedBox(height: 20),
                Text(
                  "OTP sent to ${widget.email}",
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  decoration: styledField("Enter OTP"),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  icon: _resending
                      ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.refresh, color: Color(0xFF33A1E0)),
                  label: const Text(
                    'Resend OTP',
                    style: TextStyle(color: Color(0xFF33A1E0)),
                  ),
                  onPressed: _resending ? null : _sendOtp,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF33A1E0), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: _loading ? null : () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Color(0xFF33A1E0))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF33A1E0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _loading ? null : _verifyOtp,
                        child: _loading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : const Text("Verify", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),  
        ),
      ),
    );
  }
}
