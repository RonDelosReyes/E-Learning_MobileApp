import 'package:e_learning_app/login_pages/register_form.dart';
import 'package:flutter/material.dart';
import '../services/login/user_login_function.dart';
import '../services/login/login_otp.dart';

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

  InputDecoration _inputStyle(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Color(0xFF33A1E0),
        fontSize: 14,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF90CAF9),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF33A1E0),
          width: 1.5,
        ),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive width for all phones
    final boxWidth = screenWidth * 0.88;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [

          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/cstabackground.png',
              fit: BoxFit.cover,
            ),
          ),

          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    children: [

                      const SizedBox(height: 30),

                      // Logo
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          'assets/cstalogo.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Login Card
                      Center(
                        child: Container(
                          width: boxWidth,
                          padding: const EdgeInsets.only(bottom: 25),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F9FF),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 25,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [

                              // Gradient Header
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF33A1E0),
                                      Color(0xFF1976D2),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 25),

                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                child: Column(
                                  children: [

                                    TextField(
                                      controller: emailController,
                                      decoration: _inputStyle('Email:'),
                                    ),

                                    const SizedBox(height: 18),

                                    TextField(
                                      controller: passwordController,
                                      obscureText: _obscurePassword,
                                      decoration: _inputStyle(
                                        'Password:',
                                        suffix: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                            color: const Color(0xFF33A1E0),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                              !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 30),

                                    SizedBox(
                                      width: double.infinity,
                                      height: 50,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          const Color(0xFF33A1E0),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(16),
                                          ),
                                        ),
                                        onPressed: _isLoading
                                            ? null
                                            : () async {
                                          setState(
                                                  () => _isLoading = true);

                                          await UserLoginController()
                                              .handleLogin(
                                            context: context,
                                            email: emailController.text
                                                .trim(),
                                            password:
                                            passwordController.text,
                                          );

                                          await LoginOtpHandler(
                                            email: emailController.text
                                                .trim(),
                                          ).checkAndTriggerOtp(context);

                                          if (mounted) {
                                            setState(() =>
                                            _isLoading = false);
                                          }
                                        },
                                        child: _isLoading
                                            ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child:
                                          CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                            : const Text(
                                          'Login',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          color: Color(0xFF33A1E0),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (_) =>
                                          const RegistrationModal(),
                                        );
                                      },
                                      child: const Text(
                                        'Don’t have an account? Register here',
                                        style: TextStyle(
                                          color: Color(0xFF757575),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          'School of Information Technology | CSTA',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
