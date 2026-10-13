// Cores (Dark Teal, Beige), tipografia e temas

import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF0B3740),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF258A60),
      primary: const Color(0xFF258A60),
      surface: const Color(0xFFFBE4AE),
    ),
  );
}