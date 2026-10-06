import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/indicador_higiene.dart';
import '../services/higiene_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_layout.dart';
import '../widgets/estados_vista.dart';
import '../widgets/tarjeta_base.dart';

/// Pantalla de detalle de un año del indicador. Se abre con la ruta
/// `/indicadores/:anio` y demuestra dos formas de recibir datos:
///
///  1. `state.extra`: el objeto [IndicadorHigiene] ya descargado por la
///     pantalla anterior (evita una segunda petición HTTP).
///  2. Consulta propia al API: cuando el usuario abre la ruta directamente
///     (deep link, recarga del navegador), `extra` llega en null y la
///     pantalla obtiene el dato por su cuenta.
class PantallaIndicadorDetalle extends StatefulWidget {
  final int anio;
  final IndicadorHigiene? indicadorInicial;

  const PantallaIndicadorDetalle({
    super.key,
    required this.anio,
    this.indicadorInicial,
  });

  @override
  State<PantallaIndicadorDetalle> createState() =>
      _PantallaIndicadorDetalleState();
}

class _PantallaIndicadorDetalleState extends State<PantallaIndicadorDetalle> {
  final HigieneApiService _servicio = HigieneApiService();
  late Future<IndicadorHigiene?> _futuroIndicador;

  @override
  void initState() {
    super.initState();
    _futuroIndicador = _obtenerIndicador();
  }

  @override
  void dispose() {
    _servicio.cerrar();
    super.dispose();
  }

  Future<IndicadorHigiene?> _obtenerIndicador() async {
    // Atajo: si la pantalla anterior ya nos entregó el objeto, no se
    // vuelve a consultar la red.
    if (widget.indicadorInicial != null) {
      return widget.indicadorInicial;
    }

    final List<IndicadorHigiene> indicadores = await _servicio
        .obtenerIndicadoresPeru();

    for (final IndicadorHigiene indicador in indicadores) {
      if (indicador.anio == widget.anio) {
        return indicador;
      }
    }
    return null; // El año solicitado no existe en la serie.
  }

  void _reintentar() {
    setState(() {
      _futuroIndicador = _obtenerIndicador();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Año ${widget.anio}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: AppLayout(
        child: FutureBuilder<IndicadorHigiene?>(
          future: _futuroIndicador,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<IndicadorHigiene?> snapshot,
              ) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const EstadoCarga(
                    mensaje: 'Cargando el año solicitado…',
                  );
                }
                if (snapshot.hasError) {
                  return EstadoError(
                    mensaje: '${snapshot.error}',
                    alReintentar: _reintentar,
                  );
                }

                final IndicadorHigiene? indicador = snapshot.data;
                if (indicador == null) {
                  return EstadoVacio(
                    mensaje:
                        'El año ${widget.anio} no figura en la serie '
                        'histórica del indicador.',
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _TarjetaValor(indicador: indicador),
                      const SizedBox(height: 16),
                      _TarjetaFicha(indicador: indicador),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Volver a la lista'),
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

class _TarjetaValor extends StatelessWidget {
  final IndicadorHigiene indicador;

  const _TarjetaValor({required this.indicador});

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Column(
        children: <Widget>[
          Text(
            '${indicador.anio}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.navy,
            ),
          ),
          Text(
            indicador.ambito,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          Text(
            indicador.valorTexto,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: indicador.fraccion,
              minHeight: 12,
              backgroundColor: AppColors.navy.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaFicha extends StatelessWidget {
  final IndicadorHigiene indicador;

  const _TarjetaFicha({required this.indicador});

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Ficha del registro',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          _Fila(etiqueta: 'Indicador', valor: indicador.codigoIndicador),
          _Fila(etiqueta: 'País', valor: indicador.pais),
          _Fila(etiqueta: 'Año', valor: '${indicador.anio}'),
          _Fila(etiqueta: 'Ámbito', valor: indicador.ambito),
          _Fila(
            etiqueta: 'Valor exacto',
            valor: indicador.valor?.toString() ?? 'sin dato',
          ),
          const Divider(height: 24),
          Text(
            IndicadorHigiene.descripcion,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Fila extends StatelessWidget {
  final String etiqueta;
  final String valor;

  const _Fila({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 110,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
