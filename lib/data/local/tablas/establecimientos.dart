import 'package:drift/drift.dart';

/// Tabla `establecimientos`: catálogo local de establecimientos de salud
/// auditados.
///
/// **Semana 10 — temática 2.2.2 (Definición de tablas con drift).**
/// Cada clase Dart que extiende `Table` se convierte en una sentencia
/// `CREATE TABLE` cuando se ejecuta `build_runner`. Las ventajas frente a
/// escribir el SQL a mano son:
///
///  * el esquema y el código Dart no pueden desincronizarse;
///  * `flutter analyze` detecta un nombre de columna mal escrito;
///  * las consultas devuelven *data classes* tipadas, no `Map<String, Object?>`.
class Establecimientos extends Table {
  /// Clave primaria natural: el `CODIGO_UNICO` del formulario oficial.
  /// Se usa `text()` y no un autoincremental porque el código lo asigna
  /// el MINSA, no la aplicación.
  TextColumn get codigoUnico => text()();

  TextColumn get nombre => text().withLength(min: 3, max: 200)();

  /// Nivel de complejidad: 'I-1' … 'III-2'.
  TextColumn get categoria => text()();

  TextColumn get red => text().withDefault(const Constant(''))();
  TextColumn get microred => text().withDefault(const Constant(''))();
  TextColumn get departamento => text().withDefault(const Constant(''))();
  TextColumn get provincia => text().withDefault(const Constant(''))();
  TextColumn get distrito => text().withDefault(const Constant(''))();

  /// `nullable()` porque no toda auditoría captura coordenadas.
  RealColumn get latitud => real().nullable()();
  RealColumn get longitud => real().nullable()();

  DateTimeColumn get creadoEn =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{codigoUnico};
}
