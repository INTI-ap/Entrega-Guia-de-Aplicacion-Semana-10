import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/entidades/establecimiento.dart';
import '../widgets/app_layout.dart';

/// Pantalla del establecimiento auditado. Los datos provienen de la entidad
/// de dominio [Establecimiento]; en el Reto 1 se propone que el catálogo se
/// lea de la tabla `establecimientos` en lugar de usar el ejemplo.
class PantallaEstablecimiento extends StatelessWidget {
  const PantallaEstablecimiento({super.key});

  @override
  Widget build(BuildContext context) {
    final Establecimiento establecimiento = Establecimiento.ejemplo();

    return Scaffold(
      appBar: AppBar(title: const Text('Establecimiento')),
      body: SingleChildScrollView(
        child: AppLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TarjetaBase(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Datos del establecimiento',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FilaDato('Código único', establecimiento.codigoUnico),
                    _FilaDato('Nombre', establecimiento.nombre),
                    _FilaDato('Categoría', establecimiento.categoria.etiqueta),
                    _FilaDato('Red', establecimiento.red),
                    _FilaDato('Microred', establecimiento.microred),
                    _FilaDato('Ubicación', establecimiento.ubicacionPolitica),
                    _FilaDato(
                      'Geolocalización',
                      establecimiento.tieneGeolocalizacion
                          ? '${establecimiento.latitud}, '
                              '${establecimiento.longitud}'
                          : 'No registrada',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/oportunidades'),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Continuar a la observación'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilaDato extends StatelessWidget {
  const _FilaDato(this.etiqueta, this.valor);

  final String etiqueta;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 130,
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
                fontSize: 13,
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
