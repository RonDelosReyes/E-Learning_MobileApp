import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../admin/a_dashboard_page.dart';
import '../../db_connect.dart';
import '../../faculty/f_dashboard_page.dart';
import '../../login_pages/otp_modal.dart';
import '../../pages/dashboard_page.dart';
import '../../user_provider.dart';
import '../auth_service.dart';
import '../otp_service_email.dart';

class LoginController {
  bool _otpDialogOpen = false; //prevent duplicate OTP dialogs

  Future<void> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    final loginData = await AuthService().login(
      context: context,
      email: email,
      password: password,
    );

    if (loginData == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // ---------- USER EXTRACTION ----------
    final user = loginData['tbl_user'] ?? loginData['user'] ?? loginData;
    if (user == null || (user is Map && user.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not found.")),
      );
      return;
    }

    final int? statusNo = user['status_no'];

    // ---------- STATUS HANDLING ----------
    if (statusNo == 3) {
      if (_otpDialogOpen) return;
      _otpDialogOpen = true;

      final otpService = OtpService(supabase: supabase);

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => OtpModal(
          email: email,
          otpService: otpService,
          onVerified: (verified) async {
            if (!verified) return;

            // Update status ONLY
            await supabase
                .from('tbl_user')
                .update({'status_no': 1})
                .eq('user_id', user['user_id']);

            _otpDialogOpen = false;
          },
        ),
      );

      // After dialog closes, STOP login flow
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account verified. Please login again."),
        ),
      );

      return;
    }


    //INACTIVE
    if (statusNo == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Your account is inactive. Please contact the administrator.",
          ),
        ),
      );
      return;
    }

    //UNKNOWN STATUS
    if (statusNo != 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid account status.")),
      );
      return;
    }

    // ---------- ROLE DETECTION ----------
    final bool isAdmin =
        loginData['tbl_admin'] != null && loginData['tbl_admin'].isNotEmpty;
    final bool isFaculty =
        loginData['tbl_faculty'] != null && loginData['tbl_faculty'].isNotEmpty;
    final bool isStudent =
        loginData['tbl_student'] != null && loginData['tbl_student'].isNotEmpty;

    if (!isAdmin && !isFaculty && !isStudent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No role assigned to this account.")),
      );
      return;
    }

    // ---------- BASE USER DATA ----------
    final Map<String, dynamic> data = {
      "user_id": user["user_id"],
      "firstName": user["firstName"],
      "middleInitial": user["middleInitial"],
      "lastName": user["lastName"],
      "contact_no": user["contact_no"],
      "email": user["email"],
      "date_created": user['date_created'] ?? user['date_joined'],
    };

    // ---------- ADMIN ----------
    if (isAdmin) {
      final a = loginData['tbl_admin'][0];
      data.addAll({
        "role": "Admin",
        "admin_id": a["admin_id"],
      });

      userProvider.setUser(data);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashBoardPage()),
      );
      return;
    }

    // ---------- STUDENT ----------
    if (isStudent) {
      final s = loginData['tbl_student'][0];
      data.addAll({
        "role": "Student",
        "student_id": s["student_id"],
        "studentNumber": s["student_num"],
        "yearLevel": s["year_level"],
      });

      userProvider.setUser(data);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashBoardPage()),
      );
      return;
    }

    // ---------- FACULTY ----------
    if (isFaculty) {
      final f = loginData['tbl_faculty'][0];
      data.addAll({
        "role": "Faculty",
        "faculty_id": f["faculty_id"],
        "department": f["department"],
        "specialization": f["specialization"],
      });

      userProvider.setUser(data);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FacultyDashBoardPage()),
      );
    }
  }
}
