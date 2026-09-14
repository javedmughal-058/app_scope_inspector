import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppShadows {
  static const lightCard = [
    BoxShadow(
      color: Color(0x0F07195A),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> forBrightness(Brightness brightness) {
    return brightness == Brightness.light ? lightCard : const [];
  }
}
