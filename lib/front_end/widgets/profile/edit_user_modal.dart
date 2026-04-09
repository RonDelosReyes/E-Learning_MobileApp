import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../back_end/providers/user_provider.dart';
import '../../../back_end/utils/empty_text_validator.dart';
import '../../../back_end/controllers/profile/edit_user_controller.dart';
import '../../../models/profile/edit_user_model.dart';
import '../dialog/cancel_dialog.dart';

class EditUserModal {
  static Future<void> show(BuildContext context, UserProvider user) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isFaculty = user.role == 'Faculty';
    final editUserController = EditUserController();

    // -------------------- Controllers --------------------
    final firstNameCtrl = TextEditingController(text: user.firstName ?? "");
    final middleInitialCtrl = TextEditingController(text: user.middleInitial ?? "");
    final lastNameCtrl = TextEditingController(text: user.lastName ?? "");
    final contactCtrl = TextEditingController(text: user.contactNo ?? "");
    
    // Student specific
    final studentNumberCtrl = TextEditingController(text: user.studentNumber ?? "");
    final yearLevelCtrl = TextEditingController(text: user.yearLevel ?? "");
    final yearOptions = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

    // Faculty specific
    final deptCtrl = TextEditingController(text: user.department ?? "");
    final specCtrl = TextEditingController(text: user.specialization ?? "");

    bool isLoading = false;

    // Error states for each field
    String? firstNameError;
    String? lastNameError;
    String? studentNumError;
    String? yearLevelError;
    String? contactError;
    String? deptError;
    String? specError;

    // -------------------- Snapshot for unsaved changes --------------------
    final initialValues = {
      "firstName": firstNameCtrl.text,
      "middleInitial": middleInitialCtrl.text,
      "lastName": lastNameCtrl.text,
      "contact": contactCtrl.text,
      "studentNumber": studentNumberCtrl.text,
      "yearLevel": yearLevelCtrl.text,
      "dept": deptCtrl.text,
      "spec": specCtrl.text,
    };

