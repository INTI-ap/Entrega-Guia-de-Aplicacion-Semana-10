import 'daos/auditorias_dao.dart';
import 'daos/indicadores_dao.dart';
import 'daos/preferencias_dao.dart';
import 'manos_seguras_db.dart';

/// **Contenedor de la capa de infraestructura local.**
///
/// Reúne la base de datos y sus tres DAO. Existe porque los DAO **no** se
/// declaran en `@DriftDatabase(daos: [...])`:
///
/// * si se declararan allí, el archivo de la base tendría que importar los
///   DAO y estos tendrían que importar la base, creando un ciclo de imports;
/// * con ese ciclo, el generador de drift no puede resolver el tipo de la
///   base y escribe `DatabaseAccessor<dynamic /* = invalid */>` en el código
///   generado, lo que rompe la compilación (Anexo A, Error 7 de la guía).
///
/// La solución —construir el *wiring* en un archivo aparte— es la misma que
/// se aplicó con get_it en la Semana 9: **quien conoce las clases concretas
/// es el contenedor, no las capas**.
class InfraestructuraLocal {
  InfraestructuraLocal(this.base)
      : auditoriasDao = DriftAuditoriasDao(base),
        indicadoresDao = DriftIndicadoresDao(base),
        preferenciasDao = DriftPreferenciasDao(base);

  /// Base de datos SQLite abierta por [abrirBaseDeDatos] o en memoria.
  final ManosSegurasDb base;

  final DriftAuditoriasDao auditoriasDao;
  final DriftIndicadoresDao indicadoresDao;
  final DriftPreferenciasDao preferenciasDao;

  /// Cierra la conexión. Se llama desde el `dispose` de get_it.
  Future<void> cerrar() => base.close();
}
