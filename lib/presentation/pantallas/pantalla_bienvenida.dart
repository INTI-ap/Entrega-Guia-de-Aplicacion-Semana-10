import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../widgets/app_layout.dart';
import '../widgets/tarjetas.dart';

/// Pantalla de bienvenida: presenta el proyecto, los 5 Momentos y el acceso a
/// los dos recorridos de la Semana 10 (auditorías locales y contexto del API).
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
            children: <Widget>[
              const _Encabezado(),
              const SizedBox(height: 20),
              const TarjetaMomentos(),
              const SizedBox(height: 4),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/establecimiento'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Comenzar auditoría'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/auditorias'),
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Auditorías guardadas en el dispositivo'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/diagnostico'),
                  icon: const Icon(Icons.storage_outlined),
                  label: const Text('Diagnóstico de la base local'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado();

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
        children: <Widget>[
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
            'Auditoría digital de higiene de manos con persistencia local '
            '(offline-first). Semana 10: los registros ya no se pierden al '
            'cerrar la aplicación.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'drift + SQLite · Clean Architecture · get_it',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
