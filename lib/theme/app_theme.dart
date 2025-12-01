// lib/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppColors {
  // Gradients for light and dark mode
  static const Gradient lightGradient = LinearGradient(
    colors: [Color(0xFF4FC3F7), Color(0xFF81D4FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient darkGradient = LinearGradient(
    colors: [Color.fromARGB(255, 26, 196, 131), Color.fromARGB(255, 61, 225, 195)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData lightTheme({String? fontFamily}) {
    final base = ThemeData.light();
    return base.copyWith(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF6F9FC),
      primaryColor: const Color(0xFF3B82F6),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF3B82F6),
        brightness: Brightness.light,
        primary: const Color(0xFF3B82F6),
        onPrimary: Colors.white,
        background: const Color(0xFFF6F9FC),
        onBackground: Colors.black87,
      ),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      textTheme: (base.textTheme).apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
        fontFamily: fontFamily,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3B82F6),
          foregroundColor: Colors.white,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF3B82F6),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  static ThemeData darkTheme({String? fontFamily}) {
    final base = ThemeData.dark();
    return base.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF111827),
      primaryColor: const Color(0xFF60A5FA),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF60A5FA),
        brightness: Brightness.dark,
        primary: const Color(0xFF60A5FA),
        onPrimary: Colors.black,
        background: const Color(0xFF111827),
        onBackground: Colors.white,
      ),
      cardColor: const Color(0xFF1F2937),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF111827),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      textTheme: (base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
        fontFamily: fontFamily,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF60A5FA),
          foregroundColor: Colors.black,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF111827),
        selectedItemColor: const Color(0xFF60A5FA),
        unselectedItemColor: Colors.grey[400],
      ),
    );
  }
}