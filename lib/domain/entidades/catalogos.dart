/// Entidades del dominio del instrumento oficial de higiene de manos
/// (RM N.° 255-2016/MINSA), extraídas de las listas `choices` del
/// formulario `formularioahmniveliii.xlsx`.
///
/// **Semana 8 — capa Domain.** Estas entidades son *plain Dart*: no
/// importan `flutter`, ni `drift`, ni `http`. Esa pureza es la que permite
/// probarlas con `dart test` en milisegundos y la que garantiza que la
/// regla de negocio no se rompa al cambiar de base de datos.
///
/// Nota de refactorización (Semana 9-10): antes estas clases vivían en
/// `lib/models/` junto con los constructores `fromJson` del API. El
/// `fromJson` se movió a `lib/data/mapeadores/` (capa Data) y aquí solo
/// quedan las reglas del negocio y sus valores legibles.
library;

/// Los 5 Momentos para la higiene de manos (OMS / MINSA), en el mismo
/// orden y con las mismas etiquetas que la lista `yc7fh57` del XLSForm.
///
/// El valor textual `clave` es el que se guarda en SQLite: si algún día
/// cambia la etiqueta visible, los registros ya guardados siguen siendo
/// legibles (principio Abierto/Cerrado, Semana 9).
enum Momento {
  antesDeTocarPaciente(
    clave: 'antes_paciente',
    etiqueta: 'Antes de tocar al paciente',
  ),
  antesDeTareaAseptica(
    clave: 'antes_aseptica',
    etiqueta: 'Antes de realizar una tarea limpia/aséptica',
  ),
  despuesRiesgoFluidos(
    clave: 'despues_fluidos',
    etiqueta: 'Después del riesgo de exposición a fluidos corporales',
  ),
  despuesDeTocarPaciente(
    clave: 'despues_paciente',
    etiqueta: 'Después de tocar al paciente',
  ),
  despuesEntornoPaciente(
    clave: 'despues_entorno',
    etiqueta: 'Después del contacto con el entorno del paciente',
  );

  const Momento({required this.clave, required this.etiqueta});

  /// Identificador estable usado en la base de datos y en el API.
  final String clave;

  /// Texto que se muestra al usuario.
  final String etiqueta;

  /// Reconstruye el enum a partir de su clave almacenada. Si el registro
  /// viene de una versión futura con un momento desconocido, se degrada a
  /// un valor seguro en lugar de lanzar una excepción: la app no debe
  /// caerse por un dato viejo.
  static Momento desdeClave(String? clave) {
    return Momento.values.firstWhere(
      (Momento m) => m.clave == clave,
      orElse: () => Momento.antesDeTocarPaciente,
    );
  }
}

/// Acción registrada para una oportunidad de observación, según la lista
/// `zg0zv29` del XLSForm oficial.
enum Accion {
  guantes(clave: 'guantes', etiqueta: 'Guantes'),
  lavadoDeManos(clave: 'lavado', etiqueta: 'Lavado de manos (LV)'),
  omision(clave: 'omision', etiqueta: 'Omisión'),
  friccionDeManos(clave: 'friccion', etiqueta: 'Fricción de manos (FM)');

  const Accion({required this.clave, required this.etiqueta});

  final String clave;
  final String etiqueta;

  /// Una omisión es la única acción que representa incumplimiento; las
  /// otras tres (guantes, lavado, fricción) cuentan como cumplimiento.
  ///
  /// Esta es una **regla de negocio** y por eso vive en el dominio, no en
  /// la pantalla ni en el DAO.
  bool get esCumplimiento => this != Accion.omision;

  static Accion desdeClave(String? clave) {
    return Accion.values.firstWhere(
      (Accion a) => a.clave == clave,
      orElse: () => Accion.omision,
    );
  }
}

/// Categoría del establecimiento de salud según su nivel de complejidad
/// (campos `CATEGORIA_DEL_ESTABLECIMIENTO` del XLSForm).
enum CategoriaNivel {
  i1('I-1'),
  i2('I-2'),
  i3('I-3'),
  i4('I-4'),
  ii1('II-1'),
  ii2('II-2'),
  iii1('III-1'),
  iii2('III-2');

  const CategoriaNivel(this.etiqueta);

  final String etiqueta;

  static CategoriaNivel desdeEtiqueta(String? etiqueta) {
    return CategoriaNivel.values.firstWhere(
      (CategoriaNivel c) => c.etiqueta == etiqueta,
      orElse: () => CategoriaNivel.ii2,
    );
  }
}
