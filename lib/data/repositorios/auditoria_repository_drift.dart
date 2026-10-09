import '../../core/fallos.dart';
import '../../core/id.dart';
import '../../domain/entidades/auditoria.dart';
import '../../domain/entidades/oportunidad_registro.dart';
import '../../domain/repositorios/auditoria_repository.dart';
import '../local/daos/auditorias_dao.dart';

/// **Implementación del repositorio de auditorías sobre drift/SQLite.**
///
/// Semana 9 (DIP: implementa la abstracción del dominio) + Semana 10
/// (persistencia local y transacciones).
///
/// Responsabilidades de esta clase (y solo estas):
///
///  * traducir los fallos de SQLite a [FalloLocal]/[FalloNoEncontrado];
///  * agrupar la escritura de la cabecera y su detalle en **una sola
///    transacción**, que es lo que garantiza que no queden auditorías a
///    medias si la aplicación se cierra;
///  * generar el identificador UUID en el dispositivo cuando la auditoría
///    todavía no lo tiene.
///
/// Nada de esto vive en la pantalla ni en el DAO: esa separación es la que
/// permite sustituir drift por Firestore en la Unidad III sin tocar la UI.
class AuditoriaRepositoryDrift implements AuditoriaRepository {
  AuditoriaRepositoryDrift(this._dao, {this.generadorId = generarUuidV4});

  final AuditoriasDao _dao;

  /// Se inyecta para poder producir identificadores predecibles en las
  /// pruebas (`() => 'id-fijo-1'`).
  final String Function() generadorId;

  @override
  Stream<List<Auditoria>> observarAuditorias({bool incluirEliminadas = false}) {
    return _dao.observar(incluirEliminadas: incluirEliminadas).handleError((
      Object error,
    ) {
      throw FalloLocal(
        'No se pudieron leer las auditorías guardadas.',
        causa: error,
      );
    });
  }

  @override
  Future<List<Auditoria>> listarAuditorias({
    bool incluirEliminadas = false,
  }) async {
    try {
      return await _dao.listar(incluirEliminadas: incluirEliminadas);
    } catch (error) {
      throw FalloLocal(
        'No se pudieron leer las auditorías guardadas.',
        causa: error,
      );
    }
  }

  /// **Reto 1:** filtra por rango de fechas mediante el DAO en SQL.
  @override
  Future<List<Auditoria>> listarPorRango(DateTime desde, DateTime hasta) async {
    try {
      return await _dao.listarPorRango(desde, hasta);
    } on Fallo {
      rethrow;
    } catch (error) {
      throw FalloLocal(
        'No se pudieron leer las auditorías en el rango especificado.',
        causa: error,
      );
    }
  }

  /// Reto 5: paginación en SQL.
  @override
  Future<List<Auditoria>> listarPaginado({
    bool incluirEliminadas = false,
    required int limite,
    int offset = 0,
  }) async {
    try {
      return await _dao.listar(
        incluirEliminadas: incluirEliminadas,
        limite: limite,
        offset: offset,
      );
    } catch (error) {
      throw FalloLocal(
        'No se pudieron leer las auditorías paginadas.',
        causa: error,
      );
    }
  }

  @override
  Future<Auditoria> obtenerPorId(String id) async {
    try {
      final Auditoria? auditoria = await _dao.buscarPorId(id);
      if (auditoria == null) {
        throw FalloNoEncontrado('No existe la auditoría $id.');
      }
      return auditoria;
    } on Fallo {
      rethrow;
    } catch (error) {
      throw FalloLocal('No se pudo leer la auditoría $id.', causa: error);
    }
  }

  /// Confirma cabecera y oportunidades juntas; un fallo revierte ambas.
  @override
  Future<String> guardar(Auditoria auditoria) async {
    try {
      return await _dao.transaccion(() async {
        final String id = auditoria.id.isEmpty ? generadorId() : auditoria.id;
        final Auditoria conId = auditoria.copyWith(id: id);

        final bool insertada = await _dao.insertarCabecera(conId);
        if (!insertada) {
          throw FalloDeValidacion(
            'Ya existe una auditoría con el identificador $id. '
            'Genere uno nuevo o use actualizar().',
          );
        }

        for (int i = 0; i < conId.oportunidades.length; i++) {
          final OportunidadRegistro oportunidad = conId.oportunidades[i];
          await _dao.insertarOportunidad(
            oportunidad.copyWith(
              auditoriaId: id,
              numero: oportunidad.numero == 0 ? i + 1 : oportunidad.numero,
            ),
          );
        }

        return id;
      });
    } on Fallo {
      rethrow;
    } catch (error) {
      throw FalloLocal(
        'No se pudo guardar la auditoría en el dispositivo.',
        causa: error,
      );
    }
  }

