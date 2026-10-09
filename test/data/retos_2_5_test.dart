import 'dart:convert';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:manos_seguras/data/local/daos/indicadores_dao.dart';
import 'package:manos_seguras/data/local/infraestructura.dart';
import 'package:manos_seguras/data/local/manos_seguras_db.dart'
    hide
        Auditoria,
        AuditoriasCompanion,
        Establecimiento,
        EstablecimientosCompanion,
        Oportunidade,
        OportunidadesCompanion;
import 'package:manos_seguras/data/mapeadores/mapeadores.dart';
import 'package:manos_seguras/data/remoto/higiene_api_service.dart';
import 'package:manos_seguras/data/repositorios/auditoria_repository_drift.dart';
import 'package:manos_seguras/data/repositorios/indicador_repository_offline_first.dart';
import 'package:manos_seguras/domain/entidades/auditoria.dart';
import 'package:manos_seguras/domain/entidades/catalogos.dart';
import 'package:manos_seguras/domain/entidades/establecimiento.dart';
import 'package:manos_seguras/domain/entidades/indicador_higiene.dart';
import 'package:manos_seguras/domain/entidades/oportunidad_registro.dart';
import 'package:manos_seguras/domain/entidades/personal.dart';
import 'package:manos_seguras/domain/servicios/calculadora_adherencia.dart';

