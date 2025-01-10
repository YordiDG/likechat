// lib/core/theme/typography/font_size_scaling.dart

import 'package:flutter/material.dart';

/// Clase utilitaria para manejar el escalado responsivo de las fuentes
class FontSizeScaling {
  /// Factor de escala base
  static const double _baseScaleFactor = 1.0;

  /// Tamaño de pantalla de referencia (diseño base)
  static const double _designScreenWidth = 375.0;

  /// Escala un tamaño de fuente según el tamaño de la pantalla
  static double scale(double fontSize) {
    return fontSize * _calculateScaleFactor();
  }

  /// Calcula el factor de escala basado en el tamaño de la pantalla
  static double _calculateScaleFactor() {
    // Obtener el contexto de la pantalla actual
    final context = NavigationService.navigatorKey.currentContext;
    if (context == null) return _baseScaleFactor;

    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth / _designScreenWidth;

    // Limitar el factor de escala para evitar textos demasiado grandes o pequeños
    return scaleFactor.clamp(0.8, 1.2);
  }
}

/// Servicio de navegación para acceder al contexto global
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
}