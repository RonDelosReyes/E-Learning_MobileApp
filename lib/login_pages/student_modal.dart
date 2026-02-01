import 'package:flutter/material.dart';
import '../services/login/register_function.dart';
import 'otp_modal.dart';
import '../db_connect.dart';
import '../services/otp_service_email.dart';

class StudentDetailsModal extends StatefulWidget {
  final String firstName;
  final String middleInitial;
  final String lastName;
  final String contactNo;
  final String email;
  final String password;
  final RegistrationService service;
  final VoidCallback onBack;

  const StudentDetailsModal({
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
  State<StudentDetailsModal> createState() => _StudentDetailsModalState();
}

class _StudentDetailsModalState extends State<StudentDetailsModal> {
  final studentNum = TextEditingController();
  String? selectedYearLevel;
  bool _isLoading = false;

  final List<String> yearLevels = ["1st Year", "2nd Year", "3rd Year", "4th Year"];

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
                const Text("Student Details",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF33A1E0))),
                const SizedBox(height: 20),
                TextField(controller: studentNum, decoration: styledField("Student Number")),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedYearLevel,
                  decoration: styledField("Year Level"),
                  items: yearLevels
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (val) => setState(() => selectedYearLevel = val),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF33A1E0), width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: widget.onBack,
                        child: const Text("Back", style: TextStyle(color: Color(0xFF33A1E0))),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF33A1E0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                          if (studentNum.text.isEmpty || selectedYearLevel == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please fill all student fields')));
                            return;
                          }

                          setState(() => _isLoading = true);

                          // ✅ Call the updated registerStudent
                          final success = await widget.service.registerStudent(
                            firstName: widget.firstName,
                            middleInitial: widget.middleInitial,
                            lastName: widget.lastName,
                            contactNo: widget.contactNo,
                            email: widget.email,
                            password: widget.password,
                            studentNum: studentNum.text,
                            yearLevel: selectedYearLevel!,
                          );

                          setState(() => _isLoading = false);

                          if (success) {
                            // Show OTP modal
                            final otpService = OtpService(supabase: supabase);
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
                                const SnackBar(content: Text('Registration failed')));
                          }
                        },
                        child: _isLoading
                            ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                            : const Text("Register", style: TextStyle(color: Colors.white)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
