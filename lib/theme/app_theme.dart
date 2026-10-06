import 'package:flutter/material.dart';

/// Paleta institucional de la Universidad Andina del Cusco (UAC),
/// reutilizada en todas las pantallas de ManosSeguras desde la
/// Guía de Práctica N.° 2 (Sesiones 4-5).
class AppColors {
  AppColors._();

  static const Color navy = Color(0xFF194D84);
  static const Color navyDark = Color(0xFF123A66);
  static const Color cyan = Color(0xFF00CEFE);
  static const Color background = Color(0xFFF2F7FC);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1B2A3A);
  static const Color textSecondary = Color(0xFF5C6B7A);

  // Colores semánticos para cumplimiento/incumplimiento (Guía N.° 4,
  // indicador de estado tipo Stack sobre el avatar del observado).
  static const Color exito = Color(0xFF2E7D32);
  static const Color alerta = Color(0xFFC62828);
}

/// ThemeData central de la aplicación. Todas las pantallas construidas
/// en las Guías de Práctica reutilizan este tema en lugar de definir
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
  /// claro/oscuro/sistema). Se incluye desde el proyecto base para
  /// que ningún equipo de la evaluación tenga que crearla desde cero
  /// ni tocar la raíz de la app (main.dart) más de lo necesario.
  /// Reutiliza el mismo esquema de color base (seedColor navy) para
  /// que la identidad visual de la app se mantenga reconocible.
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
