import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/establecimiento.dart';
import '../theme/app_theme.dart';
import '../widgets/app_layout.dart';
import '../widgets/tarjeta_base.dart';

/// Pantalla que muestra los datos del establecimiento de salud a
/// auditar, construida en la Guía de Práctica N.° 3 (Sesiones 4-7)
/// sobre los campos oficiales del formulario KoboToolbox
/// (CODIGO_UNICO, NOMBRE_ESTABLECIMIENTO, CATEGORIA_DEL_ESTABLECIMIENTO,
/// RED, MICRORED).
///
/// Aplica Row y Column para organizar la información (Sesión 7) y
/// Expanded para repartir el espacio entre etiqueta y valor en cada
/// fila de datos.
class PantallaEstablecimiento extends StatelessWidget {
  const PantallaEstablecimiento({super.key});

  @override
  Widget build(BuildContext context) {
    final establecimiento = Establecimiento.ejemplo();

    return Scaffold(
      appBar: AppBar(title: const Text('Establecimiento')),
      body: SingleChildScrollView(
        child: AppLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CabeceraEstablecimiento(establecimiento: establecimiento),
              const SizedBox(height: 16),
              _TarjetaDatosGenerales(establecimiento: establecimiento),
              const SizedBox(height: 16),
              _TarjetaUbicacion(establecimiento: establecimiento),
              const SizedBox(height: 24),
              _BotonContinuar(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CabeceraEstablecimiento extends StatelessWidget {
  final Establecimiento establecimiento;
  const _CabeceraEstablecimiento({required this.establecimiento});

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.navy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_hospital,
              color: AppColors.navy,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          // Expanded asegura que el nombre del establecimiento use
          // todo el espacio restante sin desbordar la fila (Sesión 6/7).
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  establecimiento.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Código único: ${establecimiento.codigoUnico}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
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

class _TarjetaDatosGenerales extends StatelessWidget {
  final Establecimiento establecimiento;
  const _TarjetaDatosGenerales({required this.establecimiento});

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Datos generales',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          _FilaDato(etiqueta: 'Categoría', valor: establecimiento.categoria),
          _FilaDato(etiqueta: 'Red', valor: establecimiento.red),
          _FilaDato(etiqueta: 'Microred', valor: establecimiento.microred),
        ],
      ),
    );
  }
}

class _TarjetaUbicacion extends StatelessWidget {
  final Establecimiento establecimiento;
  const _TarjetaUbicacion({required this.establecimiento});

  @override
  Widget build(BuildContext context) {
    return TarjetaBase(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.map_outlined, color: AppColors.navy, size: 20),
              SizedBox(width: 8),
              Text(
                'Ubicación',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FilaDato(
            etiqueta: 'Departamento',
            valor: establecimiento.departamento,
          ),
          _FilaDato(etiqueta: 'Provincia', valor: establecimiento.provincia),
          _FilaDato(etiqueta: 'Distrito', valor: establecimiento.distrito),
          if (establecimiento.tieneGeolocalizacion)
            _FilaDato(
              etiqueta: 'Coordenadas',
              valor:
                  '${establecimiento.latitud!.toStringAsFixed(4)}, '
                  '${establecimiento.longitud!.toStringAsFixed(4)}',
            ),
        ],
      ),
    );
  }
}

/// Fila reutilizable etiqueta/valor, usada en varias tarjetas de esta
/// pantalla. Row + Expanded evita que un valor largo desborde la fila.
class _FilaDato extends StatelessWidget {
  final String etiqueta;
  final String valor;
  const _FilaDato({required this.etiqueta, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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

class _BotonContinuar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => context.go('/personal'),
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continuar con el personal'),
      ),
    );
  }
}
