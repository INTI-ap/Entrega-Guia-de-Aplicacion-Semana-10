import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pantallas/pantalla_auditoria_detalle.dart';
import '../presentation/pantallas/pantalla_auditorias.dart';
import '../presentation/pantallas/pantalla_bienvenida.dart';
import '../presentation/pantallas/pantalla_diagnostico.dart';
import '../presentation/pantallas/pantalla_establecimiento.dart';
import '../presentation/pantallas/pantalla_indicador_detalle.dart';
import '../presentation/pantallas/pantalla_indicadores.dart';
import '../presentation/pantallas/pantalla_oportunidades.dart';

/// Configuración central de la navegación con `go_router` (temática 1.4.1),
/// conservada de la Sesión 15 y extendida con las dos pantallas nuevas de la
/// Semana 10:
///
/// ```
///  /                       PantallaBienvenida
///  /establecimiento        catálogo del establecimiento auditado
///  /oportunidades          captura de los 5 Momentos → guarda en SQLite
///  /auditorias             listado local (drift) con adherencia
///  /auditorias/:id         detalle de una auditoría guardada
///  /indicadores            serie de la OMS con caché offline-first
///  /indicadores/:anio      detalle de un año
///  /diagnostico            estado de la base de datos local
/// ```
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: <RouteBase>[
    GoRoute(
      path: '/papelera',
      builder: (context, state) => const PantallaAuditorias(papelera: true),
    ),
    GoRoute(
      path: '/',
      name: 'bienvenida',
      builder: (BuildContext context, GoRouterState state) =>
          const PantallaBienvenida(),
    ),
    GoRoute(
      path: '/establecimiento',
      name: 'establecimiento',
      builder: (BuildContext context, GoRouterState state) =>
          const PantallaEstablecimiento(),
    ),
    GoRoute(
      path: '/oportunidades',
      name: 'oportunidades',
      builder: (BuildContext context, GoRouterState state) =>
          const PantallaOportunidades(),
    ),
    GoRoute(
      path: '/auditorias',
      name: 'auditorias',
      builder: (BuildContext context, GoRouterState state) =>
          const PantallaAuditorias(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          name: 'auditoriaDetalle',
          builder: (BuildContext context, GoRouterState state) {
            final String id = state.pathParameters['id'] ?? '';
            if (id.isEmpty) {
              return const PantallaRutaInvalida(
                mensaje: 'Falta el identificador de la auditoría.',
              );
            }
            return PantallaAuditoriaDetalle(auditoriaId: id);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/indicadores',
      name: 'indicadores',
      builder: (BuildContext context, GoRouterState state) =>
          const PantallaIndicadores(),
      routes: <RouteBase>[
        GoRoute(
          path: ':anio',
          name: 'indicadorDetalle',
          builder: (BuildContext context, GoRouterState state) {
            final int? anio = int.tryParse(state.pathParameters['anio'] ?? '');
            if (anio == null) {
              return const PantallaRutaInvalida(
                mensaje: 'El año solicitado no es un número válido.',
              );
            }
            return PantallaIndicadorDetalle(anio: anio);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/diagnostico',
      name: 'diagnostico',
      builder: (BuildContext context, GoRouterState state) =>
          const PantallaDiagnostico(),
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) =>
      PantallaRutaInvalida(
        mensaje: 'No existe la ruta solicitada: ${state.uri}',
      ),
);

/// Pantalla de respaldo para rutas inexistentes o parámetros inválidos.
class PantallaRutaInvalida extends StatelessWidget {
  const PantallaRutaInvalida({super.key, required this.mensaje});

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ruta no disponible')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.wrong_location_outlined, size: 56),
              const SizedBox(height: 16),
              Text(mensaje, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Volver al inicio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
