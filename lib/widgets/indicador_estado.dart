import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Avatar circular con un indicador de estado superpuesto en la
/// esquina inferior derecha, construido con Stack y Positioned
/// (Guía de Práctica N.° 4, Sesión 8).
///
/// Se usa tanto para mostrar el estado de cumplimiento de una
/// oportunidad de observación (verde = cumplió, rojo = omisión)
/// como para representar el avatar del personal observado.
class IndicadorEstado extends StatelessWidget {
  final String iniciales;
  final bool cumplio;
  final double radio;

  const IndicadorEstado({
    super.key,
    required this.iniciales,
    required this.cumplio,
    this.radio = 28,
  });

  @override
  Widget build(BuildContext context) {
    final colorEstado = cumplio ? AppColors.exito : AppColors.alerta;
    final diametroBadge = radio * 0.65;

    return SizedBox(
      width: radio * 2 + 6,
      height: radio * 2 + 6,
      child: Stack(
        // clipBehavior en none: el badge sobresale ligeramente fuera
        // del círculo del avatar, como se explicó en la Sesión 8
        // (2.5. clipBehavior: qué ocurre con el contenido desbordado).
        clipBehavior: Clip.none,
        children: [
          // Widget no posicionado: ocupa la posición natural dentro
          // del Stack (esquina superior izquierda del área disponible).
          CircleAvatar(
            radius: radio,
            backgroundColor: AppColors.navy,
            child: Text(
              iniciales,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Widget posicionado con precisión mediante Positioned,
          // ubicado en la esquina inferior derecha del avatar.
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: diametroBadge,
              height: diametroBadge,
              decoration: BoxDecoration(
                color: colorEstado,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                cumplio ? Icons.check : Icons.close,
                size: diametroBadge * 0.65,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
