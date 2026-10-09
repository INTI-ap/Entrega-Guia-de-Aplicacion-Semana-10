import '../../core/fallos.dart';
import '../../domain/entidades/indicador_higiene.dart';
import '../../domain/repositorios/indicador_repository.dart';
import '../local/daos/indicadores_dao.dart';
import '../remoto/higiene_api_service.dart';

/// **Repositorio offline-first del indicador de la OMS.**
///
/// Este es **el corazón del patrón offline-first** de la Semana 10 y la pieza
/// que resuelve el Reto 2. Orquesta tres fuentes de datos y decide, sin que
/// la pantalla lo sepa, de dónde sale cada respuesta:
///
/// ```
///   obtenerIndicadores()
///      │
///      ├─ ¿forzarRefresco? ¿caché vencida? ─────────────────────────┐
///      │                                                            │
///      │ no                                        sí ↓             │
///      └──────────────► leerCache()        HigieneApiService        │
///                            │              │        │             │
///                            │            éxito     fallo          │
///                            │              │        │             │
///                            │        guardarEnCache │             │
///                            │              │        ├─ ¿hay caché? ─► caché
///                            │              │        └─ no ─► respaldo local
///                            ▼              ▼
///                     OrigenDatos.cacheLocal / OrigenDatos.red
/// ```
///
/// **Contrato de robustez:** este método NUNCA lanza excepción por falta de
/// red. Un vendedor de software no puede permitir que la aplicación de una
/// enfermera que audita en un puesto de salud rural se quede en blanco.
class IndicadorRepositoryOfflineFirst implements IndicadorRepository {
  IndicadorRepositoryOfflineFirst({
    required IndicadoresDao dao,
    required HigieneApiService servicio,
    this.vigencia = const Duration(hours: 24),
    Map<String, Duration>? vigencias,
    DateTime Function()? reloj,
  })  : _dao = dao,
        _servicio = servicio,
        _vigencias = vigencias,
        _reloj = reloj ?? DateTime.now;

  final IndicadoresDao _dao;
  final HigieneApiService _servicio;

  /// Cuánto tiempo se considera "fresca" la caché antes de intentar una
  /// nueva descarga. Es una política de negocio, no un detalle técnico: se
  /// puede ajustar por recurso (24 h para una serie anual de la OMS, 5 min
  /// para el clima).
  final Duration vigencia;

  /// Reto 2: política de vigencia por recurso (codigo -> Duration).
  final Map<String, Duration>? _vigencias;

  /// Reto 2: política por recurso con al menos tres recursos distintos.
  /// La serie anual de la OMS cambia una vez al año, el catálogo de
  /// establecimientos puede cambiar semanalmente y el resumen de una
  /// auditoría en curso debe refrescarse en minutos.
  static const Map<String, Duration> vigenciasPorRecurso =
      <String, Duration>{
    'WSH_HYGIENE_BASIC': Duration(hours: 24),
    'establecimientos': Duration(days: 7),
    'auditorias': Duration(minutes: 15),
  };

  /// Reloj inyectable para probar el vencimiento sin esperar 24 horas.
  final DateTime Function() _reloj;

  /// Reto 2: devuelve la vigencia configurada para [codigo].
  @override
  Duration vigenciaPara(String codigo) {
    if (_vigencias != null && _vigencias.containsKey(codigo)) {
      return _vigencias[codigo]!;
    }
    return vigenciasPorRecurso[codigo] ?? vigencia;
  }

  /// Reto 2: vigencia por recurso. [codigo] selecciona la política;
  /// si es nulo se usa el indicador principal.
  @override
  bool cacheEsVigente(
    DateTime? ultimaSincronizacion, {
    DateTime? ahora,
    String? codigo,
  }) {
    if (ultimaSincronizacion == null) return false;
    final DateTime momento = ahora ?? _reloj();
    final Duration politica =
        vigenciaPara(codigo ?? HigieneApiService.codigoIndicador);
    return momento.difference(ultimaSincronizacion) <= politica;
  }

  /// **Reto 2: política de tres niveles con vigencia por recurso.**
  ///
  /// El método respeta la siguiente prioridad y **nunca lanza excepción por
  /// falta de red**:
  ///
  /// | Situación                                   | Resultado            |
  /// |---------------------------------------------|----------------------|
  /// | Caché vigente y no se fuerza el refresco    | `cacheLocal`         |
  /// | Descarga exitosa                            | `red` (y guarda)     |
  /// | Descarga fallida + caché con filas          | `cacheLocal` (vieja) |
  /// | Descarga fallida + caché vacía              | `respaldo` (assets)  |
  @override
  Future<ResultadoIndicadores> obtenerIndicadores({
    bool forzarRefresco = false,
  }) async {
    final String codigo = HigieneApiService.codigoIndicador;
    final DateTime? ultima = await _dao.ultimaSincronizacion(codigo);

    // Nivel 2: caché local vigente.
    if (!forzarRefresco && cacheEsVigente(ultima, codigo: codigo)) {
      final List<IndicadorHigiene> locales = await _dao.leerTodo();
      if (locales.isNotEmpty) {
        return ResultadoIndicadores(
          indicadores: locales,
          origen: OrigenDatos.cacheLocal,
          actualizadoEn: ultima,
          datosObsoletos: false,
        );
      }
    }

    // Nivel 1: servicio remoto.
    try {
      final List<IndicadorHigiene> remotas =
          await _servicio.obtenerIndicadoresPeru();
      await _dao.reemplazarTodo(remotas, momento: _reloj());
      return ResultadoIndicadores(
        indicadores: remotas,
        origen: OrigenDatos.red,
        actualizadoEn: _reloj(),
        datosObsoletos: false,
      );
    } on FalloRemoto {
      // Se registra el fallo consecutivo (Reto 2, consigna 11).
      try {
        await _dao.registrarIntentoFallido(codigo);
      } catch (_) {
        // El registro del fallo nunca debe romper la degradación.
      }
      // Nivel 2 degradado: la caché existe pero está vencida.
      final List<IndicadorHigiene> locales = await _dao.leerTodo();
      if (locales.isNotEmpty) {
        return ResultadoIndicadores(
          indicadores: locales,
          origen: OrigenDatos.cacheLocal,
          actualizadoEn: ultima,
          datosObsoletos: true,
        );
      }

      // Nivel 3: respaldo empaquetado en la aplicación.
      return ResultadoIndicadores(
        indicadores: _servicio.respaldoLocal(),
        origen: OrigenDatos.respaldo,
        datosObsoletos: true,
      );
    }
  }

  /// Reto 2: borra la marca de sincronización sin borrar los datos.
  @override
  Future<void> invalidar(String codigo) => _dao.invalidarMarca(codigo);

  @override
  Future<List<IndicadorHigiene>> leerCache() => _dao.leerTodo();

  @override
  Future<void> guardarEnCache(
    List<IndicadorHigiene> indicadores, {
    DateTime? momento,
  }) {
    return _dao.reemplazarTodo(
      indicadores,
      momento: momento ?? _reloj(),
    );
  }

  @override
  Future<DateTime?> ultimaSincronizacion() =>
      _dao.ultimaSincronizacion(HigieneApiService.codigoIndicador);

  @override
  Future<void> limpiarCache() => _dao.limpiar();
}
