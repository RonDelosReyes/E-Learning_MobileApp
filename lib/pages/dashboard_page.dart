import 'package:e_learning_app/login_pages/login_form.dart';
import 'package:e_learning_app/pages/techlib_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import '../widget/alert_dialog.dart';
import '../widget/logout_dialog.dart';
import '../widget/student/hamburg_menu_stud.dart';
import 'courses_page.dart';

class DashBoardPage extends StatelessWidget {
  const DashBoardPage({super.key});

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = Provider.of<UserProvider>(context).firstName;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: const Color(0xFF33A1E0),
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
        ),
        drawer: const AppDrawer(),
        body: _buildBody(context, firstName),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String? firstName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  'Welcome back, $firstName!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Continue your learning journey today',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildProgressCard("Basic Computer Parts", 0.45),
          const SizedBox(height: 20),
          _buildActionList(context), // Vertical clickable cards
          const SizedBox(height: 20),
          _buildBottomProgress(),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, double progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF33A1E0).withValues(alpha:0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${(progress * 100).toInt()}%', style: const TextStyle(color: Color(0xFF33A1E0), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: const Color(0xFFE0E0E0), color: const Color(0xFF33A1E0)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionList(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      {
        "title": "Courses",
        "subtitle": "Start learning now",
        "icon": Icons.book,
        "onTap": () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesPage())),
      },
      {
        "title": "Tech Library",
        "subtitle": "Explore resources",
        "icon": Icons.folder,
        "onTap": () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TechLibraryPage())),
      },
      {
        "title": "AR Lab",
        "subtitle": "Interactive experiments",
        "icon": Icons.vrpano,
        "onTap": () => CustomAlertDialog().show(context),
      },
      {
        "title": "Community Hub",
        "subtitle": "Connect with peers",
        "icon": Icons.people,
        "onTap": () => CustomAlertDialog().show(context),
      },
      {
        "title": "Logout",
        "subtitle": "Sign out safely",
        "icon": Icons.logout,
        "onTap": () {
          LogoutDialog.show(
            context: context,
            onLogout: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LogInForm()),
              );
            },
          );
        },
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final action = actions[index];
        return ActionCard(
          title: action["title"] as String,
          subtitle: action["subtitle"] as String,
          icon: action["icon"] as IconData,
          onTap: action["onTap"] as VoidCallback,
        );
      },
    );
  }

  Widget _buildBottomProgress() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Your Progress", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(value: 0.6, minHeight: 8, color: const Color(0xFF33A1E0), backgroundColor: const Color(0xFFE3F2FD)),
          ),
          const SizedBox(height: 8),
          const Text("60%", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black54)),
        ],
      ),
    );
  }
}

// ===== PROFESSIONAL CLICKABLE ACTION CARD =====
class ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      splashColor: Colors.blue.withValues(alpha:0.2),
      child: Card(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: const Color(0xFF33A1E0)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.black54)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}