import 'package:drift/drift.dart';

import 'auditorias.dart';

/// Tabla `oportunidades`: el detalle de la auditoría, una fila por cada
/// oportunidad de observación registrada (grupos
/// `EVALUACION_OBLIGATORIO_oportunidad_01` a `_05` del XLSForm).
///
/// **Reto 5 — integridad y rendimiento.** Esta tabla es la que más filas
/// acumula (cada auditoría aporta 5 o más) y por eso es donde se practican:
///
///  * `PRAGMA foreign_keys = ON` + `ON DELETE CASCADE`, para que al borrar
///    una auditoría no queden oportunidades huérfanas;
///  * un índice único `(auditoriaId, numero)` que impide registrar dos
///    veces la misma oportunidad si el usuario presiona el botón dos veces;
///  * `scopedDao` y `limit`/`offset` para no cargar 10 000 filas de golpe.
@TableIndex(name: 'idx_oportunidades_auditoria', columns: {#auditoriaId})
class Oportunidades extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get auditoriaId => text().references(
        Auditorias,
        #id,
        onDelete: KeyAction.cascade,
      )();

  /// Número correlativo de la oportunidad dentro de la auditoría (1..n).
  IntColumn get numero => integer()();

  /// Clave textual del enum `Momento` ('antes_paciente', 'despues_entorno'…).
  TextColumn get momentoClave => text()();

  /// Clave textual del enum `Accion` ('guantes', 'lavado', 'omision'…).
  TextColumn get accionClave => text()();

  /// Nota libre opcional del observador.
  TextColumn get observacion => text().nullable()();

  /// Duración en segundos de la observación (Reto 4):
  IntColumn get duracionSegundos => integer().nullable()();

  DateTimeColumn get registradoEn =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column<Object>>> get uniqueKeys => <Set<Column<Object>>>[
        <Column<Object>>{auditoriaId, numero},
      ];
}
