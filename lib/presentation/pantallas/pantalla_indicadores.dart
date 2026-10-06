import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/id.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entidades/indicador_higiene.dart';
import '../../domain/repositorios/indicador_repository.dart';
import '../di.dart';
import '../widgets/app_layout.dart';
import '../widgets/estados_vista.dart';

/// Pantalla del indicador de la OMS **con caché local (offline-first)**.
///
/// Es la evolución directa de la pantalla de la Sesión 16. La diferencia es
/// que ahora el `Future` no va contra la red sino contra el repositorio
/// offline-first, que decide internamente entre tres fuentes y devuelve,
/// junto con los datos, su **origen**.
///
/// La interfaz muestra ese origen con [InsigniaOrigen]: es la parte visible
/// del patrón y la que el usuario necesita para confiar en lo que ve.
class PantallaIndicadores extends StatefulWidget {
  const PantallaIndicadores({super.key});

  @override
  State<PantallaIndicadores> createState() => _PantallaIndicadoresState();
}

class _PantallaIndicadoresState extends State<PantallaIndicadores> {
  final IndicadorRepository _repositorio = getIt<IndicadorRepository>();

  late Future<ResultadoIndicadores> _futuro;
  bool _forzando = false;

  @override
  void initState() {
    super.initState();
    _futuro = _repositorio.obtenerIndicadores();
  }

  Future<void> _recargar({bool forzar = false}) async {
    final Future<ResultadoIndicadores> consulta =
        _repositorio.obtenerIndicadores(forzarRefresco: forzar);
    setState(() {
      _futuro = consulta;
      _forzando = forzar;
    });

    try {
      await consulta;
    } finally {
      if (mounted) setState(() => _forzando = false);
    }
  }

  Future<void> _vaciarCache() async {
    await _repositorio.limpiarCache();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Caché local vaciada.')),
    );
    await _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contexto nacional'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Forzar descarga',
            onPressed: _forzando ? null : () => _recargar(forzar: true),
            icon: const Icon(Icons.cloud_download_outlined),
          ),
          IconButton(
            tooltip: 'Vaciar caché local',
            onPressed: _vaciarCache,
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: AppLayout(
        child: FutureBuilder<ResultadoIndicadores>(
          future: _futuro,
          builder: (
            BuildContext context,
            AsyncSnapshot<ResultadoIndicadores> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const EstadoCarga(mensaje: 'Consultando el indicador…');
            }

            if (snapshot.hasError) {
              return EstadoError(
                mensaje: '${snapshot.error}',
                alReintentar: _recargar,
              );
            }

            final ResultadoIndicadores? resultado = snapshot.data;
            if (resultado == null || resultado.estaVacio) {
              return EstadoVacio(
                mensaje: 'No hay registros del indicador en el dispositivo '
                    'ni en el servicio.',
                accionEtiqueta: 'Reintentar',
                alAccionar: _recargar,
              );
            }

            final List<IndicadorHigiene> indicadores = resultado.indicadores;

            return RefreshIndicator(
              onRefresh: () => _recargar(forzar: true),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: <Widget>[
                  _Cabecera(resultado: resultado),
                  const SizedBox(height: 16),
                  const TituloSeccion(
                    'Serie histórica por año',
                    icono: Icons.show_chart,
                  ),
                  ...indicadores.reversed.map(
                    (IndicadorHigiene i) => _TarjetaIndicador(
                      indicador: i,
                      alTocar: () => context.push(
                        '/indicadores/${i.anio}',
                        extra: i,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.resultado});

  final ResultadoIndicadores resultado;

  @override
  Widget build(BuildContext context) {
    final List<IndicadorHigiene> conValor = resultado.indicadores
        .where((IndicadorHigiene i) => i.tieneValor)
        .toList();
    final IndicadorHigiene? primero = conValor.isEmpty ? null : conValor.first;
    final IndicadorHigiene? ultimo = conValor.isEmpty ? null : conValor.last;

    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Población con instalaciones básicas de lavado de manos en el '
            'hogar (%)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Observatorio Mundial de la Salud (OMS) · Indicador '
            'WSH_HYGIENE_BASIC · Perú',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              InsigniaOrigen(
                etiqueta: resultado.origen.etiqueta,
                esRemoto: resultado.origen == OrigenDatos.red,
              ),
              const SizedBox(width: 8),
              if (resultado.actualizadoEn != null)
                Flexible(
                  child: Text(
                    'Actualizado: ${formatearFechaHora(resultado.actualizadoEn!)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          if (primero != null && ultimo != null) ...<Widget>[
            const Divider(height: 28),
            Row(
              children: <Widget>[
                Expanded(
                  child: _Dato(
                    etiqueta: '${primero.anio}',
                    valor: primero.valorTexto,
                  ),
                ),
                const Icon(Icons.arrow_forward, color: AppColors.textSecondary),
                Expanded(
                  child: _Dato(
                    etiqueta: '${ultimo.anio}',
                    valor: ultimo.valorTexto,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato({required this.etiqueta, required this.valor});

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          valor,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _TarjetaIndicador extends StatelessWidget {
  const _TarjetaIndicador({required this.indicador, this.alTocar});

  final IndicadorHigiene indicador;
  final VoidCallback? alTocar;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: alTocar,
      borderRadius: BorderRadius.circular(16),
      child: TarjetaBase(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.navy.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${indicador.anio}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    indicador.ambito,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  indicador.valorTexto,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: indicador.fraccion,
                minHeight: 8,
                backgroundColor: AppColors.background,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.cyan,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
