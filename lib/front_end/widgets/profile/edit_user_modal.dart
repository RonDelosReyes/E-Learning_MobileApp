import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_learning_app/back_end/providers/user_provider.dart';
import 'package:e_learning_app/back_end/utils/empty_text_validator.dart';
import 'package:e_learning_app/back_end/controllers/profile/edit_user_controller.dart';
import 'package:e_learning_app/models/profile/edit_user_model.dart';
import 'package:e_learning_app/front_end/widgets/dialog/cancel_dialog.dart';

class EditUserModal {
  static Future<void> show(BuildContext context, UserProvider user) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final editUserController = EditUserController();

    // -------------------- Controllers --------------------
    final firstNameCtrl = TextEditingController(text: user.firstName ?? "");
    final middleNameCtrl = TextEditingController(text: user.middleName ?? "");
    final lastNameCtrl = TextEditingController(text: user.lastName ?? "");
    
    // Student specific
    final studentNumberCtrl = TextEditingController(text: user.studentNo ?? "");
    // Display programName instead of ID
    final programNameCtrl = TextEditingController(text: user.programName ?? "N/A");

    bool isLoading = false;

    // Error states for each field
    String? firstNameError;
    String? lastNameError;
    String? studentNumError;

    // -------------------- Snapshot for unsaved changes --------------------
    final initialValues = {
      "firstName": firstNameCtrl.text,
      "middleName": middleNameCtrl.text,
      "lastName": lastNameCtrl.text,
      "studentNo": studentNumberCtrl.text,
    };

    bool hasUnsavedChanges() {
      return firstNameCtrl.text != initialValues["firstName"] ||
          middleNameCtrl.text != initialValues["middleName"] ||
          lastNameCtrl.text != initialValues["lastName"] ||
          studentNumberCtrl.text != initialValues["studentNo"];
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
                    _styledInput(context, "Middle Name", middleNameCtrl, lettersOnly: true),
                    _styledInput(context, "Last Name", lastNameCtrl, errorText: lastNameError, lettersOnly: true),
                    
                    _styledInput(context, "Student Number", studentNumberCtrl, 
                        errorText: studentNumError,
                        inputFormatter: FilteringTextInputFormatter.allow(RegExp(r'^\d*-?\d*$'))),
                    
                    // Program field: Disabled and displaying the name
                    _styledInput(context, "Program", programNameCtrl, enabled: false),
                    
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
                                studentNumError = EmptyTextValidator.validate(studentNumberCtrl.text, "Student Number");
                              });

                              // Check if any error exists from empty validator
                              if (firstNameError != null || lastNameError != null || studentNumError != null) {
                                return;
                              }

                              setState(() => isLoading = true);

                              try {
                                final model = EditUserModel(
                                  userId: user.userId!,
                                  firstName: firstNameCtrl.text.trim(),
                                  lastName: lastNameCtrl.text.trim(),
                                  middleName: middleNameCtrl.text.trim(),
                                  role: "Student",
                                  studentId: user.studentId,
                                  studentNum: studentNumberCtrl.text.trim(),
                                  programId: user.programId, // Preserve existing program ID
                                );

                                await editUserController.updateProfile(model);
                                
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
      {String? errorText, bool lettersOnly = false, bool digitsOnly = false, int? maxLength, TextInputFormatter? inputFormatter, bool enabled = true}) {
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
        enabled: enabled,
        inputFormatters: formatters,
        style: TextStyle(color: enabled ? theme.textTheme.bodyMedium?.color : theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          labelStyle: TextStyle(color: theme.colorScheme.primary.withValues(alpha: 0.8), fontSize: 13),
          filled: true,
          fillColor: enabled ? theme.cardTheme.color?.withValues(alpha: 0.5) : theme.cardTheme.color?.withValues(alpha: 0.2),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: theme.dividerColor.withValues(alpha: 0.05)),
          ),
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
}
