import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../connection/db_connect.dart';
import '../providers/user_provider.dart';
import '../../front_end/login/login_page.dart';
import '../../front_end/student_pages/dashboard/dashboard_page.dart';
import '../../front_end/faculty_pages/dashboard/f_dashboard_page.dart';
import '../../front_end/widgets/login/reset_pass_modal.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  /// Initializes the authentication listener to handle events like password recovery.
  static void initAuthListener(GlobalKey<NavigatorState> navigatorKey) {
    supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        debugPrint("Password recovery event detected.");
        final context = navigatorKey.currentContext;
        if (context != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const ResetPassModal(),
          );
        }
      }
    });
  }

  @override
  State<AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<AppEntry> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    debugPrint("APP_ENTRY: Checking for existing session...");
    
    // Give Supabase a moment to recover the session from disk if needed
    Session? session = supabase.auth.currentSession;
    
    if (session == null) {
      // Small delay to allow session recovery to finish (common on cold starts)
      await Future.delayed(const Duration(milliseconds: 300));
      session = supabase.auth.currentSession;
    }
    
    if (session != null) {
      debugPrint("APP_ENTRY: Session found for user ${session.user.id}. Restoring details...");
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        
        // Fetch user basic data using auth_id (the UUID)
        await userProvider.fetchUserByAuthId(session.user.id);
        
        if (userProvider.userId != null) {
          debugPrint("APP_ENTRY: User details restored successfully: ${userProvider.fullName}");
        } else {
          debugPrint("APP_ENTRY: Session exists but matching record not found in tbl_user.");
          // This might happen if user record was deleted from database manually.
          await supabase.auth.signOut();
        }
      } catch (e) {
        debugPrint("APP_ENTRY: Error auto-logging in: $e");
      }
    } else {
      debugPrint("APP_ENTRY: No persistent session found.");
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.userId != null) {
          debugPrint("APP_ENTRY: Redirecting to ${userProvider.role} Dashboard.");
          if (userProvider.role == 'Faculty') {
            return const FacultyDashBoardPage();
          } else {
            return const DashBoardPage();
          }
        }
        
        debugPrint("APP_ENTRY: Redirecting to Login Form.");
        return const LogInForm();
      },
    );
  }
}
