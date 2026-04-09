import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../back_end/services/login/register_function.dart';
import '../../../back_end/utils/email_validator.dart';
import '../dialog/cancel_dialog.dart';
import '../dialog/register_success_dialog.dart';

class RegistrationModal extends StatefulWidget {
  const RegistrationModal({super.key});

  @override
  RegistrationModalState createState() => RegistrationModalState();
}

class RegistrationModalState extends State<RegistrationModal> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleInitialController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController contactNoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController studentNumController = TextEditingController();
  
  String? selectedYearLevel;
  bool _isLoading = false;

  // Error states for validation
  String? firstNameError;
  String? lastNameError;
  String? studentNumError;
  String? yearLevelError;
  String? contactError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  final List<String> yearLevels = ["1st Year", "2nd Year", "3rd Year", "4th Year"];
  final RegistrationService _registrationService = RegistrationService();

  InputDecoration styledField(String label, {String? errorText}) => InputDecoration(
        labelText: label,
        errorText: errorText,
        labelStyle: const TextStyle(
          color: Color(0xFF1565C0),
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
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );

  void showAlert(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFF1565C0))),
          ),
        ],
      ),
    );
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

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
                // Header
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
                  child: const Center(
                    child: Text(
                      'STUDENT REGISTRATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      TextField(
                        controller: firstNameController,
                        decoration: styledField("First Name", errorText: firstNameError),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: middleInitialController,
                        decoration: styledField("Middle Initial (Optional)"),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                          LengthLimitingTextInputFormatter(1),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: lastNameController,
                        decoration: styledField("Last Name", errorText: lastNameError),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: studentNumController,
                        decoration: styledField("Student Number", errorText: studentNumError),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        value: selectedYearLevel,
                        decoration: styledField("Year Level", errorText: yearLevelError),
                        items: yearLevels.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                        onChanged: (val) => setState(() => selectedYearLevel = val),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: contactNoController,
                        decoration: styledField("Contact Number", errorText: contactError),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: emailController,
                        decoration: styledField("Email Address", errorText: emailError),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: styledField("Password", errorText: passwordError),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: styledField("Confirm Password", errorText: confirmPasswordError),
                      ),
                      const SizedBox(height: 30),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                CancelDialog.show(
                                  context: context,
                                  onConfirm: () => Navigator.pop(context),
                                );
                              },
                              child: const Text("Cancel", style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1565C0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              onPressed: _isLoading ? null : _handleRegistration,
                              child: _isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text("Register", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
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

  Future<void> _handleRegistration() async {
    // Reset error states
    setState(() {
      firstNameError = firstNameController.text.isEmpty ? "Required" : null;
      lastNameError = lastNameController.text.isEmpty ? "Required" : null;
      studentNumError = studentNumController.text.isEmpty ? "Required" : null;
      yearLevelError = selectedYearLevel == null ? "Required" : null;
      contactError = contactNoController.text.isEmpty ? "Required" : null;
      emailError = emailController.text.isEmpty ? "Required" : null;
      passwordError = passwordController.text.isEmpty ? "Required" : null;
      confirmPasswordError = confirmPasswordController.text.isEmpty ? "Required" : null;
    });

    if (firstNameError != null || lastNameError != null || studentNumError != null || 
        yearLevelError != null || contactError != null || emailError != null || 
        passwordError != null || confirmPasswordError != null) {
      return;
    }

    if (!_isValidEmail(emailController.text.trim())) {
      setState(() => emailError = "Enter a valid email address");
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() => confirmPasswordError = "Passwords do not match");
      return;
    }

    if (passwordController.text.length < 6) {
      setState(() => passwordError = "Must be at least 6 characters");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if email is already taken
      bool taken = await EmailValidator.isEmailTaken(emailController.text.trim());
      if (taken) {
        setState(() {
          _isLoading = false;
          emailError = EmailValidator.getTakenEmailError();
        });
        return;
      }

      await _registrationService.registerStudent(
        firstName: firstNameController.text.trim(),
        middleInitial: middleInitialController.text.trim(),
        lastName: lastNameController.text.trim(),
        contactNo: contactNoController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        studentNum: studentNumController.text.trim(),
        yearLevel: selectedYearLevel!,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pop(context); // Close RegistrationModal
        RegisterSuccessDialog.show(context);
      }
    } on AuthException catch (e) {
      setState(() => _isLoading = false);
      showAlert("Registration Failed", e.message);
    } catch (e) {
      setState(() => _isLoading = false);
      showAlert("Registration Failed", "An unexpected error occurred.");
    }
  }
}
