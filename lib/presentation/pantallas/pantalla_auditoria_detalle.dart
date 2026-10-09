import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/fallos.dart';
import '../../core/id.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entidades/auditoria.dart';
import '../../domain/entidades/oportunidad_registro.dart';
import '../../domain/repositorios/auditoria_repository.dart';
import '../di.dart';
import '../widgets/app_layout.dart';
import '../widgets/estados_vista.dart';
import '../widgets/tarjetas.dart';

/// Detalle de una auditoría guardada, cargada **desde la base local** por su
/// identificador (parámetro de ruta `:id`).
///
/// Es la prueba visible de que la persistencia funciona: la auditoría que se
/// capturó en `PantallaOportunidades` sigue aquí después de cerrar y volver a
/// abrir la aplicación.
class PantallaAuditoriaDetalle extends StatefulWidget {
  const PantallaAuditoriaDetalle({super.key, required this.auditoriaId});

  final String auditoriaId;

  @override
  State<PantallaAuditoriaDetalle> createState() =>
      _PantallaAuditoriaDetalleState();
}

class _PantallaAuditoriaDetalleState extends State<PantallaAuditoriaDetalle> {
  late Future<Auditoria> _futuro;

  @override
  void initState() {
    super.initState();
    // El Future se crea UNA sola vez, en initState (lección de la Sesión 16).
    _futuro = getIt<AuditoriaRepository>().obtenerPorId(widget.auditoriaId);
  }

  void _recargar() {
    setState(() {
      _futuro = getIt<AuditoriaRepository>().obtenerPorId(widget.auditoriaId);
    });
  }

  /// **Reto 3 (parte B):** cambiar el estado de la auditoría.
  ///
  /// TODO(reto-3): implemente el cambio de estado (`borrador` → `finalizada`)
  /// usando `AuditoriaRepository.actualizar(...)`. Observe que el repositorio
  /// reemplaza el detalle completo, así que debe enviar la auditoría con sus
  /// oportunidades tal como se cargó.
  Future<void> _avanzarEstado(Auditoria auditoria) async {
    final EstadoAuditoria siguiente = switch (auditoria.estado) {
      EstadoAuditoria.borrador => EstadoAuditoria.finalizada,
      EstadoAuditoria.finalizada => EstadoAuditoria.sincronizada,
      EstadoAuditoria.sincronizada => EstadoAuditoria.sincronizada,
    };

    try {
      await getIt<AuditoriaRepository>().actualizar(
        auditoria.copyWith(estado: siguiente),
      );
      if (!mounted) return;
      _recargar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado: ${siguiente.etiqueta}')),
      );
    } on Fallo catch (fallo) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(fallo.mensaje),
          backgroundColor: AppColors.alerta,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la auditoría'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Recargar',
            onPressed: _recargar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Auditoria>(
        future: _futuro,
        builder: (BuildContext context, AsyncSnapshot<Auditoria> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const EstadoCarga(mensaje: 'Leyendo la auditoría…');
          }

          if (snapshot.hasError) {
            return EstadoError(
              mensaje: '${snapshot.error}',
              alReintentar: _recargar,
            );
          }

          final Auditoria? auditoria = snapshot.data;
          if (auditoria == null) {
            return const EstadoVacio(mensaje: 'La auditoría no existe.');
          }

          return SingleChildScrollView(
            child: AppLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _Cabecera(auditoria: auditoria),
                  if (auditoria.observacionGeneral?.isNotEmpty ?? false)
                    TarjetaBase(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Observación general',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(auditoria.observacionGeneral!),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  TituloSeccion(
                    'Oportunidades (${auditoria.totalOportunidades})',
                    icono: Icons.list_alt,
                  ),
                  if (auditoria.oportunidades.isEmpty)
                    const TarjetaBase(
                      child: Text(
                        'Esta auditoría no tiene oportunidades registradas.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ...auditoria.oportunidades.map(
                      (OportunidadRegistro o) => TarjetaOportunidad(
                        numero: o.numero,
                        momento: o.momento,
                        accion: o.accion,
                        observacion: o.observacion,
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _avanzarEstado(auditoria),
                      icon: const Icon(Icons.sync),
                      label: Text(
                        'Cambiar estado (actual: '
                        '${auditoria.estado.etiqueta})',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/auditorias'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Volver al listado'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.auditoria});

  final Auditoria auditoria;

  @override
  Widget build(BuildContext context) {
    final double adherencia = auditoria.porcentajeAdherencia;

    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  auditoria.establecimientoNombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              InsigniaOrigen(
                etiqueta: auditoria.estado.etiqueta,
                esRemoto: auditoria.estado == EstadoAuditoria.sincronizada,
                icono: Icons.sync,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _Dato('Identificador (UUID)', auditoria.id),
          _Dato('Fecha', formatearFechaHora(auditoria.fecha)),
          _Dato('Observador', auditoria.observadorNombre),
          _Dato('Personal observado', auditoria.observadoNombre),
          _Dato('Establecimiento (código)', auditoria.establecimientoId),
          _Dato(
            'Sincronizada',
            auditoria.sincronizadaEn == null
                ? 'Pendiente de envío'
                : formatearFechaHora(auditoria.sincronizadaEn!),
          ),
          const Divider(height: 24),
          Row(
            children: <Widget>[
              _Indicador(
                etiqueta: 'Cumplidas',
                valor: '${auditoria.oportunidadesCumplidas}',
                color: AppColors.exito,
              ),
              _Indicador(
                etiqueta: 'Omisiones',
                valor: '${auditoria.omisiones}',
                color: AppColors.alerta,
              ),
              _Indicador(
                etiqueta: 'Adherencia',
                valor: formatearPorcentaje(
                  auditoria.tieneDatos ? adherencia : null,
                ),
                color: AppColors.navy,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dato extends StatelessWidget {
  const _Dato(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 140,
            child: Text(
              etiqueta,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.etiqueta,
    required this.valor,
    required this.color,
  });

  final String etiqueta;
  final String valor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: <Widget>[
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
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
