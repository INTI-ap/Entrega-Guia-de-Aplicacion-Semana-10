import 'catalogos.dart';

/// Establecimiento de salud auditado, según los campos oficiales del
/// formulario KoboToolbox `formularioahmniveliii.xlsx`
/// (CODIGO_UNICO, NOMBRE_ESTABLECIMIENTO, CATEGORIA_DEL_ESTABLECIMIENTO,
/// RED, MICRORED, departamento, provincia y distrito).
///
/// **Capa Domain (Semana 8).** Sin dependencias externas: solo Dart puro.
class Establecimiento {
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

  final String codigoUnico;
  final String nombre;
  final CategoriaNivel categoria;
  final String red;
  final String microred;
  final String departamento;
  final String provincia;
  final String distrito;

  /// Coordenadas GPS. Son opcionales: no todos los registros de campo
  /// cuentan con geolocalización capturada al momento de la auditoría.
  final double? latitud;
  final double? longitud;

  /// Indica si el establecimiento cuenta con geolocalización registrada.
  bool get tieneGeolocalizacion => latitud != null && longitud != null;

  /// Ubicación política legible: "Cusco / Cusco / Wanchaq".
  String get ubicacionPolitica => '$departamento / $provincia / $distrito';

  /// Establecimiento de ejemplo usado como dato semilla, siguiendo la
  /// convención de datos reales de GERESA Cusco.
  factory Establecimiento.ejemplo() {
    return const Establecimiento(
      codigoUnico: '00006405',
      nombre: 'Hospital Regional del Cusco',
      categoria: CategoriaNivel.ii2,
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
