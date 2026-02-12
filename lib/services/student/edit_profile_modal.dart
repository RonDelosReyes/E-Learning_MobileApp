import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../user_provider.dart';
import '../../widget/cancel_dialog.dart';

enum ProfileType { student, faculty, admin }

class EditProfileModal {
  static Future<void> show(
      BuildContext context,
      UserProvider user, {
        ProfileType? profileType,
      }) {
    final type = profileType ?? _detectProfileType(user);

    // -------------------- Controllers --------------------
    final firstNameCtrl =
    TextEditingController(text: user.firstName ?? "");
    final middleInitialCtrl =
    TextEditingController(text: user.middleInitial ?? "");
    final lastNameCtrl =
    TextEditingController(text: user.lastName ?? "");
    final emailCtrl =
    TextEditingController(text: user.email ?? "");
    final contactCtrl =
    TextEditingController(text: user.contactNo ?? "");

    final studentNumberCtrl =
    TextEditingController(text: user.studentNumber ?? "");
    final yearLevelCtrl =
    TextEditingController(text: user.yearLevel ?? "");
    final yearOptions = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

    final deptCtrl =
    TextEditingController(text: user.department ?? "");
    final specCtrl =
    TextEditingController(text: user.specialization ?? "");

    bool isLoading = false;

    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (context, setState) {
          void showAlert(String title, String content) {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF33A1E0),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  content,
                  style: const TextStyle(color: Colors.black87),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "OK",
                      style: TextStyle(color: Color(0xFF33A1E0)),
                    ),
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
            return allowedDomains
                .contains(parts[1].toLowerCase());
          }

          final studentNumberFormatter =
          FilteringTextInputFormatter.allow(
            RegExp(r'^\d*-?\d*$'),
          );

