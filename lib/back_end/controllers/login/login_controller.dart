import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../connection/db_connect.dart';
import '../../../front_end/faculty_pages/dashboard/f_dashboard_page.dart';
import '../../../front_end/student_pages/dashboard/dashboard_page.dart';
import '../../providers/user_provider.dart';
import '../../utils/email_validator.dart';
import '../../services/login/login_service.dart';

class UserLoginController {
  Future<void> handleLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    // 1. Authenticate via Supabase Auth and fetch profile
    final userData = await AuthService().login(
      context: context,
      email: email,
      password: password,
    );

    if (userData == null) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // 2. Status Handling
    final int? statusNo = userData['status_no'];

    // status_no 3: Pending Verification (Email not confirmed)
    if (statusNo == 3) {
      await AuthService().signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid login credentials."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // status_no 2: Inactive/Banned
    if (statusNo == 2) {
      await AuthService().signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid login credentials."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (statusNo != 1) {
      await AuthService().signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid login credentials.")),
      );
      return;
    }

    // 3. Role Detection
    final dynamic facultyData = userData['tbl_faculty'];
    final dynamic studentData = userData['tbl_student'];

    final bool isFaculty = facultyData != null &&
        (facultyData is List ? facultyData.isNotEmpty : true);
    final bool isStudent = studentData != null &&
        (studentData is List ? studentData.isNotEmpty : true);

    if (!isFaculty && !isStudent) {
      await AuthService().signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid login credentials.")),
      );
      return;
    }

    // 4. Prepare User Data for Provider
    final Map<String, dynamic> providerData = {
      "user_id": userData["user_id"],
      "firstName": userData["firstName"],
      "middleInitial": userData["middleInitial"],
      "lastName": userData["lastName"],
      "contact_no": userData["contact_no"],
      "email": userData["email"],
      "date_created": userData['date_created'],
      "tbl_faculty": userData['tbl_faculty'],
      "tbl_student": userData['tbl_student'],
      "tbl_profile": userData['tbl_profile'],
    };

    // 5. Navigate based on Role
    if (isStudent) {
      final s = studentData is List ? studentData[0] : studentData;
      providerData.addAll({
        "role": "Student",
        "student_id": s["student_id"],
        "studentNumber": s["student_num"],
        "yearLevel": s["year_level"],
      });

      userProvider.setUser(providerData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashBoardPage()),
      );
    } else if (isFaculty) {
      final f = facultyData is List ? facultyData[0] : facultyData;
      providerData.addAll({
        "role": "Faculty",
        "faculty_id": f["faculty_id"],
        "department": f["department"],
        "specialization": f["specialization"],
      });

      userProvider.setUser(providerData);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FacultyDashBoardPage()),
      );
    }
  }

  /// Handles the process of updating the user's email.
  Future<void> handleEmailUpdate(BuildContext context, String newEmail) async {
    final email = newEmail.trim();

    // 1. Validate Format
    if (!EmailValidator.isValidFormat(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address.")),
      );
      return;
    }

    // 2. Check if Taken
    bool isTaken = await EmailValidator.isEmailTaken(email);
    if (isTaken) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(EmailValidator.getTakenEmailError())),
      );
      return;
    }

    try {
      // 3. Call Service
      await AuthService().updateUserEmail(email);

      if (!context.mounted) return;
      
      // 4. Show Success Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Email Update Requested", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          content: const Text(
            "A confirmation link has been sent to your new email address. "
            "Please confirm it to complete the change. Note: Depending on your settings, "
            "you may also need to confirm a link sent to your old email address."
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update email. Please try again later.")),
      );
    }
  }
}
