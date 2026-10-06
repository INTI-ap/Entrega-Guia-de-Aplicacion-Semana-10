import 'package:flutter/material.dart';

import '../models/indicador_higiene.dart';
import '../theme/app_theme.dart';
import 'tarjeta_base.dart';

/// Tarjeta reutilizable que resume un registro anual del indicador de
/// higiene de la OMS.
///
/// Reutiliza [TarjetaBase] (Sesión 4-5: Container, padding, margin),
/// Row + Expanded (Sesión 7) y una barra de progreso que representa
/// visualmente el porcentaje reportado.
class TarjetaIndicador extends StatelessWidget {
  final IndicadorHigiene indicador;
  final VoidCallback? alTocar;

  const TarjetaIndicador({super.key, required this.indicador, this.alTocar});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // InkWell aporta el efecto visual de toque dentro del Material
      // (Sesión 13). El padre decide qué hacer: navegar al detalle.
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
                const SizedBox(width: 10),
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: indicador.tieneValor
                        ? AppColors.navy
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: indicador.fraccion,
                minHeight: 8,
                backgroundColor: AppColors.navy.withValues(alpha: 0.08),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Ver detalle del año ${indicador.anio}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
