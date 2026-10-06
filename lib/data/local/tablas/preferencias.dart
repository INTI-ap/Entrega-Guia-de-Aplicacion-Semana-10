import 'package:drift/drift.dart';

/// Tabla `preferencias`: almacén **clave-valor** para datos pequeños y
/// sueltos (modo de tema, último establecimiento usado, versión de
/// términos aceptada).
///
/// **Semana 10 — temática 2.2.1 (SQL vs NoSQL en móvil).** Esta tabla es
/// un ejemplo deliberado del caso de uso "clave-valor dentro de una base
/// SQL": no necesita esquema propio, no se consulta, no se relaciona. La
/// sección 4 de la guía compara cuándo usar esta tabla, `shared_preferences`
/// o una tabla relacional completa.
class Preferencias extends Table {
  TextColumn get clave => text()();
  TextColumn get valor => text()();

  DateTimeColumn get actualizadoEn =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{clave};
}
