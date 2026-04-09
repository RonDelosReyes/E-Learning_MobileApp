class ResetPasswordRequest {
  final String newPassword;
  final String confirmPassword;

  ResetPasswordRequest({
    required this.newPassword,
    required this.confirmPassword,
  });

  bool get passwordsMatch => newPassword == confirmPassword;
  bool get isValid => newPassword.length >= 6 && passwordsMatch;
}
