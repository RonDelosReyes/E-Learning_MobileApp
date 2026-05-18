class EditUserModel {
  final int userId;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String role;

  // Student specific
  final int? studentId;
  final String? studentNum;
  final int? programId;

  EditUserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.role,
    this.studentId,
    this.studentNum,
    this.programId,
  });
}
