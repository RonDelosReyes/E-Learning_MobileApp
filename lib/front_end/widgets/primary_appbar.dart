import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const PrimaryAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;
    final gradient = theme.extension<AppGradient>()?.primary;

    return AppBar(
      centerTitle: true,
      elevation: 0,
      backgroundColor: gradient != null ? Colors.transparent : theme.colorScheme.primary,
      flexibleSpace: gradient != null
          ? Container(
              decoration: BoxDecoration(
                gradient: gradient,
              ),
            )
          : null,
      iconTheme: IconThemeData(
        color: onPrimary,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: onPrimary,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
