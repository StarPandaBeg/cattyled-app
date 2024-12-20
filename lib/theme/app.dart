import 'package:flutter/material.dart';

ThemeData appTheme() {
  return ThemeData(
    scaffoldBackgroundColor: const Color(0xFF1c1a1a),
    fontFamily: "Montserrat",
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff008aff),
      surface: const Color(0xff1f1f1f),
      primary: const Color(0xff008aff),
      secondary: Colors.white,
      error: const Color(0xff800000),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: Color(0xff999999),
        fontSize: 18,
      ),
      bodyMedium: TextStyle(
        color: Color(0xff999999),
        fontSize: 14,
      ),
    ),
    cardTheme: CardTheme(
      color: const Color(0xff1f1f1f),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    iconTheme: const IconThemeData(
      size: 32,
      color: Color(0xff008aff),
    ),
    highlightColor: const Color(0xFF2A2727),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF1c1a1a),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      fillColor: Color.fromARGB(255, 26, 26, 26),
      filled: true,
      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith<Color>(
          (states) {
            if (states.contains(WidgetState.pressed)) {
              return const Color(0xFF0058A4);
            }
            return const Color(0xff008aff);
          },
        ),
        foregroundColor: const WidgetStatePropertyAll(Colors.white),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        ),
      ),
    ),
  );
}
