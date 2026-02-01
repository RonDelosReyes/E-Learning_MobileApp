import '../../db_connect.dart';
import '../otp_service_email.dart';

class RegistrationService {
  final OtpService otpService;

  RegistrationService({required this.otpService});

  // Register Student
  Future<bool> registerStudent({
    required String firstName,
    required String middleInitial,
    required String lastName,
    required String contactNo,
    required String email,
    required String password,
    required String studentNum,
    required String yearLevel,
  }) async {
    try {
      // 1️⃣ Insert user into tbl_user (keep bigint user_id)
      final userRes = await supabase.from('tbl_user').insert({
        'firstName': firstName,
        'middleInitial': middleInitial,
        'lastName': lastName,
        'contact_no': contactNo,
        'email': email,
        'password_hash': password,
        'status_no': 3, // pending OTP verification
        'date_created': DateTime.now().toIso8601String(),
      }).select().single();

      final int userId = userRes['user_id'];

      // 2️⃣ Insert student linked to user
      await supabase.from('tbl_student').insert({
        'user_no': userId,
        'student_num': studentNum,
        'year_level': yearLevel,
      });

      // 3️⃣ Send OTP
      return await otpService.sendOtp(email);
    } catch (e) {
      print('Student registration failed: $e');
      return false;
    }
  }

  // Register Faculty
  Future<bool> registerFaculty({
    required String firstName,
    required String middleInitial,
    required String lastName,
    required String contactNo,
    required String email,
    required String password,
    required String department,
    required String specialization,
  }) async {
    try {
      // 1️⃣ Insert user into tbl_user
      final userRes = await supabase.from('tbl_user').insert({
        'firstName': firstName,
        'middleInitial': middleInitial,
        'lastName': lastName,
        'contact_no': contactNo,
        'email': email,
        'password_hash': password,
        'status_no': 3, // pending OTP verification
        'date_created': DateTime.now().toIso8601String(),
      }).select().single();

      final int userId = userRes['user_id'];

      // 2️⃣ Insert faculty linked to user
      await supabase.from('tbl_faculty').insert({
        'user_no': userId,
        'department': department,
        'specialization': specialization,
      });

      // 3️⃣ Send OTP
      return await otpService.sendOtp(email);
    } catch (e) {
      print('Faculty registration failed: $e');
      return false;
    }
  }

  // ✅ Optional: Update status_no after OTP verification
  Future<bool> markUserVerified(String email) async {
    try {
      final userRes = await supabase
          .from('tbl_user')
          .select()
          .eq('email', email)
          .single();

      if (userRes == null) return false;

      final int userId = userRes['user_id'];

      await supabase
          .from('tbl_user')
          .update({'status_no': 1})
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('Failed to mark user verified: $e');
      return false;
    }
  }
}
