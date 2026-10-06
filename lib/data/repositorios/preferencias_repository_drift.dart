import '../../core/fallos.dart';
import '../../domain/repositorios/indicador_repository.dart';
import '../local/daos/preferencias_dao.dart';

/// **Implementación clave-valor sobre drift.**
///
/// Guarda preferencias en la tabla `preferencias`. Se eligió reutilizar la
/// misma base SQLite en lugar de agregar `shared_preferences` porque:
///
///  * una sola base significa una sola copia de seguridad y una sola
///    migración;
///  * `shared_preferences` es asíncrono igual y no aporta nada aquí;
///  * el estudiante practica `insertOnConflictUpdate` (UPSERT), una
///    operación SQL que volverá a necesitar con datos remotos.
///
/// Cuando la preferencia es un dato sensible (un token de sesión, un PIN),
/// **no** se guarda aquí: la Semana 11 introduce `flutter_secure_storage`.
class PreferenciasRepositoryDrift implements PreferenciasRepository {
  PreferenciasRepositoryDrift(this._dao);

  final PreferenciasDao _dao;

  @override
  Future<String?> leer(String clave) async {
    try {
      return await _dao.leer(clave);
    } catch (error) {
      throw FalloLocal(
        'No se pudo leer la preferencia "$clave".',
        causa: error,
      );
    }
  }

  @override
  Future<void> guardar(String clave, String valor) async {
    try {
      await _dao.guardar(clave, valor);
    } catch (error) {
      throw FalloLocal(
        'No se pudo guardar la preferencia "$clave".',
        causa: error,
      );
    }
  }

  @override
  Future<void> eliminar(String clave) async {
    try {
      await _dao.eliminar(clave);
    } catch (error) {
      throw FalloLocal(
        'No se pudo eliminar la preferencia "$clave".',
        causa: error,
      );
    }
  }

  @override
  Future<Map<String, String>> leerTodo() async {
    try {
      return await _dao.leerTodo();
    } catch (error) {
      throw FalloLocal(
        'No se pudieron leer las preferencias guardadas.',
        causa: error,
      );
    }
  }
}
