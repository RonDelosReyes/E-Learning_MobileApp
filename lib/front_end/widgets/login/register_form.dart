import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_learning_app/theme/app_theme.dart';
import '../../../back_end/services/login/register_function.dart';
import '../../../back_end/utils/email_validator.dart';
import '../../../back_end/utils/password_strength_guide.dart';
import '../dialog/alert_dialog.dart';
import '../dialog/cancel_dialog.dart';
import '../dialog/register_success_dialog.dart';
import '../primary_button.dart';

enum VerificationStatus { none, verifying, verified, failed }

class RegistrationModal extends StatefulWidget {
  const RegistrationModal({super.key});

  @override
  RegistrationModalState createState() => RegistrationModalState();
}

class RegistrationModalState extends State<RegistrationModal> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController studentNumController = TextEditingController();
  final TextEditingController programIdController = TextEditingController();
  
  bool _isLoading = false;
  VerificationStatus _verificationStatus = VerificationStatus.none;
  int? _verifiedUserId;

  // Error states for validation
  String? firstNameError;
  String? lastNameError;
  String? studentNumError;
  String? programIdError;
  String? emailError;
  String? passwordError;
  String? confirmPasswordError;

  final RegistrationService _registrationService = RegistrationService();

  Future<void> _verifyStudent() async {
    final studentNo = studentNumController.text.trim();
    if (studentNo.isEmpty) {
      setState(() => studentNumError = "Enter student number");
      return;
    }

    setState(() {
      _verificationStatus = VerificationStatus.verifying;
      studentNumError = null;
    });

    try {
      final data = await _registrationService.verifyStudentNo(studentNo);
      if (data != null) {
        setState(() {
          _verificationStatus = VerificationStatus.verified;
          _verifiedUserId = data['user_id'];
          firstNameController.text = data['firstName'] ?? '';
          middleNameController.text = data['middleName'] ?? '';
          lastNameController.text = data['lastName'] ?? '';
          programIdController.text = data['program_name'] ?? '';
        });
      } else {
        setState(() {
          _verificationStatus = VerificationStatus.failed;
          studentNumError = "Student number not found";
        });
      }
    } catch (e) {
      setState(() {
        _verificationStatus = VerificationStatus.failed;
        studentNumError = e.toString();
      });
    }
  }

  InputDecoration styledField(BuildContext context, String label, {String? errorText, Widget? suffixIcon}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      suffixIcon: suffixIcon,
      labelStyle: TextStyle(
        color: isDark ? Colors.white60 : theme.colorScheme.primary,
        fontSize: 14,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkInputEnabledBorder : AppColors.lightInputEnabledBorder,
          width: 1
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
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
  }

  void showAlert(String title, String content) {
    CustomAlertDialog.show(
      context: context,
      title: title,
      message: content,
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    firstNameController.dispose();
    middleNameController.dispose();
    lastNameController.dispose();
    studentNumController.dispose();
    programIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildVerificationSuffix() {
    switch (_verificationStatus) {
      case VerificationStatus.verifying:
        return const Padding(
          padding: EdgeInsets.all(12.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      case VerificationStatus.verified:
        return const Icon(Icons.check_circle, color: Colors.green);
      case VerificationStatus.failed:
        return const Icon(Icons.cancel, color: Colors.red);
      case VerificationStatus.none:
      default:
        return TextButton(
          onPressed: _verifyStudent,
          child: const Text("Verify", style: TextStyle(fontWeight: FontWeight.bold)),
        );
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final scale = (screenWidth / 375.0).clamp(0.85, 1.2);
    final subTextColor = isDark ? Colors.white70 : Colors.black54;
    final gradient = theme.extension<AppGradient>()?.primary;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: theme.cardColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: theme.scaffoldBackgroundColor,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: gradient == null ? theme.colorScheme.primary : null,
                    gradient: gradient,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                        controller: studentNumController,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        onChanged: (val) {
                          setState(() {
                            _verificationStatus = VerificationStatus.none;
                            _verifiedUserId = null;
                            studentNumError = null; // Clear error when typing
                            
                            // Clear fields except email
                            firstNameController.clear();
                            middleNameController.clear();
                            lastNameController.clear();
                            programIdController.clear();
                            passwordController.clear();
                            confirmPasswordController.clear();
                            
                            // Clear error messages if any
                            firstNameError = null;
                            lastNameError = null;
                            programIdError = null;
                            passwordError = null;
                            confirmPasswordError = null;
                          });
                        },
                        decoration: styledField(
                          context, 
                          "Student Number", 
                          errorText: studentNumError,
                          suffixIcon: _buildVerificationSuffix(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: firstNameController,
                        enabled: false, // Name fields are read-only after verification
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: styledField(context, "First Name", errorText: firstNameError),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: middleNameController,
                        enabled: false,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: styledField(context, "Middle Name (Optional)"),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                        ],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: lastNameController,
                        enabled: false,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: styledField(context, "Last Name", errorText: lastNameError),
                        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))],
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: programIdController,
                        enabled: false,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: styledField(context, "Program", errorText: programIdError),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: emailController,
                        enabled: _verificationStatus == VerificationStatus.verified,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: styledField(context, "Email Address", errorText: emailError),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: passwordController,
                        enabled: _verificationStatus == VerificationStatus.verified,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: styledField(context, "Password", errorText: passwordError),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: confirmPasswordController,
                        enabled: _verificationStatus == VerificationStatus.verified,
                        obscureText: true,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: styledField(context, "Confirm Password", errorText: confirmPasswordError),
                      ),
                      const SizedBox(height: 20),

                      // Password Strength Guide
                      PasswordStrengthGuide(
                        password: passwordController.text,
                        scale: scale,
                        subTextColor: subTextColor,
                      ),

                      const SizedBox(height: 30),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              onPressed: () {
                                CancelDialog.show(
                                  context: context,
                                  onConfirm: () => Navigator.pop(context),
                                );
                              },
                              child: Text("Cancel", style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              text: "Register",
                              isLoading: _isLoading,
                              onPressed: _handleRegistration,
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
    if (_verificationStatus != VerificationStatus.verified || _verifiedUserId == null) {
      setState(() => studentNumError = "Please verify your student number first");
      return;
    }

    // Reset error states
    setState(() {
      emailError = emailController.text.isEmpty ? "Required" : null;
      passwordError = passwordController.text.isEmpty ? "Required" : null;
      confirmPasswordError = confirmPasswordController.text.isEmpty ? "Required" : null;
    });

    if (emailError != null || passwordError != null || confirmPasswordError != null) {
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
        userId: _verifiedUserId!,
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
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
      showAlert("Registration Failed", e.toString());
    }
  }
}
