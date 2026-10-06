import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Panel de layout responsivo compartido por todas las pantallas, construido
/// en la Guía N.° 04 con `LayoutBuilder` y `MediaQuery` (Sesiones 9-10) y
/// conservado sin cambios en la Semana 10.
class AppLayout extends StatelessWidget {
  const AppLayout({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Ancho lógico a partir del cual se considera "tablet".
  static const double anchoTablet = 700;

  /// Ancho máximo del contenido en pantallas anchas.
  static const double anchoMaximoContenido = 640;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool esTablet = constraints.maxWidth >= anchoTablet;

        if (!esTablet) {
          return Padding(padding: padding, child: child);
        }

        final double anchoPantalla = MediaQuery.of(context).size.width;
        final double anchoEfectivo = anchoPantalla < anchoMaximoContenido
            ? anchoPantalla
            : anchoMaximoContenido;

        return Center(
          child: SizedBox(
            width: anchoEfectivo,
            child: Padding(padding: padding, child: child),
          ),
        );
      },
    );
  }
}

/// Tarjeta base con estilo institucional (Sesión 4-5: `Container`, padding,
/// margin), reutilizada por todas las pantallas del proyecto.
class TarjetaBase extends StatelessWidget {
  const TarjetaBase({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Título de sección con el color institucional, para no repetir el mismo
/// `TextStyle` en cada pantalla.
class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.texto, {super.key, this.icono});

  final String texto;
  final IconData? icono;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          if (icono != null) ...<Widget>[
            Icon(icono, color: AppColors.navy, size: 20),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
