import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.blue,
      brightness: Brightness.light,
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.blue,
      brightness: Brightness.dark,
      useMaterial3: true,
    );
  }
}