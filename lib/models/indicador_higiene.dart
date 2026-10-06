/// Modelo de dominio que representa un registro del indicador público
/// de la Organización Mundial de la Salud (OMS) consumido en la
/// Sesión 15-16: `WSH_HYGIENE_BASIC` — "Población con instalaciones
/// básicas de lavado de manos en el hogar (%)".
///
/// Este archivo demuestra cómo un JSON real (`Map<String, dynamic>`)
/// se convierte en un objeto tipado de Dart, aplicando clases,
/// constructores, null safety y factory constructors (Sesión 3).
///
/// Fuente de datos:
/// https://ghoapi.azureedge.net/api/WSH_HYGIENE_BASIC
library;

class IndicadorHigiene {
  /// Texto que describe el indicador. La API no lo entrega: se declara
  /// aquí para mostrarlo en la interfaz.
  static const String descripcion =
      'Población con instalaciones básicas de lavado de manos en el hogar (%)';

  /// Código del indicador en el Observatorio Mundial de la Salud.
  final String codigoIndicador;

  /// Código ISO de 3 letras del país o área (por ejemplo, 'PER').
  final String pais;

  /// Año del registro (`TimeDim` en la respuesta del API).
  final int anio;

  /// Ámbito de residencia legible ('Rural', 'Urbano', 'Total').
  final String ambito;

  /// Valor del indicador en porcentaje. Es nullable a propósito:
  /// la API entrega `NumericValue: null` cuando no hay dato disponible,
  /// caso que el resto de la app debe manejar sin romperse.
  final double? valor;

  const IndicadorHigiene({
    required this.codigoIndicador,
    required this.pais,
    required this.anio,
    required this.ambito,
    this.valor,
  });

  /// Constructor que traduce la respuesta cruda del API a un objeto de
  /// dominio. Es "defensivo": cada campo se convierte con un método
  /// auxiliar que tolera valores nulos o de tipo inesperado, de modo
  /// que un solo registro malformado no tumbe toda la lista.
  factory IndicadorHigiene.fromJson(Map<String, dynamic> json) {
    return IndicadorHigiene(
      codigoIndicador: _aTexto(json['IndicatorCode'], 'SIN_CODIGO'),
      pais: _aTexto(json['SpatialDim'], 'N/D'),
      anio: _aEntero(json['TimeDim']),
      ambito: _ambitoLegible(
        json['Dim1'] is String ? json['Dim1'] as String : null,
      ),
      valor: _aDecimal(json['NumericValue']),
    );
  }

  /// Indica si el registro trae un valor numérico utilizable.
  bool get tieneValor => valor != null;

  /// Porcentaje formateado para la interfaz.
  String get valorTexto =>
      valor == null ? 'Sin dato' : '${valor!.toStringAsFixed(1)} %';

  /// Valor normalizado entre 0.0 y 1.0, listo para un LinearProgressIndicator.
  double get fraccion => valor == null ? 0 : (valor! / 100).clamp(0.0, 1.0);

  // ---------------------------------------------------------------------
  // Conversiones defensivas: la respuesta de un servicio externo es datos
  // no confiables; nunca se asume el tipo recibido.
  // ---------------------------------------------------------------------

  static int _aEntero(dynamic valorCrudo) {
    if (valorCrudo is int) return valorCrudo;
    if (valorCrudo is num) return valorCrudo.toInt();
    if (valorCrudo is String) return int.tryParse(valorCrudo) ?? 0;
    return 0;
  }

  static String _aTexto(dynamic valorCrudo, String respaldo) {
    if (valorCrudo is String && valorCrudo.isNotEmpty) return valorCrudo;
    return respaldo;
  }

  static double? _aDecimal(dynamic valorCrudo) {
    if (valorCrudo is num) return valorCrudo.toDouble();
    if (valorCrudo is String) return double.tryParse(valorCrudo);
    return null;
  }

  static String _ambitoLegible(String? dim1) {
    switch (dim1) {
      case 'RESIDENCEAREATYPE_RUR':
        return 'Rural';
      case 'RESIDENCEAREATYPE_URB':
        return 'Urbano';
      case 'RESIDENCEAREATYPE_TOTL':
        return 'Total';
      default:
        return 'No especificado';
    }
  }

  @override
  String toString() => 'IndicadorHigiene($pais, $anio, $ambito, $valorTexto)';
}
