import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_learning_app/theme/app_theme.dart';
import 'package:e_learning_app/back_end/controllers/login/login_controller.dart';
import '../widgets/login/register_form.dart';
import '../widgets/login/forgot_pass_modal.dart';
import '../widgets/primary_button.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final LoginController _controller = LoginController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _controller.emailController.text = savedEmail;
        _rememberMe = true;
      });
    }
  }

  Future<void> _saveRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('remembered_email', _controller.emailController.text.trim());
    } else {
      await prefs.remove('remembered_email');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
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
          color: theme.colorScheme.primary,
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
    final themeExt = theme.extension<AppGradient>();
    final gradient = themeExt?.primary;

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
                                color: themeExt?.loginTitle ?? (isDark ? Colors.white : AppColors.loginTitleBlue),
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
                                      color: gradient == null ? theme.colorScheme.primary : null,
                                      gradient: gradient,
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
                                          controller: _controller.emailController,
                                          decoration: _inputStyle(context, 'Email Address', scale),
                                          style: TextStyle(fontSize: 15 * scale, color: isDark ? Colors.white : Colors.black87),
                                          keyboardType: TextInputType.emailAddress,
                                        ),
                                        SizedBox(height: 20 * scale),
                                        TextField(
                                          controller: _controller.passwordController,
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
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                  height: 24 * scale,
                                                  width: 24 * scale,
                                                  child: Checkbox(
                                                    value: _rememberMe,
                                                    activeColor: theme.colorScheme.primary,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4 * scale)),
                                                    onChanged: (val) => setState(() => _rememberMe = val ?? false),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Remember Me',
                                                  style: TextStyle(
                                                    color: theme.textTheme.bodySmall?.color,
                                                    fontSize: 12 * scale,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => const ForgotPassModal(),
                                                );
                                              },
                                              child: Text(
                                                'Forgot Password?',
                                                style: TextStyle(
                                                  color: themeExt?.loginLink ?? (isDark ? AppColors.loginLinkDark : AppColors.loginLinkBlue),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12 * scale,
                                                  fontFamily: 'Poppins',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        SizedBox(height: 32 * scale),
                                        
                                        PrimaryButton(
                                          text: 'LOGIN',
                                          isLoading: _isLoading,
                                          borderRadius: 14 * scale,
                                          fontSize: 16 * scale,
                                          onPressed: () async {
                                            setState(() => _isLoading = true);
                                            await _saveRememberMe();
                                            await _controller.login(context);
                                            if (mounted) setState(() => _isLoading = false);
                                          },
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
                                      color: themeExt?.loginLink ?? (isDark ? AppColors.loginLinkDark : AppColors.loginLinkBlue),
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
