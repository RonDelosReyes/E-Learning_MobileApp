class EmailRequestModel {
  final String authId;
  final String newEmail;

  EmailRequestModel({
    required this.authId,
    required this.newEmail,
  });

  Map<String, dynamic> toJson() {
    return {
      'auth_id': authId,
      'new_email': newEmail,
      'status': 'pending',
    };
  }
}
