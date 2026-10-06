import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/fallos.dart';
import '../../core/id.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entidades/auditoria.dart';
import '../../domain/entidades/catalogos.dart';
import '../../domain/entidades/establecimiento.dart';
import '../../domain/entidades/oportunidad_registro.dart';
import '../../domain/entidades/personal.dart';
import '../../domain/repositorios/auditoria_repository.dart';
import '../../domain/repositorios/indicador_repository.dart';
import '../di.dart';
import '../widgets/app_layout.dart';
import '../widgets/tarjetas.dart';

/// Captura de oportunidades (los 5 Momentos) **y guardado en la base local**.
///
/// Es el punto donde la Semana 10 cambia el comportamiento de la aplicación:
/// hasta la Sesión 15, al cerrar la pantalla los datos se perdían porque
/// vivían en `setState`. Ahora el botón *Guardar* construye una [Auditoria]
/// (entidad de dominio) y la entrega al repositorio, que la escribe en SQLite
/// dentro de una transacción.
///
/// Puntos didácticos del archivo:
///
///  * la pantalla **no conoce drift**: solo pide `getIt<AuditoriaRepository>()`;
///  * después de cada `await` se verifica `mounted` antes de tocar el
///    `BuildContext` (lección de la Sesión 16);
///  * los fallos llegan traducidos como [Fallo], no como `SqliteException`.
class PantallaOportunidades extends StatefulWidget {
  const PantallaOportunidades({super.key});

  @override
  State<PantallaOportunidades> createState() => _PantallaOportunidadesState();
}

class _PantallaOportunidadesState extends State<PantallaOportunidades> {
  final AuditoriaRepository _repositorio = getIt<AuditoriaRepository>();

  /// Estado efímero de la captura (se pierde si no se guarda: por eso existe
  /// el botón Guardar).
  final List<OportunidadRegistro> _oportunidades = <OportunidadRegistro>[];
  int _siguienteNumero = 1;
  bool _guardando = false;

  Accion _accionSeleccionada = Accion.friccionDeManos;
  bool _cargandoPreferencia = true;

  /// Último establecimiento usado, leído del almacén clave-valor
  /// (`preferencias`). Es un ejemplo del uso correcto de una tabla clave-valor:
  /// un dato suelto, sin relaciones.
  String? _ultimoEstablecimiento;

  @override
  void initState() {
    super.initState();
    _recuperarUltimoEstablecimiento();
  }

  Future<void> _recuperarUltimoEstablecimiento() async {
    try {
      final String? codigo = await getIt<PreferenciasRepository>()
          .leer('establecimiento.ultimo');
      if (!mounted) return;
      setState(() {
        _ultimoEstablecimiento = codigo;
        _cargandoPreferencia = false;
      });
    } on Fallo {
      if (!mounted) return;
      setState(() => _cargandoPreferencia = false);
    }
  }

  void _agregar() {
    final Momento momento =
        Momento.values[(_oportunidades.length) % Momento.values.length];

    setState(() {
      _oportunidades.add(
        OportunidadRegistro(
          auditoriaId: '', // lo completa el repositorio al guardar
          numero: _siguienteNumero,
          momento: momento,
          accion: _accionSeleccionada,
        ),
      );
      _siguienteNumero++;
    });
  }

  void _quitar(int numero) {
    setState(() {
      _oportunidades.removeWhere(
        (OportunidadRegistro o) => o.numero == numero,
      );
    });
  }

