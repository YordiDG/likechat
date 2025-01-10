// lib/app/Globales/FontApp/AppThemeProvider.dart

import 'package:flutter/material.dart';
import 'AppTypography.dart';

class AppThemeProvider extends ChangeNotifier {
  final AppTypography _typography = AppTypography();

  ThemeData getTheme({
    required double fontSize,
    required bool isDarkMode,
  }) {
    final textTheme = _typography.getTextTheme(
      fontSize: fontSize,
      isDarkMode: isDarkMode,
    );

    if (isDarkMode) {
      return ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.cyan,
        scaffoldBackgroundColor: Colors.black,
        textTheme: textTheme,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.cyan),
          ),
          labelStyle: TextStyle(color: Colors.grey[300]),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.cyan,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.cyan,
          selectionColor: Colors.cyan.withOpacity(0.3),
          selectionHandleColor: Colors.cyan,
        ),
      );
    } else {
      return ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.cyan,
        scaffoldBackgroundColor: Colors.white,
        textTheme: textTheme,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.cyan),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.cyan,
          textTheme: ButtonTextTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.cyan,
          selectionColor: Colors.cyan.withOpacity(0.3),
          selectionHandleColor: Colors.cyan,
        ),
      );
    }
  }
}