import 'package:flutter/material.dart';
import 'package:e_learning_app/login_pages/login_form.dart';
import 'package:e_learning_app/widget/alert_dialog.dart';
import 'package:e_learning_app/widget/logout_dialog.dart';

// Faculty pages
import 'package:e_learning_app/faculty/f_profile_page.dart';
import 'package:e_learning_app/faculty/f_user_management.dart';
import 'package:e_learning_app/faculty/f_dashboard_page.dart';

class FacultyAppDrawer extends StatelessWidget {
  const FacultyAppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final menuItems = _menuItems(context);

    return Drawer(
      backgroundColor: const Color(0xFF33A1E0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCloseButton(context),
            const SizedBox(height: 40),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: menuItems
                      .map((item) => _drawerButton(item))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Close Button --------------------
  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 20),
      child: IconButton(
        icon: const Icon(Icons.close, color: Colors.white, size: 40),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  // -------------------- Drawer Button --------------------
  Widget _drawerButton(DrawerMenuItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            item.title,
            style: TextStyle(
              color: item.isLogout ? Colors.red : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // -------------------- Menu Configuration --------------------
  List<DrawerMenuItem> _menuItems(BuildContext context) {
    return [
      DrawerMenuItem(
        title: 'Home',
        onTap: () => _navigate(context, const FacultyDashBoardPage()),
      ),
      DrawerMenuItem(
        title: 'Courses',
        onTap: () => CustomAlertDialog().show(context),
      ),
      DrawerMenuItem(
        title: 'Tech Library',
        onTap: () => CustomAlertDialog().show(context),
      ),
      DrawerMenuItem(
        title: 'Knowledge Lab',
        onTap: () => CustomAlertDialog().show(context),
      ),
      DrawerMenuItem(
        title: 'User Manager',
        onTap: () => _navigate(context, const FacultyUserManagerPage()),
      ),
      DrawerMenuItem(
        title: 'My Profile',
        onTap: () => _navigate(context, const FacultyProfilePage()),
      ),
      DrawerMenuItem(
        title: 'Log Out',
        isLogout: true,
        onTap: () {
          LogoutDialog.show(
            context: context,
            onLogout: () {
              Navigator.of(context, rootNavigator: true).pushReplacement(
                MaterialPageRoute(builder: (_) => const LogInForm()),
              );
            },
          );
        },
      ),
    ];
  }

  // -------------------- Navigation Helper --------------------
  void _navigate(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }
}

// -------------------- Drawer Menu Model --------------------
class DrawerMenuItem {
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const DrawerMenuItem({
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });
}
