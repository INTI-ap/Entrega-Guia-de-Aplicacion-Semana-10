import 'oportunidad_registro.dart';

/// Estado del ciclo de vida de una auditoría dentro de la aplicación
/// **offline-first**. Es una máquina de estados sencilla que la capa de
/// datos usa para decidir qué registros enviar al servidor.
enum EstadoAuditoria {
  /// Capturada en el dispositivo, todavía no sincronizada.
  borrador(clave: 'borrador', etiqueta: 'Borrador local'),

  /// Cerrada por el observador; queda lista para sincronizar.
  finalizada(clave: 'finalizada', etiqueta: 'Finalizada (pendiente de envío)'),

  /// Confirmada por el servidor.
  sincronizada(clave: 'sincronizada', etiqueta: 'Sincronizada');

  const EstadoAuditoria({required this.clave, required this.etiqueta});

  final String clave;
  final String etiqueta;

  static EstadoAuditoria desdeClave(String? clave) {
    return EstadoAuditoria.values.firstWhere(
      (EstadoAuditoria e) => e.clave == clave,
      orElse: () => EstadoAuditoria.borrador,
    );
  }
}

/// Una auditoría completa: la cabecera del formulario (establecimiento,
/// observador, personal observado, fecha) más la lista de oportunidades
/// registradas.
///
/// **Capa Domain (Semana 8) + SRP (Semana 9).** Esta clase solo representa
/// datos y calcula indicadores; no sabe leer ni escribir en SQLite. Toda la
/// persistencia vive en `AuditoriaRepository` / `AuditoriasDao`.
///
/// **Trade-off documentado (Semana 10).** Los nombres de las personas se
/// guardan también en la auditoría (denormalización) para que el listado
/// offline se dibuje con una sola consulta y para que el registro histórico
/// conserve el nombre que la persona tenía al momento de la observación.
class Auditoria {
  const Auditoria({
    required this.id,
    required this.establecimientoId,
    required this.establecimientoNombre,
    required this.observadorDni,
    required this.observadorNombre,
    required this.observadoDni,
    required this.observadoNombre,
    required this.fecha,
    this.estado = EstadoAuditoria.borrador,
    this.eliminada = false,
    this.sincronizadaEn,
    this.fechaInicio,
    this.fechaFin,
    this.numeroCamas,
    this.consentimientoVerbal,
    this.observacionGeneral,
    this.oportunidades = const <OportunidadRegistro>[],
  });

  /// Identificador generado en el dispositivo (UUID v4). Se genera local
  /// y no con `AUTOINCREMENT` porque el registro debe poder crearse sin
  /// conexión y fusionarse después con el servidor sin colisiones.
  final String id;

  final String establecimientoId;
  final String establecimientoNombre;
  final String observadorDni;
  final String observadorNombre;
  final String observadoDni;
  final String observadoNombre;
  final DateTime fecha;
  final EstadoAuditoria estado;

  /// Borrado lógico (*soft delete*): la fila nunca se elimina físicamente
  /// para no perder la trazabilidad exigida por la norma de auditoría.
  final bool eliminada;

  /// Marca de tiempo de la última sincronización con el servidor.
  final DateTime? sincronizadaEn;

  /// Campos del formulario oficial (Reto 1):
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int? numeroCamas;
  final bool? consentimientoVerbal;

  /// Observación general de la auditoría (Reto 4):
  final String? observacionGeneral;

  final List<OportunidadRegistro> oportunidades;

  // -------------------------------------------------------------------
  // Indicadores derivados. Son reglas de negocio puras y por eso se
  // calculan aquí y no en la pantalla (SRP, Semana 9).
  // -------------------------------------------------------------------

  int get totalOportunidades => oportunidades.length;

  int get oportunidadesCumplidas =>
      oportunidades.where((OportunidadRegistro o) => o.cumplio).length;

  int get omisiones => totalOportunidades - oportunidadesCumplidas;

  /// Porcentaje de adherencia (0 a 100). Si no hay oportunidades
  /// registradas devuelve 0 y la interfaz debe mostrar "Sin datos".
  double get porcentajeAdherencia {
    if (totalOportunidades == 0) return 0;
    return (oportunidadesCumplidas / totalOportunidades) * 100;
  }

  bool get tieneDatos => totalOportunidades > 0;

  Auditoria copyWith({
    String? id,
    String? establecimientoId,
    String? establecimientoNombre,
    String? observadorDni,
    String? observadorNombre,
    String? observadoDni,
    String? observadoNombre,
    DateTime? fecha,
    EstadoAuditoria? estado,
    bool? eliminada,
    DateTime? sincronizadaEn,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? numeroCamas,
    bool? consentimientoVerbal,
    String? observacionGeneral,
    List<OportunidadRegistro>? oportunidades,
  }) {
    return Auditoria(
      id: id ?? this.id,
      establecimientoId: establecimientoId ?? this.establecimientoId,
      establecimientoNombre: establecimientoNombre ?? this.establecimientoNombre,
      observadorDni: observadorDni ?? this.observadorDni,
      observadorNombre: observadorNombre ?? this.observadorNombre,
      observadoDni: observadoDni ?? this.observadoDni,
      observadoNombre: observadoNombre ?? this.observadoNombre,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      eliminada: eliminada ?? this.eliminada,
      sincronizadaEn: sincronizadaEn ?? this.sincronizadaEn,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      numeroCamas: numeroCamas ?? this.numeroCamas,
      consentimientoVerbal: consentimientoVerbal ?? this.consentimientoVerbal,
      observacionGeneral: observacionGeneral ?? this.observacionGeneral,
      oportunidades: oportunidades ?? this.oportunidades,
    );
  }

  @override
  String toString() =>
      'Auditoria($id, $establecimientoNombre, '
      '$oportunidadesCumplidas/$totalOportunidades)';
}

/// Resumen agregado que consume la pantalla de indicadores locales.
///
/// **Reto 5 (opcional, rendimiento):** la consulta que lo produce debe
/// resolver el cálculo con `SUM`/`COUNT` en SQL, no cargando todas las
/// auditorías en memoria.
class ResumenAdherencia {
  const ResumenAdherencia({
    required this.totalAuditorias,
    required this.totalOportunidades,
    required this.totalCumplidas,
    this.promedioAdherencia,
    this.ultimaAuditoria,
  });

  factory ResumenAdherencia.vacio() {
    return const ResumenAdherencia(
      totalAuditorias: 0,
      totalOportunidades: 0,
      totalCumplidas: 0,
    );
  }

  final int totalAuditorias;
  final int totalOportunidades;
  final int totalCumplidas;
  final double? promedioAdherencia;
  final DateTime? ultimaAuditoria;

  int get totalOmisiones => totalOportunidades - totalCumplidas;

  double get porcentajeGlobal {
    if (totalOportunidades == 0) return 0;
    return (totalCumplidas / totalOportunidades) * 100;
  }
}
