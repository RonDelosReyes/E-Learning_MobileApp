import 'package:e_learning_app/db_connect.dart';
import 'package:flutter/material.dart';
import '../services/pages/profile_service.dart';

class UserProvider with ChangeNotifier {
  int? userId;
  String? firstName;
  String? middleInitial;
  String? lastName;
  String? email;
  String? contactNo;
  String? dateCreated;

  // Profile Pic Path
  String profileImagePath = 'assets/profile_pic.png';

  // Admin only
  int? adminId;

  // Faculty only
  int? facultyId;
  String? department;
  String? specialization;

  // Student only
  int? studentId;
  String? studentNumber;
  String? yearLevel;

  String? role;

  final ProfileService _profileService = ProfileService();

  String get fullName {
    final mi = (middleInitial != null && middleInitial!.isNotEmpty)
        ? ' ${middleInitial!}.'
        : '';
    final fName = firstName ?? '';
    final lName = lastName ?? '';
    return '$fName$mi $lName'.trim();
  }

  void setUser(Map<String, dynamic> data) {
    userId = data['user_id'];
    firstName = data['firstName'];
    middleInitial = data['middleInitial'];
    lastName = data['lastName'];
    email = data['email'];
    contactNo = data['contact_no'];
    dateCreated = data['date_created']?.toString();

    role = data['role'] ??
        (data['admin_id'] != null
            ? 'Admin'
            : data['faculty_id'] != null
            ? 'Faculty'
            : data['student_id'] != null
            ? 'Student'
            : null);

    // Admin
    adminId = role == "Admin" ? data['admin_id'] : null;

    // Faculty
    if (role == "Faculty") {
      facultyId = data['faculty_id'];
      department = data['department'];
      specialization = data['specialization'];
    } else {
      facultyId = null;
      department = null;
      specialization = null;
    }

    // Student
    if (role == "Student") {
      studentId = data['student_id'];
      studentNumber = data['studentNumber'];
      yearLevel = data['yearLevel'];
    } else {
      studentId = null;
      studentNumber = null;
      yearLevel = null;
    }

    // Profile Image: Keep current if none from backend
    profileImagePath = data['file_path'] ?? profileImagePath ?? 'assets/profile_pic.png';

    notifyListeners();
  }

  void setProfileImage(String? path) {
    profileImagePath = path ?? profileImagePath;
    notifyListeners();
  }

  void clearUser() {
    userId = null;
    firstName = null;
    middleInitial = null;
    lastName = null;
    email = null;
    contactNo = null;
    dateCreated = null;

    adminId = null;
    facultyId = null;
    specialization = null;
    department = null;

    studentId = null;
    studentNumber = null;
    yearLevel = null;

    role = null;
    profileImagePath = 'assets/profile_pic.png';

    notifyListeners();
  }

  /// Fetch user by ID
  Future<void> fetchUserById(int userId) async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select('''
      user_id,
      firstName,
      middleInitial,
      lastName,
      contact_no,
      email,
      date_created,
      tbl_student!inner(
        student_id,
        student_num,
        year_level
      ),
      tbl_faculty(
        faculty_id,
        department,
        specialization
      ),
      tbl_admin(
        admin_id,
        user_no
      )
    ''')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return;

      final userMap = Map<String, dynamic>.from(response);

      final data = <String, dynamic>{
        'user_id': userMap['user_id'],
        'firstName': userMap['firstName'],
        'middleInitial': userMap['middleInitial'],
        'lastName': userMap['lastName'],
        'contact_no': userMap['contact_no'],
        'email': userMap['email'],
        'date_created': userMap['date_created']?.toString(),
      };

      // STUDENT
      final studentData = userMap['tbl_student'];
      if (studentData != null) {
        Map<String, dynamic> s;
        if (studentData is List && studentData.isNotEmpty) {
          s = Map<String, dynamic>.from(studentData[0]);
        } else if (studentData is Map) {
          s = Map<String, dynamic>.from(studentData);
        } else {
          s = {};
        }
        data.addAll({
          'student_id': s['student_id'],
          'studentNumber': s['student_num'] ?? '',
          'yearLevel': s['year_level'] ?? '',
        });
      }