    bool hasUnsavedChanges() {
      return firstNameCtrl.text != initialValues["firstName"] ||
          middleInitialCtrl.text != initialValues["middleInitial"] ||
          lastNameCtrl.text != initialValues["lastName"] ||
          contactCtrl.text != initialValues["contact"] ||
          studentNumberCtrl.text != initialValues["studentNumber"] ||
          yearLevelCtrl.text != initialValues["yearLevel"] ||
          deptCtrl.text != initialValues["dept"] ||
          specCtrl.text != initialValues["spec"];
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async {
            if (hasUnsavedChanges()) {
              bool discard = false;
              await CancelDialog.show(
                context: context,
                onConfirm: () => discard = true,
              );
              return discard;
            }
            return true;
          },
          child: StatefulBuilder(builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 24,
                right: 24,
                top: 12,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle Bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "Edit Profile",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Poppins',
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    _styledInput(context, "First Name", firstNameCtrl, errorText: firstNameError, lettersOnly: true),
                    _styledInput(context, "Middle Initial", middleInitialCtrl, lettersOnly: true, maxLength: 1),
                    _styledInput(context, "Last Name", lastNameCtrl, errorText: lastNameError, lettersOnly: true),
                    
                    if (!isFaculty) ...[
                      _styledInput(context, "Student Number", studentNumberCtrl, 
                          errorText: studentNumError,
                          inputFormatter: FilteringTextInputFormatter.allow(RegExp(r'^\d*-?\d*$'))),
                      _styledDropdown(context, "Year Level", yearLevelCtrl, yearOptions, errorText: yearLevelError),
                    ],

                    if (isFaculty) ...[
                      _styledInput(context, "Contact No", contactCtrl, errorText: contactError, digitsOnly: true, maxLength: 11),
                      _styledInput(context, "Department", deptCtrl, errorText: deptError),
                      _styledInput(context, "Specialization", specCtrl, errorText: specError),
                    ],
                    
                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: colorScheme.primary, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () {
                              if (hasUnsavedChanges()) {
                                CancelDialog.show(
                                  context: context,
                                  onConfirm: () {
                                    Navigator.pop(context); // Close dialog
                                    Navigator.pop(context); // Close modal
                                  },
                                );
                              } else {
                                Navigator.pop(context);
                              }
                            },
                            child: Text("Cancel", 
                                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: isLoading ? null : () async {
                              // Reset error states
                              setState(() {
                                firstNameError = EmptyTextValidator.validate(firstNameCtrl.text, "First Name");
                                lastNameError = EmptyTextValidator.validate(lastNameCtrl.text, "Last Name");
                                
                                if (!isFaculty) {
                                  studentNumError = EmptyTextValidator.validate(studentNumberCtrl.text, "Student Number");
                                  yearLevelError = EmptyTextValidator.validate(yearLevelCtrl.text, "Year Level");
                                } else {
                                  contactError = EmptyTextValidator.validate(contactCtrl.text, "Contact Number");
                                  deptError = EmptyTextValidator.validate(deptCtrl.text, "Department");
                                  specError = EmptyTextValidator.validate(specCtrl.text, "Specialization");
                                }
                              });

                              // Check if any error exists from empty validator
                              if (firstNameError != null || lastNameError != null ||
                                  (!isFaculty && (studentNumError != null || yearLevelError != null)) ||
                                  (isFaculty && (contactError != null || deptError != null || specError != null))) {
                                return;
                              }

                              // Additional Validations
                              if (isFaculty && contactCtrl.text.length != 11) {
                                setState(() => contactError = "Contact Number must be 11 digits");
                                return;
                              }

                              setState(() => isLoading = true);

                              try {
                                final model = EditUserModel(
                                  userId: user.userId!,
                                  firstName: firstNameCtrl.text.trim(),
                                  middleInitial: middleInitialCtrl.text.trim(),
                                  lastName: lastNameCtrl.text.trim(),
                                  contactNo: contactCtrl.text.trim(),
                                  role: user.role!,
                                  studentId: user.studentId,
                                  studentNum: studentNumberCtrl.text.trim(),
                                  yearLevel: yearLevelCtrl.text.trim(),
                                  facultyId: user.facultyId,
                                  department: deptCtrl.text.trim(),
                                  specialization: specCtrl.text.trim(),
                                );

                                await editUserController.updateProfile(model);
                                await user.fetchUserById(user.userId!); // Refresh provider

                                if (context.mounted) Navigator.pop(context);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text("Error: $e")),
                                  );
                                }
                              } finally {
                                if (context.mounted) setState(() => isLoading = false);
                              }
                            },
                            child: isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Text("Save", style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  static Widget _styledInput(BuildContext context, String label, TextEditingController ctrl,
      {String? errorText, bool lettersOnly = false, bool digitsOnly = false, int? maxLength, TextInputFormatter? inputFormatter}) {
    final theme = Theme.of(context);
    List<TextInputFormatter> formatters = [];
    if (lettersOnly) formatters.add(FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')));
    if (digitsOnly) formatters.add(FilteringTextInputFormatter.digitsOnly);
    if (maxLength != null) formatters.add(LengthLimitingTextInputFormatter(maxLength));
    if (inputFormatter != null) formatters.add(inputFormatter);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        inputFormatters: formatters,
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          labelStyle: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.8), fontSize: 13),
          filled: true,
          fillColor: theme.cardTheme.color?.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
      ),
    );
  }

  static Widget _styledDropdown(BuildContext context, String label, TextEditingController ctrl, List<String> options, {String? errorText}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: ctrl.text.isNotEmpty ? ctrl.text : null,
        style: TextStyle(color: theme.textTheme.bodyMedium?.color),
        dropdownColor: theme.cardTheme.color,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          labelStyle: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.8), fontSize: 13),
          filled: true,
          fillColor: theme.cardTheme.color?.withValues(alpha: 0.5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1.5),
          ),
        ),
        items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
        onChanged: (val) => ctrl.text = val ?? '',
      ),
    );
  }
}
