// Cores (Dark Teal, Beige), tipografia e temas

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppColors.verdeEscuro,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.verdeEscuro,
      secondary: AppColors.verdeAcao,
      surface: AppColors.fundoBege,
      onSurface: Colors.black87,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColors.fundoBege,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.verdeEscuro,
        foregroundColor: AppColors.fundoBege,
      ),

      cardTheme: const CardThemeData(
        color: AppColors.cardOpcoesFundo,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),

      textTheme: ThemeData.light().textTheme.apply(
        bodyColor: Colors.black87,
        displayColor: AppColors.verdeEscuro,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.verdeEscuro,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.65),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardOpcoesFundo,
        indicatorColor: AppColors.verdeAcao.withValues(alpha: 0.20),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: Colors.black12,
      ),
    );
  }

  static ThemeData get darkTheme {
    final esquema = ColorScheme.fromSeed(
      seedColor: AppColors.verdeDestaque,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.verdeDestaque,
      secondary: AppColors.verdeBase,
      surface: AppColors.superficieEscura,
      onSurface: AppColors.textoClaro,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: esquema,
      scaffoldBackgroundColor: AppColors.fundoEscuro,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.fundoEscuro,
        foregroundColor: AppColors.textoClaro,
      ),

      cardTheme: const CardThemeData(
        color: AppColors.cardEscuro,
        elevation: 2,
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      ),

      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: AppColors.textoClaro,
        displayColor: AppColors.textoClaro,
      ),

      iconTheme: const IconThemeData(
        color: AppColors.verdeDestaque,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.superficieEscura,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.cardEscuro,
        indicatorColor: AppColors.verdeDestaque.withValues(alpha: 0.20),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: AppColors.textoClaro.withValues(alpha: 0.15),
      ),
    );
  }
}
