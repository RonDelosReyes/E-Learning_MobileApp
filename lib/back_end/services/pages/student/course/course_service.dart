import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CoursesService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Fetch progress for a specific student
  Future<List<Map<String, dynamic>>> fetchCourseProgress(int studentId) async {
    try {
      final response = await supabase
          .from('tbl_progress')
          .select('prog_percent, res_no')
          .eq('stud_no', studentId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching progress: $e");
      return [];
    }
  }

  // Get progress value by resource id
  double getProgress(List<Map<String, dynamic>> progressList, int resourceId) {
    final match = progressList.firstWhere(
          (p) => p['res_no'] == resourceId,
      orElse: () => {'prog_percent': 0.0},
    );
    return (match['prog_percent'] ?? 0.0).toDouble();
  }

  bool isCourseUnlocked(
      int currentCourseId, List<Map<String, dynamic>> progressList, List<int> courseOrder) {
    final currentIndex = courseOrder.indexOf(currentCourseId);
    if (currentIndex == 0) return true;

    final prevCourseId = courseOrder[currentIndex - 1];
    final prevProgress = getProgress(progressList, prevCourseId); // still 0-100
    return prevProgress >= 100; // works as expected
  }
}