  @override
  Future<void> actualizar(Auditoria auditoria) async {
    try {
      await _dao.transaccion(() async {
        final anterior = await obtenerPorId(auditoria.id);
        final int filas = await _dao.actualizarCabecera(auditoria);

        if (filas == 0) {
          throw FalloNoEncontrado(
            'No existe la auditoría ${auditoria.id} que intenta actualizar.',
          );
        }

        // Solo reemplaza el detalle si cambió; una edición de cabecera conserva sus IDs.
        if (!_mismoDetalle(anterior, auditoria)) {
          // Reemplazo completo del detalle: es la estrategia más simple y
          // correcta para 5-10 filas por auditoría. Para volúmenes mayores,
          // conviene un *diff* (insertar/actualizar/borrar solo lo que cambió).
          await _dao.borrarOportunidadesDe(auditoria.id);
          for (final OportunidadRegistro oportunidad
              in auditoria.oportunidades) {
            await _dao.insertarOportunidad(
              oportunidad.copyWith(auditoriaId: auditoria.id),
            );
          }
        }
        await _dao.registrarCambios(anterior, auditoria);
      });
    } on Fallo {
      rethrow;
    } catch (error) {
      throw FalloLocal('No se pudo actualizar la auditoría.', causa: error);
    }
  }

  @override
  Future<void> eliminarLogicamente(String id) async {
    try {
      await _dao.transaccion(() async {
        final anterior = await obtenerPorId(id);
        final int filas = await _dao.marcarEliminada(id);
        if (filas == 0) {
          throw FalloNoEncontrado('No existe la auditoría $id.');
        }
        await _dao.registrarCambios(
          anterior,
          anterior.copyWith(eliminada: true),
        );
      });
    } on Fallo {
      rethrow;
    } catch (error) {
      throw FalloLocal('No se pudo anular la auditoría $id.', causa: error);
    }
  }

  @override
  Future<void> restaurar(String id) async {
    try {
      await _dao.transaccion(() async {
        final anterior = await obtenerPorId(id);
        final int filas = await _dao.restaurar(id);
        if (filas == 0) {
          throw FalloNoEncontrado('No existe la auditoría $id para restaurar.');
        }
        await _dao.registrarCambios(
          anterior,
          anterior.copyWith(eliminada: false),
        );
      });
    } on Fallo {
      rethrow;
    } catch (error) {
      throw FalloLocal('No se pudo restaurar la auditoría $id.', causa: error);
    }
  }

  bool _mismoDetalle(Auditoria a, Auditoria b) {
    if (a.oportunidades.length != b.oportunidades.length) return false;
    for (int i = 0; i < a.oportunidades.length; i++) {
      final x = a.oportunidades[i];
      final y = b.oportunidades[i];
      if (x.numero != y.numero ||
          x.momento != y.momento ||
          x.accion != y.accion ||
          x.observacion != y.observacion ||
          x.duracionSegundos != y.duracionSegundos) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<String> duplicar(String id) async {
    final original = await obtenerPorId(id);
    final nuevaId = generadorId();
    final hoy = DateTime.now();
    // Se crea una observación nueva; no hereda marcas de sincronización ni anulación.
    return guardar(
      Auditoria(
        id: nuevaId,
        establecimientoId: original.establecimientoId,
        establecimientoNombre: original.establecimientoNombre,
        observadorDni: original.observadorDni,
        observadorNombre: original.observadorNombre,
        observadoDni: original.observadoDni,
        observadoNombre: original.observadoNombre,
        fecha: hoy,
        fechaInicio: hoy,
        numeroCamas: original.numeroCamas,
        consentimientoVerbal: original.consentimientoVerbal,
        observacionGeneral: original.observacionGeneral,
        oportunidades: original.oportunidades
            .map(
              (o) => OportunidadRegistro(
                auditoriaId: nuevaId,
                numero: o.numero,
                momento: o.momento,
                accion: o.accion,
                observacion: o.observacion,
                duracionSegundos: o.duracionSegundos,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Future<OportunidadRegistro> agregarOportunidad(
    OportunidadRegistro oportunidad,
  ) async {
    try {
      return await _dao.transaccion(() async {
        final anterior = await obtenerPorId(oportunidad.auditoriaId);
        final guardada = await _dao.insertarOportunidad(
          oportunidad.copyWith(
            numero: oportunidad.numero == 0
                ? anterior.totalOportunidades + 1
                : oportunidad.numero,
          ),
        );
        await _dao.registrarCambios(anterior, await obtenerPorId(anterior.id));
        return guardada;
      });
    } on Fallo {
      rethrow;
    } catch (error) {
      throw FalloLocal('No se pudo registrar la oportunidad.', causa: error);
    }
  }

  @override
  Future<void> eliminarOportunidad(int id) async {
    try {
      await _dao.transaccion(() async {
        final auditoriaId = await _dao.auditoriaDeOportunidad(id);
        if (auditoriaId == null) return;
        final antes = await obtenerPorId(auditoriaId);
        await _dao.borrarOportunidad(id);
        await _dao.registrarCambios(antes, await obtenerPorId(auditoriaId));
      });
    } catch (error) {
      throw FalloLocal('No se pudo eliminar la oportunidad.', causa: error);
    }
  }

  @override
  Future<ResumenAdherencia> resumenAdherencia() async {
    try {
      return await _dao.resumenAdherencia();
    } catch (error) {
      throw FalloLocal(
        'No se pudieron calcular los indicadores locales.',
        causa: error,
      );
    }
  }

  @override
  Future<Map<EstadoAuditoria, int>> conteoPorEstado() async {
    try {
      return await _dao.conteoPorEstado();
    } catch (error) {
      throw FalloLocal(
        'No se pudo calcular el estado de sincronización.',
        causa: error,
      );
    }
  }
}
