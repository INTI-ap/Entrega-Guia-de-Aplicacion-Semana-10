/// **Alias públicos de los tipos que drift genera.**
///
/// Cuando el esquema se declara en varios archivos y los DAO viven en
/// bibliotecas separadas, el generador no puede nombrar las clases de tabla
/// internas (`$AuditoriasTable`, …) desde el DAO: aparecen errores como
///
/// ```
/// The argument type 'Expression<bool> Function(Auditorias)'
/// can't be assigned to the parameter type 'Expression<bool> Function(Table)'
/// ```
///
/// Porque `attachedDatabase.auditorias` se resuelve como `dynamic` y el
/// analizador no puede inferir el tipo del parámetro de `where()`.
///
/// La solución es declarar aquí, una sola vez, alias con nombres estables y
/// usarlos con prefijo desde los DAO:
///
/// ```dart
/// import '../aliases.dart' as g;
/// // …
/// ..where((g.TablaAuditorias t) => t.eliminada.equals(false))
/// ```
///
/// Lo mismo hace falta para el parámetro de tipo de `SimpleSelectStatement` y
/// de `OrderClauseGenerator`.
///
/// Es un patrón pequeño y muy útil: la alternativa oficial de drift
/// (`build.yaml` con `databases:` + pruebas de esquema) exige generar y
/// versionar archivos JSON del esquema, lo que para un proyecto de curso
/// agrega más complejidad de la que resuelve.
///
/// Nota: los alias se declaran sobre las **clases de tabla**, no sobre las
/// filas. Las filas siguen accediéndose con el prefijo `db.`
/// (`db.Auditoria`, `db.Oportunidade`, …).
library;

import 'manos_seguras_db.dart';

/// Tabla `establecimientos` tal como la genera drift para esta base.
typedef TablaEstablecimientos = $EstablecimientosTable;

/// Tabla `personal` tal como la genera drift para esta base.
typedef TablaPersonal = $PersonalTable;

/// Tabla `auditorias` tal como la genera drift para esta base.
typedef TablaAuditorias = $AuditoriasTable;

/// Tabla `oportunidades` tal como la genera drift para esta base.
typedef TablaOportunidades = $OportunidadesTable;

/// Tabla `indicadores_cache` tal como la genera drift para esta base.
typedef TablaIndicadoresCache = $IndicadoresCacheTable;

/// Tabla `sincronizaciones` tal como la genera drift para esta base.
typedef TablaSincronizaciones = $SincronizacionesTable;

/// Tabla `preferencias` tal como la genera drift para esta base.
typedef TablaPreferencias = $PreferenciasTable;
