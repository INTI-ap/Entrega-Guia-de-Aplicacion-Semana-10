import 'package:drift/drift.dart';

// Las tablas se importan **sin prefijo**: el código que genera drift declara
// `class $PersonalTable extends Personal` dentro de esta misma biblioteca, de
// modo que las clases de tabla deben estar visibles sin calificar. Este
// archivo, por diseño, no importa entidades del dominio ni mapeadores: solo
// declara el esquema, la versión y las migraciones.
import 'tablas/auditorias.dart';
import 'tablas/auditorias_historial.dart';
import 'tablas/establecimientos.dart';
import 'tablas/indicadores_cache.dart';
import 'tablas/oportunidades.dart';
import 'tablas/personal.dart';
import 'tablas/preferencias.dart';

part 'manos_seguras_db.g.dart';

/// **Base de datos local de ManosSeguras (drift + SQLite).**
///
/// Semana 10 — temáticas 2.2.1, 2.2.2 y 2.2.3.
///
/// `@DriftDatabase` enumera las tablas y los DAO que forman parte de la
/// base. `build_runner` genera, en `manos_seguras_db.g.dart`:
///
///  * una *data class* por tabla (`db.Auditoria`, `db.Oportunidad`, …);
///  * un `Companion` por tabla, usado para insertar y actualizar;
///  * los *getters* `auditorias`, `oportunidades`, `indicadoresCache`,
///    `preferencias`, `sincronizaciones`, `establecimientos` y `personal`;
///  * los *getters* tipados de cada tabla (`auditorias`, `oportunidades`, …).
///
/// **Regla de oro de este archivo:** la base de datos no contiene reglas de
/// negocio, ni mapeos, ni conoce los DAO. Solo declara el esquema, la versión
/// y las migraciones. Por eso **no** lleva `daos:` en la anotación: los DAO
/// se construyen en `InfraestructuraLocal` (`infraestructura.dart`).
///
/// ¿Por qué? Porque declararlos aquí crearía un ciclo de imports
/// (`db` → `dao` → `db`) y el generador de drift, al no poder resolver el tipo
/// de la base, emitiría `DatabaseAccessor<dynamic /* = invalid */>` en el
/// código generado. Es un error real que apareció al elaborar esta guía y se
/// documenta en el Anexo A (Error 7): la solución es sacar el *wiring* del
/// archivo de la base.
///
/// **Versionado del esquema.** [schemaVersion] empieza en 1. Cambiar el
/// esquema sin subir este número deja a los usuarios con una base
/// incompatible; subirlo sin escribir la migración lanza la excepción
/// "You've bumped the schema version but didn't provide a strategy".
/// Ese es el escenario del **Reto 4**.
@DriftDatabase(
  tables: <Type>[
    Establecimientos,
    Personal,
    Auditorias,
    AuditoriasHistorial,
    Oportunidades,
    IndicadoresCache,
    Sincronizaciones,
    Preferencias,
  ],
)
class ManosSegurasDb extends _$ManosSegurasDb {
  ManosSegurasDb(super.executor);

  @override
  int get schemaVersion => 3;

  /// Estrategia de migración.
  ///
  /// **Reto 4.** Migración incremental v1 -> v2 sin pérdida de datos.
  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int desde, int hasta) async {
        if (desde < 2) {
          await m.addColumn(auditorias, auditorias.fechaInicio);
          await m.addColumn(auditorias, auditorias.fechaFin);
          await m.addColumn(auditorias, auditorias.numeroCamas);
          await m.addColumn(auditorias, auditorias.consentimientoVerbal);
          await m.addColumn(auditorias, auditorias.observacionGeneral);
          await m.addColumn(oportunidades, oportunidades.duracionSegundos);
          // Reto 2: contador de fallos consecutivos por recurso.
          await m.addColumn(
            sincronizaciones,
            sincronizaciones.intentosFallidos,
          );
          // Reto 5: índice compuesto (estado, fecha) para el listado.
          // En bases ya instaladas el índice no se crea solo: se crea aquí.
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_auditorias_estado_fecha '
            'ON auditorias (estado, fecha)',
          );

          await customStatement(
            "UPDATE auditorias SET observacion_general = '' "
            "WHERE observacion_general IS NULL",
          );
        }
        if (desde < 3) {
          await m.createTable(auditoriasHistorial);
        }
      },
      beforeOpen: (OpeningDetails detalles) async {
        // `PRAGMA foreign_keys = ON` NO viene activado por omisión en
        // SQLite: sin esta línea las cláusulas REFERENCES son decorativas.
        // Activarlo es la mitad del Reto 5; la otra mitad es probarlo.
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // -------------------------------------------------------------------
  // Utilidades de diagnóstico y de siembra (solo laboratorio)
  // -------------------------------------------------------------------

  /// Inserta o actualiza un establecimiento a partir de su *companion*.
  ///
  /// Se expone aquí —y no se accede al *getter* `establecimientos` desde
  /// fuera— para que todo el acceso a SQL pase por la base de datos o por
  /// sus DAO: es la misma regla de encapsulamiento que se aplica en el
  /// resto del proyecto (Ley de Demeter).
  Future<void> insertarEstablecimiento(
    EstablecimientosCompanion fila,
  ) async {
    await into(establecimientos).insertOnConflictUpdate(fila);
  }

  /// Inserta o actualiza una persona (observador u observado).
  Future<void> insertarPersonal(PersonalCompanion fila) async {
    await into(personal).insertOnConflictUpdate(fila);
  }

  /// Cuenta las filas de cada tabla, para la pantalla de diagnóstico.
  Future<Map<String, int>> contarFilas() async {
    Future<int> contar(TableInfo<Table, Object?> tabla) async {
      final QueryRow fila = await customSelect(
        'SELECT COUNT(*) AS total FROM ${tabla.actualTableName}',
        readsFrom: <ResultSetImplementation<Object?, Object?>>{tabla},
      ).getSingle();
      return fila.read<int?>('total') ?? 0;
    }

    return <String, int>{
      'establecimientos': await contar(establecimientos),
      'personal': await contar(personal),
      'auditorias': await contar(auditorias),
      'auditorias_historial': await contar(auditoriasHistorial),
      'oportunidades': await contar(oportunidades),
      'indicadores_cache': await contar(indicadoresCache),
      'preferencias': await contar(preferencias),
    };
  }

  /// Comprueba si existe un establecimiento (la usa la pantalla de
  /// diagnóstico para demostrar la clave foránea).
  Future<bool> existeEstablecimiento(String codigoUnico) async {
    final Establecimiento? fila = await (select(establecimientos)
          ..where(
            ($EstablecimientosTable t) => t.codigoUnico.equals(codigoUnico),
          ))
        .getSingleOrNull();
    return fila != null;
  }

  /// Borra auditorías y oportunidades en una sola transacción (utilidad de
  /// laboratorio para dejar la base en un estado reproducible).
  Future<void> limpiarAuditorias() async {
    await transaction(() async {
      await delete(auditoriasHistorial).go();
      await delete(oportunidades).go();
      await delete(auditorias).go();
    });
  }

  /// Devuelve el valor del `PRAGMA foreign_keys` (1 = activo). Es la
  /// comprobación que exige el Reto 5.
  Future<int> estadoClavesForaneas() async {
    final QueryRow fila =
        await customSelect('PRAGMA foreign_keys').getSingle();
    return fila.read<int>('foreign_keys');
  }
}
