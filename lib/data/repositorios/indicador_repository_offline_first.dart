import '../../core/fallos.dart';
import '../../domain/entidades/indicador_higiene.dart';
import '../../domain/repositorios/indicador_repository.dart';
import '../local/daos/indicadores_dao.dart';
import '../remoto/higiene_api_service.dart';

/// Consulta el indicador OMS usando red, caché local y respaldo.
/// La vigencia decide cuándo descargar y la caché permite continuar sin red.
class IndicadorRepositoryOfflineFirst implements IndicadorRepository {
  IndicadorRepositoryOfflineFirst({
    required IndicadoresDao dao,
    required HigieneApiService servicio,
    Duration vigencia = const Duration(hours: 24),
    Map<String, Duration>? politicaVigencia,
    DateTime Function()? reloj,
  }) : _dao = dao,
       _servicio = servicio,
       _reloj = reloj ?? DateTime.now,
       politicaVigencia = Map.unmodifiable(
         politicaVigencia ??
             {
               HigieneApiService.codigoIndicador: vigencia,
               'establecimientos': const Duration(days: 7),
               'auditorias': const Duration(minutes: 5),
             },
       );

  final IndicadoresDao _dao;
  final HigieneApiService _servicio;

  /// Cada recurso tiene su propio intervalo de actualización.
  final Map<String, Duration> politicaVigencia;

  Duration get vigencia => politicaVigencia[HigieneApiService.codigoIndicador]!;

  /// Reloj inyectable para probar el vencimiento sin esperar 24 horas.
  final DateTime Function() _reloj;

  /// Una marca ausente, futura o vencida obliga a consultar la red.
  @override
  bool cacheEsVigente(
    DateTime? ultimaSincronizacion, {
    DateTime? ahora,
    String codigo = HigieneApiService.codigoIndicador,
  }) {
    if (ultimaSincronizacion == null) return false;
    final DateTime momento = ahora ?? _reloj();
    final ttl = politicaVigencia[codigo];
    final edad = momento.difference(ultimaSincronizacion);
    return ttl != null && !edad.isNegative && edad < ttl;
  }

  /// Usa respaldo cuando falla la red y no hay datos guardados.
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
      final List<IndicadorHigiene> remotas = await _servicio
          .obtenerIndicadoresPeru();
      final momento = _reloj();
      await _dao.reemplazarTodo(remotas, momento: momento);
      return ResultadoIndicadores(
        indicadores: remotas,
        origen: OrigenDatos.red,
        actualizadoEn: momento,
      );
    } on FalloRemoto {
      // El fallo conserva la última descarga exitosa y aumenta el contador.
      await _dao.registrarFallo(HigieneApiService.codigoIndicador);
      // Nivel 2 degradado: la caché existe pero está vencida.
      final List<IndicadorHigiene> locales = await _dao.leerTodo();
      if (locales.isNotEmpty) {
        return ResultadoIndicadores(
          indicadores: locales,
          origen: OrigenDatos.cacheLocal,
          actualizadoEn: await _dao.fechaDatos(),
          datosObsoletos: !cacheEsVigente(ultima),
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
    return _dao.reemplazarTodo(indicadores, momento: momento ?? _reloj());
  }

  @override
  Future<DateTime?> ultimaSincronizacion() =>
      _dao.ultimaSincronizacion(HigieneApiService.codigoIndicador);

  @override
  Future<void> limpiarCache() => _dao.limpiar();

  @override
  Future<void> invalidar(String codigo) => _dao.invalidar(codigo);
}
