import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_spacing.dart';

/// Crazy Trip - Theme Configuration
/// Material Design 3 Expressive theme with vibrant colors and modern styling
class AppTheme {
  AppTheme._();

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      tertiary: AppColors.tertiaryColor,
      error: AppColors.errorColor,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      surfaceVariant: AppColors.lightSurfaceVariant,
      onPrimary: AppColors.lightOnPrimary,
      onSecondary: AppColors.lightOnSecondary,
      onBackground: AppColors.lightOnBackground,
      onSurface: AppColors.lightOnSurface,
      outline: AppColors.lightOutline,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,

    // Typography
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.lightBackground,
      foregroundColor: AppColors.lightOnBackground,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTextStyles.titleLarge,
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: AppSpacing.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        minimumSize: const Size(64, AppSpacing.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        minimumSize: const Size(64, AppSpacing.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        minimumSize: const Size(64, AppSpacing.minTouchTarget),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: AppSpacing.elevationFAB,
      shape: CircleBorder(),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: AppSpacing.elevationMedium,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.lightOutline,
      selectedLabelStyle: AppTextStyles.labelMedium,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      showUnselectedLabels: true,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xxs,
      ),
      labelStyle: AppTextStyles.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      tertiary: AppColors.tertiaryColor,
      error: AppColors.errorColor,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceVariant: AppColors.darkSurfaceVariant,
      onPrimary: AppColors.darkOnPrimary,
      onSecondary: AppColors.darkOnSecondary,
      onBackground: AppColors.darkOnBackground,
      onSurface: AppColors.darkOnSurface,
      outline: AppColors.darkOutline,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,

    // Typography (same as light)
    textTheme: TextTheme(
      displayLarge: AppTextStyles.displayLarge.copyWith(
        color: AppColors.darkOnBackground,
      ),
      displayMedium: AppTextStyles.displayMedium.copyWith(
        color: AppColors.darkOnBackground,
      ),
      displaySmall: AppTextStyles.displaySmall.copyWith(
        color: AppColors.darkOnBackground,
      ),
      headlineLarge: AppTextStyles.headlineLarge.copyWith(
        color: AppColors.darkOnBackground,
      ),
      headlineMedium: AppTextStyles.headlineMedium.copyWith(
        color: AppColors.darkOnBackground,
      ),
      headlineSmall: AppTextStyles.headlineSmall.copyWith(
        color: AppColors.darkOnBackground,
      ),
      titleLarge: AppTextStyles.titleLarge.copyWith(
        color: AppColors.darkOnBackground,
      ),
      titleMedium: AppTextStyles.titleMedium.copyWith(
        color: AppColors.darkOnBackground,
      ),
      titleSmall: AppTextStyles.titleSmall.copyWith(
        color: AppColors.darkOnBackground,
      ),
      bodyLarge: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.darkOnBackground,
      ),
      bodyMedium: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.darkOnBackground,
      ),
      bodySmall: AppTextStyles.bodySmall.copyWith(
        color: AppColors.darkOnBackground,
      ),
      labelLarge: AppTextStyles.labelLarge.copyWith(
        color: AppColors.darkOnBackground,
      ),
      labelMedium: AppTextStyles.labelMedium.copyWith(
        color: AppColors.darkOnBackground,
      ),
      labelSmall: AppTextStyles.labelSmall.copyWith(
        color: AppColors.darkOnBackground,
      ),
    ),

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: AppColors.darkOnBackground,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTextStyles.titleLarge,
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: AppSpacing.elevationLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      ),
      clipBehavior: Clip.antiAlias,
    ),

    // Elevated Button Theme (same as light)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        minimumSize: const Size(64, AppSpacing.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        minimumSize: const Size(64, AppSpacing.minTouchTarget),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingHorizontal,
          vertical: AppSpacing.buttonPaddingVertical,
        ),
        minimumSize: const Size(64, AppSpacing.minTouchTarget),
        textStyle: AppTextStyles.labelLarge,
      ),
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      elevation: AppSpacing.elevationFAB,
      shape: CircleBorder(),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      elevation: AppSpacing.elevationMedium,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryColor,
      unselectedItemColor: AppColors.darkOutline,
      selectedLabelStyle: AppTextStyles.labelMedium,
      unselectedLabelStyle: AppTextStyles.labelMedium,
      showUnselectedLabels: true,
      backgroundColor: AppColors.darkSurface,
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s,
        vertical: AppSpacing.xxs,
      ),
      labelStyle: AppTextStyles.labelMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
      ),
    ),
  );
}
