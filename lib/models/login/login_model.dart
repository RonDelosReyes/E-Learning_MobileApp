class LoginCredentials {
  final String email;
  final String password;

  LoginCredentials({required this.email, required this.password});
}

class UserProfile {
  final int userId;
  final String firstName;
  final String? middleInitial;
  final String lastName;
  final String email;
  final String contactNo;
  final int statusNo;
  final String? role;

  UserProfile({
    required this.userId,
    required this.firstName,
    this.middleInitial,
    required this.lastName,
    required this.email,
    required this.contactNo,
    required this.statusNo,
    this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      firstName: json['firstName'],
      middleInitial: json['middleInitial'],
      lastName: json['lastName'],
      email: json['email'] ?? '',
      contactNo: json['contact_no'],
      statusNo: json['status_no'],
    );
  }
}
