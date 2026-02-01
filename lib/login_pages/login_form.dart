import 'package:e_learning_app/login_pages/register_form.dart';
import 'package:flutter/material.dart';
import '../services/login/login_function.dart';
import '../services/login/login_otp.dart';


class LogInForm extends StatefulWidget {
  const LogInForm({super.key});

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false; // <-- loading state

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned(
            left: -310,
            top: 0,
            width: 1068,
            height: 914,
            child: Image.asset('assets/cstabackground.png', fit: BoxFit.cover),
          ),

          // Logo
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: Container(
                width: 171,
                height: 170,
                decoration: BoxDecoration(
                  image: const DecorationImage(
                    image: AssetImage('assets/cstalogo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // Login White Box
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 270),
              child: Container(
                width: 300,
                height: 400,
                decoration: ShapeDecoration(
                  color: const Color(0xFFF5F9FF),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    // Title
                    Positioned(
                      top: 20,
                      left: 0,
                      right: 0,
                      child: const Text(
                        'Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF33A1E0),
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Email
                    Positioned(
                      top: 80,
                      left: 18,
                      right: 18,
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email:',
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    // Password
                    Positioned(
                      top: 150,
                      left: 18,
                      right: 18,
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password:',
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
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    // Login Button
                    Positioned(
                      top: 235,
                      left: 18,
                      right: 18,
                      child: GestureDetector(
                        onTap: _isLoading ? null : () async {
                          setState(() => _isLoading = true);

                          //Attempt login
                          final success = await LoginController().handleLogin(
                            context: context,
                            email: emailController.text.trim(),
                            password: passwordController.text,
                          );

                          //Trigger OTP modal if status_no == 3
                            await LoginOtpHandler(
                              email: emailController.text.trim(),
                            ).checkAndTriggerOtp(context);

                          if (mounted) setState(() => _isLoading = false);
                        },
                        child: Container(
                          height: 50,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF33A1E0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: _isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              'Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Forgot Password
                    Positioned(
                      top: 300,
                      left: 18,
                      right: 18,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFF33A1E0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // Register Button
                    Positioned(
                      top: 335,
                      left: 18,
                      right: 18,
                      child: TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const RegistrationModal();
                            },
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
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            top: 770,
            left: 18,
            right: 18,
            child: const Text(
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
    );
  }
}
