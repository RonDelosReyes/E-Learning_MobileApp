import 'package:e_learning_app/db_connect.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/otp_service_email.dart';
import '../services/login/register_function.dart';
import '../widget/cancel_dialog.dart';
import 'faculty_modal.dart';
import 'student_modal.dart';

class RegistrationModal extends StatefulWidget {
  const RegistrationModal({super.key});

  @override
  RegistrationModalState createState() => RegistrationModalState();
}

class RegistrationModalState extends State<RegistrationModal> {
  String userType = 'student';

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleInitialController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dateCreatedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    dateCreatedController.text =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  InputDecoration styledField(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF33A1E0),
        fontSize: 14,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF33A1E0), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  void showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    final allowedDomains = [
      'gmail.com',
      'yahoo.com',
      'outlook.com',
      'hotmail.com',
      'icloud.com',
      'live.com',
      'aol.com',
    ];

    if (!email.contains('@')) return false;
    final parts = email.split('@');
    if (parts.length != 2) return false;
    return allowedDomains.contains(parts[1].toLowerCase());
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'REGISTER',
                    style: const TextStyle(
                      color: Color(0xFF33A1E0),
                      fontSize: 22,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Type",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF33A1E0),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text("Faculty"),
                      value: 'faculty',
                      groupValue: userType,
                      activeColor: const Color(0xFF33A1E0),
                      onChanged: (value) => setState(() => userType = value!),
                    ),
                    RadioListTile<String>(
                      title: const Text("Student"),
                      value: 'student',
                      groupValue: userType,
                      activeColor: const Color(0xFF33A1E0),
                      onChanged: (value) => setState(() => userType = value!),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Name fields
                TextField(
                  controller: firstNameController,
                  decoration: styledField("First Name"),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: middleInitialController,
                  decoration: styledField("Middle Initial"),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                    LengthLimitingTextInputFormatter(1),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: lastNameController,
                  decoration: styledField("Last Name"),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                  ],
                ),
                const SizedBox(height: 10),

                // Contact Number Field
                TextField(
                  controller: contactNoController,
                  decoration: styledField("Contact Number"),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                ),
                const SizedBox(height: 10),
                // Email Field
                TextField(
                  controller: emailController,
                  decoration: styledField("Email"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: styledField("Password"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: styledField("Confirm Password"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: dateCreatedController,
                  enabled: false,
                  decoration: styledField("Date Created"),
                ),
                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF33A1E0),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          CancelDialog.show(
                            context: context,
                            onConfirm: () => Navigator.pop(context),
                          );
                        },
                        child: const Text(
                          "Back",
                          style: TextStyle(color: Color(0xFF33A1E0)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF33A1E0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          // Validate required fields
                          if (firstNameController.text.isEmpty ||
                              lastNameController.text.isEmpty ||
                              contactNoController.text.isEmpty ||
                              emailController.text.isEmpty ||
                              passwordController.text.isEmpty ||
                              confirmPasswordController.text.isEmpty) {
                            showAlert(
                              "Missing Fields",
                              "Please fill in all required fields.",
                            );
                            return;
                          }

                          if (contactNoController.text.length != 11) {
                            showAlert(
                              "Invalid Contact Number",
                              "Contact Number must be exactly 11 digits.",
                            );
                            return;
                          }

                          if (!_isValidEmail(emailController.text)) {
                            showAlert(
                              "Invalid Email",
                              "Please enter a valid email from a trusted provider.",
                            );
                            return;
                          }

                          if (passwordController.text !=
                              confirmPasswordController.text) {
                            showAlert(
                              "Password Mismatch",
                              "Password and Confirm Password do not match.",
                            );
                            return;
                          }

                          // 🔹 Initialize OTP Service and RegistrationService
                          final otpService = OtpService(
                            supabase: supabase,
                          ); // your OTP handler
                          final service = RegistrationService(
                            otpService: otpService,
                          );

                          // Show the corresponding details modal
                          bool goBack =
                              await showDialog(
                                context: context,
                                builder: (_) {
                                  if (userType == "student") {
                                    return StudentDetailsModal(
                                      firstName: firstNameController.text,
                                      middleInitial:
                                          middleInitialController.text,
                                      lastName: lastNameController.text,
                                      contactNo: contactNoController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      service: service,
                                      onBack: () =>
                                          Navigator.pop(context, true),
                                    );
                                  } else {
                                    return FacultyDetailsModal(
                                      firstName: firstNameController.text,
                                      middleInitial:
                                          middleInitialController.text,
                                      lastName: lastNameController.text,
                                      contactNo: contactNoController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      service: service,
                                      onBack: () =>
                                          Navigator.pop(context, true),
                                    );
                                  }
                                },
                              ) ??
                              false;

                          if (!goBack) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "Register",
                          style: TextStyle(color: Colors.white),
                        ),
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
