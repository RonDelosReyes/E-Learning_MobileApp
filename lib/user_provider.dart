import 'package:e_learning_app/db_connect.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int? userId;
  String? firstName;
  String? middleInitial;
  String? lastName;
  String? email;
  String? contactNo;
  String? dateCreated;

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

    // Determine role if not provided
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
      dateCreated = data['date_created']?.toString();
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

    notifyListeners();
  }

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

      debugPrint("🔹 fetchUserById response: $response");

      if (response == null) {
        debugPrint("No user found for ID $userId");
        return;
      }

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
        'date_created': data['date_created'],
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
        data.addAll({
          'admin_id': a['admin_id'],
          'admin_date_created': a['date_created'],
        });
      }

      //Infer role based on available tables
      data['role'] = data['admin_id'] != null
          ? 'Admin'
          : data['faculty_id'] != null
          ? 'Faculty'
          : data['student_id'] != null
          ? 'Student'
          : null;

      setUser(data);
      debugPrint("After setUser - fullName: $fullName, email: $email, studentNumber: $studentNumber");
    } catch (e) {
      debugPrint("Error fetching user by ID: $e");
    }
  }

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
      debugPrint("Updating student profile in DB - studentId: $studentId, userId: $userId");
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

      debugPrint("DB update done. Refetching user...");
      await fetchUserById(userId);

      debugPrint("After fetchUserById - user.firstName: $firstName, user.studentNumber: $studentNumber");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student profile updated successfully')),
      );
    } catch (e) {
      debugPrint("Error updating student profile: $e");
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
    final int? uid = userId;

    if (facultyId == null || uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faculty or User ID not loaded")),
      );
      return;
    }

    try {
      // Update DB
      await supabase.from('tbl_user').update({
        'firstName': firstName,
        'middleInitial': middleInitial,
        'lastName': lastName,
        'email': email,
        'contact_no': contactNo,
      }).eq('user_id', uid);

      await supabase.from('tbl_faculty').update({
        'department': department,
        'specialization': specialization,
      }).eq('faculty_id', facultyId);

      // Update local state
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
      debugPrint('Error updating faculty profile: $e');
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
