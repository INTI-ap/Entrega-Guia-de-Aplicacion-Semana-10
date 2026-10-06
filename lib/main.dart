import 'package:flutter/material.dart';

import 'core/tema_app.dart';
import 'core/theme/app_theme.dart';
import 'data/local/sembrador.dart';
import 'domain/entidades/auditoria.dart';
import 'domain/repositorios/auditoria_repository.dart';
import 'presentation/di.dart';
import 'presentation/widgets/app_layout.dart';
import 'router/app_router.dart';

/// Punto de entrada de ManosSeguras.
///
/// **Semana 10 — arranque con dependencias asíncronas.**
///
/// El orden de esta función es parte de la arquitectura y conviene leerlo con
/// cuidado:
///
/// ```
///  1. ensureInitialized()        → obligatorio antes de usar plugins
///  2. iniciarDependencias()      → abre SQLite y arma el grafo de get_it
///  3. cargar la preferencia tema → lee de la tabla `preferencias`
///  4. sembrar datos si está vacía
///  5. runApp(...)
/// ```
///
/// Si el paso 2 falla, la aplicación no puede continuar: no hay forma de
/// mostrar datos sin base de datos. Por eso el arranque se envuelve en un
/// `try/catch` que muestra una pantalla de error comprensible (patrón
/// *fail fast with a friendly message*) en lugar de dejar la pantalla en blanco.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await iniciarDependencias();

    await getIt<TemaApp>().cargarDesdeDisco();
    await _sembrarSiEsPrimerArranque();

    runApp(const ManosSegurasApp());
  } catch (error, pila) {
    debugPrint('Falló el arranque de ManosSeguras: $error\n$pila');
    runApp(_PantallaFalloDeArranque(mensaje: '$error'));
  }
}

/// Siembra datos de demostración la primera vez que se abre la aplicación,
/// para que las pantallas de auditorías y de diagnóstico tengan contenido.
///
/// **Decisión documentada:** este comportamiento es aceptable en un proyecto
/// de laboratorio, pero en producción debe quedar detrás de una bandera de
/// compilación (`--dart-define=DEMO=true`) o eliminarse. Es un ejemplo de
/// decisión de diseño que el informe técnico debe registrar.
Future<void> _sembrarSiEsPrimerArranque() async {
  final AuditoriaRepository repositorio = getIt<AuditoriaRepository>();
  final List<Auditoria> existentes = await repositorio.listarAuditorias();
  if (existentes.isNotEmpty) return;

  final SembradorDatos sembrador = getIt<SembradorDatos>();
  await sembrador.limpiar();
  await sembrador.sembrar(cantidad: 3);
}

/// Raíz de la aplicación.
class ManosSegurasApp extends StatelessWidget {
  const ManosSegurasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: getIt<TemaApp>(),
      builder: (BuildContext context, ThemeMode modoActual, Widget? _) {
        return MaterialApp.router(
          title: 'ManosSeguras',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          darkTheme: AppTheme.darkTheme,
          themeMode: modoActual,
          // Toda la navegación vive en un único lugar (Sesión 15).
          routerConfig: appRouter,
        );
      },
    );
  }
}

/// Pantalla que se muestra si el arranque falla (por ejemplo, si la base de
/// datos local no puede abrirse). Evita la pantalla en blanco y ofrece un
/// diagnóstico mínimo.
class _PantallaFalloDeArranque extends StatelessWidget {
  const _PantallaFalloDeArranque({required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: Scaffold(
        appBar: AppBar(title: const Text('ManosSeguras')),
        body: AppLayout(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.storage_rounded,
                  size: 56,
                  color: AppColors.alerta,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo abrir la base de datos local',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  mensaje,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
