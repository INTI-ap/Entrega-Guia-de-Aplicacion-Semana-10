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
  /// Emite la lista completa cada vez que cambia `auditorias` o
  /// `oportunidades`.
  ///
  /// **Pista de implementación:** `select(auditorias).watch()` ya emite una
  /// lista en cada cambio; agregue las oportunidades de cada auditoría
  /// dentro de un `asyncMap` y devuelva `List<Auditoria>`.
  Stream<List<Auditoria>> observar({bool incluirEliminadas = false});

  /// Lectura puntual de todas las auditorías, con su detalle.
  Future<List<Auditoria>> listar({bool incluirEliminadas = false});

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
  Future<List<Auditoria>> listar({bool incluirEliminadas = false}) async {
    final List<db.Auditoria> filas = await _cabeceras(
      incluirEliminadas: incluirEliminadas,
    );
    return _conOportunidades(filas, incluirEliminadas: incluirEliminadas);
  }

  @override
  Future<Auditoria?> buscarPorId(String id) async {
    final db.Auditoria? cabecera = await (select(attachedDatabase.auditorias)
          ..where((g.TablaAuditorias t) => t.id.equals(id)))
        .getSingleOrNull();

    if (cabecera == null) return null;

    final List<db.Oportunidade> oportunidades =
        await _oportunidadesDe(cabecera.id);
    return AuditoriaMapper.desdeFilas(cabecera, oportunidades);
  }

  @override
  Future<bool> insertarCabecera(Auditoria auditoria) async {
    final db.Auditoria? existente = await (select(attachedDatabase.auditorias)
          ..where((g.TablaAuditorias t) => t.id.equals(auditoria.id)))
        .getSingleOrNull();

    if (existente != null) return false;

    await into(attachedDatabase.auditorias)
        .insert(auditoria.aCabeceraFila());
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
    return (update(attachedDatabase.auditorias)
          ..where((g.TablaAuditorias t) => t.id.equals(auditoria.id)))
        .write(
      auditoria.aCabeceraFila().copyWith(
            actualizadoEn: Value<DateTime>(DateTime.now()),
          ),
    );
  }

  /// **Versión base del Reto 3.** Borrado lógico: la fila nunca se elimina
  /// físicamente para no perder la trazabilidad que exige la norma.
  ///
  /// TODO(reto-3, mejora): implemente `restaurar(String id)` y
  /// `listarEliminadas()`, y agregue una prueba que verifique que el borrado
  /// lógico no rompe las claves foráneas del detalle.
  @override
  Future<int> marcarEliminada(String id) {
    return (update(attachedDatabase.auditorias)
          ..where((g.TablaAuditorias t) => t.id.equals(id)))
        .write(
      db.AuditoriasCompanion(
        eliminada: const Value<bool>(true),
        actualizadoEn: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  @override
  Future<int> borrarOportunidadesDe(String auditoriaId) {
    return (delete(attachedDatabase.oportunidades)
          ..where((g.TablaOportunidades t) => t.auditoriaId.equals(auditoriaId)))
        .go();
  }

  @override
  Future<OportunidadRegistro> insertarOportunidad(
    OportunidadRegistro oportunidad,
  ) async {
    final int id = await into(attachedDatabase.oportunidades)
        .insert(oportunidad.aFila());
    return oportunidad.copyWith(id: id);
  }

  @override
  Future<int> borrarOportunidad(int id) {
    return (delete(attachedDatabase.oportunidades)
          ..where((g.TablaOportunidades t) => t.id.equals(id)))
        .go();
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
      final EstadoAuditoria estado =
          EstadoAuditoria.desdeClave(fila.read<String>('estado'));
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

  /// **Reto 5 (rendimiento).**
  ///
  /// TODO(reto-5): reescriba esta agregación con `GROUP BY momento_clave` y
  /// compare el tiempo con 1 000 oportunidades sembradas. La versión base
  /// resuelve el cálculo en memoria para que la pantalla funcione desde el
  /// primer minuto.
  @override
  Future<Map<String, ({int total, int cumplidas})>> resumenPorMomento() async {
    final List<Auditoria> auditorias = await listar();
    final Map<String, ({int total, int cumplidas})> acumulado =
        <String, ({int total, int cumplidas})>{};

    for (final Auditoria auditoria in auditorias) {
      for (final OportunidadRegistro oportunidad in auditoria.oportunidades) {
        final String clave = oportunidad.momento.clave;
        final ({int total, int cumplidas}) actual =
            acumulado[clave] ?? (total: 0, cumplidas: 0);
        acumulado[clave] = (
          total: actual.total + 1,
          cumplidas: actual.cumplidas + (oportunidad.cumplio ? 1 : 0),
        );
      }
    }

    return acumulado;
  }

  // -------------------------------------------------------------------
  // Auxiliares privados
  // -------------------------------------------------------------------

  Future<List<db.Auditoria>> _cabeceras({
    bool incluirEliminadas = false,
  }) {
    final SimpleSelectStatement<g.TablaAuditorias, db.Auditoria> consulta =
        select(attachedDatabase.auditorias)
          ..orderBy(<OrderClauseGenerator<g.TablaAuditorias>>[
            (g.TablaAuditorias t) => OrderingTerm(
                  expression: t.fecha,
                  mode: OrderingMode.desc,
                ),
          ]);
    if (!incluirEliminadas) {
      consulta.where((g.TablaAuditorias t) => t.eliminada.equals(false));
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
      final List<db.Oportunidade> oportunidades =
          await _oportunidadesDe(fila.id);
      resultado.add(AuditoriaMapper.desdeFilas(fila, oportunidades));
    }
    return resultado;
  }
}
