/// Personas que participan en una observación de higiene de manos.
///
/// **Capa Domain (Semana 8) + principio de Sustitución de Liskov
/// (LSP, Semana 9).** [Observador] y [Observado] heredan de [Personal] y
/// pueden usarse en cualquier lugar donde se espere un [Personal]: el
/// repositorio guarda ambos con la misma operación `insertPersonal`.
library;

/// Clase base con los campos comunes del formulario oficial (DNI,
/// nombres y apellidos).
sealed class Personal {
  const Personal({required this.dni, required this.nombresApellidos});

  final String dni;
  final String nombresApellidos;

  /// Rol con el que la persona se guarda en la base de datos local.
  /// Es un `String` y no un `enum` porque la columna es `TextColumn`:
  /// mantener el mismo tipo en dominio y datos evita conversiones.
  String get rol;

  /// Iniciales usadas como contenido del avatar circular en las tarjetas.
  String get iniciales {
    final List<String> partes = nombresApellidos
        .trim()
        .split(RegExp(r'\s+'));
    if (partes.isEmpty || partes.first.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes.last.substring(0, 1))
        .toUpperCase();
  }
}

/// Personal que realiza la observación (auditor de higiene de manos).
class Observador extends Personal {
  const Observador({required super.dni, required super.nombresApellidos});

  @override
  String get rol => 'observador';

  factory Observador.ejemplo() {
    return const Observador(
      dni: '23456789',
      nombresApellidos: 'Ana Quispe Mamani',
    );
  }
}

/// Personal observado durante el ejercicio de auditoría.
class Observado extends Personal {
  const Observado({
    required super.dni,
    required super.nombresApellidos,
    required this.categoriaProfesional,
    this.servicioMedico,
  });

  final String categoriaProfesional;

  /// Campo opcional: no siempre se conoce el servicio o UPSS exacto.
  final String? servicioMedico;

  @override
  String get rol => 'observado';

  factory Observado.ejemplo() {
    return const Observado(
      dni: '45678912',
      nombresApellidos: 'Carlos Huamán Ttito',
      categoriaProfesional: 'Enfermero(a)',
      servicioMedico: 'Medicina General',
    );
  }
}
