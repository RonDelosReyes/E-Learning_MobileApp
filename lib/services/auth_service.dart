import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:e_learning_app/db_connect.dart';

class AuthService {
  Future<Map<String, dynamic>?> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return null;
    }

    try {
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();
      final loginData = await supabase
          .from('tbl_user')
          .select('''
            user_id,
            firstName,
            middleInitial,
            lastName,
            contact_no,
            email,
            password_hash,
            status_no,
            date_created,
            tbl_status(status),

            tbl_admin (
              admin_id,
              user_no
            ),

            tbl_faculty (
              faculty_id,
              user_no,
              department,
              specialization
            ),

            tbl_student (
              student_id,
              user_no,
              student_num,
              year_level
            )
          ''')
          .eq('email', email.trim())
          .eq('password_hash', hashedPassword)
          .maybeSingle();

      debugPrint("Supabase login response: $loginData");

      if (loginData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid email or password")),
        );
        return null;
      }

      bool isAdmin = loginData['tbl_admin'] != null &&
          (loginData['tbl_admin'] as List).isNotEmpty;

      bool isFaculty = loginData['tbl_faculty'] != null &&
          (loginData['tbl_faculty'] as List).isNotEmpty;

      bool isStudent = loginData['tbl_student'] != null &&
          (loginData['tbl_student'] as List).isNotEmpty;

      if (isAdmin) {
        loginData['role'] = 'Admin';
      } else if (isFaculty) {
        loginData['role'] = 'Faculty';
      } else if (isStudent) {
        loginData['role'] = 'Student';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("This account has no assigned role.")),
        );
        return null;
      }

      // Return full data including detected role
      return loginData;

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
      return null;
    }
  }
}
