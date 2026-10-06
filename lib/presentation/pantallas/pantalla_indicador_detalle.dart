import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entidades/indicador_higiene.dart';
import '../../domain/repositorios/indicador_repository.dart';
import '../di.dart';
import '../widgets/app_layout.dart';
import '../widgets/estados_vista.dart';

/// Detalle de un año concreto del indicador. El año llega como parámetro de
/// ruta (`/indicadores/:anio`) y los datos se leen **de la caché local**, no
/// del servicio: el detalle no necesita red porque la serie ya se descargó.
class PantallaIndicadorDetalle extends StatefulWidget {
  const PantallaIndicadorDetalle({super.key, required this.anio});

  final int anio;

  @override
  State<PantallaIndicadorDetalle> createState() =>
      _PantallaIndicadorDetalleState();
}

class _PantallaIndicadorDetalleState extends State<PantallaIndicadorDetalle> {
  late Future<List<IndicadorHigiene>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = getIt<IndicadorRepository>().leerCache();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Año ${widget.anio}')),
      body: AppLayout(
        child: FutureBuilder<List<IndicadorHigiene>>(
          future: _futuro,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<IndicadorHigiene>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EstadoCarga(mensaje: 'Leyendo la caché local…');
            }
            if (snapshot.hasError) {
              return EstadoError(
                mensaje: '${snapshot.error}',
                alReintentar: () => setState(() {
                  _futuro = getIt<IndicadorRepository>().leerCache();
                }),
              );
            }

            final List<IndicadorHigiene> todos =
                snapshot.data ?? const <IndicadorHigiene>[];
            final List<IndicadorHigiene> delAnio = todos
                .where((IndicadorHigiene i) => i.anio == widget.anio)
                .toList();

            if (delAnio.isEmpty) {
              return EstadoVacio(
                mensaje: 'No hay datos guardados para el año ${widget.anio}.\n'
                    'Vuelva a la lista y fuerce una descarga.',
                icono: Icons.event_busy_outlined,
                accionEtiqueta: 'Volver a la serie',
                alAccionar: () => context.go('/indicadores'),
              );
            }

            return ListView(
              children: <Widget>[
                ...delAnio.map(
                  (IndicadorHigiene i) => TarjetaBase(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '${i.anio} · ${i.ambito}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.navy,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          i.valorTexto,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: i.fraccion,
                            minHeight: 12,
                            backgroundColor: AppColors.background,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.cyan,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Clave en la caché: ${i.clave}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          'Código del indicador: ${i.codigoIndicador}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () => context.go('/indicadores'),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Volver a la serie'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
