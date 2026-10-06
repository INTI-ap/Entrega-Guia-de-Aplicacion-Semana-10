// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:manos_seguras/core/tema_app.dart';
import 'package:manos_seguras/domain/entidades/auditoria.dart';
import 'package:manos_seguras/domain/entidades/catalogos.dart';
import 'package:manos_seguras/domain/entidades/oportunidad_registro.dart';
import 'package:manos_seguras/domain/repositorios/auditoria_repository.dart';
import 'package:manos_seguras/domain/repositorios/indicador_repository.dart';
import 'package:manos_seguras/presentation/di.dart';
import 'package:manos_seguras/presentation/pantallas/pantalla_auditoria_detalle.dart';
import 'package:manos_seguras/presentation/pantallas/pantalla_auditorias.dart';
import 'package:manos_seguras/presentation/pantallas/pantalla_bienvenida.dart';
import 'package:manos_seguras/presentation/pantallas/pantalla_oportunidades.dart';
import 'package:manos_seguras/presentation/widgets/tarjetas.dart';

import '../dobles/preferencias_en_memoria.dart';
import '../dobles/repositorio_auditorias_en_memoria.dart';

/// **Pruebas de widget de la capa de presentación.**
///
/// No abren SQLite ni hacen peticiones de red: el repositorio se sustituye por
/// el doble en memoria de `test/dobles/`. La navegación se prueba con un
/// `GoRouter` de prueba en lugar del router de la aplicación, para aislar cada
/// pantalla.
void main() {
  late RepositorioAuditoriasEnMemoria repositorio;

  setUp(() {
    repositorio = RepositorioAuditoriasEnMemoria(
      iniciales: <Auditoria>[_auditoria(id: 'aud-1')],
    );

    if (getIt.isRegistered<AuditoriaRepository>()) {
      getIt.unregister<AuditoriaRepository>();
    }
    getIt
      ..registerSingleton<AuditoriaRepository>(repositorio)
      ..registerSingleton<PreferenciasRepository>(PreferenciasEnMemoria())
      ..registerSingleton<TemaApp>(
        TemaApp(getIt<PreferenciasRepository>()),
      );
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('la pantalla de bienvenida muestra los 5 Momentos',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PantallaBienvenida()),
    );

    // "ManosSeguras" aparece en el AppBar y en el encabezado.
    expect(find.text('ManosSeguras'), findsWidgets);
    expect(find.text('Los 5 Momentos'), findsOneWidget);
    expect(find.text(Momento.antesDeTocarPaciente.etiqueta), findsOneWidget);
    expect(
      find.text(Momento.despuesEntornoPaciente.etiqueta),
      findsOneWidget,
    );
    expect(find.text('Comenzar auditoría'), findsOneWidget);
  });

  testWidgets('la tarjeta de auditoría muestra el porcentaje de adherencia',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarjetaAuditoria(auditoria: _auditoria(id: 'aud-3')),
        ),
      ),
    );

    // 3 de 5 oportunidades cumplidas → 60.0 %.
    expect(find.text('60.0 %'), findsOneWidget);
    expect(find.text('Hospital Regional del Cusco'), findsOneWidget);
    expect(find.text('5 oportunidades'), findsOneWidget);
  });

  testWidgets('la tarjeta de auditoría sin datos muestra "Sin datos"',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TarjetaAuditoria(
            auditoria: _auditoria(id: 'aud-vacia', conOportunidades: false),
          ),
        ),
      ),
    );

    expect(find.text('Sin datos'), findsOneWidget);
  });

  testWidgets('la pantalla de auditorías lista lo que devuelve el repositorio',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: PantallaAuditorias()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Resumen local (calculado en SQL)'), findsOneWidget);
    expect(find.text('Hospital Regional del Cusco'), findsOneWidget);
    expect(find.text('Detalle por auditoría'), findsOneWidget);
  });

  testWidgets('la pantalla de auditorías muestra el estado vacío',
      (WidgetTester tester) async {
    repositorio = RepositorioAuditoriasEnMemoria();
    getIt.unregister<AuditoriaRepository>();
    getIt.registerSingleton<AuditoriaRepository>(repositorio);

    await tester.pumpWidget(
      const MaterialApp(home: PantallaAuditorias()),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Todavía no hay auditorías'),
      findsOneWidget,
    );
    expect(find.text('Capturar auditoría'), findsOneWidget);
  });

  testWidgets('la pantalla de auditorías muestra el estado de error',
      (WidgetTester tester) async {
    repositorio.falla = true;

    await tester.pumpWidget(
      const MaterialApp(home: PantallaAuditorias()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('el detalle carga la auditoría por su id',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PantallaAuditoriaDetalle(auditoriaId: 'aud-1'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detalle de la auditoría'), findsOneWidget);
    expect(find.text('Oportunidades (5)'), findsOneWidget);
    expect(find.text('Oportunidad 01'), findsOneWidget);
    expect(find.text('Oportunidad 05'), findsOneWidget);
  });

  testWidgets('el detalle muestra el error controlado si el id no existe',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PantallaAuditoriaDetalle(auditoriaId: 'no-existe'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('No existe la auditoría'), findsWidgets);
  });

  testWidgets('registrar oportunidades y guardar llama al repositorio',
      (WidgetTester tester) async {
    await tester.pumpWidget(_appConRouter(const PantallaOportunidades()));
    await tester.pumpAndSettle();

    // Al inicio no hay oportunidades.
    expect(find.textContaining('Aún no hay oportunidades'), findsOneWidget);

    // Se agrega una: el botón dice "Agregar oportunidad 01".
    await tester.tap(find.byIcon(Icons.add).first);
    await tester.pumpAndSettle();

    expect(find.text('Oportunidad 01'), findsOneWidget);
    expect(find.textContaining('1 de 1 oportunidades cumplidas'), findsOneWidget);

    // Guardar debe llegar al repositorio. El botón queda al final de una
    // pantalla con scroll, así que hay que asegurarse de que esté visible.
    final Finder botonGuardar = find.byIcon(Icons.save_outlined);
    await tester.ensureVisible(botonGuardar);
    await tester.pumpAndSettle();
    await tester.tap(botonGuardar);
    await tester.pumpAndSettle();

    expect(repositorio.llamadasAGuardar, 1);
    final List<Auditoria> guardadas =
        await repositorio.listarAuditorias();
    expect(guardadas, hasLength(2)); // la inicial + la nueva
  });

  testWidgets('guardar sin oportunidades muestra un aviso y no persiste',
      (WidgetTester tester) async {
    await tester.pumpWidget(_appConRouter(const PantallaOportunidades()));
    await tester.pumpAndSettle();

    final Finder botonGuardar = find.byIcon(Icons.save_outlined);
    await tester.ensureVisible(botonGuardar);
    await tester.pumpAndSettle();
    await tester.tap(botonGuardar);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.textContaining('Registre al menos una oportunidad'),
      findsOneWidget,
    );
    expect(repositorio.llamadasAGuardar, 0);
  });
}

/// Router mínimo para las pantallas que navegan con `context.go(...)`.
///
/// Se usa en las pruebas en lugar del `appRouter` de la aplicación para no
/// arrastrar todas las pantallas: cada prueba monta solo lo que necesita.
Widget _appConRouter(Widget pantalla) {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, __) => pantalla),
      GoRoute(
        path: '/auditorias',
        builder: (_, __) => const Scaffold(body: Text('listado')),
      ),
      GoRoute(
        path: '/auditorias/:id',
        builder: (_, GoRouterState state) => Scaffold(
          body: Text('detalle ${state.pathParameters['id']}'),
        ),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

// ---------------------------------------------------------------------
// Datos auxiliares
// ---------------------------------------------------------------------

Auditoria _auditoria({
  required String id,
  bool conOportunidades = true,
}) {
  final List<OportunidadRegistro> oportunidades = conOportunidades
      ? List<OportunidadRegistro>.generate(
          Momento.values.length,
          (int i) => OportunidadRegistro(
            auditoriaId: id,
            numero: i + 1,
            momento: Momento.values[i],
            accion: i < 3 ? Accion.lavadoDeManos : Accion.omision,
          ),
        )
      : const <OportunidadRegistro>[];

  return Auditoria(
    id: id,
    establecimientoId: '00006405',
    establecimientoNombre: 'Hospital Regional del Cusco',
    observadorDni: '23456789',
    observadorNombre: 'Ana Quispe Mamani',
    observadoDni: '45678912',
    observadoNombre: 'Carlos Huamán Ttito',
    fecha: DateTime(2026, 10, 20, 9, 30),
    oportunidades: oportunidades,
  );
}
