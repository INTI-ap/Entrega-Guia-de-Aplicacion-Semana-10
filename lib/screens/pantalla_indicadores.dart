import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/indicador_higiene.dart';
import '../services/higiene_api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_layout.dart';
import '../widgets/estados_vista.dart';
import '../widgets/tarjeta_base.dart';
import '../widgets/tarjeta_indicador.dart';

/// Pantalla nueva de la Sesión 15-16: consume el API REST público del
/// Observatorio Mundial de la Salud y **renderiza una lista de datos**
/// (temática 1.4.2), integrando el servicio asíncrono con la interfaz.
///
/// Es un `StatefulWidget` (Sesión 12) porque mantiene tres cosas que
/// cambian durante su vida útil: el `Future` en curso, el resultado que
/// muestra el `FutureBuilder` y el estado de la recarga.
class PantallaIndicadores extends StatefulWidget {
  /// Servicio opcional, para inyectar un doble de prueba en los tests
  /// (`test/indicador_higiene_test.dart`). En producción se omite y la
  /// pantalla construye su propio servicio.
  final HigieneApiService? servicio;

  const PantallaIndicadores({super.key, this.servicio});

  @override
  State<PantallaIndicadores> createState() => _PantallaIndicadoresState();
}

class _PantallaIndicadoresState extends State<PantallaIndicadores> {
  bool _soloDesde2015 = false;
  // El servicio se crea UNA sola vez, en el estado (Sesión 12), no en
  // build(): crearlo en build() abriría una conexión nueva en cada
  // reconstrucción.
  late final HigieneApiService _servicio =
      widget.servicio ?? HigieneApiService();

  // El Future también se guarda como campo de estado. Si se construyera
  // dentro de build(), cada setState() dispararía una petición HTTP nueva.
  late Future<List<IndicadorHigiene>> _futuroIndicadores;

  @override
  void initState() {
    super.initState();
    // initState() es el lugar correcto para lanzar la primera carga.
    _futuroIndicadores = _servicio.obtenerIndicadoresPeru();
  }

  @override
  void dispose() {
    // Liberar el cliente HTTP evita fugas de recursos (igual que con
    // TextEditingController en la Sesión 14).
    _servicio.cerrar();
    super.dispose();
  }

  /// Reintenta la consulta. Se usa tanto desde el botón "Reintentar" del
  /// estado de error como desde el gesto de "deslizar para actualizar".
  Future<void> _recargar() async {
    final Future<List<IndicadorHigiene>> nuevaConsulta = _servicio
        .obtenerIndicadoresPeru();

    setState(() {
      _futuroIndicadores = nuevaConsulta;
    });

    try {
      await nuevaConsulta;
    } on ApiException catch (error) {
      // Después de un await el widget puede haber sido retirado del
      // árbol: sin esta verificación, usar `context` lanzaría una
      // excepción ("Looking up a deactivated widget's ancestor").
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.mensaje)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contexto nacional'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: AppLayout(
        child: FutureBuilder<List<IndicadorHigiene>>(
          // El Future ya fue creado en initState(); build() solo lo observa.
          future: _futuroIndicadores,
          builder:
              (
                BuildContext context,
                AsyncSnapshot<List<IndicadorHigiene>> snapshot,
              ) {
                // 1) Todavía no llega la respuesta.
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const EstadoCarga();
                }

                // 2) La promesa se completó con error.
                if (snapshot.hasError) {
                  return EstadoError(
                    mensaje: '${snapshot.error}',
                    alReintentar: _recargar,
                  );
                }

                // 3) La promesa se completó con datos.
                final List<IndicadorHigiene> indicadores =
                    snapshot.data ?? const <IndicadorHigiene>[];

                if (indicadores.isEmpty) {
                  return const EstadoVacio();
                }

                final List<IndicadorHigiene> visibles = _soloDesde2015
                    ? indicadores.where((i) => i.anio >= 2015).toList()
                    : indicadores;

                return RefreshIndicator(
                  onRefresh: _recargar,
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: <Widget>[
                      _CabeceraIndicador(total: indicadores.length),
                      const SizedBox(height: 12),
                      _ResumenTendencia(indicadores: indicadores),
                      const SizedBox(height: 16),
                      const Text(
                        'Serie histórica por año',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Solo desde 2015'),
                        value: _soloDesde2015,
                        onChanged: (valor) =>
                            setState(() => _soloDesde2015 = valor),
                      ),
                      const SizedBox(height: 12),
                      // ListView.builder dentro de un ListView: se desactiva
                      // su propio scroll con shrinkWrap + NeverScrollableScrollPhysics.
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: visibles.length,
                        itemBuilder: (BuildContext context, int indice) {
                          final IndicadorHigiene indicador = visibles[indice];
                          return TarjetaIndicador(
                            indicador: indicador,
                            // Navegación al detalle por RUTA CON PARÁMETRO.
                            // `extra` transporta el objeto ya descargado para
                            // no repetir la petición HTTP.
                            alTocar: () => context.push(
                              '/indicadores/${indicador.anio}',
                              extra: indicador,
                            ),
                          );
                        },
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

class _CabeceraIndicador extends StatelessWidget {
  final int total;

  const _CabeceraIndicador({required this.total});

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: const <Widget>[
              Icon(Icons.public, color: AppColors.navy),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Indicador OMS · Perú',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            IndicadorHigiene.descripcion,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$total registros recibidos desde ghoapi.azureedge.net',
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

/// Bloque que resume la serie: primer año, último año y variación.
/// Aplica `first`, `last` y `fold` sobre la lista (Sesiones 2 y 3).
class _ResumenTendencia extends StatelessWidget {
  final List<IndicadorHigiene> indicadores;

  const _ResumenTendencia({required this.indicadores});

  @override
  Widget build(BuildContext context) {
    final IndicadorHigiene primero = indicadores.first;
    final IndicadorHigiene ultimo = indicadores.last;

    final List<IndicadorHigiene> conValor = indicadores
        .where((IndicadorHigiene i) => i.tieneValor)
        .toList();

    final double promedio = conValor.isEmpty
        ? 0
        : conValor.fold<double>(
                0,
                (double suma, IndicadorHigiene i) => suma + i.valor!,
              ) /
              conValor.length;

    final double? variacion = (primero.tieneValor && ultimo.tieneValor)
        ? ultimo.valor! - primero.valor!
        : null;

    return TarjetaBase(
      child: Row(
        children: <Widget>[
          Expanded(
            child: _DatoResumen(
              etiqueta: 'Promedio',
              valor: '${promedio.toStringAsFixed(1)} %',
            ),
          ),
          Expanded(
            child: _DatoResumen(
              etiqueta: 'Último año (${ultimo.anio})',
              valor: ultimo.valorTexto,
            ),
          ),
          Expanded(
            child: _DatoResumen(
              etiqueta: 'Variación ${primero.anio}–${ultimo.anio}',
              valor: variacion == null
                  ? 'N/D'
                  : '${variacion >= 0 ? '+' : ''}${variacion.toStringAsFixed(1)} pp',
              color: (variacion ?? 0) >= 0 ? AppColors.exito : AppColors.alerta,
            ),
          ),
        ],
      ),
    );
  }
}

class _DatoResumen extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color? color;

  const _DatoResumen({required this.etiqueta, required this.valor, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text(
          valor,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          etiqueta,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