      // FACULTY
      final facultyData = userMap['tbl_faculty'];
      Map<String, dynamic> f;
      if (facultyData is List && facultyData.isNotEmpty) {
        f = Map<String, dynamic>.from(facultyData[0]);
      } else if (facultyData is Map) {
        f = Map<String, dynamic>.from(facultyData);
      } else {
        f = {};
      }
      data.addAll({
        'faculty_id': f['faculty_id'],
        'department': f['department'] ?? '',
        'specialization': f['specialization'] ?? '',
      });

      // ADMIN
      final adminData = userMap['tbl_admin'];
      if (adminData != null) {
        Map<String, dynamic> a;
        if (adminData is List && adminData.isNotEmpty) {
          a = Map<String, dynamic>.from(adminData[0]);
        } else if (adminData is Map) {
          a = Map<String, dynamic>.from(adminData);
        } else {
          a = {};
        }
        data.addAll({'admin_id': a['admin_id']});
      }

      // PROFILE IMAGE: Keep old if null
      final profileFile = await _profileService.fetchProfileFile(userId: userId);
      data['file_path'] = profileFile?.filePath ?? profileImagePath ?? 'assets/profile_pic.png';

      // Infer role
      data['role'] = data['admin_id'] != null
          ? 'Admin'
          : data['faculty_id'] != null
          ? 'Faculty'
          : data['student_id'] != null
          ? 'Student'
          : null;

      setUser(data);
    } catch (e) {
      debugPrint("Error fetching user by ID: $e");
    }
  }

  /// Update profile image locally (no upload needed)
  void updateProfileImage(String? path) {
    if (path != null) profileImagePath = path;
    notifyListeners();
  }

  // STUDENT & FACULTY UPDATE METHODS
  Future<void> updateStudentProfile({
    required BuildContext context,
    required int studentId,
    required int userId,
    required String firstName,
    required String middleInitial,
    required String lastName,
    required String email,
    required String studentNumber,
    required String yearLevel,
  }) async {
    try {
      await supabase.from('tbl_user').update({
        'firstName': firstName,
        'middleInitial': middleInitial,
        'lastName': lastName,
        'email': email,
      }).eq('user_id', userId);

      await supabase.from('tbl_student').update({
        'student_num': studentNumber,
        'year_level': yearLevel,
      }).eq('student_id', studentId);

      // Fetch user without overwriting profileImagePath
      final oldImage = profileImagePath;
      await fetchUserById(userId);
      profileImagePath = oldImage;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  Future<void> updateFacultyProfile({
    required BuildContext context,
    required int? facultyId,
    required String firstName,
    required String middleInitial,
    required String lastName,
    required String email,
    required String contactNo,
    required String department,
    required String specialization,
  }) async {
    if (facultyId == null || userId == null) return;

    try {
      await supabase.from('tbl_user').update({
        'firstName': firstName,
        'middleInitial': middleInitial,
        'lastName': lastName,
        'email': email,
        'contact_no': contactNo,
      }).eq('user_id', userId!);

      await supabase.from('tbl_faculty').update({
        'department': department,
        'specialization': specialization,
      }).eq('faculty_id', facultyId);

      this.firstName = firstName;
      this.middleInitial = middleInitial;
      this.lastName = lastName;
      this.email = email;
      this.contactNo = contactNo;
      this.department = department;
      this.specialization = specialization;

      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faculty profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  void updateProfile({
    String? email,
    String? contactNo,
    String? department,
    String? specialization,
  }) {
    if (email != null) this.email = email;
    if (contactNo != null) this.contactNo = contactNo;
    if (department != null) this.department = department;
    if (specialization != null) this.specialization = specialization;
    notifyListeners();
  }
}
