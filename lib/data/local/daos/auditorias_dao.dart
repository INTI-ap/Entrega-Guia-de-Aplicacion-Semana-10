import 'dart:convert';
import 'package:drift/drift.dart';

import '../../../domain/entidades/auditoria.dart';
import '../../../domain/entidades/oportunidad_registro.dart';
// De la biblioteca de la base solo se usan las filas generadas
// (`db.Auditoria`, `db.Oportunidade`, …) y la clase `db.ManosSegurasDb`. El
// prefijo evita que las *data classes* generadas choquen con las entidades del
// dominio (las dos se llaman `Auditoria`).
import '../../local/manos_seguras_db.dart' as db;
import '../../mapeadores/mapeadores.dart';
// Para los parámetros de `where()` y `orderBy()` se usan los alias públicos de
// `aliases.dart`: las clases de tabla generadas (`$AuditoriasTable`) son
// privadas de la biblioteca de la base y no se pueden nombrar desde aquí.
import '../aliases.dart' as g;

/// **Contrato del DAO de auditorías (Data Access Object).**
///
/// Semana 10 — temática 2.2.3 (patrón DAO y migraciones básicas).
///
/// Un DAO agrupa todas las consultas de un agregado (aquí: la auditoría y
/// sus oportunidades) y **no** contiene reglas de negocio ni maneja
/// transacciones de varios agregados. Su ventaja frente a escribir SQL
/// suelto en la pantalla es que:
///
///  * las consultas quedan en un solo lugar y son reutilizables;
///  * el repositorio se prueba con un DAO doble;
///  * cambiar el motor (por ejemplo a Firestore) no toca la interfaz.
///
/// La implementación real es [DriftAuditoriasDao]; la interfaz permite
/// escribir un doble en memoria para los *widget tests*.
abstract interface class AuditoriasDao {
  Future<T> transaccion<T>(Future<T> Function() accion);
  Future<void> registrarCambios(Auditoria anterior, Auditoria nueva);
  Future<String?> auditoriaDeOportunidad(int id);

  /// Emite la lista completa cada vez que cambia `auditorias` o
  /// `oportunidades`.
  ///
  /// **Pista de implementación:** `select(auditorias).watch()` ya emite una
  /// lista en cada cambio; agregue las oportunidades de cada auditoría
  /// dentro de un `asyncMap` y devuelva `List<Auditoria>`.
  Stream<List<Auditoria>> observar({bool incluirEliminadas = false});

  /// Lectura puntual de todas las auditorías, con su detalle.
  ///
  /// Reto 5: [limite] y [offset] implementan paginación en SQL para no
  /// cargar 10 000 filas en un ListView.
  Future<List<Auditoria>> listar({
    bool incluirEliminadas = false,
    int? limite,
    int? offset,
  });

  /// Lista solo las auditorías activas dentro del rango [desde] y [hasta].
  /// Reto 1: filtra a nivel de SQL (`where`), no en memoria.
  Future<List<Auditoria>> listarPorRango(
    DateTime desde,
    DateTime hasta, {
    int? limite,
    int? offset,
  });

  /// Lee una auditoría concreta con su detalle.
  Future<Auditoria?> buscarPorId(String id);

  /// Inserta la cabecera. Devuelve `false` si el `id` ya existía.
  ///
  /// **Reto 1:** use `insertReturningOrNull` o `insertOnConflictUpdate`
  /// según la semántica que decida para su proyecto, y documéntela.
  Future<bool> insertarCabecera(Auditoria auditoria);

  /// Actualiza la cabecera. Devuelve el número de filas afectadas.
  Future<int> actualizarCabecera(Auditoria auditoria);

  /// Marca `eliminada = true` (borrado lógico). Reto 3.
  Future<int> marcarEliminada(String id);

  /// Restaura una auditoría anulada marcando `eliminada = false`. Reto 3.
  Future<int> restaurar(String id);

  /// Elimina físicamente las filas de `oportunidades` de una auditoría.
  Future<int> borrarOportunidadesDe(String auditoriaId);

