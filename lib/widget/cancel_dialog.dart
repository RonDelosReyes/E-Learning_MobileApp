import 'package:flutter/material.dart';

class CancelDialog {
  static Future<void> show({
    required BuildContext context,
    required VoidCallback onConfirm, // changed to match call
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFF5F9FF),
        title: const Text(
          "Cancel Registration",
          style: TextStyle(
            color: Color(0xFF33A1E0),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Are you sure you want to cancel? Unsaved data will be lost.",
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "No",
              style: TextStyle(color: Color(0xFF33A1E0)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm(); // call the correct callback
            },
            child: const Text(
              "Yes",
              style: TextStyle(color: Color(0xFF33A1E0)),
            ),
          ),
        ],
      ),
    );
  }
}