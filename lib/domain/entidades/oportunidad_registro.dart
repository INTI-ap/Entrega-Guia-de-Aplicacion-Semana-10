import 'catalogos.dart';

/// Una oportunidad de observación registrada: el par
/// (Momento, Acción) que el observador anota cada vez que corresponde una
/// indicación de higiene de manos, tal como en los grupos
/// `EVALUACION_OBLIGATORIO_oportunidad_01` a `_05` del XLSForm oficial.
///
/// **Capa Domain (Semana 8).** El campo [id] es `nullable` porque una
/// oportunidad recién capturada en la pantalla todavía no existe en la
/// base de datos; la capa Data lo ignora al insertar y lo rellena al leer.
class OportunidadRegistro {
  const OportunidadRegistro({
    this.id,
    required this.auditoriaId,
    required this.numero,
    required this.momento,
    required this.accion,
    this.observacion,
    this.duracionSegundos,
  });

  final int? id;
  final String auditoriaId;
  final int numero;
  final Momento momento;
  final Accion accion;

  /// Nota libre del observador (campo opcional del XLSForm, por ejemplo
  /// "se colocó guantes sin realizar higiene previa").
  final String? observacion;

  /// Duración en segundos de la oportunidad (Reto 4).
  final int? duracionSegundos;

  /// Regla de negocio delegada en el catálogo [Accion].
  bool get cumplio => accion.esCumplimiento;

  /// Código visible en la interfaz: "O-03".
  String get codigo => 'O-${numero.toString().padLeft(2, '0')}';

  OportunidadRegistro copyWith({
    int? id,
    String? auditoriaId,
    int? numero,
    Momento? momento,
    Accion? accion,
    String? observacion,
    int? duracionSegundos,
  }) {
    return OportunidadRegistro(
      id: id ?? this.id,
      auditoriaId: auditoriaId ?? this.auditoriaId,
      numero: numero ?? this.numero,
      momento: momento ?? this.momento,
      accion: accion ?? this.accion,
      observacion: observacion ?? this.observacion,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
    );
  }

  @override
  String toString() =>
      'OportunidadRegistro($codigo, ${momento.clave}, ${accion.clave})';
}
