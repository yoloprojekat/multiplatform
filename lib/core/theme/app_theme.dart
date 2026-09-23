import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = Typography.material2021().white;
    final textTheme = GoogleFonts.outfitTextTheme(baseTextTheme).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyanAccent,
        secondary: AppColors.neonBlue,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.statusOffline,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
      ),
      textTheme: textTheme,
      cardTheme: CardTheme(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedCornerShape(20),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedCornerShape(24),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.cyanAccent;
          }
          return AppColors.textSecondary;
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.cyanAccent.withOpacity(0.4);
          }
          return AppColors.surfaceElevated;
        }),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.surfaceBorderSubtle),
        ),
        textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      ),
    );
  }
}
