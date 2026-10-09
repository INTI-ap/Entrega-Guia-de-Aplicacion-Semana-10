import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/fallos.dart';
import '../../core/id.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entidades/auditoria.dart';
import '../../domain/repositorios/auditoria_repository.dart';
import '../di.dart';
import '../widgets/app_layout.dart';
import '../widgets/estados_vista.dart';
import '../widgets/tarjetas.dart';
import 'pantalla_editar_auditoria.dart';

/// Listado **local** de auditorías guardadas en el dispositivo.
///
/// Usa `StreamBuilder` sobre `AuditoriaRepository.observarAuditorias()`: cada
/// vez que la tabla `auditorias` cambia, drift emite la lista nueva y la
/// interfaz se reconstruye sola. Es la antesala de la gestión de estado
/// reactiva con Riverpod de la Semana 12.
class PantallaAuditorias extends StatelessWidget {
  const PantallaAuditorias({super.key, this.papelera = false});

  final bool papelera;

  @override
  Widget build(BuildContext context) {
    final AuditoriaRepository repositorio = getIt<AuditoriaRepository>();

    return Scaffold(
      appBar: AppBar(
        title: Text(papelera ? 'Papelera' : 'Auditorías guardadas'),
        actions: <Widget>[
          IconButton(
            tooltip: papelera ? 'Auditorías activas' : 'Papelera',
            onPressed: () => context.go(papelera ? '/auditorias' : '/papelera'),
            icon: Icon(papelera ? Icons.folder_open : Icons.delete_outline),
          ),
          IconButton(
            tooltip: 'Recargar',
            onPressed: () => context.go(papelera ? '/papelera' : '/auditorias'),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: StreamBuilder<List<Auditoria>>(
        stream: repositorio.observarAuditorias(incluirEliminadas: papelera),
        builder:
            (BuildContext context, AsyncSnapshot<List<Auditoria>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const EstadoCarga(mensaje: 'Leyendo la base local…');
              }

              if (snapshot.hasError) {
                return EstadoError(
                  mensaje: '${snapshot.error}',
                  alReintentar: () =>
                      context.go(papelera ? '/papelera' : '/auditorias'),
                );
              }

              final List<Auditoria> auditorias =
                  (snapshot.data ?? const <Auditoria>[])
                      .where((a) => papelera ? a.eliminada : !a.eliminada)
                      .toList();

              if (auditorias.isEmpty) {
                return EstadoVacio(
                  mensaje: papelera
                      ? 'La papelera está vacía.'
                      : 'Todavía no hay auditorías en el dispositivo.\n'
                            'Capture una desde "Comenzar auditoría".',
                  icono: Icons.folder_off_outlined,
                  accionEtiqueta: papelera
                      ? 'Volver a auditorías'
                      : 'Capturar auditoría',
                  alAccionar: () =>
                      context.go(papelera ? '/auditorias' : '/oportunidades'),
                );
              }

              final int totalOportunidades = auditorias.fold<int>(
                0,
                (int s, Auditoria a) => s + a.totalOportunidades,
              );
              final int totalCumplidas = auditorias.fold<int>(
                0,
                (int s, Auditoria a) => s + a.oportunidadesCumplidas,
              );
              final double global = totalOportunidades == 0
                  ? 0
                  : (totalCumplidas / totalOportunidades) * 100;

              return RefreshIndicator(
                onRefresh: () async =>
                    context.go(papelera ? '/papelera' : '/auditorias'),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: <Widget>[
                    TarjetaBase(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Resumen local',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: <Widget>[
                              _Metrica(
                                etiqueta: 'Auditorías',
                                valor: '${auditorias.length}',
                              ),
                              _Metrica(
                                etiqueta: 'Oportunidades',
                                valor: '$totalOportunidades',
                              ),
                              _Metrica(
                                etiqueta: 'Adherencia',
                                valor: formatearPorcentaje(global),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const TituloSeccion(
                      'Detalle por auditoría',
                      icono: Icons.list_alt,
                    ),
                    ...auditorias.map(
                      (Auditoria a) => TarjetaAuditoria(
                        auditoria: a,
                        alTocar: () => context.push('/auditorias/${a.id}'),
                        alEditar: papelera ? null : () => _editar(context, a),
                        alAnular: papelera
                            ? null
                            : () => _confirmarAnulacion(context, a),
                        alRestaurar: papelera
                            ? () => _accion(
                                context,
                                () => repositorio.restaurar(a.id),
                                'Auditoría restaurada.',
                              )
                            : null,
                        alDuplicar: papelera
                            ? null
                            : () => _accion(context, () async {
                                await repositorio.duplicar(a.id);
                              }, 'Auditoría duplicada como borrador.'),
                      ),
                    ),
                  ],
                ),
              );
            },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/oportunidades'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva auditoría'),
      ),
    );
  }

  Future<void> _editar(BuildContext context, Auditoria auditoria) async {
    final guardada = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PantallaEditarAuditoria(auditoria: auditoria),
      ),
    );
    if (!context.mounted || guardada != true) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cambios guardados.')));
  }

  Future<void> _accion(
    BuildContext context,
    Future<void> Function() accion,
    String mensaje,
  ) async {
    try {
      await accion();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(mensaje)));
    } on Fallo catch (fallo) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(fallo.mensaje)));
    }
  }

  /// **Reto 3:** el borrado lógico se confirma con el usuario y luego se
  /// ejecuta sobre el repositorio. Observe que nunca se llama a `delete`
  /// directo sobre la base: todo pasa por el contrato del dominio.
  Future<void> _confirmarAnulacion(
    BuildContext context,
    Auditoria auditoria,
  ) async {
    final bool? confirmado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Anular auditoría'),
        content: Text(
          'La auditoría del ${formatearFecha(auditoria.fecha)} quedará '
          'marcada como anulada. El registro NO se elimina de la base '
          '(borrado lógico) para conservar la trazabilidad de la norma.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Anular'),
          ),
        ],
      ),
    );

    if (confirmado != true) return;

    try {
      await getIt<AuditoriaRepository>().eliminarLogicamente(auditoria.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Auditoría anulada.')));
    } on Fallo catch (fallo) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallo.mensaje),
          backgroundColor: AppColors.alerta,
        ),
      );
    }
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            valor,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            etiqueta,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
