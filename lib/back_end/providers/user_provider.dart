import 'package:e_learning_app/back_end/connection/db_connect.dart';
import 'package:e_learning_app/back_end/utils/profile_pic_fetcher.dart';
import 'package:e_learning_app/back_end/utils/name_helper.dart';
import 'package:e_learning_app/back_end/utils/hardware_checker.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  int? userId;
  int? studentId;
  String? studentNo;
  String? firstName;
  String? middleName;
  String? lastName;
  String? email;
  int? programId;
  String? programName;
  int? statusNo;
  String? dateCreated;
  bool isFirstTimer = true;
  bool isArSupported = false; // Default to false for safety

  // Profile Pic Path (URL from bucket)
  String profileImagePath = 'assets/profile_pic.png';

  String get middleInitial => StandardNameHelper.getMiddleInitial(middleName);

  String get fullName => StandardNameHelper.formatFullName(firstName, middleName, lastName);

  void setUser(Map<String, dynamic> data) {
    debugPrint("DEBUG: [UserProvider] setUser triggered.");
    
    userId = data['user_id'];
    firstName = data['firstName'];
    middleName = data['middleName'];
    lastName = data['lastName'];
    statusNo = data['status_no'];
    dateCreated = data['date_created']?.toString();
    email = data['email'] ?? email;

    final studentData = data['tbl_student'];
    final student = (studentData is List && studentData.isNotEmpty) 
        ? studentData[0] 
        : (studentData is Map ? studentData : null);

    if (student != null) {
      debugPrint("DEBUG: [UserProvider] Student record found: $student");
      studentId = student['student_id'];
      studentNo = student['student_no'];
      programId = student['program_id'];
      isFirstTimer = student['is_first_timer'] ?? true;
      
      final pData = student['tbl_program'];
      final program = (pData is List && pData.isNotEmpty) 
          ? pData[0] 
          : (pData is Map ? pData : null);

      if (program != null) {
        programName = program['program_name'];
        debugPrint("DEBUG: [UserProvider] Successfully mapped programName: $programName");
      } else {
        programName = null;
      }
    }

    notifyListeners();

    // Pass the userId to the fetcher (as required by tbl_profile)
    if (userId != null) {
      refreshProfileImage();
    }
    
    _checkArSupport();
  }

  Future<void> _checkArSupport() async {
    isArSupported = await HardwareChecker.checkArSupport();
    notifyListeners();
  }

  Future<void> refreshProfileImage() async {
    if (userId == null) {
      debugPrint("DEBUG: [UserProvider] refreshProfileImage called but userId is null.");
      return;
    }
    
    debugPrint("DEBUG: [UserProvider] Refreshing profile image for userId: $userId");
    final url = await ProfilePicFetcher.fetch(userId!);
    debugPrint("DEBUG: [UserProvider] ProfilePicFetcher returned URL: $url");

    if (url != null) {
      profileImagePath = url;
      notifyListeners();
    }
  }

  void updateProfileImage(String? path) {
    if (path != null) {
      profileImagePath = path;
      notifyListeners();
    }
  }

  void clearUser() {
    userId = null;
    studentId = null;
    studentNo = null;
    firstName = null;
    middleName = null;
    lastName = null;
    email = null;
    programId = null;
    programName = null;
    statusNo = null;
    dateCreated = null;
    isFirstTimer = true;
    profileImagePath = 'assets/profile_pic.png';
    notifyListeners();
  }

  Future<void> fetchUserByAuthId(String authId) async {
    try {
      final response = await supabase
          .from('tbl_user')
          .select('''
            *,
            tbl_student!tbl_student_user_id_fkey (
              *,
              tbl_program!tbl_student_program_id_fkey (program_name)
            )
          ''')
          .eq('auth_id', authId)
          .maybeSingle();

      if (response != null) {
        final userData = Map<String, dynamic>.from(response);
        userData['email'] = supabase.auth.currentUser?.email;
        setUser(userData);
      }
    } catch (e) {
      debugPrint("DEBUG: [UserProvider] fetchUserByAuthId ERROR: $e");
    }
  }

  Future<void> updateStudentProfile({
    required BuildContext context,
    required int userId,
    required String firstName,
    required String? middleName,
    required String lastName,
    required String studentNo,
    required int programId,
  }) async {
    try {
      await supabase.from('tbl_user').update({
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
      }).eq('user_id', userId);

      await supabase.from('tbl_student').update({
        'student_no': studentNo,
        'program_id': programId,
      }).eq('user_no', userId);

      await fetchUserByAuthId(supabase.auth.currentUser!.id);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully')));
    } catch (e) {
      debugPrint("Error updating student profile: $e");
    }
  }
}
