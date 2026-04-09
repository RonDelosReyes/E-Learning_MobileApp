import 'package:e_learning_app/back_end/connection/db_connect.dart';
import 'package:e_learning_app/back_end/utils/profile_pic_fetcher.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider with ChangeNotifier {
  int? userId;
  String? firstName;
  String? middleInitial;
  String? lastName;
  String? email;
  String? contactNo;
  String? dateCreated;

  // Profile Pic Path (URL from bucket)
  String profileImagePath = 'assets/profile_pic.png';

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
    email = data['email'] ?? email; // Use existing if not provided
    contactNo = data['contact_no'];
    dateCreated = data['date_created']?.toString();

    // Check Faculty
    final fData = data['tbl_faculty'];
    final faculty = (fData != null && fData is List && fData.isNotEmpty) 
        ? fData[0] 
        : (fData is Map ? fData : null);

    // Check Student
    final sData = data['tbl_student'];
    final student = (sData != null && sData is List && sData.isNotEmpty) 
        ? sData[0] 
        : (sData is Map ? sData : null);

    if (faculty != null) {
      role = 'Faculty';
      facultyId = faculty['faculty_id'];
      department = faculty['department'];
      specialization = faculty['specialization'];
      
      studentId = null;
      studentNumber = null;
      yearLevel = null;
    } else if (student != null) {
      role = 'Student';
      studentId = student['student_id'];
      studentNumber = student['student_num'];
      yearLevel = student['year_level'];
      
      facultyId = null;
      department = null;
      specialization = null;
    } else {
      role = data['role'] ?? role; // Fallback
    }

    // Handle Profile Image from initial data if available
    if (data['file_path'] != null) {
      profileImagePath = data['file_path'];
    }

    notifyListeners();

    // Automatically trigger a profile pic refresh using the fetcher logic
    if (userId != null) {
      refreshProfileImage();
    }
  }

  /// Update profile image and cache it in the provider
  Future<void> refreshProfileImage() async {
    if (userId == null) return;
    
    final url = await ProfilePicFetcher.fetch(userId!);
    if (url != null) {
      profileImagePath = url;
      notifyListeners();
    }
  }

  /// Manually update profile image locally
  void updateProfileImage(String? path) {
    if (path != null) {
      profileImagePath = path;
      notifyListeners();
    }
  }

  void clearUser() {
    userId = null;
    firstName = null;
    middleInitial = null;
    lastName = null;
    email = null;
    contactNo = null;
    dateCreated = null;

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

  /// Fetch user details using auth_id (UUID from Supabase Auth)
  Future<void> fetchUserByAuthId(String authId) async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select('''
            *,
            tbl_student (*),
            tbl_faculty (*),
            tbl_profile (filePath)
          ''')
          .eq('auth_id', authId)
          .maybeSingle();

      if (response != null) {
        final userData = Map<String, dynamic>.from(response);
        // Ensure email is set from current auth user if missing in tbl_user
        userData['email'] ??= supabase.auth.currentUser?.email;
        setUser(userData);
      }
    } catch (e) {
      debugPrint("Error fetching user by Auth ID: $e");
    }
  }

  /// Fetch user by ID and align with tbl_profile and ProfilePictures bucket
  Future<void> fetchUserById(int userId) async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select('''
            *,
            tbl_student (*),
            tbl_faculty (*),
            tbl_profile (filePath)
          ''')
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return;

      final userData = Map<String, dynamic>.from(response);
      
      // Email is usually in auth.users, get it from the current session if possible
      userData['email'] = supabase.auth.currentUser?.email;

      setUser(userData);
    } catch (e) {
      debugPrint("Error fetching user by ID: $e");
    }
  }

  // UPDATES
  Future<void> updateStudentProfile({
    required BuildContext context,
    required int studentId,
    required int userId,
    required String firstName,
    required String middleInitial,
    required String lastName,
    required String studentNumber,
    required String yearLevel,
  }) async {
    try {
      await supabase
          .from('tbl_user')
          .update({
            'firstName': firstName,
            'middleInitial': middleInitial,
            'lastName': lastName,
          })
          .eq('user_id', userId);

      await supabase
          .from('tbl_student')
          .update({
            'student_num': studentNumber, 
            'year_level': yearLevel
          })
          .eq('student_id', studentId);

      await fetchUserById(userId);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student profile updated successfully')),
      );
    } catch (e) {
      debugPrint("Error updating student profile: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile. Please try again later.')),
      );
    }
  }

  Future<void> updateFacultyProfile({
    required BuildContext context,
    required int? facultyId,
    required String firstName,
    required String middleInitial,
    required String lastName,
    required String contactNo,
    required String department,
    required String specialization,
  }) async {
    if (facultyId == null || userId == null) return;

    try {
      await supabase
          .from('tbl_user')
          .update({
            'firstName': firstName,
            'middleInitial': middleInitial,
            'lastName': lastName,
            'contact_no': contactNo,
          })
          .eq('user_id', userId!);

      await supabase
          .from('tbl_faculty')
          .update({
            'department': department, 
            'specialization': specialization
          })
          .eq('faculty_id', facultyId);

      await fetchUserById(userId!);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faculty profile updated successfully')),
      );
    } catch (e) {
      debugPrint("Error updating faculty profile: $e");
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile. Please try again later.')),
      );
    }
  }
}
