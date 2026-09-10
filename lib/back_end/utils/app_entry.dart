import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:e_learning_app/back_end/connection/db_connect.dart';
import 'package:e_learning_app/back_end/providers/user_provider.dart';
import 'package:e_learning_app/front_end/widgets/main_shell.dart';
import 'package:e_learning_app/front_end/widgets/otp_modal.dart';
import 'package:e_learning_app/front_end/login/login_page.dart';
import 'package:e_learning_app/front_end/widgets/student/assessment/baseline_assessment_modal.dart';

class AppEntry extends StatefulWidget {
  const AppEntry({super.key});

  static StreamSubscription<AuthState>? _authSubscription;
  static String? pendingEmailChange;
  static String? requestingAuthId; // Track the original user ID

  static void initAuthListener(GlobalKey<NavigatorState> navigatorKey) {
    _authSubscription?.cancel();
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      debugPrint("AUTH_EVENT: $event");

      if (event == AuthChangeEvent.signedIn && session != null) {
        final context = navigatorKey.currentContext;
        if (context == null) return;

        if (pendingEmailChange != null) {
          final targetEmail = pendingEmailChange!;
          final originalId = requestingAuthId;
          
          pendingEmailChange = null; 

          if (Navigator.of(context).canPop()) {
            Navigator.pop(context);
          }

          Future.delayed(const Duration(milliseconds: 500), () {
             if (navigatorKey.currentContext != null) {
               OtpModal.show(
                 navigatorKey.currentContext!, 
                 targetEmail, 
                 originalAuthId: originalId,
                 isFromLink: true,
               );
             }
          });
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
    Session? session = supabase.auth.currentSession;
    if (session == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      session = supabase.auth.currentSession;
    }
    
    if (session != null) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.fetchUserByAuthId(session.user.id);
        if (userProvider.studentId == null) {
          await supabase.auth.signOut();
        }
      } catch (e) {
        debugPrint("APP_ENTRY: Error auto-logging in: $e");
      }
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.studentId != null) {
          if (userProvider.isFirstTimer) {
            return const BaselineAssessmentModal();
          }
          return const MainShell();
        }
        return const LogInForm();
      },
    );
  }
}
