import 'package:flutter/material.dart';

abstract class AppGradients {
  static const primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF248BFF), Color(0xFF3044F5), Color(0xFF6B3DF5)],
  );

  static const splash = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF07195A), Color(0xFF09237E), Color(0xFF173DD7)],
  );

  static const blueCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF248BFF), Color(0xFF175CFF)],
  );

  static const purpleCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF976BFF), Color(0xFF6B3DF5)],
  );

  static const greenCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF40DC9A), Color(0xFF16B978)],
  );

  static const orangeCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB13B), Color(0xFFFF7A1A)],
  );
}
