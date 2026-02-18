import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/student/hamburgMenu_backend.dart';
import '../../user_provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final backend = AppDrawerBackend(context, currentRoute);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppDrawerBackend.iconDefault),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            const SizedBox(height: 10),

            // Reactive Profile Header
            Consumer<UserProvider>(
              builder: (context, user, child) {
                return GestureDetector(
                  onTap: backend.openProfileOverlay,
                  child: backend.buildProfileHeader(user),
                );
              },
            ),

            const SizedBox(height: 30),

            // Menu items
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: backend.menuItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = backend.menuItems[index];
                  final isSelected = currentRoute == item.route;
                  return backend.buildDrawerItem(item, isSelected);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
