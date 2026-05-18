import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../models/student/course/course_model.dart';

class CoursesService {
  final SupabaseClient supabase = Supabase.instance.client;

  // Fetch all available courses
  Future<List<CourseModel>> fetchAllCourses() async {
    try {
      final response = await supabase
          .from('tbl_course')
          .select('''
            *,
            tbl_admin (
              tbl_user (firstName, lastName)
            )
          ''');
      
      return (response as List).map((json) => CourseModel.fromMap(json)).toList();
    } catch (e) {
      debugPrint("Error fetching courses: $e");
      return [];
    }
  }

  // Fetch details for a specific course including modules and lessons
  Future<CourseModel?> fetchCourseDetails(int courseId) async {
    try {
      final response = await supabase
          .from('tbl_course')
          .select('''
            *,
            tbl_admin (
              tbl_user (firstName, lastName)
            ),
            tbl_course_material (*),
            tbl_module (
              *,
              tbl_module_assessment (*),
              tbl_lesson (
                *,
                tbl_course_material (*)
              )
            )
          ''')
          .eq('course_id', courseId)
          .maybeSingle();

      if (response == null) return null;
      return CourseModel.fromMap(response);
    } catch (e) {
      debugPrint("Error fetching course details: $e");
      return null;
    }
  }

  // Check if a user is enrolled in a course
  Future<bool> isUserEnrolled(int userId, int courseId) async {
    try {
      final response = await supabase
          .from('tbl_user_course_progress')
          .select()
          .eq('user_no', userId)
          .eq('course_no', courseId)
          .maybeSingle();
      return response != null;
    } catch (e) {
      debugPrint("Error checking enrollment: $e");
      return false;
    }
  }

  // Initialize progress records for a course and its modules
  Future<void> initializeCourseProgress(int userId, CourseModel course) async {
    try {
      // 1. Create course progress record
      await supabase.from('tbl_user_course_progress').insert({
        'user_no': userId,
        'course_no': course.id,
        'progress_rate': 0.00,
        'is_completed': false,
      });

      // 2. Create module progress records for each module in the course
      if (course.modules.isNotEmpty) {
        final moduleProgressRecords = course.modules.map((module) => {
          'user_no': userId,
          'course_no': course.id,
          'module_no': module.id,
          'progress_rate': 0.00,
          'is_completed': false,
        }).toList();

        await supabase.from('tbl_user_module_progress').insert(moduleProgressRecords);
      }
    } catch (e) {
      debugPrint("Error initializing course progress: $e");
      throw Exception("Failed to prepare course curriculum.");
    }
  }

  // Fetch progress for a specific student (lessons completed)
  Future<Set<int>> fetchCompletedLessons(int userId) async {
    try {
      final response = await supabase
          .from('tbl_user_lesson_progress')
          .select('lesson_no')
          .eq('user_no', userId)
          .eq('is_completed', true);

      return (response as List).map((item) => item['lesson_no'] as int).toSet();
    } catch (e) {
      debugPrint("Error fetching completed lessons: $e");
      return {};
    }
  }

