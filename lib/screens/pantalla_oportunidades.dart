import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/oportunidad.dart';
import '../theme/app_theme.dart';
import '../widgets/app_layout.dart';
import '../widgets/etiquetas_momentos.dart';
import '../widgets/indicador_estado.dart';
import '../widgets/tarjeta_base.dart';

/// Pantalla que lista las oportunidades de observación registradas
/// (grupos EVALUACION_OBLIGATORIO_oportunidad_01 a _05 del formulario
/// oficial), construida originalmente en la Guía de Práctica N.° 3
/// y enriquecida en la Guía N.° 4 (Sesión 8) con:
///   - un indicador de estado tipo Stack (verde/rojo) sobre cada
///     oportunidad, indicando si la acción registrada representó
///     cumplimiento o una omisión;
///   - una nube de etiquetas tipo Wrap con el resumen de los 5
///     Momentos cubiertos por el registro.
class PantallaOportunidades extends StatelessWidget {
  const PantallaOportunidades({super.key});

  @override
  Widget build(BuildContext context) {
    final oportunidades = Oportunidad.listaEjemplo();
    final cumplidas = oportunidades.where((o) => o.cumplio).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Oportunidades')),
      body: SingleChildScrollView(
        child: AppLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResumenCumplimiento(
                total: oportunidades.length,
                cumplidas: cumplidas,
              ),
              const SizedBox(height: 16),
              _TarjetaMomentosCubiertos(oportunidades: oportunidades),
              const SizedBox(height: 16),
              const Text(
                'Detalle de oportunidades',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              ...oportunidades.map((o) => _TarjetaOportunidad(oportunidad: o)),
              const SizedBox(height: 16),
              // Puente hacia el API REST público de la OMS (Sesión 16):
              // datos de contexto nacional del indicador de higiene.
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/indicadores'),
                  icon: const Icon(Icons.public),
                  label: const Text('Ver contexto nacional (API OMS)'),
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

class _ResumenCumplimiento extends StatelessWidget {
  final int total;
  final int cumplidas;
  const _ResumenCumplimiento({required this.total, required this.cumplidas});

  @override
  Widget build(BuildContext context) {
    final porcentaje = total == 0 ? 0 : ((cumplidas / total) * 100).round();

    return TarjetaBase(
      child: Row(
        children: [
          // Expanded + Flexible reparten el espacio entre el bloque de
          // texto y el porcentaje destacado (Sesión 7).
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

class _TarjetaMomentosCubiertos extends StatelessWidget {
  final List<Oportunidad> oportunidades;
  const _TarjetaMomentosCubiertos({required this.oportunidades});

  @override
  Widget build(BuildContext context) {
    final momentos = oportunidades.map((o) => o.momento).toSet().toList();

    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Momentos cubiertos',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          EtiquetasMomentos(momentos: momentos),
        ],
      ),
    );
  }
}

class _TarjetaOportunidad extends StatelessWidget {
  final Oportunidad oportunidad;
  const _TarjetaOportunidad({required this.oportunidad});

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          IndicadorEstado(
            iniciales: 'O${oportunidad.numero}',
            cumplio: oportunidad.cumplio,
            radio: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Oportunidad ${oportunidad.numero.toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  oportunidad.momento.etiqueta,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  'Acción: ${oportunidad.accion.etiqueta}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: oportunidad.cumplio
                        ? AppColors.exito
                        : AppColors.alerta,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
