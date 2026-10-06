/// Modelo de datos que representa un establecimiento de salud auditado,
/// basado en los campos oficiales del formulario KoboToolbox
/// `formularioahmniveliii.xlsx` (campos CODIGO_UNICO, NOMBRE_ESTABLECIMIENTO,
/// CATEGORIA_DEL_ESTABLECIMIENTO, RED, MICRORED, entre otros).
///
/// Construido en la Guía de Práctica N.° 3 (PantallaEstablecimiento,
/// Sesiones 4-7) aplicando clases, constructores y null safety (Sesión 3).
class Establecimiento {
  final String codigoUnico;
  final String nombre;
  final String categoria;
  final String red;
  final String microred;
  final String departamento;
  final String provincia;
  final String distrito;

  // Campo opcional (nullable): no todos los registros de campo cuentan
  // con coordenadas GPS capturadas al momento de la auditoría.
  final double? latitud;
  final double? longitud;

  const Establecimiento({
    required this.codigoUnico,
    required this.nombre,
    required this.categoria,
    required this.red,
    required this.microred,
    required this.departamento,
    required this.provincia,
    required this.distrito,
    this.latitud,
    this.longitud,
  });

  /// Indica si el establecimiento cuenta con geolocalización registrada.
  bool get tieneGeolocalizacion => latitud != null && longitud != null;

  /// Establecimiento de ejemplo usado como dato semilla en la app,
  /// siguiendo la convención de datos reales de GERESA Cusco.
  factory Establecimiento.ejemplo() {
    return const Establecimiento(
      codigoUnico: '00006405',
      nombre: 'Hospital Regional del Cusco',
      categoria: 'II-2',
      red: 'Red Cusco Sur',
      microred: 'Microred Cusco',
      departamento: 'Cusco',
      provincia: 'Cusco',
      distrito: 'Cusco',
      latitud: -13.5226,
      longitud: -71.9673,
    );
  }
}
