import 'package:flutter/material.dart';

/// ThemeMode actual de la aplicación (light/dark/system), expuesto
/// como ValueNotifier para que cualquier pantalla pueda leerlo o
/// modificarlo sin que la raíz de la app (main.dart) necesite ser
/// StatefulWidget ni pasar callbacks a través de la navegación.
///
/// Vive en su propio archivo (en lugar de en main.dart) para evitar
/// un import circular entre main.dart y las pantallas que lo usan,
/// como la pantalla de la Variante D de la evaluación (Configuración
/// y Apariencia, Sesión 11).
final ValueNotifier<ThemeMode> temaApp = ValueNotifier(ThemeMode.system);
