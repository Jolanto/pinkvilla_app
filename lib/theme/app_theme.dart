import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Poppins-Regular',
    scaffoldBackgroundColor: Colors.black,
    colorSchemeSeed: Colors.pinkAccent,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontFamily: 'Poppins-Bold', fontSize: 32),
      headlineMedium: TextStyle(fontFamily: 'Poppins-Semibold', fontSize: 24),
      bodyLarge: TextStyle(fontFamily: 'Poppins-Regular', fontSize: 16),
      bodyMedium: TextStyle(fontFamily: 'Poppins-Light', fontSize: 14),
    ),
  );
}

