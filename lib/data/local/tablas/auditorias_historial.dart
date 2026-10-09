import 'package:drift/drift.dart';
import 'auditorias.dart';

/// Cambios conservados junto con la auditoría, incluso cuando se anula.
class AuditoriasHistorial extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get auditoriaId => text().references(Auditorias, #id)();
  DateTimeColumn get fecha => dateTime()();
  TextColumn get campo => text()();
  TextColumn get valorAnterior => text().nullable()();
  TextColumn get valorNuevo => text().nullable()();
}
