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
    DateTime Function()? reloj,
  })  : _dao = dao,
        _servicio = servicio,
        _reloj = reloj ?? DateTime.now;

  final IndicadoresDao _dao;
  final HigieneApiService _servicio;

  /// Cuánto tiempo se considera "fresca" la caché antes de intentar una
  /// nueva descarga. Es una política de negocio, no un detalle técnico: se
  /// puede ajustar por recurso (24 h para una serie anual de la OMS, 5 min
  /// para el clima).
  final Duration vigencia;

  /// Reloj inyectable para probar el vencimiento sin esperar 24 horas.
  final DateTime Function() _reloj;

  /// **Versión base del Reto 2.**
  ///
  /// TODO(reto-2, mejora): convierta [vigencia] en un mapa por recurso
  /// (`{'WSH_HYGIENE_BASIC': Duration(hours: 24), 'establecimientos': …}`) y
  /// exponga en la interfaz cuánto falta para el próximo refresco.
  @override
  bool cacheEsVigente(DateTime? ultimaSincronizacion, {DateTime? ahora}) {
    if (ultimaSincronizacion == null) return false;
    final DateTime momento = ahora ?? _reloj();
    return momento.difference(ultimaSincronizacion) <= vigencia;
  }

  /// **Versión base del Reto 2: la política de tres niveles.**
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
  ///
  /// TODO(reto-2, mejora): agregue un `debugPrint` con la causa del fallo y
  /// exponga en [ResultadoIndicadores] un indicador `datosObsoletos` para
  /// que la interfaz pueda advertir "estos datos tienen más de 24 h".
  @override
  Future<ResultadoIndicadores> obtenerIndicadores({
    bool forzarRefresco = false,
  }) async {
    final DateTime? ultima = await _dao.ultimaSincronizacion(
      HigieneApiService.codigoIndicador,
    );

    // Nivel 2: caché local vigente.
    if (!forzarRefresco && cacheEsVigente(ultima)) {
      final List<IndicadorHigiene> locales = await _dao.leerTodo();
      if (locales.isNotEmpty) {
        return ResultadoIndicadores(
          indicadores: locales,
          origen: OrigenDatos.cacheLocal,
          actualizadoEn: ultima,
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
      );
    } on FalloRemoto {
      // Nivel 2 degradado: la caché existe pero está vencida.
      final List<IndicadorHigiene> locales = await _dao.leerTodo();
      if (locales.isNotEmpty) {
        return ResultadoIndicadores(
          indicadores: locales,
          origen: OrigenDatos.cacheLocal,
          actualizadoEn: ultima,
        );
      }

      // Nivel 3: respaldo empaquetado en la aplicación.
      return ResultadoIndicadores(
        indicadores: _servicio.respaldoLocal(),
        origen: OrigenDatos.respaldo,
      );
    }
  }

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
