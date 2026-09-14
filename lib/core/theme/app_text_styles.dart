import 'package:flutter/material.dart';

import '../utils/scaling.dart';

abstract class AppTextStyles {
  static const fontFamily = 'Inter';

  static TextStyle get large => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle get medium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  static TextStyle get small => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static TextStyle get displayLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w800,
    height: 1.20,
  );

  static TextStyle get displayMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w800,
    height: 1.20,
  );

  static TextStyle get displaySmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w800,
    height: 1.25,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    height: 1.30,
  );

  static TextStyle get headlineSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
    height: 1.30,
  );

  static TextStyle get titleLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static TextStyle get titleMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    height: 1.30,
  );

  static TextStyle get titleSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    height: 1.30,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    height: 1.40,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );

  static TextStyle get labelLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    height: 1.20,
  );

  static TextStyle get labelMedium => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    height: 1.20,
  );

  static TextStyle get labelSmall => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.20,
  );

  static TextStyle get tiny => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    height: 1.20,
  );

  static TextStyle get button => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    height: 1.20,
  );

  static TextStyle get bottomNavigation => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get statistic => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  static TextStyle get splash => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w800,
    height: 1.20,
  );
}
