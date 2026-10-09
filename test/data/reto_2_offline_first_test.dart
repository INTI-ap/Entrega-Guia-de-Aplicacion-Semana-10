import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:manos_seguras/data/local/daos/indicadores_dao.dart';
import 'package:manos_seguras/data/local/manos_seguras_db.dart';
import 'package:manos_seguras/data/remoto/higiene_api_service.dart';
import 'package:manos_seguras/data/repositorios/indicador_repository_offline_first.dart';
import 'package:manos_seguras/domain/entidades/indicador_higiene.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late ManosSegurasDb base;
  late DriftIndicadoresDao dao;
  final ahora = DateTime.utc(2026, 10, 8, 15);
  const codigo = HigieneApiService.codigoIndicador;
  const datos = [
    IndicadorHigiene(
      codigoIndicador: codigo,
      pais: 'PER',
      anio: 2024,
      ambito: 'Rural',
      valor: 75,
    ),
  ];
  late int llamadas;
  late bool falla;
  late HigieneApiService servicio;
  late IndicadorRepositoryOfflineFirst repo;

  setUp(() {
    base = ManosSegurasDb(NativeDatabase.memory());
    dao = DriftIndicadoresDao(base);
    llamadas = 0;
    falla = false;
    servicio = HigieneApiService(
      cliente: MockClient((request) async {
        llamadas++;
        return http.Response(
          falla
              ? 'Servicio caído'
              : jsonEncode({
                  'value': [
                    {
                      'IndicatorCode': codigo,
                      'SpatialDim': 'PER',
                      'TimeDim': 2024,
                      'Dim1': 'RESIDENCEAREATYPE_RUR',
                      'NumericValue': 80,
                    },
                  ],
                }),
          falla ? 503 : 200,
        );
      }),
    );
    repo = IndicadorRepositoryOfflineFirst(
      dao: dao,
      servicio: servicio,
      reloj: () => ahora,
    );
  });
  tearDown(() async {
    servicio.cerrar();
    await base.close();
  });

  test('caché vigente evita la red y conserva fecha y datos', () async {
    final fecha = ahora.subtract(const Duration(hours: 1));
    await dao.reemplazarTodo(datos, momento: fecha);
    final r = await repo.obtenerIndicadores();
    expect(r.origen, OrigenDatos.cacheLocal);
    expect(r.datosObsoletos, false);
    expect(r.actualizadoEn, fecha);
    expect(r.indicadores.single.valor, 75);
    expect(llamadas, 0);
  });
  test(
    'caché vencida descarga y reemplaza datos con la hora inyectada',
    () async {
      await dao.reemplazarTodo(
        datos,
        momento: ahora.subtract(const Duration(days: 2)),
      );
      final r = await repo.obtenerIndicadores();
      expect(r.origen, OrigenDatos.red);
      expect(r.datosObsoletos, false);
      expect(r.actualizadoEn, ahora);
      expect((await dao.leerTodo()).single.valor, 80);
      expect(await dao.ultimaSincronizacion(codigo), ahora);
      expect(llamadas, 1);
    },
  );
  test('red caída conserva caché vencida y la marca como obsoleta', () async {
    falla = true;
    final fecha = ahora.subtract(const Duration(days: 2));
    await dao.reemplazarTodo(datos, momento: fecha);
    final r = await repo.obtenerIndicadores();
    expect(r.origen, OrigenDatos.cacheLocal);
    expect(r.datosObsoletos, true);
    expect(r.actualizadoEn, fecha);
    expect(r.indicadores.single.valor, 75);
    expect(await dao.intentosFallidos(codigo), 1);
  });
  test('red caída sin caché entrega respaldo sin lanzar excepción', () async {
    falla = true;
    final r = await repo.obtenerIndicadores();
    expect(r.origen, OrigenDatos.respaldo);
    expect(r.indicadores, isNotEmpty);
    expect(r.datosObsoletos, false);
    expect(r.actualizadoEn, null);
    expect(await dao.ultimaSincronizacion(codigo), null);
    expect(await dao.intentosFallidos(codigo), 1);
  });
  test('refresco forzado consulta la red incluso con caché vigente', () async {
    await dao.reemplazarTodo(datos, momento: ahora);
    final r = await repo.obtenerIndicadores(forzarRefresco: true);
    expect(r.origen, OrigenDatos.red);
    expect(llamadas, 1);
  });
  test(
    'fallos consecutivos se reinician después de descargar con éxito',
    () async {
      falla = true;
      await repo.obtenerIndicadores();
      await repo.obtenerIndicadores();
      expect(await dao.intentosFallidos(codigo), 2);
      falla = false;
      await repo.obtenerIndicadores();
      expect(await dao.intentosFallidos(codigo), 0);
    },
  );
  test(
    'fallo de refresco forzado no vuelve obsoleta una caché reciente',
    () async {
      falla = true;
      await dao.reemplazarTodo(datos, momento: ahora);
      final r = await repo.obtenerIndicadores(forzarRefresco: true);
      expect(r.origen, OrigenDatos.cacheLocal);
      expect(r.datosObsoletos, false);
    },
  );
  test(
    'invalidar conserva datos, fecha y fallos y obliga a descargar',
    () async {
      await dao.reemplazarTodo(datos, momento: ahora);
      await dao.registrarFallo(codigo);
      await repo.invalidar(codigo);
      expect(await dao.ultimaSincronizacion(codigo), null);
      expect(await dao.intentosFallidos(codigo), 1);
      expect((await dao.leerTodo()).single.valor, 75);
      falla = true;
      final r = await repo.obtenerIndicadores();
      expect(llamadas, 1);
      expect(r.datosObsoletos, true);
      expect(r.actualizadoEn, ahora);
    },
  );
  test(
    'invalidar otro recurso no afecta el indicador ni su contador',
    () async {
      await dao.reemplazarTodo(datos, momento: ahora);
      await dao.registrarFallo('establecimientos');
      await repo.invalidar('establecimientos');
      expect(await dao.intentosFallidos('establecimientos'), 1);
      expect(await dao.intentosFallidos(codigo), 0);
      expect(await dao.ultimaSincronizacion(codigo), ahora);
    },
  );
  test('vigencia varía por recurso y expira en el límite exacto', () {
    expect(
      repo.cacheEsVigente(
        ahora.subtract(const Duration(days: 2)),
        codigo: 'establecimientos',
      ),
      true,
    );
    expect(
      repo.cacheEsVigente(
        ahora.subtract(const Duration(minutes: 5)),
        codigo: 'auditorias',
      ),
      false,
    );
    expect(
      repo.cacheEsVigente(ahora.subtract(const Duration(hours: 24))),
      false,
    );
    expect(repo.cacheEsVigente(ahora.add(const Duration(seconds: 1))), false);
    expect(repo.cacheEsVigente(ahora, codigo: 'desconocido'), false);
  });
  test('migración v2 a v3 conserva caché y sincronización existentes', () async {
    final carpeta = await Directory.systemTemp.createTemp('reto2_migracion_');
    final archivo = File('${carpeta.path}/base.sqlite');
    try {
      final inicial = ManosSegurasDb(NativeDatabase(archivo));
      await DriftIndicadoresDao(inicial).reemplazarTodo(datos, momento: ahora);
      await inicial.close();
      final cruda = sqlite.sqlite3.open(archivo.path);
      cruda.execute(
        'ALTER TABLE sincronizaciones DROP COLUMN intentos_fallidos',
      );
      cruda.execute(
        'ALTER TABLE sincronizaciones RENAME TO sincronizaciones_nueva',
      );
      cruda.execute(
        'CREATE TABLE sincronizaciones (codigo TEXT NOT NULL PRIMARY KEY, '
        'ultima_sincronizacion TEXT NOT NULL, registros INTEGER NOT NULL DEFAULT 0)',
      );
      cruda.execute(
        'INSERT INTO sincronizaciones SELECT codigo, ultima_sincronizacion, '
        'registros FROM sincronizaciones_nueva',
      );
      cruda.execute('DROP TABLE sincronizaciones_nueva');
      cruda.execute('PRAGMA user_version = 2');
      cruda.close();
      final migrada = ManosSegurasDb(NativeDatabase(archivo));
      try {
        final acceso = DriftIndicadoresDao(migrada);
        expect((await acceso.leerTodo()).single.valor, 75);
        expect(await acceso.ultimaSincronizacion(codigo), ahora);
        expect(await acceso.intentosFallidos(codigo), 0);
        await acceso.registrarFallo(codigo);
        expect(await acceso.intentosFallidos(codigo), 1);
        final version = await migrada
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.read<int>('user_version'), 3);
        await acceso.invalidar(codigo);
        expect(await acceso.ultimaSincronizacion(codigo), null);
        expect((await acceso.leerTodo()).single.valor, 75);
      } finally {
        await migrada.close();
      }
    } finally {
      await carpeta.delete(recursive: true);
    }
  });
}
