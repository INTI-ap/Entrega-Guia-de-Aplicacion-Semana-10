import '../entidades/indicador_higiene.dart';

/// **Contrato del repositorio de indicadores (patrón offline-first).**
///
/// La regla que implementa el Reto 2 es exactamente esta:
///
/// ```
///   ¿Hay datos locales y son recientes?
///        sí → devolver caché  (OrigenDatos.cacheLocal)
///        no → consultar el servicio remoto
///               éxito → guardar en caché y devolver (OrigenDatos.red)
///               fallo → si hay caché vieja, devolverla (OrigenDatos.cacheLocal)
///                       si no, devolver el respaldo (OrigenDatos.respaldo)
/// ```
abstract interface class IndicadorRepository {
  /// Indica si la caché local puede usarse sin consultar el servicio.
  ///
  /// Reto 2: [codigo] selecciona la vigencia por recurso. Si es nulo se usa
  /// la vigencia del indicador principal.
  bool cacheEsVigente(
    DateTime? ultimaSincronizacion, {
    DateTime? ahora,
    String? codigo,
  });

  /// Vigencia configurada para [codigo] (política por recurso, Reto 2).
  Duration vigenciaPara(String codigo);

  /// Consulta offline-first: nunca lanza excepción por falta de red;
  /// degrada el [OrigenDatos] y sigue mostrando datos.
  Future<ResultadoIndicadores> obtenerIndicadores({
    bool forzarRefresco = false,
  });

  /// Datos que están guardados en el dispositivo, sin tocar la red.
  Future<List<IndicadorHigiene>> leerCache();

  /// Inserta o reemplaza los registros descargados y actualiza la marca
  /// de sincronización.
  Future<void> guardarEnCache(
    List<IndicadorHigiene> indicadores, {
    DateTime? momento,
  });

  /// Fecha de la última descarga exitosa, o `null` si nunca se descargó.
  Future<DateTime?> ultimaSincronizacion();

  /// Vacía la caché (útil para demostrar el camino "sin datos locales").
  Future<void> limpiarCache();

  /// Reto 2: borra la marca de sincronización de [codigo] sin borrar los
  /// datos, de modo que la próxima consulta fuerce la descarga.
  Future<void> invalidar(String codigo);
}

/// **Contrato del almacén clave-valor** para preferencias y banderas
/// sencillas: modo de tema, último código de establecimiento usado,
/// versión del esquema aceptada, etc.
///
/// No se usa para datos estructurados: para eso está SQLite. La decisión
/// "SQL vs clave-valor" se argumenta en la sección 4 de la guía.
abstract interface class PreferenciasRepository {
  Future<String?> leer(String clave);

  Future<void> guardar(String clave, String valor);

  Future<void> eliminar(String clave);

  Future<Map<String, String>> leerTodo();
}