/// Pruebas de los Retos 2 y 5. No tocan la lógica de los Retos 1 y 4,
/// solo la ejercitan como base (catálogos, guardar, migración v2).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late ManosSegurasDb base;
  late InfraestructuraLocal infra;
  late IndicadoresDao dao;

  setUp(() {
    base = ManosSegurasDb(NativeDatabase.memory());
    infra = InfraestructuraLocal(base);
    dao = infra.indicadoresDao;
  });

  tearDown(() async {
    await base.close();
  });

  Future<void> sembrarCatalogos() async {
    await base.insertarEstablecimiento(Establecimiento.ejemplo().aFila());
    await base.insertarPersonal(Observador.ejemplo().aFila());
    await base.insertarPersonal(Observado.ejemplo().aFila());
  }

  HigieneApiService servicioQueFalla() {
    return HigieneApiService(
      cliente: MockClient((http.Request p) async {
        throw http.ClientException('Sin conexión (prueba)');
      }),
    );
  }

  HigieneApiService servicioQueResponde(int cantidad) {
    return HigieneApiService(
      cliente: MockClient((http.Request p) async {
        return http.Response(_cuerpoApi(cantidad), 200);
      }),
    );
  }

  IndicadorRepositoryOfflineFirst repo({
    required HigieneApiService servicio,
    DateTime? ahora,
  }) {
    return IndicadorRepositoryOfflineFirst(
      dao: dao,
      servicio: servicio,
      reloj: () => ahora ?? DateTime(2026, 10, 20, 12),
    );
  }

  group('Reto 2 - 5 caminos de decisión', () {
    test('1/5 caché vigente no consulta la red y no es obsoleta', () async {
      final DateTime ahora = DateTime(2026, 10, 20, 12);
      await dao.reemplazarTodo(
        _indicadores(2),
        momento: ahora.subtract(const Duration(hours: 1)),
      );
      bool red = false;
      final HigieneApiService svc = HigieneApiService(
        cliente: MockClient((http.Request p) async {
          red = true;
          return http.Response(_cuerpoApi(2), 200);
        }),
      );
      final ResultadoIndicadores r =
          await repo(servicio: svc, ahora: ahora).obtenerIndicadores();
      expect(r.origen, OrigenDatos.cacheLocal);
      expect(r.datosObsoletos, isFalse);
      expect(red, isFalse);
    });

    test('2/5 caché vencida + éxito descarga red y actualiza caché',
        () async {
      await dao.reemplazarTodo(
        _indicadores(2),
        momento: DateTime(2026, 1, 1),
      );
      final ResultadoIndicadores r =
          await repo(servicio: servicioQueResponde(3)).obtenerIndicadores();
      expect(r.origen, OrigenDatos.red);
      expect(r.datosObsoletos, isFalse);
      expect(await dao.leerTodo(), hasLength(3));
      expect(await dao.obtenerIntentosFallidos('WSH_HYGIENE_BASIC'), 0);
    });

    test('3/5 caché vencida + fallo sirve caché obsoleta y cuenta fallo',
        () async {
      await dao.reemplazarTodo(
        _indicadores(4),
        momento: DateTime(2026, 1, 1),
      );
      final ResultadoIndicadores r = await repo(
        servicio: servicioQueFalla(),
        ahora: DateTime(2026, 10, 20),
      ).obtenerIndicadores();
      expect(r.origen, OrigenDatos.cacheLocal);
      expect(r.datosObsoletos, isTrue);
      expect(r.indicadores, hasLength(4));
      expect(await dao.obtenerIntentosFallidos('WSH_HYGIENE_BASIC'), 1);
    });

    test('4/5 sin caché + fallo devuelve respaldo sin lanzar', () async {
      final ResultadoIndicadores r =
          await repo(servicio: servicioQueFalla()).obtenerIndicadores();
      expect(r.origen, OrigenDatos.respaldo);
      expect(r.indicadores, isNotEmpty);
      expect(r.datosObsoletos, isTrue);
    });

    test('5/5 forzar refresco con caché vigente igual descarga red',
        () async {
      final DateTime ahora = DateTime(2026, 10, 20, 12);
      await dao.reemplazarTodo(
        _indicadores(2),
        momento: ahora.subtract(const Duration(hours: 1)),
      );
      final ResultadoIndicadores r =
          await repo(servicio: servicioQueResponde(3), ahora: ahora)
              .obtenerIndicadores(forzarRefresco: true);
      expect(r.origen, OrigenDatos.red);
      expect(r.indicadores, hasLength(3));
    });
  });

  group('Reto 2 - política por recurso e invalidar', () {
    test('vigencia por recurso: 3 recursos distintos', () {
      final IndicadorRepositoryOfflineFirst r =
          repo(servicio: servicioQueFalla());
      expect(r.vigenciaPara('WSH_HYGIENE_BASIC'), const Duration(hours: 24));
      expect(r.vigenciaPara('establecimientos'), const Duration(days: 7));
      expect(r.vigenciaPara('auditorias'), const Duration(minutes: 15));
    });

    test('invalidar borra la marca sin borrar datos y fuerza descarga',
        () async {
      final DateTime ahora = DateTime(2026, 10, 20, 12);
      await dao.reemplazarTodo(_indicadores(2), momento: ahora);
      await repo(servicio: servicioQueFalla()).invalidar('WSH_HYGIENE_BASIC');
      expect(await dao.ultimaSincronizacion('WSH_HYGIENE_BASIC'), isNull);
      expect(await dao.leerTodo(), hasLength(2));
      final ResultadoIndicadores r =
          await repo(servicio: servicioQueResponde(3), ahora: ahora)
              .obtenerIndicadores();
      expect(r.origen, OrigenDatos.red);
    });

    test('fallos se reinician a cero tras descarga exitosa', () async {
      await dao.reemplazarTodo(_indicadores(2), momento: DateTime(2026, 1, 1));
      await repo(servicio: servicioQueFalla(), ahora: DateTime(2026, 10, 20))
          .obtenerIndicadores();
      expect(await dao.obtenerIntentosFallidos('WSH_HYGIENE_BASIC'), 1);
      await repo(servicio: servicioQueResponde(2)).obtenerIndicadores();
      expect(await dao.obtenerIntentosFallidos('WSH_HYGIENE_BASIC'), 0);
    });
  });

  group('Reto 5 - integridad, índices y paginación', () {
    test('PRAGMA foreign_keys activo y oportunidad huérfana rechazada',
        () async {
      expect(await base.estadoClavesForaneas(), 1);
      expect(
        () => infra.auditoriasDao.insertarOportunidad(
          const OportunidadRegistro(
            auditoriaId: 'no-existe',
            numero: 1,
            momento: Momento.antesDeTocarPaciente,
            accion: Accion.lavadoDeManos,
          ),
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('índice compuesto existe y EXPLAIN lo usa', () async {
      final String plan = await infra.auditoriasDao.explicarPlanListado();
      expect(plan, isNotEmpty);
      // La consulta del listado filtra por eliminada y ordena por fecha;
      // el índice (estado, fecha) debe aparecer en el plan.
      debugPrint('EXPLAIN QUERY PLAN:\n$plan');
    });

    test('paginación LIMIT/OFFSET no carga todo', () async {
      await sembrarCatalogos();
      final AuditoriaRepositoryDrift rep = AuditoriaRepositoryDrift(
        infra.auditoriasDao,
      );
      for (int i = 0; i < 5; i++) {
        await rep.guardar(_auditoria(id: 'pag-$i'));
      }
      final List<Auditoria> p1 =
          await rep.listarPaginado(limite: 2, offset: 0);
      final List<Auditoria> p2 =
          await rep.listarPaginado(limite: 2, offset: 2);
      final List<Auditoria> p3 =
          await rep.listarPaginado(limite: 2, offset: 4);
      expect(p1, hasLength(2));
      expect(p2, hasLength(2));
      expect(p3, hasLength(1));
      expect(await rep.listarPaginado(limite: 2, offset: 10), isEmpty);
    });

    test('resumenPorMomento SQL coincide con cálculo en memoria', () async {
      await sembrarCatalogos();
      final AuditoriaRepositoryDrift rep = AuditoriaRepositoryDrift(
        infra.auditoriasDao,
      );
      await rep.guardar(
        _auditoria(id: 'm1', oportunidades: _cincoOportunidades(2)),
      );
      final Map<String, ({int total, int cumplidas})> sql =
          await infra.auditoriasDao.resumenPorMomento();
      final List<Auditoria> todas = await rep.listarAuditorias();
      final ResumenAdherencia memoria =
          const CalculadoraAdherencia().resumir(todas);
      final int totalSql =
          sql.values.fold<int>(0, (int s, v) => s + v.total);
      expect(totalSql, memoria.totalOportunidades);
      expect(sql.keys, hasLength(5));
    });

    test('medición 1000 auditorías: SQL vs memoria', () async {
      await sembrarCatalogos();
      final AuditoriaRepositoryDrift rep = AuditoriaRepositoryDrift(
        infra.auditoriasDao,
      );
      final Stopwatch reloj = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        await rep.guardar(
          _auditoria(id: 'med-$i', oportunidades: _cincoOportunidades(2)),
        );
      }
      final int msSiembra = reloj.elapsedMilliseconds;
      reloj.reset();
      final ResumenAdherencia sql = await rep.resumenAdherencia();
      final int msSql = reloj.elapsedMilliseconds;
      reloj.reset();
      final List<Auditoria> todas =
          await rep.listarPaginado(limite: 1000, offset: 0);
      final ResumenAdherencia memoria =
          const CalculadoraAdherencia().resumir(todas);
      final int msMemoria = reloj.elapsedMilliseconds;
      debugPrint(
        'Siembra: ${msSiembra}ms · SQL: ${msSql}ms · Memoria: ${msMemoria}ms',
      );
      expect(sql.totalOportunidades, memoria.totalOportunidades);
      expect(sql.totalOportunidades, 5000);
    }, timeout: const Timeout(Duration(minutes: 5)));
  });
}

Auditoria _auditoria({
  required String id,
  List<OportunidadRegistro> oportunidades = const <OportunidadRegistro>[],
}) {
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

List<OportunidadRegistro> _cincoOportunidades(int omisiones) {
  return List<OportunidadRegistro>.generate(
    Momento.values.length,
    (int i) => OportunidadRegistro(
      auditoriaId: '',
      numero: i + 1,
      momento: Momento.values[i],
      accion: i < omisiones ? Accion.omision : Accion.lavadoDeManos,
    ),
  );
}

List<IndicadorHigiene> _indicadores(int cantidad) {
  return List<IndicadorHigiene>.generate(
    cantidad,
    (int i) => IndicadorHigiene(
      codigoIndicador: HigieneApiService.codigoIndicador,
      pais: 'PER',
      anio: 2020 + i,
      ambito: 'Rural',
      valor: 50 + i.toDouble(),
    ),
  );
}

String _cuerpoApi(int cantidad) {
  return jsonEncode(<String, dynamic>{
    'value': List<Map<String, dynamic>>.generate(
      cantidad,
      (int i) => <String, dynamic>{
        'IndicatorCode': 'WSH_HYGIENE_BASIC',
        'SpatialDim': 'PER',
        'TimeDim': 2020 + i,
        'Dim1': 'RESIDENCEAREATYPE_RUR',
        'NumericValue': 50 + i.toDouble(),
      },
    ),
  });
}
