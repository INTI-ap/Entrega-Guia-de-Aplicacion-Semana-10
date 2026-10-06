/// Modelos de dominio del instrumento oficial de higiene de manos
/// (RM N.° 255-2016/MINSA), extraídos de las listas `choices` del
/// formulario `formularioahmniveliii.xlsx`: los 5 Momentos de higiene
/// de manos de la OMS y las 4 acciones posibles por oportunidad.
///
/// Se modelan como `enum` de Dart (Sesión 3) en lugar de texto libre,
/// de modo que el compilador impida valores fuera del catálogo oficial.
library;

/// Los 5 Momentos para la higiene de manos (OMS / MINSA), en el mismo
/// orden y con las mismas etiquetas que la lista `yc7fh57` del XLSForm.
enum Momento {
  antesDeTocarPaciente('Antes de tocar al paciente'),
  antesDeTareaAseptica('Antes de realizar una tarea limpia/aséptica'),
  despuesRiesgoFluidos('Después del riesgo de exposición a fluidos corporales'),
  despuesDeTocarPaciente('Después de tocar al paciente'),
  despuesEntornoPaciente('Después del contacto con el entorno del paciente');

  final String etiqueta;
  const Momento(this.etiqueta);
}

/// Acción registrada para una oportunidad de observación, según la
/// lista `zg0zv29` del XLSForm oficial.
enum Accion {
  guantes('Guantes'),
  lavadoDeManos('Lavado de manos (LV)'),
  omision('Omisión'),
  friccionDeManos('Fricción de manos (FM)');

  final String etiqueta;
  const Accion(this.etiqueta);

  /// Una omisión es la única acción que representa incumplimiento;
  /// las otras tres (guantes, lavado, fricción) cuentan como
  /// cumplimiento de la indicación.
  bool get esCumplimiento => this != Accion.omision;
}

/// Una oportunidad de observación: el par (Momento, Acción) que el
/// observador registra cada vez que corresponde una indicación de
/// higiene de manos, tal como en los grupos
/// `EVALUACION_OBLIGATORIO_oportunidad_01` a `_05` del XLSForm.
///
/// Construida en la Guía de Práctica N.° 4 (Sesiones 8-10) como base
/// de datos para el indicador tipo Stack y las etiquetas tipo Wrap.
class Oportunidad {
  final int numero;
  final Momento momento;
  final Accion accion;

  const Oportunidad({
    required this.numero,
    required this.momento,
    required this.accion,
  });

  bool get cumplio => accion.esCumplimiento;

  /// Conjunto de 5 oportunidades de ejemplo, una por cada Momento,
  /// usado como dato semilla en PantallaOportunidades.
  static List<Oportunidad> listaEjemplo() {
    return const [
      Oportunidad(
        numero: 1,
        momento: Momento.antesDeTocarPaciente,
        accion: Accion.friccionDeManos,
      ),
      Oportunidad(
        numero: 2,
        momento: Momento.antesDeTareaAseptica,
        accion: Accion.lavadoDeManos,
      ),
      Oportunidad(
        numero: 3,
        momento: Momento.despuesRiesgoFluidos,
        accion: Accion.guantes,
      ),
      Oportunidad(
        numero: 4,
        momento: Momento.despuesDeTocarPaciente,
        accion: Accion.omision,
      ),
      Oportunidad(
        numero: 5,
        momento: Momento.despuesEntornoPaciente,
        accion: Accion.friccionDeManos,
      ),
    ];
  }
}