  /// Inserta una oportunidad y devuelve la fila creada (con su `id`).
  Future<OportunidadRegistro> insertarOportunidad(
    OportunidadRegistro oportunidad,
  );

  /// Elimina una oportunidad por su clave primaria.
  Future<int> borrarOportunidad(int id);

  /// Cuenta las auditorías por estado, con `GROUP BY` en SQL.
  Future<Map<EstadoAuditoria, int>> conteoPorEstado();

  /// Calcula el resumen de adherencia con `SUM`/`COUNT` en SQL. Reto 5.
  Future<ResumenAdherencia> resumenAdherencia();

  /// Cuenta de oportunidades por momento, con `GROUP BY`. Reto 5.
  Future<Map<String, ({int total, int cumplidas})>> resumenPorMomento();

  /// Reto 5: devuelve el plan de ejecución de la consulta del listado
  /// (`EXPLAIN QUERY PLAN`) para demostrar que usa el índice
  /// `idx_auditorias_estado_fecha`.
  Future<String> explicarPlanListado();
}

/// **Implementación de referencia con drift.**
///
/// Extiende `DatabaseAccessor<ManosSegurasDb>`, la clase base que drift expone
/// para escribir DAO fuera del archivo de la base. **No** se anota con
/// `@DriftAccessor`: ver el Anexo A (Error 7) de la guía. El DAO se construye
/// en `InfraestructuraLocal` y se inyecta con get_it.
///
/// Los métodos marcados con `TODO(reto-n)` son los que el estudiante debe
/// completar; el resto se entrega funcionando para que el proyecto compile
/// y las pruebas puedan ejecutarse desde el primer minuto.
class DriftAuditoriasDao extends DatabaseAccessor<db.ManosSegurasDb>
    implements AuditoriasDao {
  DriftAuditoriasDao(super.db);

  @override
  Future<T> transaccion<T>(Future<T> Function() accion) =>
      attachedDatabase.transaction(accion);

  @override
  Future<void> registrarCambios(Auditoria anterior, Auditoria nueva) async {
    final antes = _valores(anterior);
    final despues = _valores(nueva);
    final fecha = DateTime.now();
    for (final campo in antes.keys) {
      if (antes[campo] == despues[campo]) continue;
      await into(attachedDatabase.auditoriasHistorial).insert(
        db.AuditoriasHistorialCompanion.insert(
          auditoriaId: nueva.id,
          fecha: fecha,
          campo: campo,
          valorAnterior: Value(antes[campo]),
          valorNuevo: Value(despues[campo]),
        ),
      );
    }
  }

  Map<String, String?> _valores(Auditoria a) => {
    'establecimientoId': a.establecimientoId,
    'establecimientoNombre': a.establecimientoNombre,
    'observadorDni': a.observadorDni,
    'observadorNombre': a.observadorNombre,
    'observadoDni': a.observadoDni,
    'observadoNombre': a.observadoNombre,
    'fecha': a.fecha.toIso8601String(),
    'estado': a.estado.clave,
    'eliminada': a.eliminada.toString(),
    'sincronizadaEn': a.sincronizadaEn?.toIso8601String(),
    'fechaInicio': a.fechaInicio?.toIso8601String(),
    'fechaFin': a.fechaFin?.toIso8601String(),
    'numeroCamas': a.numeroCamas?.toString(),
    'consentimientoVerbal': a.consentimientoVerbal?.toString(),
    'observacionGeneral': a.observacionGeneral,
    'oportunidades': jsonEncode(
      a.oportunidades
          .map(
            (o) => {
              'numero': o.numero,
              'momento': o.momento.clave,
              'accion': o.accion.clave,
              'observacion': o.observacion,
              'duracionSegundos': o.duracionSegundos,
            },
          )
          .toList(),
    ),
  };

  @override
  Stream<List<Auditoria>> observar({bool incluirEliminadas = false}) {
    final SimpleSelectStatement<g.TablaAuditorias, db.Auditoria> consulta =
        select(attachedDatabase.auditorias);
    if (!incluirEliminadas) {
      consulta.where((g.TablaAuditorias t) => t.eliminada.equals(false));
    }

    return consulta.watch().asyncMap(
      (List<db.Auditoria> filas) =>
          _conOportunidades(filas, incluirEliminadas: incluirEliminadas),
    );
  }

  @override
  Future<List<Auditoria>> listar({
    bool incluirEliminadas = false,
    int? limite,
    int? offset,
  }) async {
    final List<db.Auditoria> filas = await _cabeceras(
      incluirEliminadas: incluirEliminadas,
      limite: limite,
      offset: offset,
    );
    return _conOportunidades(filas, incluirEliminadas: incluirEliminadas);
  }

  /// **Reto 1 (consigna 6):** filtra por rango directamente en SQL usando `where()`.
  /// Reto 5: acepta [limite]/[offset] para paginar.
  @override
  Future<List<Auditoria>> listarPorRango(
    DateTime desde,
    DateTime hasta, {
    int? limite,
    int? offset,
  }) async {
    final SimpleSelectStatement<g.TablaAuditorias, db.Auditoria> consulta =
        select(attachedDatabase.auditorias)
          ..where(
            (g.TablaAuditorias t) =>
                t.eliminada.equals(false) &
                t.fecha.isBiggerOrEqualValue(desde) &
                t.fecha.isSmallerOrEqualValue(hasta),
          )
          ..orderBy(<OrderingTerm Function(g.TablaAuditorias)>[
            (g.TablaAuditorias t) => OrderingTerm.desc(t.fecha),
          ]);
    // Reto 5: paginación en SQL. Cargar 10 000 filas en un ListView agota
    // memoria y batería aunque "funcione": se pagina con LIMIT/OFFSET.
    if (limite != null) {
      consulta.limit(limite, offset: offset ?? 0);
    }
    final List<db.Auditoria> filas = await consulta.get();
    return _conOportunidades(filas);
  }

  @override
  Future<Auditoria?> buscarPorId(String id) async {
    final db.Auditoria? cabecera = await (select(
      attachedDatabase.auditorias,
    )..where((g.TablaAuditorias t) => t.id.equals(id))).getSingleOrNull();

    if (cabecera == null) return null;

    final List<db.Oportunidade> oportunidades = await _oportunidadesDe(
      cabecera.id,
    );
    return AuditoriaMapper.desdeFilas(cabecera, oportunidades);
  }

  @override
  Future<bool> insertarCabecera(Auditoria auditoria) async {
    final db.Auditoria? existente =
        await (select(attachedDatabase.auditorias)
              ..where((g.TablaAuditorias t) => t.id.equals(auditoria.id)))
            .getSingleOrNull();

    if (existente != null) return false;

    await into(attachedDatabase.auditorias).insert(auditoria.aCabeceraFila());
    return true;
  }

  /// **Versión base del Reto 3.** Actualiza la cabecera y refresca la marca
  /// `actualizadoEn`.
  ///
  /// TODO(reto-3, mejora): extienda esta operación para que:
  ///   * conserve la fecha original de la observación (`fecha`) y no la
  ///     sobrescriba con "ahora";
  ///   * devuelva la auditoría actualizada (no solo el número de filas);
  ///   * registre en `sincronizaciones` que el registro quedó pendiente de
  ///     envío al servidor.
  @override
  Future<int> actualizarCabecera(Auditoria auditoria) {
    return (update(
      attachedDatabase.auditorias,
    )..where((g.TablaAuditorias t) => t.id.equals(auditoria.id))).write(
      auditoria.aCabeceraFila().copyWith(
        actualizadoEn: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  /// **Reto 3.** Borrado lógico: la fila nunca se elimina
  /// físicamente para no perder la trazabilidad que exige la norma.
  @override
  Future<int> marcarEliminada(String id) {
    return (update(
      attachedDatabase.auditorias,
    )..where((g.TablaAuditorias t) => t.id.equals(id))).write(
      db.AuditoriasCompanion(
        eliminada: const Value<bool>(true),
        actualizadoEn: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  /// **Reto 3.** Restauración de una auditoría anulada.
  @override
  Future<int> restaurar(String id) {
    return (update(
      attachedDatabase.auditorias,
    )..where((g.TablaAuditorias t) => t.id.equals(id))).write(
      db.AuditoriasCompanion(
        eliminada: const Value<bool>(false),
        actualizadoEn: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  @override
  Future<int> borrarOportunidadesDe(String auditoriaId) {
    return (delete(
          attachedDatabase.oportunidades,
        )..where((g.TablaOportunidades t) => t.auditoriaId.equals(auditoriaId)))
        .go();
  }

  @override
  Future<OportunidadRegistro> insertarOportunidad(
    OportunidadRegistro oportunidad,
  ) async {
    final int id = await into(
      attachedDatabase.oportunidades,
    ).insert(oportunidad.aFila());
    return oportunidad.copyWith(id: id);
  }

  @override
  Future<String?> auditoriaDeOportunidad(int id) async {
    final fila = await customSelect(
      'SELECT auditoria_id FROM oportunidades WHERE id = ?',
      variables: [Variable<int>(id)],
      readsFrom: {attachedDatabase.oportunidades},
    ).getSingleOrNull();
    return fila?.read<String>('auditoria_id');
  }

  @override
  Future<int> borrarOportunidad(int id) {
    return (delete(
      attachedDatabase.oportunidades,
    )..where((g.TablaOportunidades t) => t.id.equals(id))).go();
  }

  /// **Versión base con SQL agregado.**
  ///
  /// Demuestra el patrón `customSelect` + `GROUP BY`, que es el que hay que
  /// dominar en la temática 2.2.3. TODO(reto-5): compárela con una versión
  /// que además filtre por rango de fechas usando índices.
  @override
  Future<Map<EstadoAuditoria, int>> conteoPorEstado() async {
    final List<QueryRow> filas = await customSelect(
      'SELECT estado, COUNT(*) AS total FROM auditorias '
      'WHERE eliminada = 0 GROUP BY estado',
      readsFrom: <ResultSetImplementation<Object?, Object?>>{
        attachedDatabase.auditorias,
      },
    ).get();

    final Map<EstadoAuditoria, int> conteo = <EstadoAuditoria, int>{
      for (final EstadoAuditoria estado in EstadoAuditoria.values) estado: 0,
    };

    for (final QueryRow fila in filas) {
      final EstadoAuditoria estado = EstadoAuditoria.desdeClave(
        fila.read<String>('estado'),
      );
      conteo[estado] = fila.read<int>('total');
    }

    return conteo;
  }

  /// **Versión base con una sola consulta agregada.**
  ///
  /// El promedio de adherencia se calcula en SQL: `SUM` de cumplimientos
  /// sobre `COUNT` de oportunidades. Así, con 10 000 filas, la pantalla no
  /// carga 10 000 objetos en memoria (Reto 5).
  @override
  Future<ResumenAdherencia> resumenAdherencia() async {
    // Nota de SQLite: las cadenas literales van con comillas SIMPLES. Con
    // comillas dobles SQLite busca un identificador (una columna llamada
    // "omision") y falla con "no such column".
    final QueryRow fila = await customSelect(
      "SELECT "
      "  COUNT(DISTINCT a.id)                                   AS total_auditorias, "
      "  COUNT(o.id)                                            AS total_oportunidades, "
      "  COALESCE(SUM(CASE WHEN o.accion_clave = 'omision' "
      "                    THEN 0 ELSE 1 END), 0)               AS total_cumplidas, "
      "  MAX(a.fecha)                                           AS ultima "
      "FROM auditorias a "
      "LEFT JOIN oportunidades o ON o.auditoria_id = a.id "
      "WHERE a.eliminada = 0",
      readsFrom: <ResultSetImplementation<Object?, Object?>>{
        attachedDatabase.auditorias,
        attachedDatabase.oportunidades,
      },
    ).getSingle();

    final int totalOportunidades = fila.read<int?>('total_oportunidades') ?? 0;
    if (totalOportunidades == 0) return ResumenAdherencia.vacio();

    final DateTime? ultima = fila.read<DateTime?>('ultima');

    return ResumenAdherencia(
      totalAuditorias: fila.read<int?>('total_auditorias') ?? 0,
      totalOportunidades: totalOportunidades,
      totalCumplidas: fila.read<int?>('total_cumplidas') ?? 0,
      promedioAdherencia:
          (fila.read<int?>('total_cumplidas') ?? 0) / totalOportunidades * 100,
      ultimaAuditoria: ultima,
    );
  }

  /// **Reto 5 (rendimiento): agregación en SQL con GROUP BY.**
  ///
  /// Calcula por momento: total y cumplidas (accion != 'omision'),
  /// solo sobre auditorías activas. Una sola fila por momento, sin cargar
  /// 5 000 objetos en memoria.
  @override
  Future<Map<String, ({int total, int cumplidas})>> resumenPorMomento() async {
    final List<QueryRow> filas = await customSelect(
      "SELECT o.momento_clave AS momento, "
      "COUNT(o.id) AS total, "
      "COALESCE(SUM(CASE WHEN o.accion_clave = 'omision' "
      "THEN 0 ELSE 1 END), 0) AS cumplidas "
      "FROM oportunidades o "
      "INNER JOIN auditorias a ON a.id = o.auditoria_id "
      "WHERE a.eliminada = 0 "
      "GROUP BY o.momento_clave",
      readsFrom: <ResultSetImplementation<Object?, Object?>>{
        attachedDatabase.auditorias,
        attachedDatabase.oportunidades,
      },
    ).get();
    final Map<String, ({int total, int cumplidas})> resultado =
        <String, ({int total, int cumplidas})>{};
    for (final QueryRow fila in filas) {
      resultado[fila.read<String>('momento')] = (
        total: fila.read<int>('total'),
        cumplidas: fila.read<int>('cumplidas'),
      );
    }
    return resultado;
  }

  @override
  Future<String> explicarPlanListado() async {
    final List<QueryRow> filas = await customSelect(
      'EXPLAIN QUERY PLAN SELECT * FROM auditorias '
      'WHERE eliminada = 0 ORDER BY fecha DESC',
      readsFrom: <ResultSetImplementation<Object?, Object?>>{
        attachedDatabase.auditorias,
      },
    ).get();
    return filas
        .map((QueryRow f) => f.read<String?>('detail') ?? '')
        .join('\n');
  }

  // -------------------------------------------------------------------
  // Auxiliares privados
  // -------------------------------------------------------------------

  Future<List<db.Auditoria>> _cabeceras({
    bool incluirEliminadas = false,
    int? limite,
    int? offset,
  }) {
    final SimpleSelectStatement<g.TablaAuditorias, db.Auditoria> consulta =
        select(attachedDatabase.auditorias)
          ..orderBy(<OrderClauseGenerator<g.TablaAuditorias>>[
            (g.TablaAuditorias t) =>
                OrderingTerm(expression: t.fecha, mode: OrderingMode.desc),
          ]);
    if (!incluirEliminadas) {
      consulta.where((g.TablaAuditorias t) => t.eliminada.equals(false));
    }
    if (limite != null) {
      consulta.limit(limite, offset: offset ?? 0);
    }
    return consulta.get();
  }

  Future<List<db.Oportunidade>> _oportunidadesDe(String auditoriaId) {
    return (select(attachedDatabase.oportunidades)
          ..where((g.TablaOportunidades t) => t.auditoriaId.equals(auditoriaId))
          ..orderBy(<OrderClauseGenerator<g.TablaOportunidades>>[
            (g.TablaOportunidades t) => OrderingTerm(expression: t.numero),
          ]))
        .get();
  }

  Future<List<Auditoria>> _conOportunidades(
    List<db.Auditoria> filas, {
    bool incluirEliminadas = false,
  }) async {
    final List<Auditoria> resultado = <Auditoria>[];
    for (final db.Auditoria fila in filas) {
      final List<db.Oportunidade> oportunidades = await _oportunidadesDe(
        fila.id,
      );
      resultado.add(AuditoriaMapper.desdeFilas(fila, oportunidades));
    }
    return resultado;
  }
}
