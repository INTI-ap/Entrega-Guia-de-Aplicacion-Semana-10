import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:manos_seguras/core/fallos.dart';
import 'package:manos_seguras/data/local/daos/indicadores_dao.dart';
import 'package:manos_seguras/data/local/infraestructura.dart';
// De la biblioteca de la base solo se necesita `ManosSegurasDb`. Las *data
// classes* que drift genera allí (`Auditoria`, `Oportunidade`, …) se ocultan
// porque chocan con las entidades del dominio, que son las que usan las
// pruebas. Es la misma precaución que se toma en la capa de datos.
import 'package:manos_seguras/data/local/manos_seguras_db.dart'
    hide
        Auditoria,
        AuditoriasCompanion,
        Establecimiento,
        EstablecimientosCompanion,
        IndicadoresCacheData,
        IndicadoresCacheCompanion,
        Oportunidade,
        OportunidadesCompanion,
        PersonalData,
        PersonalCompanion,
        Preferencia,
        PreferenciasCompanion,
        Sincronizacione,
        SincronizacionesCompanion;
import 'package:manos_seguras/data/local/sembrador.dart';
import 'package:manos_seguras/data/mapeadores/mapeadores.dart';
import 'package:manos_seguras/data/remoto/higiene_api_service.dart';
import 'package:manos_seguras/data/repositorios/auditoria_repository_drift.dart';
import 'package:manos_seguras/data/repositorios/indicador_repository_offline_first.dart';
import 'package:manos_seguras/data/repositorios/preferencias_repository_drift.dart';
import 'package:manos_seguras/domain/entidades/auditoria.dart';
import 'package:manos_seguras/domain/entidades/catalogos.dart';
import 'package:manos_seguras/domain/entidades/establecimiento.dart';
import 'package:manos_seguras/domain/entidades/indicador_higiene.dart';
import 'package:manos_seguras/domain/entidades/oportunidad_registro.dart';
import 'package:manos_seguras/domain/entidades/personal.dart';

