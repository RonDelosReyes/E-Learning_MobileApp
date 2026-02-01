import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../user_provider.dart';
import '../../widget/cancel_dialog.dart';

class EditFacultyModal {
  static Future<void> show(BuildContext context, UserProvider user) async {
    // -------------------- Controllers --------------------
    final firstNameCtrl = TextEditingController(text: user.firstName ?? "");
    final middleInitialCtrl = TextEditingController(text: user.middleInitial ?? "");
    final lastNameCtrl = TextEditingController(text: user.lastName ?? "");
    final emailCtrl = TextEditingController(text: user.email ?? "");
    final contactCtrl = TextEditingController(text: user.contactNo ?? "");
    final deptCtrl = TextEditingController(text: user.department ?? "");
    final specCtrl = TextEditingController(text: user.specialization ?? "");

    bool isLoading = false;

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white, // White background
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return Container(
          color: Colors.white, // Ensure modal background is white
          child: StatefulBuilder(builder: (context, setState) {
            void showAlert(String title, String content) {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Text(title,
                      style: const TextStyle(
                          color: Color(0xFF33A1E0), fontWeight: FontWeight.bold)),
                  content: Text(content, style: const TextStyle(color: Colors.black87)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("OK", style: TextStyle(color: Color(0xFF33A1E0))),
                    )
                  ],
                ),
              );
            }

            bool isValidEmail(String email) {
              final allowedDomains = [
                'gmail.com',
                'yahoo.com',
                'outlook.com',
                'hotmail.com',
                'icloud.com',
                'live.com',
                'aol.com',
              ];
              if (!email.contains('@')) return false;
              final parts = email.split('@');
              if (parts.length != 2) return false;
              return allowedDomains.contains(parts[1].toLowerCase());
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 25,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _styledInput("First Name", firstNameCtrl, lettersOnly: true),
                    _styledInput("Middle Initial", middleInitialCtrl, lettersOnly: true, maxLength: 1),
                    _styledInput("Last Name", lastNameCtrl, lettersOnly: true),
                    _styledInput("Email", emailCtrl),
                    _styledInput("Contact No", contactCtrl, digitsOnly: true, maxLength: 11),
                    _styledInput("Department", deptCtrl),
                    _styledInput("Specialization", specCtrl),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF33A1E0), width: 1.5),
                              foregroundColor: const Color(0xFF33A1E0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              CancelDialog.show(
                                context: context,
                                onConfirm: () => Navigator.pop(context),
                              );
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF33A1E0),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                              if (firstNameCtrl.text.isEmpty ||
                                  lastNameCtrl.text.isEmpty ||
                                  emailCtrl.text.isEmpty ||
                                  contactCtrl.text.isEmpty) {
                                showAlert("Missing Fields", "Please fill in all required fields.");
                                return;
                              }

                              if (contactCtrl.text.length != 11) {
                                showAlert("Invalid Contact Number", "Contact Number must be exactly 11 digits.");
                                return;
                              }

                              if (!isValidEmail(emailCtrl.text)) {
                                showAlert(
                                    "Invalid Email",
                                    "Please enter a valid email from a trusted provider (e.g., gmail.com, yahoo.com).");
                                return;
                              }

                              setState(() => isLoading = true);

                              try {
                                await user.updateFacultyProfile(
                                  context: context,
                                  facultyId: user.facultyId,
                                  firstName: firstNameCtrl.text.trim(),
                                  middleInitial: middleInitialCtrl.text.trim(),
                                  lastName: lastNameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  contactNo: contactCtrl.text.trim(),
                                  department: deptCtrl.text.trim(),
                                  specialization: specCtrl.text.trim(),
                                );

                                if (user.userId != null) {
                                  await user.fetchUserById(user.userId!);
                                }

                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Failed to update profile: $e")),
                                  );
                                }
                              }

                              if (context.mounted) setState(() => isLoading = false);
                            },
                            child: isLoading
                                ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                                : const Text(
                              "Save",
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // -------------------- Styled Input --------------------
  static Widget _styledInput(String label, TextEditingController ctrl,
      {bool lettersOnly = false, bool digitsOnly = false, int? maxLength}) {
    List<TextInputFormatter> formatters = [];
    if (lettersOnly) formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')));
    if (digitsOnly) formatters.add(FilteringTextInputFormatter.digitsOnly);
    if (maxLength != null) formatters.add(LengthLimitingTextInputFormatter(maxLength));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        inputFormatters: formatters,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF33A1E0),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF33A1E0), width: 1.5),
          ),
        ),
      ),
    );
  }
}
