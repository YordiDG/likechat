import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static final AppTypography _instance = AppTypography._internal();

  factory AppTypography() {
    return _instance;
  }

  AppTypography._internal();

  // Configuración de pesos de fuente
  static const FontWeight light = FontWeight.w100;
  static const FontWeight regular = FontWeight.w200;
  static const FontWeight medium = FontWeight.w400;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  // Método para obtener el TextTheme base
  TextTheme getTextTheme({
    required double fontSize,
    required bool isDarkMode,
  }) {
    final baseColor = isDarkMode ? Colors.white : Colors.black;
    final secondaryColor = isDarkMode ? Colors.grey[300] : Colors.grey[700];

    return TextTheme(
      // Títulos grandes
      displayLarge: GoogleFonts.acme(
        fontSize: fontSize + 24,
        fontWeight: light, // Cambiado a light para un peso más delgado
        color: baseColor,
        letterSpacing: -0.5,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.acme(
        fontSize: fontSize + 20,
        fontWeight: light, // Cambiado a light
        color: baseColor,
        letterSpacing: -0.5,
      ),
      displaySmall: GoogleFonts.acme(
        fontSize: fontSize + 16,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),

      // Encabezados
      headlineLarge: GoogleFonts.acme(
        fontSize: fontSize + 12,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),
      headlineMedium: GoogleFonts.acme(
        fontSize: fontSize + 8,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),
      headlineSmall: GoogleFonts.acme(
        fontSize: fontSize + 4,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),

      // Títulos
      titleLarge: GoogleFonts.acme(
        fontSize: fontSize + 4,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),
      titleMedium: GoogleFonts.acme(
        fontSize: fontSize + 2,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),
      titleSmall: GoogleFonts.acme(
        fontSize: fontSize,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),

      // Cuerpo de texto
      bodyLarge: GoogleFonts.acme(
        fontSize: fontSize,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),
      bodyMedium: GoogleFonts.acme(
        fontSize: fontSize - 2,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),
      bodySmall: GoogleFonts.acme(
        fontSize: fontSize - 4,
        fontWeight: light, // Cambiado a light
        color: secondaryColor,
      ),

      // Etiquetas
      labelLarge: GoogleFonts.acme(
        fontSize: fontSize - 2,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),
      labelMedium: GoogleFonts.acme(
        fontSize: fontSize - 4,
        fontWeight: light, // Cambiado a light
        color: baseColor,
      ),
      labelSmall: GoogleFonts.acme(
        fontSize: fontSize - 6,
        fontWeight: light, // Cambiado a light
        color: secondaryColor,
      ),
    );
  }
}
