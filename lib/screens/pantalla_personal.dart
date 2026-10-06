import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/personal.dart';
import '../theme/app_theme.dart';
import '../widgets/app_layout.dart';
import '../widgets/tarjeta_base.dart';

/// Pantalla de registro del personal involucrado en la observación:
/// el observador (quien audita) y el personal observado (quien es
/// auditado), construida en la Guía de Práctica N.° 3 (Sesiones 4-7)
/// sobre los campos DNI_OBSERVADOR, NOMBRES_APELLIDOS_OBSERVADOR,
/// DNI_OBSERVADO, NOMBRES_APELLIDOS_OBSERVADO y CATEGORIA_PROFESIONAL
/// del formulario oficial.
class PantallaPersonal extends StatelessWidget {
  const PantallaPersonal({super.key});

  @override
  Widget build(BuildContext context) {
    final observador = Observador.ejemplo();
    final observado = Observado.ejemplo();

    return Scaffold(
      appBar: AppBar(title: const Text('Personal')),
      body: SingleChildScrollView(
        child: AppLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TarjetaPersona(
                titulo: 'Observador',
                subtitulo: 'Realiza el registro de la observación',
                icono: Icons.visibility,
                persona: observador,
                detalle: null,
              ),
              const SizedBox(height: 16),
              _TarjetaPersona(
                titulo: 'Personal observado',
                subtitulo: 'Trabajador de salud evaluado',
                icono: Icons.medical_services_outlined,
                persona: observado,
                detalle: observado.categoriaProfesional,
              ),
              const SizedBox(height: 24),
              _BotonContinuar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TarjetaPersona extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Personal persona;
  final String? detalle;

  const _TarjetaPersona({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.persona,
    required this.detalle,
  });

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icono, color: AppColors.navy, size: 20),
              const SizedBox(width: 8),
              Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 28, top: 2, bottom: 12),
            child: Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.navy,
                child: Text(
                  persona.iniciales,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      persona.nombresApellidos,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'DNI: ${persona.dni}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (detalle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        detalle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotonContinuar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        // Navegación declarativa: se nombra el destino, no se construye
        // la pantalla desde aquí.
        onPressed: () => context.go('/oportunidades'),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Registrar oportunidades'),
      ),
    );
  }
}
