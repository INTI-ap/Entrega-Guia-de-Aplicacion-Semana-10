import 'package:manos_seguras/core/fallos.dart';
import 'package:manos_seguras/domain/entidades/auditoria.dart';
import 'package:manos_seguras/domain/entidades/oportunidad_registro.dart';
import 'package:manos_seguras/domain/repositorios/auditoria_repository.dart';

/// **Doble de prueba del repositorio de auditorías.**
///
/// Implementa el contrato del dominio con una lista en memoria, sin SQLite.
/// Es la demostración práctica de la ventaja del DIP (Semana 9): la capa de
/// presentación depende de `AuditoriaRepository`, no de drift, así que se
/// puede probar sin abrir una base de datos.
///
/// Se usa en `test/presentation/pantallas_test.dart`.
class RepositorioAuditoriasEnMemoria implements AuditoriaRepository {
  RepositorioAuditoriasEnMemoria({List<Auditoria>? iniciales})
    : _auditorias = List<Auditoria>.of(iniciales ?? const <Auditoria>[]);

  final List<Auditoria> _auditorias;

  /// Cuando es `true`, todas las operaciones fallan con [FalloLocal]. Sirve
  /// para probar los estados de error de la interfaz.
  bool falla = false;

  int llamadasAGuardar = 0;

  @override
  Stream<List<Auditoria>> observarAuditorias({
    bool incluirEliminadas = false,
  }) async* {
    yield await listarAuditorias(incluirEliminadas: incluirEliminadas);
  }

  @override
  Future<List<Auditoria>> listarAuditorias({
    bool incluirEliminadas = false,
  }) async {
    _verificarFallo();
    return _auditorias
        .where((Auditoria a) => incluirEliminadas || !a.eliminada)
        .toList();
  }

  @override
  Future<List<Auditoria>> listarPorRango(DateTime desde, DateTime hasta) async {
    _verificarFallo();
    return _auditorias
        .where(
          (Auditoria a) =>
              !a.eliminada &&
              !a.fecha.isBefore(desde) &&
              !a.fecha.isAfter(hasta),
        )
        .toList();
  }

  @override
  Future<List<Auditoria>> listarPaginado({
    bool incluirEliminadas = false,
    required int limite,
    int offset = 0,
  }) async {
    _verificarFallo();
    final List<Auditoria> filtradas = _auditorias
        .where((Auditoria a) => incluirEliminadas || !a.eliminada)
        .toList();
    if (offset >= filtradas.length) return <Auditoria>[];
    final int fin = (offset + limite).clamp(0, filtradas.length);
    return filtradas.sublist(offset, fin);
  }

  @override
  Future<Auditoria> obtenerPorId(String id) async {
    _verificarFallo();
    final Auditoria? encontrada = _auditorias
        .where((Auditoria a) => a.id == id)
        .cast<Auditoria?>()
        .firstWhere((Auditoria? a) => true, orElse: () => null);
    if (encontrada == null) {
      throw FalloNoEncontrado('No existe la auditoría $id.');
    }
    return encontrada;
  }

  @override
  Future<String> guardar(Auditoria auditoria) async {
    llamadasAGuardar++;
    _verificarFallo();
    final String id = auditoria.id.isEmpty
        ? 'id-${_auditorias.length + 1}'
        : auditoria.id;
    _auditorias.add(auditoria.copyWith(id: id));
    return id;
  }

  @override
  Future<void> actualizar(Auditoria auditoria) async {
    _verificarFallo();
    final int indice = _auditorias.indexWhere(
      (Auditoria a) => a.id == auditoria.id,
    );
    if (indice < 0) {
      throw FalloNoEncontrado('No existe la auditoría ${auditoria.id}.');
    }
    _auditorias[indice] = auditoria;
  }

  @override
  Future<void> eliminarLogicamente(String id) async {
    _verificarFallo();
    final int indice = _auditorias.indexWhere((Auditoria a) => a.id == id);
    if (indice < 0) {
      throw FalloNoEncontrado('No existe la auditoría $id.');
    }
    _auditorias[indice] = _auditorias[indice].copyWith(eliminada: true);
  }

  @override
  Future<void> restaurar(String id) async {
    _verificarFallo();
    final int indice = _auditorias.indexWhere((Auditoria a) => a.id == id);
    if (indice < 0) {
      throw FalloNoEncontrado('No existe la auditoría $id.');
    }
    _auditorias[indice] = _auditorias[indice].copyWith(eliminada: false);
  }

  @override
  Future<String> duplicar(String id) async {
    final original = await obtenerPorId(id);
    return guardar(
      original.copyWith(
        id: 'copia-${_auditorias.length}',
        fecha: DateTime.now(),
        estado: EstadoAuditoria.borrador,
        eliminada: false,
      ),
    );
  }

  @override
  Future<OportunidadRegistro> agregarOportunidad(
    OportunidadRegistro oportunidad,
  ) async {
    _verificarFallo();
    final Auditoria auditoria = await obtenerPorId(oportunidad.auditoriaId);
    final OportunidadRegistro nueva = oportunidad.copyWith(
      numero: auditoria.totalOportunidades + 1,
    );
    await actualizar(
      auditoria.copyWith(
        oportunidades: <OportunidadRegistro>[...auditoria.oportunidades, nueva],
      ),
    );
    return nueva;
  }

  @override
  Future<void> eliminarOportunidad(int id) async {
    _verificarFallo();
    for (int i = 0; i < _auditorias.length; i++) {
      final Auditoria auditoria = _auditorias[i];
      final List<OportunidadRegistro> restantes = auditoria.oportunidades
          .where((OportunidadRegistro o) => o.id != id)
          .toList();
      if (restantes.length != auditoria.oportunidades.length) {
        _auditorias[i] = auditoria.copyWith(oportunidades: restantes);
      }
    }
  }

  @override
  Future<ResumenAdherencia> resumenAdherencia() async {
    _verificarFallo();
    final List<Auditoria> activas = _auditorias
        .where((Auditoria a) => !a.eliminada)
        .toList();
    if (activas.isEmpty) return ResumenAdherencia.vacio();

    final int total = activas.fold<int>(
      0,
      (int s, Auditoria a) => s + a.totalOportunidades,
    );
    final int cumplidas = activas.fold<int>(
      0,
      (int s, Auditoria a) => s + a.oportunidadesCumplidas,
    );
    return ResumenAdherencia(
      totalAuditorias: activas.length,
      totalOportunidades: total,
      totalCumplidas: cumplidas,
      promedioAdherencia: total == 0 ? null : (cumplidas / total) * 100,
      ultimaAuditoria: activas.first.fecha,
    );
  }

  @override
  Future<Map<EstadoAuditoria, int>> conteoPorEstado() async {
    _verificarFallo();
    final Map<EstadoAuditoria, int> conteo = <EstadoAuditoria, int>{
      for (final EstadoAuditoria estado in EstadoAuditoria.values) estado: 0,
    };
    for (final Auditoria auditoria in _auditorias) {
      conteo[auditoria.estado] = (conteo[auditoria.estado] ?? 0) + 1;
    }
    return conteo;
  }

  void _verificarFallo() {
    if (falla) {
      throw const FalloLocal('Fallo simulado para las pruebas de interfaz.');
    }
  }
}
