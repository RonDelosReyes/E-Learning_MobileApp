import 'package:flutter/material.dart';
import 'package:e_learning_app/theme/app_theme.dart';
import 'package:e_learning_app/back_end/services/login/login_service.dart';
import 'package:e_learning_app/back_end/utils/password_strength_guide.dart';
import '../primary_button.dart';

class ForgotPassModal extends StatefulWidget {
  const ForgotPassModal({super.key});

  @override
  State<ForgotPassModal> createState() => _ForgotPassModalState();
}

class _ForgotPassModalState extends State<ForgotPassModal> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentStep = 0; // 0: Email, 1: OTP, 2: New Password
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOTP() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final exists = await _authService.doesEmailExist(email);
      if (!exists) throw "Email not found in our records.";

      await _authService.sendPasswordResetOTP(email);
      
      setState(() {
        _currentStep = 1;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _handleVerifyOTP() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await _authService.verifyResetOTP(email, otp);
      setState(() {
        _currentStep = 2;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _handleResetPassword() async {
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter a new password.")));
      return;
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match.")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.updatePassword(newPassword);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password reset successfully! Please login.")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final scale = (screenWidth / 375.0).clamp(0.85, 1.2);

    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white70 : Colors.black54;

    return Dialog(
      backgroundColor: theme.cardTheme.color ?? theme.cardColor,
      insetPadding: EdgeInsets.symmetric(horizontal: 20 * scale),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28 * scale),
      ),
      elevation: 0,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(28 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentStep > 0 ? () => setState(() => _currentStep--) : null,
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18 * scale,
                      color: _currentStep > 0 ? subTextColor : Colors.transparent,
                    ),
                  ),
                  Text(
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: 18 * scale,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                      color: theme.extension<AppGradient>()?.loginTitle ?? (isDark ? Colors.white : AppColors.loginTitleBlue),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: subTextColor.withAlpha(128), size: 24 * scale),
                  ),
                ],
              ),
              
              SizedBox(height: 24 * scale),

              // Dynamic Icon
              _buildStepIcon(scale, theme.colorScheme.primary),

              SizedBox(height: 24 * scale),
              
              // Dynamic Content
              _buildStepContent(scale, textColor, subTextColor, isDark),

              SizedBox(height: 32 * scale),

              // Submit Button
              PrimaryButton(
                text: _getButtonLabel(),
                isLoading: _isLoading,
                borderRadius: 16 * scale,
                fontSize: 15 * scale,
                onPressed: _getOnPressedAction(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIcon(double scale, Color primaryColor) {
    IconData icon;
    switch (_currentStep) {
      case 0: icon = Icons.email_outlined; break;
      case 1: icon = Icons.mark_email_read_outlined; break;
      case 2: icon = Icons.lock_reset_outlined; break;
      default: icon = Icons.email_outlined;
    }
    return Container(
      padding: EdgeInsets.all(24 * scale),
      decoration: BoxDecoration(
        color: primaryColor.withAlpha(20),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 56 * scale, color: primaryColor),
    );
  }

  Widget _buildStepContent(double scale, Color textColor, Color subTextColor, bool isDark) {
    final theme = Theme.of(context);
    String title;
    String description;
    Widget inputContent;

    if (_currentStep == 0) {
      title = "Reset Password";
      description = "Enter your registered email address to receive a verification code.";
      inputContent = _buildTextField(
        controller: _emailController,
        label: "Email Address",
        icon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        scale: scale,
        isDark: isDark,
        textColor: textColor,
        subTextColor: subTextColor,
      );
    } else if (_currentStep == 1) {
      title = "Verify Code";
      description = "We sent a 6-digit code to ${_emailController.text}";
      inputContent = TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24 * scale,
          fontWeight: FontWeight.bold,
          letterSpacing: 12 * scale,
          color: textColor,
        ),
        decoration: InputDecoration(
          counterText: "",
          hintText: "000000",
          hintStyle: TextStyle(color: subTextColor.withAlpha(80), letterSpacing: 12 * scale),
          filled: true,
          fillColor: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16 * scale),
            borderSide: BorderSide(color: isDark ? AppColors.darkInputEnabledBorder : AppColors.lightInputEnabledBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16 * scale),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
        ),
      );
    } else {
      title = "New Password";
      description = "Create a strong password to secure your account.";
      inputContent = Column(
        children: [
          _buildTextField(
            controller: _newPasswordController,
            label: "New Password",
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            scale: scale,
            isDark: isDark,
            textColor: textColor,
            subTextColor: subTextColor,
            onChanged: (val) => setState(() {}),
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: subTextColor.withAlpha(128),
                size: 20 * scale,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          SizedBox(height: 16 * scale),
          _buildTextField(
            controller: _confirmPasswordController,
            label: "Confirm Password",
            icon: Icons.lock_reset_outlined,
            obscureText: _obscurePassword,
            scale: scale,
            isDark: isDark,
            textColor: textColor,
            subTextColor: subTextColor,
          ),
          SizedBox(height: 20 * scale),
          
          // Strength Guide
          PasswordStrengthGuide(
            password: _newPasswordController.text,
            scale: scale,
            subTextColor: subTextColor,
          ),
        ],
      );
    }

    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22 * scale,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
            color: textColor,
          ),
        ),
        SizedBox(height: 8 * scale),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13 * scale,
            color: subTextColor,
            fontFamily: 'Poppins',
            height: 1.5,
          ),
        ),
        SizedBox(height: 32 * scale),
        inputContent,
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required double scale,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffix,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      style: TextStyle(fontSize: 14 * scale, color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: subTextColor.withAlpha(150),
          fontSize: 14 * scale,
          fontFamily: 'Poppins',
        ),
        prefixIcon: Icon(icon, color: subTextColor.withAlpha(128), size: 20 * scale),
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkInputEnabledBorder : AppColors.lightInputEnabledBorder,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16 * scale),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16 * scale,
          vertical: 18 * scale,
        ),
      ),
    );
  }

  String _getButtonLabel() {
    if (_currentStep == 0) return "SEND CODE";
    if (_currentStep == 1) return "VERIFY CODE";
    return "RESET PASSWORD";
  }

  VoidCallback _getOnPressedAction() {
    if (_currentStep == 0) return _handleSendOTP;
    if (_currentStep == 1) return _handleVerifyOTP;
    return _handleResetPassword;
  }
}
