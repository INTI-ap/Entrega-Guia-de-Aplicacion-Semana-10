import 'dart:math';

import '../../core/id.dart';
// Igual que en los mapeadores, las entidades del dominio se importan con el
// prefijo `dm.` para no chocar con las clases de datos que drift genera
// dentro de la biblioteca de la base (`Establecimiento`, `Auditoria`, …).
import '../../domain/entidades/auditoria.dart' as dm;
import '../../domain/entidades/catalogos.dart' as dm;
import '../../domain/entidades/establecimiento.dart' as dm;
import '../../domain/entidades/oportunidad_registro.dart' as dm;
import '../../domain/entidades/personal.dart' as dm;
import '../../domain/repositorios/auditoria_repository.dart';
import '../mapeadores/mapeadores.dart';
import 'manos_seguras_db.dart';

/// **Sembrador de datos de laboratorio.**
///
/// Vive en la capa Data y **no** dentro de `ManosSegurasDb` por una razón de
/// diseño: la base de datos no debe conocer entidades de dominio. Al sacarlo,
/// el archivo de la base queda cerrado a cambios (principio Abierto/Cerrado,
/// Semana 9) y el ciclo de imports se rompe.
///
/// Usa el repositorio de auditorías, es decir, escribe por el mismo camino
/// que la aplicación: eso garantiza que los datos sembrados cumplan las
/// mismas reglas (claves foráneas, numeración de oportunidades, estados).
class SembradorDatos {
  SembradorDatos({
    required ManosSegurasDb base,
    required AuditoriaRepository repositorio,
    Random? azar,
  })  : _base = base,
        _repositorio = repositorio,
        _azar = azar ?? Random(2026);

  final ManosSegurasDb _base;
  final AuditoriaRepository _repositorio;

  /// Semilla fija: los datos de ejemplo deben ser **reproducibles** para que
  /// las capturas del informe y las pruebas coincidan entre ejecuciones.
  final Random _azar;

  static const List<String> _nombresObservados = <String>[
    'Carlos Huamán Ttito',
    'Rosa Ccahuana Loayza',
    'Julio Mamani Quispe',
    'Lucía Pumacayo Sallo',
    'Marco Auccapure Huillca',
  ];

  /// Inserta establecimiento, personal y [cantidad] auditorías con sus
  /// cinco oportunidades. Devuelve cuántas auditorías se guardaron.
  Future<int> sembrar({int cantidad = 3}) async {
    final dm.Establecimiento establecimiento = dm.Establecimiento.ejemplo();
    final dm.Observador observador = dm.Observador.ejemplo();

    // Las tablas de catálogo se escriben a través de los métodos públicos de
    // la base: son datos de referencia que cambian muy poco y no tienen un
    // repositorio propio en esta versión del proyecto.
    await _base.insertarEstablecimiento(establecimiento.aFila());
    await _base.insertarPersonal(observador.aFila());

    int guardadas = 0;

    for (int i = 0; i < cantidad; i++) {
      final String dni = (45678912 + i).toString();
      final dm.Observado observado = dm.Observado(
        dni: dni,
        nombresApellidos: _nombresObservados[i % _nombresObservados.length],
        categoriaProfesional: i.isEven ? 'Enfermero(a)' : 'Médico(a)',
        servicioMedico: i.isEven ? 'Medicina General' : 'Emergencia',
      );

      await _base.insertarPersonal(observado.aFila());

      final DateTime fecha = DateTime.now().subtract(Duration(days: i * 3));

      final List<dm.OportunidadRegistro> oportunidades =
          List<dm.OportunidadRegistro>.generate(
        dm.Momento.values.length,
        (int indice) {
          final bool omite = _azar.nextInt(10) < 3;
          return dm.OportunidadRegistro(
            auditoriaId: '', // lo completa el repositorio
            numero: indice + 1,
            momento: dm.Momento.values[indice],
            accion: omite
                ? dm.Accion.omision
                : (indice.isEven
                    ? dm.Accion.friccionDeManos
                    : dm.Accion.lavadoDeManos),
          );
        },
      );

      await _repositorio.guardar(
        dm.Auditoria(
          id: generarUuidV4(),
          establecimientoId: establecimiento.codigoUnico,
          establecimientoNombre: establecimiento.nombre,
          observadorDni: observador.dni,
          observadorNombre: observador.nombresApellidos,
          observadoDni: observado.dni,
          observadoNombre: observado.nombresApellidos,
          fecha: fecha,
          estado: i == 0
              ? dm.EstadoAuditoria.borrador
              : dm.EstadoAuditoria.finalizada,
          oportunidades: oportunidades,
        ),
      );

      guardadas++;
    }

    return guardadas;
  }

  /// Borra auditorías y oportunidades. Se usa antes de sembrar para que el
  /// resultado sea reproducible.
  Future<void> limpiar() async {
    await _base.limpiarAuditorias();
  }
}