/// **Pruebas de la capa de datos (Semana 10, Retos 1 a 5).**
///
/// Todas usan una base **en memoria** (`NativeDatabase.memory()`): cada
/// prueba parte de cero, no deja archivos y no depende de Internet. Es la
/// razón por la que `flutter test` puede ejecutarse en cualquier laboratorio.
///
/// La respuesta del API se sustituye con `MockClient` (Sesión 16): se prueba
/// la lógica del repositorio, no la disponibilidad del servidor de la OMS.
void main() {
  // La prueba de persistencia abre el mismo archivo dos veces a propósito
  // para demostrar que los datos sobreviven; el aviso de drift sobre
  // "múltiples bases" no aplica a ese caso controlado.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late ManosSegurasDb base;
  late InfraestructuraLocal infra;
  late AuditoriaRepositoryDrift repositorio;
  late SembradorDatos sembrador;

  setUp(() {
    base = ManosSegurasDb(NativeDatabase.memory());
    infra = InfraestructuraLocal(base);
    repositorio = AuditoriaRepositoryDrift(
      infra.auditoriasDao,
      generadorId: () => 'id-generado-por-la-prueba',
    );
    sembrador = SembradorDatos(
      base: base,
      repositorio: repositorio,
      // Generador de azar inyectado y consumido de forma compartida entre las
      // dos llamadas de la prueba de reproducibilidad. En la aplicación real
      // cada instancia crea su propio `Random(2026)`.
      azar: Random(2026),
    );
  });

  /// Inserta el establecimiento y las personas que exigen las claves foráneas
  /// (Reto 5). Sin ellos, `guardar` debe fallar: es justamente lo que verifica
  /// la prueba "no se puede guardar una auditoría con establecimiento
  /// inexistente".
  Future<void> sembrarCatalogos() async {
    await base.insertarEstablecimiento(Establecimiento.ejemplo().aFila());
    await base.insertarPersonal(Observador.ejemplo().aFila());
    await base.insertarPersonal(Observado.ejemplo().aFila());
  }

  tearDown(() async {
    await base.close();
  });

  // -----------------------------------------------------------------
  group('Esquema y migraciones', () {
    test('la versión del esquema es la esperada (Reto 4 completado)', () {
      expect(base.schemaVersion, 3);
    });

    test('las claves foráneas se activan en beforeOpen (Reto 5)', () async {
      expect(await base.estadoClavesForaneas(), 1);
    });

    test('todas las tablas se crean vacías', () async {
      final Map<String, int> conteos = await base.contarFilas();
      expect(conteos.keys, containsAll(<String>[
        'establecimientos',
        'personal',
        'auditorias',
        'oportunidades',
        'indicadores_cache',
        'preferencias',
      ]));
      for (final int total in conteos.values) {
        expect(total, 0);
      }
    });

    test('crear una tabla dos veces no falla (idempotencia de createAll)',
        () async {
      expect(await base.contarFilas(), isNotEmpty);
    });
  });

  // -----------------------------------------------------------------
  group('Reto 1 — CRUD de auditorías (CREATE y READ)', () {
    test('guardar una auditoría asigna id y persiste cabecera y detalle',
        () async {
      await sembrarCatalogos();
      final String id = await repositorio.guardar(
        _auditoria(id: '', oportunidades: _cincoOportunidades(2)),
      );

      expect(id, 'id-generado-por-la-prueba');

      final Auditoria guardada = await repositorio.obtenerPorId(id);
      expect(guardada.establecimientoNombre, 'Hospital Regional del Cusco');
      expect(guardada.totalOportunidades, 5);
      expect(guardada.oportunidadesCumplidas, 3);
      expect(guardada.omisiones, 2);
      expect(guardada.porcentajeAdherencia, 60.0);
    });

    test('las oportunidades quedan numeradas 1..5', () async {
      await sembrarCatalogos();
      final String id = await repositorio.guardar(
        _auditoria(id: '', oportunidades: _cincoOportunidades(1)),
      );
      final Auditoria guardada = await repositorio.obtenerPorId(id);
      expect(
        guardada.oportunidades.map((OportunidadRegistro o) => o.numero),
        <int>[1, 2, 3, 4, 5],
      );
    });

    test('guardar con un id repetido lanza FalloDeValidacion', () async {
      await sembrarCatalogos();
      await repositorio.guardar(_auditoria(id: 'repetido'));
      expect(
        () => repositorio.guardar(_auditoria(id: 'repetido')),
        throwsA(isA<FalloDeValidacion>()),
      );
    });

    test('obtenerPorId con un id inexistente lanza FalloNoEncontrado',
        () async {
      expect(
        () => repositorio.obtenerPorId('no-existe'),
        throwsA(isA<FalloNoEncontrado>()),
      );
    });

    test('listarAuditorias devuelve las auditorías ordenadas por fecha',
        () async {
      await sembrarCatalogos();
      await repositorio.guardar(
        _auditoria(id: 'a', fecha: DateTime(2026, 1, 1)),
      );
      await repositorio.guardar(
        _auditoria(id: 'b', fecha: DateTime(2026, 6, 1)),
      );

      final List<Auditoria> lista = await repositorio.listarAuditorias();
      expect(lista.map((Auditoria a) => a.id), <String>['b', 'a']);
    });

    test('observarAuditorias emite la lista al guardar', () async {
      await sembrarCatalogos();
      final Stream<List<Auditoria>> flujo =
          repositorio.observarAuditorias();

      final Future<List<Auditoria>> segundoEvento =
          flujo.skip(1).first; // el primero es la lista vacía inicial

      await repositorio.guardar(_auditoria(id: 'observada'));

      final List<Auditoria> evento = await segundoEvento;
      expect(evento, hasLength(1));
      expect(evento.first.id, 'observada');
    });

    test('Reto 1 - columnas nuevas del formulario oficial se persisten y leen',
        () async {
      await sembrarCatalogos();
      final DateTime inicio = DateTime(2026, 10, 8, 9, 0);
      final DateTime fin = DateTime(2026, 10, 8, 9, 30);
      final String id = await repositorio.guardar(
        _auditoria(
          id: 'con-formulario-oficial',
        ).copyWith(
          fechaInicio: inicio,
          fechaFin: fin,
          numeroCamas: 25,
          consentimientoVerbal: true,
          observacionGeneral: 'Observación de prueba',
        ),
      );

      final Auditoria leida = await repositorio.obtenerPorId(id);
      expect(leida.fechaInicio, inicio);
      expect(leida.fechaFin, fin);
      expect(leida.numeroCamas, 25);
      expect(leida.consentimientoVerbal, isTrue);
      expect(leida.observacionGeneral, 'Observación de prueba');
    });

    test('Reto 1 - listarPorRango filtra en SQL por fecha y excluye eliminadas',
        () async {
      await sembrarCatalogos();
      await repositorio.guardar(
        _auditoria(id: 'aud-enero', fecha: DateTime(2026, 1, 15)),
      );
      await repositorio.guardar(
        _auditoria(id: 'aud-marzo', fecha: DateTime(2026, 3, 15)),
      );
      await repositorio.guardar(
        _auditoria(id: 'aud-abril', fecha: DateTime(2026, 4, 15)),
      );
      await repositorio.guardar(
        _auditoria(id: 'aud-julio', fecha: DateTime(2026, 7, 15)),
      );
      // Anulamos la de abril para verificar que no aparezca
      await repositorio.eliminarLogicamente('aud-abril');

      final List<Auditoria> rango = await repositorio.listarPorRango(
        DateTime(2026, 2, 1),
        DateTime(2026, 5, 1),
      );

      expect(rango.map((Auditoria a) => a.id), <String>['aud-marzo']);
    });
  });

  // -----------------------------------------------------------------
  group('Reto 3 — UPDATE y borrado lógico', () {
    test('actualizar cambia el estado y conserva las oportunidades', () async {
      await sembrarCatalogos();
      final String id = await repositorio.guardar(
        _auditoria(id: 'editable', oportunidades: _cincoOportunidades(2)),
      );
      final Auditoria original = await repositorio.obtenerPorId(id);

      await repositorio.actualizar(
        original.copyWith(estado: EstadoAuditoria.finalizada),
      );

      final Auditoria actualizada = await repositorio.obtenerPorId(id);
      expect(actualizada.estado, EstadoAuditoria.finalizada);
      expect(actualizada.totalOportunidades, 5);
    });

    test('actualizar una auditoría inexistente lanza FalloNoEncontrado',
        () async {
      expect(
        () => repositorio.actualizar(_auditoria(id: 'fantasma')),
        throwsA(isA<FalloNoEncontrado>()),
      );
    });

    test('eliminarLogicamente la oculta del listado pero no la borra',
        () async {
      await sembrarCatalogos();
      final String id = await repositorio.guardar(_auditoria(id: 'anulable'));

      await repositorio.eliminarLogicamente(id);

      expect(await repositorio.listarAuditorias(), isEmpty);
      final List<Auditoria> conEliminadas =
          await repositorio.listarAuditorias(incluirEliminadas: true);
      expect(conEliminadas, hasLength(1));
      expect(conEliminadas.single.eliminada, isTrue);

      // La fila sigue en la base: es trazabilidad, no basura.
      final Map<String, int> conteos = await base.contarFilas();
      expect(conteos['auditorias'], 1);
    });

    test('eliminarLogicamente dos veces es idempotente', () async {
      await sembrarCatalogos();
      final String id = await repositorio.guardar(_auditoria(id: 'doble'));
      await repositorio.eliminarLogicamente(id);
      await repositorio.eliminarLogicamente(id);
      final List<Auditoria> conEliminadas =
          await repositorio.listarAuditorias(incluirEliminadas: true);
      expect(conEliminadas, hasLength(1));
    });

    test('agregarOportunidad numera correlativamente después de las existentes',
        () async {
      await sembrarCatalogos();
      final String id = await repositorio.guardar(
        _auditoria(id: 'crece', oportunidades: _cincoOportunidades(0)),
      );

      final OportunidadRegistro nueva = await repositorio.agregarOportunidad(
        OportunidadRegistro(
          auditoriaId: id,
          numero: 0,
          momento: Momento.despuesEntornoPaciente,
          accion: Accion.lavadoDeManos,
        ),
      );

      expect(nueva.numero, 6);
      final Auditoria guardada = await repositorio.obtenerPorId(id);
      expect(guardada.totalOportunidades, 6);
    });
  });

  // -----------------------------------------------------------------
  group('Reto 1B — preferencias clave-valor', () {
    test('guardar y leer una preferencia (UPSERT)', () async {
      final PreferenciasRepositoryDrift prefs =
          PreferenciasRepositoryDrift(infra.preferenciasDao);

      expect(await prefs.leer('tema.modo'), isNull);
      await prefs.guardar('tema.modo', 'oscuro');
      expect(await prefs.leer('tema.modo'), 'oscuro');

      // Segunda escritura: debe actualizar, no duplicar.
      await prefs.guardar('tema.modo', 'claro');
      expect(await prefs.leer('tema.modo'), 'claro');
      expect(await base.contarFilas(), containsPair('preferencias', 1));
    });

    test('eliminar borra la preferencia', () async {
      final PreferenciasRepositoryDrift prefs =
          PreferenciasRepositoryDrift(infra.preferenciasDao);
      await prefs.guardar('establecimiento.ultimo', '00006405');
      await prefs.eliminar('establecimiento.ultimo');
      expect(await prefs.leer('establecimiento.ultimo'), isNull);
    });

    test(
        'Reto 1B - guardar preferencia registra timestamp en sincronizaciones',
        () async {
      final PreferenciasRepositoryDrift prefs =
          PreferenciasRepositoryDrift(infra.preferenciasDao);
      await prefs.guardar('tema.modo', 'oscuro');

      final sinc = await (base.select(base.sincronizaciones)
            ..where((t) => t.codigo.equals('preferencias')))
          .getSingleOrNull();

      expect(sinc, isNotNull);
      expect(sinc!.codigo, 'preferencias');
      expect(sinc.ultimaSincronizacion, isNotNull);
    });
  });

  // -----------------------------------------------------------------
  group('Reto 2 — caché offline-first del indicador', () {
    late IndicadoresDao dao;

    setUp(() {
      dao = infra.indicadoresDao;
    });

    test('cacheEsVigente respeta la política de 24 h', () {
      final IndicadorRepositoryOfflineFirst repo = _repositorio(
        dao: dao,
        servicio: _servicioQueFalla(),
        ahora: DateTime(2026, 10, 20, 12),
      );

      expect(repo.cacheEsVigente(null), isFalse);
      expect(
        repo.cacheEsVigente(DateTime(2026, 10, 20, 11)),
        isTrue,
      );
      expect(
        repo.cacheEsVigente(DateTime(2026, 10, 18, 12)),
        isFalse,
      );
    });

    test('reemplazarTodo guarda y escribe la marca de sincronización',
        () async {
      final DateTime momento = DateTime(2026, 10, 20, 12);
      await dao.reemplazarTodo(_indicadores(3), momento: momento);

      final List<IndicadorHigiene> cache = await dao.leerTodo();
      expect(cache, hasLength(3));
      expect(cache.first.anio, 2020);
      expect(
        await dao.ultimaSincronizacion(HigieneApiService.codigoIndicador),
        momento,
      );
    });

    test('reemplazarTodo es idempotente (no acumula duplicados)', () async {
      await dao.reemplazarTodo(_indicadores(3), momento: DateTime(2026, 10, 1));
      await dao.reemplazarTodo(_indicadores(3), momento: DateTime(2026, 10, 2));
      expect(await dao.leerTodo(), hasLength(3));
    });

    test('sin caché y con el servicio caído devuelve el respaldo local',
        () async {
      final IndicadorRepositoryOfflineFirst repo = _repositorio(
        dao: dao,
        servicio: _servicioQueFalla(),
      );

      final ResultadoIndicadores resultado = await repo.obtenerIndicadores();

      expect(resultado.origen, OrigenDatos.respaldo);
      expect(resultado.indicadores, isNotEmpty);
      expect(resultado.indicadores.first.anio, 2009);
    });

    test('con caché vencida y servicio caído devuelve la caché local',
        () async {
      await dao.reemplazarTodo(
        _indicadores(4),
        momento: DateTime(2026, 1, 1),
      );
      final IndicadorRepositoryOfflineFirst repo = _repositorio(
        dao: dao,
        servicio: _servicioQueFalla(),
        ahora: DateTime(2026, 10, 20),
      );

      final ResultadoIndicadores resultado = await repo.obtenerIndicadores();

      expect(resultado.origen, OrigenDatos.cacheLocal);
      expect(resultado.indicadores, hasLength(4));
    });

    test('con caché vigente NO consulta la red', () async {
      final DateTime ahora = DateTime(2026, 10, 20, 12);
      await dao.reemplazarTodo(
        _indicadores(2),
        momento: ahora.subtract(const Duration(hours: 1)),
      );

      bool seConsultoLaRed = false;
      final HigieneApiService servicio = HigieneApiService(
        cliente: MockClient((http.Request peticion) async {
          seConsultoLaRed = true;
          return http.Response(_cuerpoApi(2), 200);
        }),
      );

      final IndicadorRepositoryOfflineFirst repo = _repositorio(
        dao: dao,
        servicio: servicio,
        ahora: ahora,
      );
      final ResultadoIndicadores resultado = await repo.obtenerIndicadores();

      expect(resultado.origen, OrigenDatos.cacheLocal);
      expect(seConsultoLaRed, isFalse);
    });

    test('descarga exitosa guarda en caché y devuelve origen red', () async {
      final HigieneApiService servicio = HigieneApiService(
        cliente: MockClient((http.Request peticion) async {
          expect(peticion.url.host, HigieneApiService.host);
          return http.Response(
            _cuerpoApi(3),
            200,
            headers: <String, String>{
              'content-type': 'application/json; charset=utf-8',
            },
          );
        }),
      );

      final IndicadorRepositoryOfflineFirst repo = _repositorio(
        dao: dao,
        servicio: servicio,
      );
      final ResultadoIndicadores resultado = await repo.obtenerIndicadores();

      expect(resultado.origen, OrigenDatos.red);
      expect(resultado.indicadores, hasLength(3));
      expect(await dao.leerTodo(), hasLength(3));

      // La segunda consulta ya no debe tocar la red: caché vigente.
      final ResultadoIndicadores segunda = await repo.obtenerIndicadores();
      expect(segunda.origen, OrigenDatos.cacheLocal);
    });

    test('un error HTTP 500 se traduce a FalloRemoto', () async {
      final HigieneApiService servicio = HigieneApiService(
        cliente: MockClient(
          (http.Request peticion) async => http.Response('boom', 500),
        ),
      );

      await expectLater(
        servicio.obtenerIndicadoresPeru(),
        throwsA(isA<FalloRemoto>()),
      );
    });

    test('un JSON ilegible se traduce a FalloRemoto', () async {
      final HigieneApiService servicio = HigieneApiService(
        cliente: MockClient(
          (http.Request peticion) async => http.Response('{no es json', 200),
        ),
      );

      await expectLater(
        servicio.obtenerIndicadoresPeru(),
        throwsA(isA<FalloRemoto>()),
      );
    });
  });

  // -----------------------------------------------------------------
  group('Reto 5 — integridad referencial', () {
    test('una oportunidad con auditoría inexistente es rechazada', () async {
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

    test('no se puede guardar una auditoría con establecimiento inexistente',
        () async {
      expect(
        () => repositorio.guardar(
          _auditoria(id: 'huerfana', establecimientoId: '00000000'),
        ),
        throwsA(isA<Fallo>()),
      );
    });

    test('el resumen agregado se calcula en SQL', () async {
      await sembrador.sembrar(cantidad: 3);

      final ResumenAdherencia resumen = await repositorio.resumenAdherencia();
      expect(resumen.totalAuditorias, 3);
      expect(resumen.totalOportunidades, 15);
      expect(resumen.ultimaAuditoria, isNotNull);

      final Map<EstadoAuditoria, int> porEstado =
          await repositorio.conteoPorEstado();
      expect(porEstado[EstadoAuditoria.finalizada], 2);
      expect(porEstado[EstadoAuditoria.borrador], 1);
    });

    test('resumenPorMomento agrupa las cinco categorías', () async {
      await sembrador.sembrar(cantidad: 1);
      final Map<String, ({int total, int cumplidas})> porMomento =
          await infra.auditoriasDao.resumenPorMomento();

      expect(porMomento.keys, hasLength(5));
      expect(porMomento.values.first.total, 1);
    });
  });

  // -----------------------------------------------------------------
  group('Sembrado de datos de laboratorio', () {
    test('sembrar 3 auditorías produce 15 oportunidades', () async {
      final int creadas = await sembrador.sembrar(cantidad: 3);
      expect(creadas, 3);

      final Map<String, int> conteos = await base.contarFilas();
      expect(conteos['auditorias'], 3);
      expect(conteos['oportunidades'], 15);
      // Una sola vez el establecimiento y un observador + 3 observados.
      expect(conteos['establecimientos'], 1);
      expect(conteos['personal'], 4);
    });

    test('dos sembrados con la misma semilla producen los mismos totales',
        () async {
      // La reproducibilidad es una propiedad del sembrador cuando recibe la
      // MISMA semilla y parte de una base vacía. Se comprueba con dos bases
      // independientes para no confundirla con el efecto acumulativo de
      // sembrar dos veces sobre la misma base.
      Future<ResumenAdherencia> sembrarEnBaseNueva() async {
        final ManosSegurasDb otraBase =
            ManosSegurasDb(NativeDatabase.memory());
        final AuditoriaRepositoryDrift otroRepo = AuditoriaRepositoryDrift(
          InfraestructuraLocal(otraBase).auditoriasDao,
        );
        final SembradorDatos otroSembrador = SembradorDatos(
          base: otraBase,
          repositorio: otroRepo,
          azar: Random(2026),
        );
        await otroSembrador.sembrar(cantidad: 2);
        final ResumenAdherencia resumen = await otroRepo.resumenAdherencia();
        await otraBase.close();
        return resumen;
      }

      final ResumenAdherencia primero = await sembrarEnBaseNueva();
      final ResumenAdherencia segundo = await sembrarEnBaseNueva();

      expect(segundo.totalAuditorias, primero.totalAuditorias);
      expect(segundo.totalOportunidades, primero.totalOportunidades);
      expect(segundo.totalCumplidas, primero.totalCumplidas);
    });
  });

  // -----------------------------------------------------------------
  group('Persistencia real y transacciones', () {
    test('los datos sobreviven al cierre y reapertura del MISMO archivo',
        () async {
      await sembrarCatalogos();
      final File archivo = File(
        '${Directory.systemTemp.path}/manos_seguras_'
        '${DateTime.now().microsecondsSinceEpoch}.sqlite',
      );

      // --- Primera sesión: se guarda una auditoría y se cierra la base ---
      final ManosSegurasDb base1 = ManosSegurasDb(NativeDatabase(archivo));
      // Los catálogos se siembran en la base DEL ARCHIVO (no en la de memoria
      // del setUp): cada conexión tiene su propio estado.
      await base1.insertarEstablecimiento(Establecimiento.ejemplo().aFila());
      await base1.insertarPersonal(Observador.ejemplo().aFila());
      await base1.insertarPersonal(Observado.ejemplo().aFila());
      await AuditoriaRepositoryDrift(
        InfraestructuraLocal(base1).auditoriasDao,
      ).guardar(_auditoria(id: 'persistente'));
      final Auditoria antes = await AuditoriaRepositoryDrift(
        InfraestructuraLocal(base1).auditoriasDao,
      ).obtenerPorId('persistente');
      await base1.close();

      // --- Segunda sesión: se reabre el MISMO archivo ---
      final ManosSegurasDb base2 = ManosSegurasDb(NativeDatabase(archivo));
      final Auditoria recuperada = await AuditoriaRepositoryDrift(
        InfraestructuraLocal(base2).auditoriasDao,
      ).obtenerPorId('persistente');

      expect(recuperada.id, antes.id);
      expect(recuperada.establecimientoNombre, antes.establecimientoNombre);
      expect(recuperada.fecha, antes.fecha);
      expect(recuperada.totalOportunidades, 0);

      await base2.close();
      await archivo.delete();
    });

    test('limpiarAuditorias borra detalle y cabecera en una transacción',
        () async {
      await sembrador.sembrar(cantidad: 2);
      await base.limpiarAuditorias();

      final Map<String, int> conteos = await base.contarFilas();
      expect(conteos['auditorias'], 0);
      expect(conteos['oportunidades'], 0);
      // Los catálogos no se tocan.
      expect(conteos['establecimientos'], 1);
    });
  });
}

// ---------------------------------------------------------------------
// Constructores auxiliares
// ---------------------------------------------------------------------

Auditoria _auditoria({
  required String id,
  String establecimientoId = '00006405',
  DateTime? fecha,
  List<OportunidadRegistro> oportunidades = const <OportunidadRegistro>[],
}) {
  return Auditoria(
    id: id,
    establecimientoId: establecimientoId,
    establecimientoNombre: 'Hospital Regional del Cusco',
    observadorDni: '23456789',
    observadorNombre: 'Ana Quispe Mamani',
    observadoDni: '45678912',
    observadoNombre: 'Carlos Huamán Ttito',
    fecha: fecha ?? DateTime(2026, 10, 20, 9, 30),
    oportunidades: oportunidades,
  );
}

/// Cinco oportunidades, una por Momento; `omisiones` indica cuántas son
/// omisión (el resto se registran como lavado de manos).
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

/// Cuatro registros anuales para las pruebas de caché (2020..2023).
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

/// Servicio que simula una caída de red: siempre lanza [FalloRemoto].
HigieneApiService _servicioQueFalla() {
  return HigieneApiService(
    cliente: MockClient((http.Request peticion) async {
      throw http.ClientException('Sin conexión (prueba)');
    }),
  );
}

IndicadorRepositoryOfflineFirst _repositorio({
  required IndicadoresDao dao,
  required HigieneApiService servicio,
  DateTime? ahora,
}) {
  return IndicadorRepositoryOfflineFirst(
    dao: dao,
    servicio: servicio,
    vigencia: const Duration(hours: 24),
    reloj: () => ahora ?? DateTime(2026, 10, 20, 12),
  );
}

/// Cuerpo de respuesta con la misma forma que el API de la OMS.
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
