import 'package:flutter/material.dart';

class LogoutDialog {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onLogout,
  }) async {
    showDialog(
      context: context,
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF5F9FF),
        title: const Text(
          "Logout",
          style: TextStyle(
            color: Color(0xFF33A1E0),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext, rootNavigator: true).pop(),
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF33A1E0)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext, rootNavigator: true).pop();
              onLogout();
            },
            child: const Text(
              "Logout",
              style: TextStyle(color: Color(0xFF33A1E0)),
            ),
          ),
        ],
      ),
    );
  }
}
