import 'package:flutter/material.dart';
import '../models/oportunidad.dart';
import '../theme/app_theme.dart';

/// Nube de etiquetas de los 5 Momentos de higiene de manos, construida
/// con Wrap (Guía de Práctica N.° 4, Sesión 8) para que las etiquetas
/// fluyan y salten de línea automáticamente sin importar cuántos
/// momentos se muestren ni el ancho disponible.
class EtiquetasMomentos extends StatelessWidget {
  final List<Momento> momentos;

  const EtiquetasMomentos({super.key, required this.momentos});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: momentos.map((m) => _EtiquetaMomento(momento: m)).toList(),
    );
  }
}

class _EtiquetaMomento extends StatelessWidget {
  final Momento momento;

  const _EtiquetaMomento({required this.momento});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.25)),
      ),
      child: Text(
        momento.etiqueta,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.navy,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
