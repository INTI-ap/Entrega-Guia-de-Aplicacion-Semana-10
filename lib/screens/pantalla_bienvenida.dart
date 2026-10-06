import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/oportunidad.dart';
import '../theme/app_theme.dart';
import '../widgets/app_layout.dart';
import '../widgets/tarjeta_base.dart';

/// Pantalla de bienvenida de ManosSeguras, construida en la Guía de
/// Práctica N.° 2 (Sesiones 4-5) aplicando los widgets básicos
/// (Text, Container, Icon) y las técnicas de espaciado (padding,
/// margin) y anidamiento de widgets.
///
/// Incluye la tarjeta "Los 5 Momentos", que presenta el catálogo
/// oficial de la OMS/MINSA como introducción antes de auditar
/// cualquier establecimiento.
class PantallaBienvenida extends StatelessWidget {
  const PantallaBienvenida({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ManosSeguras')),
      body: SingleChildScrollView(
        child: AppLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Encabezado(),
              const SizedBox(height: 24),
              _TarjetaCincoMomentos(),
              const SizedBox(height: 24),
              _BotonComenzar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.clean_hands, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            'ManosSeguras',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Auditoría digital de higiene de manos, alineada a la '
            'RM N.° 255-2016/MINSA y al ODS 3 (Salud y bienestar).',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _TarjetaCincoMomentos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.checklist_rtl, color: AppColors.navy),
              SizedBox(width: 8),
              Text(
                'Los 5 Momentos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Instrumento oficial de la OMS para la higiene de manos '
            'en establecimientos de salud.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...Momento.values.map(
            (m) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.cyan,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${m.index + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m.etiqueta,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonComenzar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        // Antes (Sesiones 4-11): Navigator.of(context).push(MaterialPageRoute(...)).
        // Ahora (Sesión 15): navegación declarativa por ruta con nombre.
        onPressed: () => context.go('/establecimiento'),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Comenzar auditoría'),
      ),
    );
  }
}