          return Padding(
            padding: EdgeInsets.only(
              bottom:
              MediaQuery.of(context).viewInsets.bottom + 20,
              left: 20,
              right: 20,
              top: 25,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _styledInput(
                      "First Name", firstNameCtrl,
                      lettersOnly: true),
                  _styledInput(
                      "Middle Initial", middleInitialCtrl,
                      lettersOnly: true,
                      maxLength: 1),
                  _styledInput(
                      "Last Name", lastNameCtrl,
                      lettersOnly: true),

                  if (type == ProfileType.student) ...[
                    _styledInput(
                      "Student Number",
                      studentNumberCtrl,
                      inputFormatter:
                      studentNumberFormatter,
                    ),
                    _styledDropdown(
                        "Year Level",
                        yearLevelCtrl,
                        yearOptions),
                  ],

                  if (type == ProfileType.faculty) ...[
                    _styledInput("Contact No", contactCtrl,
                        digitsOnly: true, maxLength: 11),
                    _styledInput("Department", deptCtrl),
                    _styledInput(
                        "Specialization", specCtrl),
                  ],

                  _styledInput("Email", emailCtrl),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style:
                          OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF33A1E0),
                                width: 1.5),
                            foregroundColor:
                            const Color(0xFF33A1E0),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  16),
                            ),
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          onPressed: () {
                            CancelDialog.show(
                              context: context,
                              onConfirm: () =>
                                  Navigator.pop(
                                      context),
                            );
                          },
                          child: const Text(
                            "Cancel",
                            style: TextStyle(
                                fontWeight:
                                FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style:
                          ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xFF33A1E0),
                            foregroundColor:
                            Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(
                                  16),
                            ),
                            padding:
                            const EdgeInsets.symmetric(
                                vertical: 14),
                          ),
                          onPressed: isLoading
                              ? null
                              : () async {
                            if (firstNameCtrl
                                .text
                                .isEmpty ||
                                lastNameCtrl
                                    .text
                                    .isEmpty ||
                                emailCtrl
                                    .text
                                    .isEmpty ||
                                (type ==
                                    ProfileType
                                        .faculty &&
                                    contactCtrl
                                        .text
                                        .isEmpty)) {
                              showAlert(
                                  "Missing Fields",
                                  "Please fill in all required fields.");
                              return;
                            }

                            if (type ==
                                ProfileType
                                    .faculty &&
                                contactCtrl
                                    .text
                                    .length !=
                                    11) {
                              showAlert(
                                  "Invalid Contact Number",
                                  "Contact Number must be exactly 11 digits.");
                              return;
                            }

                            if (!isValidEmail(
                                emailCtrl.text)) {
                              showAlert(
                                  "Invalid Email",
                                  "Please enter a valid email from a trusted provider (e.g., gmail.com, yahoo.com).");
                              return;
                            }

                            setState(() =>
                            isLoading = true);

                            await _saveProfile(
                              context,
                              user,
                              type,
                              firstNameCtrl,
                              middleInitialCtrl,
                              lastNameCtrl,
                              emailCtrl,
                              studentNumberCtrl,
                              yearLevelCtrl,
                              contactCtrl,
                              deptCtrl,
                              specCtrl,
                            );

                            if (context.mounted) {
                              setState(() =>
                              isLoading =
                              false);
                            }
                          },
                          child: isLoading
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
                            "Save",
                            style: TextStyle(
                                fontWeight:
                                FontWeight
                                    .w600),
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
        });
      },
    );
  }

  static Widget _styledInput(
      String label,
      TextEditingController ctrl, {
        bool lettersOnly = false,
        bool digitsOnly = false,
        int? maxLength,
        TextInputFormatter? inputFormatter,
      }) {
    List<TextInputFormatter> formatters = [];
    if (lettersOnly) {
      formatters.add(FilteringTextInputFormatter.allow(
          RegExp(r'[a-zA-Z\s]')));
    }
    if (digitsOnly) {
      formatters
          .add(FilteringTextInputFormatter.digitsOnly);
    }
    if (maxLength != null) {
      formatters
          .add(LengthLimitingTextInputFormatter(maxLength));
    }
    if (inputFormatter != null) {
      formatters.add(inputFormatter);
    }

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
          contentPadding:
          const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF90CAF9), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF33A1E0), width: 1.5),
          ),
        ),
      ),
    );
  }

  static Widget _styledDropdown(
      String label,
      TextEditingController ctrl,
      List<String> options,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: DropdownButtonFormField<String>(
        value: ctrl.text.isNotEmpty
            ? ctrl.text
            : null,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF33A1E0),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(
              horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF90CAF9), width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: Color(0xFF33A1E0), width: 1.5),
          ),
        ),
        items: options
            .map((opt) => DropdownMenuItem(
          value: opt,
          child: Text(opt),
        ))
            .toList(),
        onChanged: (val) =>
        ctrl.text = val ?? '',
      ),
    );
  }

  static ProfileType _detectProfileType(
      UserProvider user) {
    if (user.adminId != null) {
      return ProfileType.admin;
    }
    if (user.facultyId != null) {
      return ProfileType.faculty;
    }
    if (user.studentId != null) {
      return ProfileType.student;
    }
    return ProfileType.admin;
  }

  static Future<void> _saveProfile(
      BuildContext context,
      UserProvider user,
      ProfileType type,
      TextEditingController firstNameCtrl,
      TextEditingController middleInitialCtrl,
      TextEditingController lastNameCtrl,
      TextEditingController emailCtrl,
      TextEditingController studentNumberCtrl,
      TextEditingController yearLevelCtrl,
      TextEditingController contactNoCtrl,
      TextEditingController deptCtrl,
      TextEditingController specCtrl,
      ) async {
    try {
      switch (type) {
        case ProfileType.student:
          if (user.studentId != null &&
              user.userId != null) {
            await user.updateStudentProfile(
              context: context,
              studentId: user.studentId!,
              userId: user.userId!,
              firstName:
              firstNameCtrl.text.trim(),
              middleInitial:
              middleInitialCtrl.text.trim(),
              lastName:
              lastNameCtrl.text.trim(),
              email: emailCtrl.text.trim(),
              studentNumber:
              studentNumberCtrl.text.trim(),
              yearLevel:
              yearLevelCtrl.text.trim(),
            );
          }
          break;

        case ProfileType.faculty:
          if (user.facultyId != null) {
            await user.updateFacultyProfile(
              context: context,
              facultyId: user.facultyId,
              firstName:
              firstNameCtrl.text.trim(),
              middleInitial:
              middleInitialCtrl.text.trim(),
              lastName:
              lastNameCtrl.text.trim(),
              email: emailCtrl.text.trim(),
              contactNo:
              contactNoCtrl.text.trim(),
              department:
              deptCtrl.text.trim(),
              specialization:
              specCtrl.text.trim(),
            );
          }
          break;

        case ProfileType.admin:
          user.updateProfile(
              email: emailCtrl.text.trim());
          break;
      }

      if (user.userId != null) {
        await user.fetchUserById(user.userId!);
      }

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
            content: Text(
                "Failed to update profile: $e")),
      );
    }
  }
}
