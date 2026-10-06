import 'package:flutter/material.dart';

import '../domain/repositorios/indicador_repository.dart';

/// `ThemeMode` actual de la aplicación (light/dark/system).
///
/// **Semana 10 — persistencia de una preferencia.**
///
/// Hasta la Sesión 11 el modo de tema vivía solo en memoria: al cerrar la
/// aplicación se perdía. Ahora la preferencia se guarda en la tabla
/// `preferencias` de SQLite a través de [PreferenciasRepository], es decir,
/// por el mismo camino que cualquier otro dato de la aplicación.
///
/// Se conserva la clase como `ValueNotifier` para no romper el
/// `ValueListenableBuilder` de `main.dart` construido en la Sesión 11: la
/// única diferencia es que ahora hay dos métodos que tocan el disco.
///
/// **¿Por qué no `shared_preferences`?** Porque una sola base de datos
/// significa un solo punto de copia de seguridad y de migración. La
/// comparación completa entre clave-valor, SQLite y archivos está en la
/// sección 4 de la guía.
class TemaApp extends ValueNotifier<ThemeMode> {
  TemaApp(this._preferencias) : super(ThemeMode.system);

  final PreferenciasRepository _preferencias;

  /// Clave con la que la preferencia se guarda en la base de datos local.
  static const String clave = 'tema.modo';

  /// Lee la preferencia guardada y actualiza [value].
  ///
  /// Se llama una sola vez, al arrancar la aplicación (`main`), después de
  /// `inicializarDependencias()`. Si no hay nada guardado o la lectura
  /// falla, se conserva `ThemeMode.system` en lugar de propagar el error:
  /// una preferencia no debe impedir que la aplicación abra.
  Future<void> cargarDesdeDisco() async {
    try {
      final String? guardado = await _preferencias.leer(clave);
      value = _desdeTexto(guardado);
    } catch (error) {
      debugPrint('No se pudo leer la preferencia de tema: $error');
    }
  }

  /// Persiste el modo elegido por el usuario y notifica a los
  /// `ValueListenableBuilder`.
  ///
  /// TODO(reto-1b): analice qué ocurre si el guardado falla (por ejemplo,
  /// disco lleno). Implemente la política que su equipo decida —revertir el
  /// valor en memoria o mantener la preferencia solo en esta sesión— y
  /// documéntela en el informe técnico.
  Future<void> cambiarYGuardar(ThemeMode nuevo) async {
    value = nuevo;
    try {
      await _preferencias.guardar(clave, _aTexto(nuevo));
    } catch (error) {
      debugPrint('No se pudo guardar la preferencia de tema: $error');
    }
  }

  static ThemeMode _desdeTexto(String? texto) {
    switch (texto) {
      case 'claro':
        return ThemeMode.light;
      case 'oscuro':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _aTexto(ThemeMode modo) {
    switch (modo) {
      case ThemeMode.light:
        return 'claro';
      case ThemeMode.dark:
        return 'oscuro';
      case ThemeMode.system:
        return 'sistema';
    }
  }
}