  /// **El corazón de la Semana 10.** Construye la auditoría y la persiste.
  Future<void> _guardar() async {
    if (_oportunidades.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registre al menos una oportunidad antes de guardar.'),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final Establecimiento establecimiento = Establecimiento.ejemplo();
    final Auditoria auditoria = Auditoria(
      // Identificador UUID v4 generado en el dispositivo: la auditoría se
      // puede guardar sin conexión sin riesgo de colisión al sincronizar.
      id: generarUuidV4(),
      establecimientoId: establecimiento.codigoUnico,
      establecimientoNombre: establecimiento.nombre,
      observadorDni: Observador.ejemplo().dni,
      observadorNombre: Observador.ejemplo().nombresApellidos,
      observadoDni: Observado.ejemplo().dni,
      observadoNombre: Observado.ejemplo().nombresApellidos,
      fecha: DateTime.now(),
      estado: EstadoAuditoria.borrador,
      oportunidades: List<OportunidadRegistro>.of(_oportunidades),
    );

    try {
      final String id = await _repositorio.guardar(auditoria);
      await getIt<PreferenciasRepository>().guardar(
        'establecimiento.ultimo',
        establecimiento.codigoUnico,
      );

      // Después de un await el widget puede haber sido retirado del árbol.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Auditoría guardada en el dispositivo.')),
      );
      context.go('/auditorias/$id');
    } on FalloDeValidacion catch (fallo) {
      if (!mounted) return;
      _mostrarError(fallo.mensaje);
    } on Fallo catch (fallo) {
      if (!mounted) return;
      _mostrarError(fallo.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: AppColors.alerta),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int cumplidas = _oportunidades
        .where((OportunidadRegistro o) => o.cumplio)
        .length;
    final int porcentaje = _oportunidades.isEmpty
        ? 0
        : ((cumplidas / _oportunidades.length) * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oportunidades'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Ver auditorías guardadas',
            onPressed: () => context.go('/auditorias'),
            icon: const Icon(Icons.folder_open_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: AppLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              if (!_cargandoPreferencia && _ultimoEstablecimiento != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Último establecimiento auditado: '
                    '$_ultimoEstablecimiento (preferencia guardada en SQLite)',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              _Resumen(cumplidas: cumplidas, total: _oportunidades.length,
                  porcentaje: porcentaje),
              const SizedBox(height: 16),
              const TituloSeccion('Registrar una oportunidad',
                  icono: Icons.add_task),
              TarjetaBase(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Acción observada',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: Accion.values.map((Accion accion) {
                        final bool seleccionada = accion == _accionSeleccionada;
                        final Color color = EstiloCatalogo.colorAccion(accion);
                        return ChoiceChip(
                          label: Text(accion.etiqueta),
                          selected: seleccionada,
                          avatar: Icon(
                            EstiloCatalogo.iconoAccion(accion),
                            size: 16,
                            color: seleccionada ? Colors.white : color,
                          ),
                          selectedColor: color,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            color: seleccionada ? Colors.white : null,
                          ),
                          onSelected: (bool _) {
                            setState(() => _accionSeleccionada = accion);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _agregar,
                        icon: const Icon(Icons.add),
                        label: Text(
                          'Agregar oportunidad '
                          '${_siguienteNumero.toString().padLeft(2, '0')}',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TituloSeccion(
                'Oportunidades registradas (${_oportunidades.length})',
                icono: Icons.list_alt,
              ),
              if (_oportunidades.isEmpty)
                const TarjetaBase(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Text(
                        'Aún no hay oportunidades. Use el botón de arriba.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                )
              else
                ..._oportunidades.map(
                  (OportunidadRegistro o) => Stack(
                    children: <Widget>[
                      TarjetaOportunidad(
                        numero: o.numero,
                        momento: o.momento,
                        accion: o.accion,
                        observacion: o.observacion,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          tooltip: 'Quitar',
                          iconSize: 18,
                          onPressed: () => _quitar(o.numero),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardar,
                  icon: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _guardando
                        ? 'Guardando en SQLite…'
                        : 'Guardar auditoría en el dispositivo',
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _Resumen extends StatelessWidget {
  const _Resumen({
    required this.cumplidas,
    required this.total,
    required this.porcentaje,
  });

  final int cumplidas;
  final int total;
  final int porcentaje;

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Cumplimiento de la observación',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '$cumplidas de $total oportunidades cumplidas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$porcentaje%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
