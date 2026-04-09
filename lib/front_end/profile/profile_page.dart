import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../back_end/services/profile/edit_user_service.dart';
import '../widgets/profile/edit_user_modal.dart';
import '../widgets/profile/profile_avatar_uploader.dart';
import '../widgets/profile/request_email_modal.dart';
import '../../back_end/providers/user_provider.dart';
import '../widgets/dialog/logout_dialog.dart';
import '../widgets/modal_appBar.dart';
import '../login/login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isInitialFetch = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialFetch) {
      _isInitialFetch = false;
      final user = context.read<UserProvider>();
      if (user.userId != null) {
        user.refreshProfileImage();
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "N/A";
    try {
      final dt = DateTime.parse(dateStr);
      return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
    } catch (e) {
      if (dateStr.length >= 10) return dateStr.substring(0, 10);
      return dateStr;
    }
  }

  void _showEditOptions(BuildContext context, UserProvider user) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: theme.dividerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              "Profile Options",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 24),
            _buildOptionItem(
              context,
              icon: Icons.person_outline,
              title: "Edit Personal Details",
              subtitle: "Update name, contact, etc.",
              onTap: () {
                Navigator.pop(context);
                EditUserModal.show(context, user);
              },
            ),
            const SizedBox(height: 12),
            _buildOptionItem(
              context,
              icon: Icons.email_outlined,
              title: "Request Email Change",
              subtitle: "Submit request to change your email",
              onTap: () {
                Navigator.pop(context);
                RequestEmailModal.show(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: colorScheme.secondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7))),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.dividerColor),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<UserProvider>(
      builder: (context, user, child) {
        final bool isFaculty = user.role == 'Faculty';
        
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: ModalAppBar(
            title: isFaculty ? 'Faculty Profile' : 'Student Profile',
            useGradient: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // ===== Profile Header Extension =====
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 80, 
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary, 
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ProfileAvatarUploader(
                          userId: user.userId ?? 0,
                          radius: 55,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role?.toUpperCase() ?? (isFaculty ? "FACULTY" : "STUDENT"),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.secondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildInfoGroup(
                        context,
                        "PERSONAL DETAILS",
                        [
                          _InfoItem(Icons.person_outline, "Full Name", user.fullName),
                          _InfoItem(Icons.email_outlined, "Email", user.email ?? "N/A"),
                          _InfoItem(Icons.phone_outlined, "Contact", user.contactNo ?? "N/A"),
                        ],
                      ),

                      const SizedBox(height: 16),

                      _buildInfoGroup(
                        context,
                        isFaculty ? "PROFESSIONAL INFO" : "ACADEMIC INFO",
                        isFaculty
                            ? [
                                _InfoItem(Icons.business_outlined, "Department", user.department ?? "N/A"),
                                _InfoItem(Icons.workspace_premium_outlined, "Specialization", user.specialization ?? "N/A"),
                              ]
                            : [
                                _InfoItem(Icons.badge_outlined, "ID Number", user.studentNumber ?? "N/A"),
                                _InfoItem(Icons.school_outlined, "Year Level", user.yearLevel ?? "N/A"),
                              ],
                      ),

                      const SizedBox(height: 16),

                      _buildInfoGroup(
                        context,
                        "ACCOUNT INFO",
                        [
                          _InfoItem(Icons.calendar_today_outlined, "Date Joined", _formatDate(user.dateCreated)),
                        ],
                      ),

                      const SizedBox(height: 32),

                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              context: context,
                              onPressed: () => _showEditOptions(context, user),
                              icon: Icons.edit_note_rounded,
                              label: "Edit Profile",
                              color: colorScheme.secondary,
                              isPrimary: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              context: context,
                              onPressed: () {
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
                              icon: Icons.logout_rounded,
                              label: "Logout",
                              color: colorScheme.error,
                              isPrimary: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoGroup(BuildContext context, String title, List<_InfoItem> items) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.6),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: theme.dividerColor.withValues(alpha: 0.05)),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (context, index) => Divider(
              height: 1, 
              color: theme.dividerColor.withValues(alpha: 0.05), 
              indent: 56,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: colorScheme.secondary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            item.value,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    required bool isPrimary,
  }) {
    return SizedBox(
      height: 50,
      child: isPrimary
          ? ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18, color: Colors.white),
              label: Text(
                label, 
                style: const TextStyle(
                  fontWeight: FontWeight.w700, 
                  fontSize: 13, 
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18, color: color),
              label: Text(
                label, 
                style: TextStyle(
                  fontWeight: FontWeight.w700, 
                  fontSize: 13, 
                  color: color,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;

  _InfoItem(this.icon, this.label, this.value);
}
