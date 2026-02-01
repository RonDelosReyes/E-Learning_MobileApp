import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class AdminUserManagerBackend {
  // Filter options
  static final List<Map<String, String>> filterOptions = [
    {'display': 'All', 'value': 'all'},
    {'display': 'Active', 'value': 'active'},
    {'display': 'Inactive', 'value': 'inactive'},
  ];

  // Fetch statuses
  static Future<List<String>> fetchStatusList() async {
    try {
      final res = await supabase.from('tbl_status').select('status');
      return (res as List).map((s) => s['status'].toString()).toList();
    } catch (e) {
      debugPrint('Error fetching statuses: $e');
      return [];
    }
  }

  // Fetch all users
  static Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    // Fetch students with their user info + status
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
        tbl_status!inner(status)
      )
    ''');

    // Fetch faculty with their user info + status
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
        tbl_status!inner(status)
      )
    ''');

    final List<Map<String, dynamic>> allUsers = [];

    // Map students
    for (var s in studentRes) {
      final user = s['tbl_user'];
      allUsers.add({
        'user_id': user['user_id'],
        'full_name': '${user['firstName']} ${user['lastName']}',
        'status': user['tbl_status']['status'],
        'role': 'Student',
      });
    }

    // Map faculty
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

  // Update user status
  static Future<void> updateUserStatus(
      int userId, String newStatus, String role, BuildContext context) async {
    try {
      final statusResponse =
      await supabase.from('tbl_status').select('status_id').eq('status', newStatus).single();

      final newStatusId = statusResponse['status_id'];

      if (role == 'Student' || role == 'Faculty') {
        // All roles update tbl_user.status_no
        await supabase.from('tbl_user').update({'status_no': newStatusId}).eq('user_id', userId);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $newStatus for $role ID: $userId'),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}