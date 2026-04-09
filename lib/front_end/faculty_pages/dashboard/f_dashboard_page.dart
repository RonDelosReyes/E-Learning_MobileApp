import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../back_end/providers/user_provider.dart';
import '../../widgets/hamburgMenu.dart';

class FacultyDashBoardPage extends StatelessWidget {
  const FacultyDashBoardPage({super.key});

  // Exit Dialog Init
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
    final user = Provider.of<UserProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _showExitDialog(context);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1565C0), size: 30),
          title: const Text(
            'FACULTY DASHBOARD',
            style: TextStyle(
              color: Color(0xFF1565C0),
              fontSize: 20,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        drawer: const AppDrawer(currentRoute: 'home'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Color(0xFF64B5F6),
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          'Prof. ${user.lastName ?? "Faculty"}',
                          style: const TextStyle(
                            color: Color(0xFF1565C0),
                            fontSize: 26,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFBBDEFB), width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFE3F2FD),
                      backgroundImage: user.profileImagePath.startsWith('http')
                          ? NetworkImage(user.profileImagePath)
                          : const AssetImage('assets/profile_pic.png') as ImageProvider,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // Quick Statistics
              const Text(
                'QUICK OVERVIEW',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildStatCard('Active Courses', '12', Icons.menu_book, const Color(0xFF1976D2)),
                  const SizedBox(width: 15),
                  _buildStatCard('Total Students', '245', Icons.people, const Color(0xFF42A5F5)),
                ],
              ),

              const SizedBox(height: 35),

              // Recent Activities Section
              const Text(
                'RECENT ACTIVITIES',
                style: TextStyle(
                  color: Color(0xFF1565C0),
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 15),
              _buildActivityItem('Student Registration', '3 new pending requests', '10 mins ago', Icons.person_add),
              _buildActivityItem('Course Update', 'Cloud Computing module updated', '2 hours ago', Icons.update),
              _buildActivityItem('System Alert', 'Database backup completed', 'Yesterday', Icons.check_circle),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 15),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: color.withOpacity(0.7),
                fontSize: 13,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String time, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE3F2FD)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1565C0), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E1E1E),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF757575),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: Color(0xFF9E9E9E),
              fontSize: 11,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
