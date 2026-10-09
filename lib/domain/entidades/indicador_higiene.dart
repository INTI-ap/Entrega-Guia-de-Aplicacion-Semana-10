/// Indicador anual del Observatorio Mundial de la Salud (OMS) usado como
/// dato de contexto nacional en ManosSeguras.
///
/// **Capa Domain (Semana 8).** En la Sesión 16 este modelo tenía un
/// `factory IndicadorHigiene.fromJson(...)` del API. En la Semana 10 la
/// conversión se movió a `lib/data/mapeadores/` y aquí solo queda la
/// entidad y sus reglas (SRP, Semana 9).
class IndicadorHigiene {
  const IndicadorHigiene({
    required this.codigoIndicador,
    required this.pais,
    required this.anio,
    required this.ambito,
    this.valor,
  });

  /// Texto que describe el indicador. El API no lo entrega: se declara
  /// aquí para mostrarlo en la interfaz.
  static const String descripcion =
      'Población con instalaciones básicas de lavado de manos en el hogar (%)';

  final String codigoIndicador;
  final String pais;
  final int anio;
  final String ambito;

  /// Es `nullable` a propósito: el API entrega `NumericValue: null`
  /// cuando no hay dato disponible.
  final double? valor;

  /// Clave primaria compuesta usada en la tabla local `indicadores_cache`.
  String get clave => '$pais|$anio|$ambito';

  bool get tieneValor => valor != null;

  String get valorTexto =>
      valor == null ? 'Sin dato' : '${valor!.toStringAsFixed(1)} %';

  /// Valor normalizado entre 0.0 y 1.0, para un `LinearProgressIndicator`.
  double get fraccion => valor == null ? 0 : (valor! / 100).clamp(0.0, 1.0);

  IndicadorHigiene copyWith({double? valor}) {
    return IndicadorHigiene(
      codigoIndicador: codigoIndicador,
      pais: pais,
      anio: anio,
      ambito: ambito,
      valor: valor ?? this.valor,
    );
  }

  @override
  String toString() => 'IndicadorHigiene($pais, $anio, $ambito, $valorTexto)';
}

/// Origen del que se obtuvieron los datos que la pantalla está mostrando.
///
/// Es el concepto central del patrón *offline-first*: la interfaz informa
/// al usuario si está viendo datos recién descargados, datos guardados en
/// el dispositivo o datos de respaldo porque no hubo red.
enum OrigenDatos {
  red(clave: 'red', etiqueta: 'Actualizado desde el servicio'),
  cacheLocal(clave: 'cache', etiqueta: 'Datos guardados en el dispositivo'),
  respaldo(clave: 'respaldo', etiqueta: 'Datos de respaldo (sin conexión)');

  const OrigenDatos({required this.clave, required this.etiqueta});

  final String clave;
  final String etiqueta;
}

/// Resultado completo de una consulta offline-first: los datos y su
/// procedencia. Devolver ambos juntos evita que la pantalla tenga que
/// adivinar de dónde vinieron los datos.
class ResultadoIndicadores {
  const ResultadoIndicadores({
    required this.indicadores,
    required this.origen,
    this.actualizadoEn,
    this.datosObsoletos = false,
  });

  final List<IndicadorHigiene> indicadores;
  final OrigenDatos origen;

  /// Momento en que los datos se descargaron del servicio (puede ser
  /// anterior a "ahora" si vienen de la caché local).
  final DateTime? actualizadoEn;

  /// La caché entregada superó su vigencia o fue invalidada.
  final bool datosObsoletos;

  bool get estaVacio => indicadores.isEmpty;
}
