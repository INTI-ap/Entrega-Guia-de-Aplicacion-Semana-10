import 'package:drift/drift.dart' show Value;

// Las entidades del dominio se importan con el prefijo `dm.` porque el
// archivo generado por drift declara, dentro de esta misma biblioteca, una
// clase de datos por tabla (`Auditoria`, `Establecimiento`, …) que choca con
// el nombre de la entidad. Prefijar el dominio deja el código explícito:
// `dm.Auditoria` es la entidad, `db.Auditoria` es la fila.
import '../../domain/entidades/auditoria.dart' as dm;
import '../../domain/entidades/catalogos.dart' as dm;
import '../../domain/entidades/establecimiento.dart' as dm;
import '../../domain/entidades/oportunidad_registro.dart' as dm;
import '../../domain/entidades/personal.dart' as dm;
import '../local/manos_seguras_db.dart' as db;


// ---------------------------------------------------------------------
// 1. Oportunidades: dominio ↔ fila
// ---------------------------------------------------------------------

extension OportunidadRegistroMapper on dm.OportunidadRegistro {
  /// Fila generada → entidad de dominio.
  static dm.OportunidadRegistro desdeFila(db.Oportunidade fila) {
    return dm.OportunidadRegistro(
      id: fila.id,
      auditoriaId: fila.auditoriaId,
      numero: fila.numero,
      momento: dm.Momento.desdeClave(fila.momentoClave),
      accion: dm.Accion.desdeClave(fila.accionClave),
      observacion: fila.observacion,
    );
  }

  db.OportunidadesCompanion aFila({bool incluirId = false}) {
    return db.OportunidadesCompanion.insert(
      auditoriaId: auditoriaId,
      numero: numero,
      momentoClave: momento.clave,
      accionClave: accion.clave,
      observacion: Value<String?>(observacion),
      id: incluirId && id != null
          ? Value<int>(id!)
          : const Value<int>.absent(),
    );
  }
}

// ---------------------------------------------------------------------
// 2. Establecimiento y personal: dominio → fila / fila → dominio
// ---------------------------------------------------------------------

extension EstablecimientoMapper on dm.Establecimiento {
  db.EstablecimientosCompanion aFila() {
    return db.EstablecimientosCompanion.insert(
      codigoUnico: codigoUnico,
      nombre: nombre,
      categoria: categoria.etiqueta,
      red: Value<String>(red),
      microred: Value<String>(microred),
      departamento: Value<String>(departamento),
      provincia: Value<String>(provincia),
      distrito: Value<String>(distrito),
      latitud: Value<double?>(latitud),
      longitud: Value<double?>(longitud),
    );
  }

  static dm.Establecimiento desdeFila(db.Establecimiento fila) {
    return dm.Establecimiento(
      codigoUnico: fila.codigoUnico,
      nombre: fila.nombre,
      categoria: dm.CategoriaNivel.desdeEtiqueta(fila.categoria),
      red: fila.red,
      microred: fila.microred,
      departamento: fila.departamento,
      provincia: fila.provincia,
      distrito: fila.distrito,
      latitud: fila.latitud,
      longitud: fila.longitud,
    );
  }
}

extension PersonalMapper on dm.Personal {
  db.PersonalCompanion aFila() {
    final String? categoria = this is dm.Observado
        ? (this as dm.Observado).categoriaProfesional
        : null;
    final String? servicio =
        this is dm.Observado ? (this as dm.Observado).servicioMedico : null;

    return db.PersonalCompanion.insert(
      dni: dni,
      nombresApellidos: nombresApellidos,
      rol: Value<String>(rol),
      categoriaProfesional: Value<String?>(categoria),
      servicioMedico: Value<String?>(servicio),
    );
  }

  static dm.Personal desdeFila(db.PersonalData fila) {
    if (fila.rol == 'observador') {
      return dm.Observador(
        dni: fila.dni,
        nombresApellidos: fila.nombresApellidos,
      );
    }
    return dm.Observado(
      dni: fila.dni,
      nombresApellidos: fila.nombresApellidos,
      categoriaProfesional: fila.categoriaProfesional ?? 'No especificada',
      servicioMedico: fila.servicioMedico,
    );
  }
}

// ---------------------------------------------------------------------
// 3. Auditoría: dominio → fila y fila → dominio
// ---------------------------------------------------------------------

extension AuditoriaMapper on dm.Auditoria {
  /// Convierte solo la cabecera. Las oportunidades se insertan aparte,
  /// porque viven en otra tabla.
  db.AuditoriasCompanion aCabeceraFila() {
    return db.AuditoriasCompanion.insert(
      id: id,
      establecimientoId: establecimientoId,
      establecimientoNombre: establecimientoNombre,
      observadorDni: observadorDni,
      observadorNombre: observadorNombre,
      observadoDni: observadoDni,
      observadoNombre: observadoNombre,
      fecha: fecha,
      estado: Value<String>(estado.clave),
      eliminada: Value<bool>(eliminada),
      sincronizadaEn: Value<DateTime?>(sincronizadaEn),
    );
  }

  /// Reconstruye la entidad de dominio a partir de la cabecera y el detalle
  /// ya leídos. Es el mapeo que más se usa en la aplicación.
  static dm.Auditoria desdeFilas(
    db.Auditoria cabecera,
    List<db.Oportunidade> oportunidades,
  ) {
    return dm.Auditoria(
      id: cabecera.id,
      establecimientoId: cabecera.establecimientoId,
      establecimientoNombre: cabecera.establecimientoNombre,
      observadorDni: cabecera.observadorDni,
      observadorNombre: cabecera.observadorNombre,
      observadoDni: cabecera.observadoDni,
      observadoNombre: cabecera.observadoNombre,
      fecha: cabecera.fecha,
      estado: dm.EstadoAuditoria.desdeClave(cabecera.estado),
      eliminada: cabecera.eliminada,
      sincronizadaEn: cabecera.sincronizadaEn,
      oportunidades: oportunidades
          .map(OportunidadRegistroMapper.desdeFila)
          .toList(growable: false),
    );
  }
}
