import 'package:drift/drift.dart';

import 'establecimientos.dart';
import 'personal.dart';

/// Tabla `auditorias`: la cabecera del formulario de observación.
///
/// Puntos que conviene observar en la Semana 10:
///
///  * **Clave primaria de texto (UUID).** El identificador se genera en el
///    dispositivo para que una auditoría capturada sin conexión pueda
///    sincronizarse después sin colisionar con las de otros dispositivos.
///  * **Claves foráneas.** `establecimientoId`, `observadorDni` y
///    `observadoDni` referencian las tablas de catálogo. Sin
///    `PRAGMA foreign_keys = ON` SQLite NO las hace cumplir (Reto 5).
///  * **Borrado lógico.** La columna `eliminada` existe porque una
///    auditoría es un documento con valor normativo: se anula, no se borra.
class Auditorias extends Table {
  TextColumn get id => text()();

  TextColumn get establecimientoId => text().references(
        Establecimientos,
        #codigoUnico,
        onDelete: KeyAction.restrict,
      )();

  /// Nombre desnormalizado (trade-off documentado): evita un JOIN en el
  /// listado offline y conserva el nombre histórico del establecimiento.
  TextColumn get establecimientoNombre => text()();

  // Dos columnas de esta tabla apuntan a `personal` (observador y
  // observado). Sin @ReferenceName, drift no puede nombrar las dos
  // relaciones inversas y omite los filtros del gestor: un aviso que
  // conviene resolver desde el primer día.
  @ReferenceName('auditoriasComoObservador')
  TextColumn get observadorDni =>
      text().references(Personal, #dni, onDelete: KeyAction.restrict)();
  TextColumn get observadorNombre => text()();

  @ReferenceName('auditoriasComoObservado')
  TextColumn get observadoDni =>
      text().references(Personal, #dni, onDelete: KeyAction.restrict)();
  TextColumn get observadoNombre => text()();

  DateTimeColumn get fecha => dateTime()();

  /// 'borrador' | 'finalizada' | 'sincronizada'.
  TextColumn get estado => text().withDefault(const Constant('borrador'))();

  /// Borrado lógico.
  BoolColumn get eliminada => boolean().withDefault(const Constant(false))();

  /// Marca temporal del último envío exitoso al servidor.
  DateTimeColumn get sincronizadaEn => dateTime().nullable()();

  /// Campos requeridos por el formulario oficial (Reto 1):
  DateTimeColumn get fechaInicio => dateTime().nullable()();
  DateTimeColumn get fechaFin => dateTime().nullable()();
  IntColumn get numeroCamas => integer().nullable()();
  BoolColumn get consentimientoVerbal =>
      boolean().nullable().withDefault(const Constant(true))();

  /// Observación general de la auditoría (Reto 4):
  TextColumn get observacionGeneral => text().nullable()();

  DateTimeColumn get creadoEn =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get actualizadoEn =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}
