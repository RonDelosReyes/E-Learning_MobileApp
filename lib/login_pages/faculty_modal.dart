import 'package:flutter/material.dart';
import '../services/login/register_function.dart';
import 'otp_modal.dart';
import '../db_connect.dart';
import '../services/otp_service_email.dart';

class FacultyDetailsModal extends StatefulWidget {
  final String firstName;
  final String middleInitial;
  final String lastName;
  final String contactNo;
  final String email;
  final String password;
  final RegistrationService service;
  final VoidCallback onBack;

  const FacultyDetailsModal({
    super.key,
    required this.firstName,
    required this.middleInitial,
    required this.lastName,
    required this.contactNo,
    required this.email,
    required this.password,
    required this.service,
    required this.onBack,
  });

  @override
  State<FacultyDetailsModal> createState() => _FacultyDetailsModalState();
}

class _FacultyDetailsModalState extends State<FacultyDetailsModal> {
  final department = TextEditingController();
  final specialization = TextEditingController();
  bool _isLoading = false;

  InputDecoration styledField(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
        color: Color(0xFF1565C0), fontSize: 14, fontWeight: FontWeight.w500),
    filled: true,
    fillColor: Colors.white,
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 1)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: const Color(0xFFF5F9FF),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== Gradient Header =====
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          'Faculty Details',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins'),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // ===== Department Field =====
                      TextField(
                        controller: department,
                        decoration: styledField("Department"),
                      ),
                      const SizedBox(height: 12),
                      // ===== Specialization Field =====
                      TextField(
                        controller: specialization,
                        decoration: styledField("Specialization"),
                      ),
                      const SizedBox(height: 24),

                      // ===== Action Buttons =====
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF1565C0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                            if (department.text.isEmpty ||
                                specialization.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Please fill all faculty fields'),
                                ),
                              );
                              return;
                            }

                            setState(() => _isLoading = true);

                            final success =
                            await widget.service.registerFaculty(
                              firstName: widget.firstName,
                              middleInitial: widget.middleInitial,
                              lastName: widget.lastName,
                              contactNo: widget.contactNo,
                              email: widget.email,
                              password: widget.password,
                              department: department.text,
                              specialization: specialization.text,
                            );

                            setState(() => _isLoading = false);

                            if (success) {
                              final otpService =
                              OtpService(supabase: supabase);
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => OtpModal(
                                  email: widget.email,
                                  otpService: otpService,
                                  onVerified: (verified) {
                                    if (verified) Navigator.pop(context);
                                  },
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                      Text('Registration failed')));
                            }
                          },
                          child: _isLoading
                              ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                              : const Text(
                            "Register",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // ===== Back Button =====
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF1565C0), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: widget.onBack,
                          child: const Text("Back",
                              style: TextStyle(
                                  color: Color(0xFF1565C0),
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