  // Mark lesson as completed and update module/course progress
  Future<void> markLessonAsCompleted(int userId, int lessonId, int moduleId) async {
    try {
      // 1. Upsert lesson progress
      await supabase.from('tbl_user_lesson_progress').upsert({
        'user_no': userId,
        'lesson_no': lessonId,
        'module_no': moduleId,
        'is_completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      });

      // 2. Get course_id for this module
      final moduleData = await supabase
          .from('tbl_module')
          .select('course_no')
          .eq('module_id', moduleId)
          .single();
      final courseId = moduleData['course_no'] as int;

      // 3. Update Module Progress
      await _updateModuleProgress(userId, moduleId, courseId);

      // 4. Update Course Progress
      await _updateCourseProgress(userId, courseId);

    } catch (e) {
      debugPrint("Error marking lesson as completed: $e");
    }
  }

  Future<void> _updateModuleProgress(int userId, int moduleId, int courseId) async {
    try {
      // 1. Get all lessons in this module
      final allLessons = await supabase
          .from('tbl_lesson')
          .select('lesson_id')
          .eq('module_no', moduleId);
      
      final lessonsList = allLessons as List;
      int totalItems = lessonsList.length;

      // 2. Get completed lessons in this module
      final completedLessons = await supabase
          .from('tbl_user_lesson_progress')
          .select('lesson_no')
          .eq('user_no', userId)
          .eq('module_no', moduleId)
          .eq('is_completed', true);
      
      int completedItems = (completedLessons as List).length;

      // 3. Check for Module Assessment
      final assessmentData = await supabase
          .from('tbl_module_assessment')
          .select('assessment_id')
          .eq('module_no', moduleId)
          .maybeSingle();

      if (assessmentData != null) {
        totalItems += 1; // Assessment counts as an item for completion
        
        // Check if passed
        final attemptData = await supabase
            .from('tbl_module_assessment_attempt')
            .select('is_passed')
            .eq('user_no', userId)
            .eq('assessment_no', assessmentData['assessment_id'])
            .eq('is_passed', true)
            .maybeSingle();
            
        if (attemptData != null) {
          completedItems += 1;
        }
      }

      double rate = totalItems > 0 ? completedItems / totalItems : 0.0;
      bool isCompleted = rate >= 1.0;

      await supabase.from('tbl_user_module_progress').upsert({
        'user_no': userId,
        'module_no': moduleId,
        'course_no': courseId,
        'progress_rate': rate,
        'is_completed': isCompleted,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      }, onConflict: 'user_no, course_no, module_no');

    } catch (e) {
      debugPrint("Error updating module progress: $e");
    }
  }

  /// Refreshes module progress after an assessment is taken
  Future<void> syncModuleAssessmentProgress(int userId, int moduleId) async {
    try {
      final moduleData = await supabase
          .from('tbl_module')
          .select('course_no')
          .eq('module_id', moduleId)
          .single();
      final courseId = moduleData['course_no'] as int;

      await _updateModuleProgress(userId, moduleId, courseId);
      await _updateCourseProgress(userId, courseId);
    } catch (e) {
      debugPrint("Error syncing module assessment progress: $e");
    }
  }

  Future<void> _updateCourseProgress(int userId, int courseId) async {
    try {
      // Get all modules in this course
      final allModules = await supabase
          .from('tbl_module')
          .select('module_id')
          .eq('course_no', courseId);
      
      final totalModules = (allModules as List).length;

      if (totalModules == 0) return;

      // Get all lessons in the entire course
      final allLessonsInCourse = await supabase
          .from('tbl_module')
          .select('tbl_lesson(lesson_id)')
          .eq('course_no', courseId);
      
      int totalLessonsInCourse = 0;
      for (var module in allLessonsInCourse) {
        totalLessonsInCourse += (module['tbl_lesson'] as List).length;
      }

      // Get all completed lessons for this user in this course
      // Join through tbl_lesson to filter by course_no
      final completedLessonsInCourse = await supabase
          .from('tbl_user_lesson_progress')
          .select('lesson_no, tbl_lesson!inner(module_no, tbl_module!inner(course_no))')
          .eq('user_no', userId)
          .eq('is_completed', true)
          .eq('tbl_lesson.tbl_module.course_no', courseId);

      final completedCount = (completedLessonsInCourse as List).length;

      double rate = totalLessonsInCourse > 0 ? completedCount / totalLessonsInCourse : 0.0;
      bool isCompleted = rate >= 1.0;

      await supabase.from('tbl_user_course_progress').upsert({
        'user_no': userId,
        'course_no': courseId,
        'progress_rate': rate,
        'is_completed': isCompleted,
        'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
      }, onConflict: 'user_no, course_no');

    } catch (e) {
      debugPrint("Error updating course progress: $e");
    }
  }

  // Fetch overall course progress
  Future<List<Map<String, dynamic>>> fetchCourseProgress(int userId) async {
    try {
      final response = await supabase
          .from('tbl_user_course_progress')
          .select('progress_rate, course_no')
          .eq('user_no', userId);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint("Error fetching progress: $e");
      return [];
    }
  }

  // Get progress value by course id
  double getProgress(List<Map<String, dynamic>> progressList, int courseId) {
    final match = progressList.firstWhere(
      (p) => p['course_no'] == courseId,
      orElse: () => {'progress_rate': 0.0},
    );
    return (match['progress_rate'] ?? 0.0).toDouble();
  }

  bool isCourseUnlocked(
      int currentCourseId, List<Map<String, dynamic>> progressList, List<int> courseOrder) {
    final currentIndex = courseOrder.indexOf(currentCourseId);
    if (currentIndex <= 0) return true;

    final prevCourseId = courseOrder[currentIndex - 1];
    final prevProgress = getProgress(progressList, prevCourseId);
    return prevProgress >= 1.0;
  }
}
