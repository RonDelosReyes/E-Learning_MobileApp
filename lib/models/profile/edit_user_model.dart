class EditUserModel {
  final int userId;
  final String firstName;
  final String lastName;
  final String? middleInitial;
  final String contactNo;
  final String role;

  // Student specific
  final int? studentId;
  final String? studentNum;
  final String? yearLevel;

  // Faculty specific
  final int? facultyId;
  final String? department;
  final String? specialization;

  EditUserModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.middleInitial,
    required this.contactNo,
    required this.role,
    this.studentId,
    this.studentNum,
    this.yearLevel,
    this.facultyId,
    this.department,
    this.specialization,
  });
}
