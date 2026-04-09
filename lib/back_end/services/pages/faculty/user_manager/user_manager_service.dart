import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase client
final supabase = Supabase.instance.client;

class UserService {
  // Fetch all statuses
  Future<List<String>> fetchStatusList() async {
    final res = await supabase.from('tbl_status').select('status');
    return (res as List).map((s) => s['status'].toString()).toList();
  }

  // Fetch all users (students + faculty_pages)
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    final studentRes = await supabase.from('tbl_student').select('''
      student_id,
      user_no,
      student_num,
      year_level,
      tbl_user!inner(
        user_id,
        "firstName",
        "middleInitial",
        "lastName",
        status_no,
        tbl_status!inner(
          status_id,
          status
        )
      )
    ''');

    final facultyRes = await supabase.from('tbl_faculty').select('''
      faculty_id,
      user_no,
      department,
      specialization,
      tbl_user!inner(
        user_id,
        "firstName",
        "middleInitial",
        "lastName",
        status_no,
        tbl_status!inner(
          status_id,
          status
        )
      )
    ''');

    final List<Map<String, dynamic>> allUsers = [];

    for (var s in studentRes) {
      final user = s['tbl_user'];
      allUsers.add({
        'user_id': user['user_id'],
        'full_name': '${user['firstName']} ${user['lastName']}',
        'status': user['tbl_status']['status'],
        'role': 'Student',
      });
    }

    for (var f in facultyRes) {
      final user = f['tbl_user'];
      allUsers.add({
        'user_id': user['user_id'],
        'full_name': '${user['firstName']} ${user['lastName']}',
        'status': user['tbl_status']['status'],
        'role': 'Faculty',
      });
    }

    return allUsers;
  }

  // Update student status
  Future<void> updateStudentStatus(
      int userId, String newStatus, BuildContext context) async {
    try {
      final statusResponse = await supabase
          .from('tbl_status')
          .select('status_id')
          .eq('status', newStatus)
          .single();

      final newStatusId = statusResponse['status_id'];

      await supabase
          .from('tbl_user')
          .update({'status_no': newStatusId})
          .eq('user_id', userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus successfully.'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("Update Student Status Error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update status. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
