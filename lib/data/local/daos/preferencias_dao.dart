import 'package:drift/drift.dart';

import '../../local/manos_seguras_db.dart' as db;
import '../aliases.dart' as g;


/// **DAO del almacén clave-valor de preferencias.**
///
/// Semana 10 — temática 2.2.1 (comparación SQL vs clave-valor). Se usa para
/// datos pequeños y sueltos: modo de tema, último establecimiento abierto,
/// banderas de la interfaz. No sustituye a las tablas relacionales.
abstract interface class PreferenciasDao {
  Future<String?> leer(String clave);

  Future<void> guardar(String clave, String valor);

  Future<void> eliminar(String clave);

  Future<Map<String, String>> leerTodo();

  /// Flujo reactivo, útil para el `ValueListenableBuilder` del tema.
  Stream<Map<String, String>> observarTodo();
}

/// Implementación con drift (ver Anexo A, Error 7: por qué no lleva
/// `@DriftAccessor`).
class DriftPreferenciasDao extends DatabaseAccessor<db.ManosSegurasDb>
    implements PreferenciasDao {
  DriftPreferenciasDao(super.db);

  @override
  Future<String?> leer(String clave) async {
    final db.Preferencia? fila =
        await (select(attachedDatabase.preferencias)
              ..where((g.TablaPreferencias t) => t.clave.equals(clave)))
            .getSingleOrNull();
    return fila?.valor;
  }

  /// **UPSERT**: `insertOnConflictUpdate` traduce a
  /// `INSERT … ON CONFLICT(clave) DO UPDATE SET …`, la forma correcta de
  /// guardar una preferencia que puede existir o no.
  ///
  /// TODO(reto-1b): registre además, en la misma transacción, la fecha del
  /// último cambio en la tabla `sincronizaciones` con el código
  /// `'preferencias'`, y muestre ese dato en la pantalla de diagnóstico.
  @override
  Future<void> guardar(String clave, String valor) {
    return into(attachedDatabase.preferencias).insertOnConflictUpdate(
      db.PreferenciasCompanion.insert(
        clave: clave,
        valor: valor,
        actualizadoEn: Value<DateTime>(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> eliminar(String clave) {
    return (delete(attachedDatabase.preferencias)
          ..where((g.TablaPreferencias t) => t.clave.equals(clave)))
        .go();
  }

  @override
  Future<Map<String, String>> leerTodo() async {
    final List<db.Preferencia> filas =
        await select(attachedDatabase.preferencias).get();
    return <String, String>{
      for (final db.Preferencia fila in filas) fila.clave: fila.valor,
    };
  }

  @override
  Stream<Map<String, String>> observarTodo() {
    return select(attachedDatabase.preferencias).watch().map(
          (List<db.Preferencia> filas) => <String, String>{
            for (final db.Preferencia fila in filas) fila.clave: fila.valor,
          },
        );
  }
}
