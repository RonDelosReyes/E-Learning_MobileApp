import 'dart:io';
import 'package:e_learning_app/Desktop_App/login_pages/desktop_login_form.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'Desktop_App/pages/admin_dashboard.dart';
import 'login_pages/login_form.dart';


class AppEntry extends StatelessWidget {
  const AppEntry({super.key});

  bool get isMobile {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  bool get isDesktop {
    if (kIsWeb) return false;
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      debugPrint('Running on MOBILE');
      return const LogInForm(); // Mobile entry
    }

    if (isDesktop) {
      debugPrint('Running on DESKTOP');
      return const DesktopLoginForm(); // Desktop entry
      // return const AdminDashBoardDesktopPage();
    }

    // Fallback (Web or unknown)
    return const LogInForm();
  }
}
