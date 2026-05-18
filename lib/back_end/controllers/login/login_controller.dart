import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_learning_app/back_end/services/login/login_service.dart';
import 'package:e_learning_app/back_end/providers/user_provider.dart';
import 'package:e_learning_app/front_end/student_pages/dashboard/dashboard_page.dart';

class LoginController {
  final AuthService _authService = AuthService();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields.")),
      );
      return;
    }

    final userData = await _authService.login(
      context: context,
      email: email,
      password: password,
    );

    if (userData != null) {
      if (!context.mounted) return;
      
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(userData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashBoardPage()),
      );
    }
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
