import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_text_styles.dart';
import '../utils/scaling.dart';

abstract class AppTheme {
  static const fontFamily = AppTextStyles.fontFamily;

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final textTertiary =
        isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final icon = isDark ? AppColors.darkIcon : AppColors.lightIcon;
    final accent = isDark ? AppColors.brightBlue : AppColors.primary;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: accent,
      secondary: isDark ? AppColors.softPurple : AppColors.purple,
      surface: surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      cardColor: card,
      dividerColor: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(color: textPrimary),
        displayMedium: AppTextStyles.displayMedium.copyWith(color: textPrimary),
        displaySmall: AppTextStyles.displaySmall.copyWith(color: textPrimary),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(color: textPrimary),
        headlineMedium:
            AppTextStyles.headlineMedium.copyWith(color: textPrimary),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(color: textPrimary),
        titleLarge: AppTextStyles.titleLarge.copyWith(color: textPrimary),
        titleMedium: AppTextStyles.titleMedium.copyWith(color: textPrimary),
        titleSmall: AppTextStyles.titleSmall.copyWith(color: textPrimary),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(color: textSecondary),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
        bodySmall: AppTextStyles.bodySmall.copyWith(color: textTertiary),
        labelLarge: AppTextStyles.labelLarge.copyWith(color: textPrimary),
        labelMedium: AppTextStyles.labelMedium.copyWith(color: textSecondary),
        labelSmall: AppTextStyles.labelSmall.copyWith(color: textTertiary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.titleLarge.copyWith(color: textPrimary),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card.r),
          side: BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor:
            isDark ? AppColors.darkSurfaceSecondary : AppColors.lightSurfaceSecondary,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: textTertiary),
        contentPadding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: isDark ? border : Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: Size(double.infinity, 54.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: AppTextStyles.button,
        ),
      ),
      iconTheme: IconThemeData(color: icon, size: 24.r),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: isDark ? 0.20 : 0.10),
        height: 72.h,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => AppTextStyles.bottomNavigation.copyWith(
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w500,
            color:
                states.contains(WidgetState.selected) ? accent : textSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? accent : icon,
            size: states.contains(WidgetState.selected) ? 25.r : 24.r,
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.darkSurfaceSecondary : AppColors.deepNavy,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.bottomSheet.r),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      ),
    );
  }
}
