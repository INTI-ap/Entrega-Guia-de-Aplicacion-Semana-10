import 'package:flutter/material.dart';

/// Paleta institucional de la Universidad Andina del Cusco (UAC),
/// reutilizada en todas las pantallas de ManosSeguras desde la
/// Guía de Práctica N.° 02 (Sesiones 4-5).
///
/// En la Semana 10 esta clase **no cambia**: es una HOJA del grafo de
/// dependencias (no depende de nadie) y varias capas dependen de ella.
/// Que la capa de presentación siga funcionando sin tocar el tema es la
/// evidencia de que la refactorización por capas de la Semana 8 se hizo
/// bien.
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF194D84);
  static const Color navyDark = Color(0xFF123A66);
  static const Color cyan = Color(0xFF00CEFE);
  static const Color background = Color(0xFFF2F7FC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1B2A3A);
  static const Color textSecondary = Color(0xFF5C6B7A);

  // Colores semánticos para cumplimiento/incumplimiento.
  static const Color exito = Color(0xFF2E7D32);
  static const Color alerta = Color(0xFFC62828);
  static const Color aviso = Color(0xFFEF6C00);
}

/// `ThemeData` central de la aplicación. Todas las pantallas construidas
/// en las guías anteriores reutilizan este tema en lugar de definir
/// colores o tipografías propias.
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        primary: AppColors.navy,
        secondary: AppColors.cyan,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD9E2F3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.navy, width: 2),
        ),
      ),
    );
  }

  /// Variante oscura del tema (Sesión 11: ThemeData, modo
  /// claro/oscuro/sistema).
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF10161F),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.navy,
        secondary: AppColors.cyan,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0B0F16),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cyan,
          foregroundColor: AppColors.navyDark,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
