import 'package:drift/drift.dart';

/// Tabla `personal`: observadores y personal observado, en una sola tabla
/// polimórfica discriminada por la columna [rol].
///
/// **Decisión de diseño (Semana 10).** La alternativa —dos tablas,
/// `observadores` y `observados`— obligaría a duplicar el índice por DNI y
/// a escribir dos DAO casi idénticos, lo que violaría DRY. La columna
/// [rol] resuelve el mismo problema con una sola tabla.
class Personal extends Table {
  TextColumn get dni => text().withLength(min: 8, max: 8)();

  TextColumn get nombresApellidos => text().withLength(min: 3, max: 150)();

  /// 'observador' | 'observado'.
  TextColumn get rol => text().withDefault(const Constant('observado'))();

  /// Solo aplica al rol 'observado'; queda `null` para los observadores.
  TextColumn get categoriaProfesional => text().nullable()();
  TextColumn get servicioMedico => text().nullable()();

  DateTimeColumn get creadoEn =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{dni};
}
