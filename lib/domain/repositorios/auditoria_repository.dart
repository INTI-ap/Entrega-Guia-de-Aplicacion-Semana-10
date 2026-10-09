import '../../core/fallos.dart';
import '../entidades/auditoria.dart';
import '../entidades/oportunidad_registro.dart';

/// **Contrato de persistencia de auditorías.**
///
/// Este archivo es la pieza central del **Principio de Inversión de
/// Dependencias (DIP, Semana 9)** aplicado a la Semana 10:
///
/// ```
///   domain/repositorios/auditoria_repository.dart   (abstracción)
///                  ▲                        ▲
///                  │ implementa             │ usa
///   data/repositorios/auditoria_          presentation/pantallas/
///     repository_drift.dart                 (no conoce drift)
/// ```
///
/// La capa de presentación depende de esta interfaz, **nunca** de
/// `AuditoriasDao`, de `AppDatabase` ni de SQLite. Gracias a eso:
///
///  * los *widget tests* pueden inyectar un doble en memoria y correr sin
///    base de datos (ver `test/dobles/repositorio_auditorias_en_memoria.dart`);
///  * migrar de drift a Firebase Firestore en la Unidad III solo exige
///    escribir una segunda implementación de esta interfaz.
abstract interface class AuditoriaRepository {
  /// Emite la lista de auditorías activas cada vez que la tabla cambia.
  /// Es un `Stream` porque la Semana 12 conectará este flujo a Riverpod.
  Stream<List<Auditoria>> observarAuditorias({bool incluirEliminadas = false});

  /// Lista puntual (útil para pruebas y para exportar).
  Future<List<Auditoria>> listarAuditorias({
    bool incluirEliminadas = false,
  });

  /// Lista las auditorías activas en el rango de fechas [desde] y [hasta] (Reto 1).
  Future<List<Auditoria>> listarPorRango(DateTime desde, DateTime hasta);

  /// Reto 5: listado paginado en SQL (LIMIT/OFFSET). Cargar 10 000 filas en
  /// un ListView agota memoria y batería: se pagina de 20 en 20.
  Future<List<Auditoria>> listarPaginado({
    bool incluirEliminadas = false,
    required int limite,
    int offset = 0,
  });

  /// Devuelve una auditoría con sus oportunidades o lanza
  /// [FalloNoEncontrado].
  Future<Auditoria> obtenerPorId(String id);

  /// Guarda cabecera y oportunidades en **una sola transacción** y
  /// devuelve el identificador definitivo.
  Future<String> guardar(Auditoria auditoria);

  /// Actualiza una auditoría existente (cabecera y oportunidades).
  Future<void> actualizar(Auditoria auditoria);

  /// Borrado lógico: marca `eliminada = true`. Nunca borra la fila.
  Future<void> eliminarLogicamente(String id);

  /// Restaura una auditoría marcada como anulada (`eliminada = false`). Reto 3.
  Future<void> restaurar(String id);

  /// Agrega una oportunidad a una auditoría ya guardada.
  Future<OportunidadRegistro> agregarOportunidad(
    OportunidadRegistro oportunidad,
  );

  /// Elimina una oportunidad concreta de una auditoría.
  Future<void> eliminarOportunidad(int id);

  /// Indicadores agregados calculados **en SQL** (Reto 5).
  Future<ResumenAdherencia> resumenAdherencia();

  /// Contadores de la barra de estado offline-first.
  Future<Map<EstadoAuditoria, int>> conteoPorEstado();
}
