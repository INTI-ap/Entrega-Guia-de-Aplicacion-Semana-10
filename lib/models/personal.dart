/// Clase base que representa a una persona registrada durante una
/// observación de higiene de manos, según los campos comunes del
/// formulario oficial (DNI, nombres y apellidos).
///
/// Construida en la Guía de Práctica N.° 3 (PantallaPersonal,
/// Sesiones 4-7) aplicando herencia entre clases relacionadas (Sesión 3):
/// tanto el observador como el personal observado comparten estos
/// atributos, pero el observado además registra una categoría
/// profesional que el observador no requiere.
class Personal {
  final String dni;
  final String nombresApellidos;

  const Personal({required this.dni, required this.nombresApellidos});

  /// Iniciales usadas como contenido del avatar circular en las
  /// tarjetas de personal (Guía N.° 4, indicador tipo Stack).
  String get iniciales {
    final partes = nombresApellidos.trim().split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }
}

/// Personal que realiza la observación (auditor de higiene de manos).
/// Hereda dni y nombresApellidos de [Personal].
class Observador extends Personal {
  const Observador({required super.dni, required super.nombresApellidos});

  factory Observador.ejemplo() {
    return const Observador(
      dni: '23456789',
      nombresApellidos: 'Ana Quispe Mamani',
    );
  }
}

/// Personal observado durante el ejercicio de auditoría (el trabajador
/// de salud cuya adherencia a los 5 Momentos se está evaluando).
/// Además de heredar dni y nombresApellidos, agrega la categoría
/// profesional propia de este rol.
class Observado extends Personal {
  final String categoriaProfesional;

  // Campo opcional: no siempre se cuenta con el servicio médico
  // específico dentro del UPSS al momento del registro.
  final String? servicioMedico;

  const Observado({
    required super.dni,
    required super.nombresApellidos,
    required this.categoriaProfesional,
    this.servicioMedico,
  });

  factory Observado.ejemplo() {
    return const Observado(
      dni: '45678912',
      nombresApellidos: 'Carlos Huamán Ttito',
      categoriaProfesional: 'Enfermero(a)',
      servicioMedico: 'Medicina General',
    );
  }
}
