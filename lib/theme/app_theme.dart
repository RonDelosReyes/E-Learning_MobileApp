import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Light Mode Blues (Vibrant & Obvious Gradient)
  static const primaryLight = Color(0xFF1565C0); // Blue 800
  static const secondaryLight = Color(0xFF42A5F5); // Blue 400
  
  // Dark Mode Blues (Balanced Mid-Tone Blue Gradient)
  static const primaryDark = Color(0xFF1E88E5); // Blue 600
  static const secondaryDark = Color(0xFF42A5F5); // Blue 400

  static const darkBackground = Color(0xFF0F172A);
  static const lightBackground = Color(0xFFF5F6FA);
  static const darkSurface = Color(0xFF1E293B);
  static const lightSurface = Colors.white;
  static const darkText = Colors.white;
  static const darkSubText = Colors.white70;
  static const lightText = Colors.black87;
  static const lightSubText = Colors.black54;

  // Login Exclusive Colors
  static const loginTitleBlue = Color(0xFF0D47A1);
  static const loginTitleDark = Colors.white;
  static const loginLinkBlue = Color(0xFF1976D2);
  static const loginLinkDark = Color(0xFF64B5F6);
  static const loginButtonBlue = Color(0xFF1565C0);

  // Input Fields
  static const lightInputFill = Color(0xFFF9FAFB);
  static const darkInputFill = Color(0xFF334155);
  static const lightInputEnabledBorder = Color(0xFFE5E7EB);
  static const darkInputEnabledBorder = Color(0xFF475569);

  // Action Colors
  static const logoutRed = Color(0xFFE53935);
  static const actionBlue = Color(0xFF1565C0); 
}

class AppGradient extends ThemeExtension<AppGradient> {
  final LinearGradient primary;
  final Color loginTitle;
  final Color loginLink;

  const AppGradient({
    required this.primary,
    required this.loginTitle,
    required this.loginLink,
  });

  @override
  ThemeExtension<AppGradient> copyWith({
    LinearGradient? primary,
    Color? loginTitle,
    Color? loginLink,
  }) {
    return AppGradient(
      primary: primary ?? this.primary,
      loginTitle: loginTitle ?? this.loginTitle,
      loginLink: loginLink ?? this.loginLink,
    );
  }

  @override
  ThemeExtension<AppGradient> lerp(ThemeExtension<AppGradient>? other, double t) {
    if (other is! AppGradient) return this;
    return AppGradient(
      primary: LinearGradient.lerp(primary, other.primary, t)!,
      loginTitle: Color.lerp(loginTitle, other.loginTitle, t)!,
      loginLink: Color.lerp(loginLink, other.loginLink, t)!,
    );
  }
}

class AppTheme {
  static AppGradient get lightGradient => const AppGradient(
        primary: LinearGradient(
          colors: [AppColors.primaryLight, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        loginTitle: AppColors.loginTitleBlue,
        loginLink: AppColors.loginLinkBlue,
      );

  static AppGradient get darkGradient => const AppGradient(
        primary: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.secondaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        loginTitle: AppColors.loginTitleDark,
        loginLink: AppColors.loginLinkDark,
      );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    extensions: [lightGradient],
    scaffoldBackgroundColor: AppColors.lightBackground,
    cardColor: AppColors.lightSurface,
    cardTheme: CardThemeData(
      color: AppColors.lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryLight,
      secondary: AppColors.secondaryLight,
      surface: AppColors.lightSurface,
      onPrimary: Colors.white,
      error: AppColors.logoutRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // For iOS (light icons)
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.loginTitleBlue, fontFamily: 'Poppins'),
      bodyLarge: TextStyle(color: AppColors.lightText, fontFamily: 'Poppins'),
      bodyMedium: TextStyle(color: AppColors.lightText, fontFamily: 'Poppins'),
      bodySmall: TextStyle(color: AppColors.lightSubText, fontFamily: 'Poppins'),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    extensions: [darkGradient],
    scaffoldBackgroundColor: AppColors.darkBackground,
    cardColor: AppColors.darkSurface,
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      secondary: AppColors.secondaryDark,
      surface: AppColors.darkSurface,
      onPrimary: Colors.white,
      error: AppColors.logoutRed,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // For iOS (light icons)
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppColors.loginTitleDark, fontFamily: 'Poppins'),
      bodyLarge: TextStyle(color: AppColors.darkText, fontFamily: 'Poppins'),
      bodyMedium: TextStyle(color: AppColors.darkText, fontFamily: 'Poppins'),
      bodySmall: TextStyle(color: AppColors.darkSubText, fontFamily: 'Poppins'),
    ),
  );

  static Widget tableCell(
      String text,
      ThemeData theme, {
        int flex = 1,
        double? width,
        Color? textColor,
      }) {
    final cellColor =
        textColor ?? theme.textTheme.bodyMedium?.color ?? Colors.black87;

    if (width != null) {
      return SizedBox(
        width: width,
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: cellColor),
          ),
        ),
      );
    } else {
      return Expanded(
        flex: flex,
        child: Center(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(color: cellColor),
          ),
        ),
      );
    }
  }
}
