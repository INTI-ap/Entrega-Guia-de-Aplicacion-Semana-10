import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manos_seguras/core/tema_app.dart';

import '../dobles/preferencias_en_memoria.dart';

/// **Pruebas de la persistencia de una preferencia (Reto 1, parte B).**
///
/// Comprueban el ciclo completo de la preferencia de tema sin abrir SQLite:
/// el repositorio se sustituye por el doble en memoria. Es exactamente la
/// razón por la que `TemaApp` recibe el repositorio por constructor en lugar
/// de instanciarlo: **inyección de dependencias = código probable**.
void main() {
  group('TemaApp', () {
    test('sin preferencia guardada arranca en ThemeMode.system', () async {
      final PreferenciasEnMemoria prefs = PreferenciasEnMemoria();
      final TemaApp tema = TemaApp(prefs);

      await tema.cargarDesdeDisco();

      expect(tema.value, ThemeMode.system);
      expect(prefs.escrituras, 0);
    });

    test('cargarDesdeDisco restaura el modo guardado', () async {
      final PreferenciasEnMemoria prefs = PreferenciasEnMemoria(
        iniciales: <String, String>{TemaApp.clave: 'oscuro'},
      );
      final TemaApp tema = TemaApp(prefs);

      await tema.cargarDesdeDisco();

      expect(tema.value, ThemeMode.dark);
    });

    test('cambiarYGuardar persiste y notifica a los escuchas', () async {
      final PreferenciasEnMemoria prefs = PreferenciasEnMemoria();
      final TemaApp tema = TemaApp(prefs);

      int notificaciones = 0;
      tema.addListener(() => notificaciones++);

      await tema.cambiarYGuardar(ThemeMode.light);

      expect(tema.value, ThemeMode.light);
      expect(notificaciones, 1);
      expect(await prefs.leer(TemaApp.clave), 'claro');
    });

    test('una preferencia desconocida no rompe: degrada a system', () async {
      final PreferenciasEnMemoria prefs = PreferenciasEnMemoria(
        iniciales: <String, String>{TemaApp.clave: 'modo-inventado'},
      );
      final TemaApp tema = TemaApp(prefs);

      await tema.cargarDesdeDisco();

      expect(tema.value, ThemeMode.system);
    });

    test('si el almacén falla al escribir, el modo se mantiene en memoria',
        () async {
      final PreferenciasEnMemoria prefs = PreferenciasEnMemoria()
        ..fallaAlGuardar = true;
      final TemaApp tema = TemaApp(prefs);

      await tema.cambiarYGuardar(ThemeMode.dark);

      // La preferencia no se pudo guardar, pero la sesión actual sí cambió:
      // una preferencia nunca debe bloquear a la aplicación.
      expect(tema.value, ThemeMode.dark);
    });
  });
}
