import 'package:flutter/material.dart';
import 'package:e_learning_app/theme/app_theme.dart';
import '../../back_end/controllers/login/login_controller.dart';
import '../widgets/login/register_form.dart';
import '../widgets/login/forgot_pass_modal.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputStyle(BuildContext context, String label, double scale, {Widget? suffix}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white60 : Colors.grey[500],
        fontSize: 14 * scale,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: isDark ? AppColors.darkInputFill : AppColors.lightInputFill,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * scale),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkInputEnabledBorder : AppColors.lightInputEnabledBorder,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12 * scale),
        borderSide: BorderSide(
          color: AppColors.loginButtonBlue,
          width: 1.5,
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16 * scale,
        vertical: 18 * scale,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final double scale = (screenWidth / 375.0).clamp(0.85, 1.2);
    final boxWidth = screenWidth * 0.9;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.15 : 0.35,
              child: Image.asset(
                'assets/cstabackground.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24 * scale),
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.06),

                            // Branded Logo
                            Container(
                              padding: EdgeInsets.all(10 * scale),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurface : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                                    blurRadius: 10 * scale,
                                    offset: Offset(0, 4 * scale),
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                'assets/cstalogo.png',
                                width: 85 * scale,
                                height: 85 * scale,
                                fit: BoxFit.contain,
                              ),
                            ),

                            SizedBox(height: 20 * scale),

                            // App Branding
                            Text(
                              'CompTech AR',
                              style: TextStyle(
                                fontSize: 32 * scale,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'Poppins',
                                color: isDark ? Colors.white : AppColors.loginTitleBlue,
                                letterSpacing: -0.5,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            // Login Form Card
                            Container(
                              width: boxWidth,
                              decoration: BoxDecoration(
                                color: theme.cardColor,
                                borderRadius: BorderRadius.circular(24 * scale),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                                    blurRadius: 30 * scale,
                                    offset: Offset(0, 10 * scale),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Form Header
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 20 * scale),
                                    decoration: BoxDecoration(
                                      color: AppColors.loginButtonBlue,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(24 * scale),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'SIGN IN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18 * scale,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Poppins',
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Form Body
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24 * scale,
                                      vertical: 36 * scale,
                                    ),
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: emailController,
                                          decoration: _inputStyle(context, 'Email Address', scale),
                                          style: TextStyle(fontSize: 15 * scale, color: isDark ? Colors.white : Colors.black87),
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        SizedBox(height: 20 * scale),
                                        TextField(
                                          controller: passwordController,
                                          obscureText: _obscurePassword,
                                          style: TextStyle(fontSize: 15 * scale, color: isDark ? Colors.white : Colors.black87),
                                          decoration: _inputStyle(
                                            context,
                                            'Password',
                                            scale,
                                            suffix: IconButton(
                                              icon: Icon(
                                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                                color: isDark ? Colors.white60 : Colors.grey[400],
                                                size: 18 * scale,
                                              ),
                                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                            ),
                                          ),
                                        ),
                                        
                                        SizedBox(height: 12 * scale),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (_) => const ForgotPassModal(),
                                              );
                                            },
                                            child: Text(
                                              'Forgot Password?',
                                              style: TextStyle(
                                                color: isDark ? AppColors.loginLinkDark : AppColors.loginLinkBlue,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13 * scale,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                          ),
                                        ),
                                        
                                        SizedBox(height: 32 * scale),
                                        
                                        SizedBox(
                                          width: double.infinity,
                                          height: 56 * scale,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.loginButtonBlue,
                                              foregroundColor: Colors.white,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(14 * scale),
                                              ),
                                            ),
                                            onPressed: _isLoading
                                                ? null
                                                : () async {
                                                    setState(() => _isLoading = true);
                                                    await UserLoginController().handleLogin(
                                                      context: context,
                                                      email: emailController.text.trim(),
                                                      password: passwordController.text,
                                                    );
                                                    if (mounted) setState(() => _isLoading = false);
                                                  },
                                            child: _isLoading
                                                ? SizedBox(
                                                    height: 24 * scale,
                                                    width: 24 * scale,
                                                    child: CircularProgressIndicator(
                                                      color: Colors.white,
                                                      strokeWidth: 2.5 * scale,
                                                    ),
                                                  )
                                                : Text(
                                                    'LOGIN',
                                                    style: TextStyle(
                                                      fontSize: 16 * scale,
                                                      fontWeight: FontWeight.bold,
                                                      fontFamily: 'Poppins',
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 28 * scale),

                            // Register Section
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontFamily: 'Poppins',
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => const RegistrationModal(),
                                    );
                                  },
                                  child: Text(
                                    'Register Now',
                                    style: TextStyle(
                                      color: isDark ? AppColors.loginLinkDark : AppColors.loginLinkBlue,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Poppins',
                                      fontSize: 14 * scale,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Spacer(),
                            SizedBox(height: 40 * scale),

                            // Footer
                            Padding(
                              padding: EdgeInsets.only(bottom: 25 * scale),
                              child: Text(
                                'CSTA School of Information Technology\nCompTech AR Project © 2024',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color,
                                  fontSize: 11 * scale,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
