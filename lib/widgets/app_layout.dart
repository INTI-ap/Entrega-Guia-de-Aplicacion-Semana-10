import 'package:flutter/material.dart';

/// Panel de layout responsivo compartido por todas las pantallas de
/// ManosSeguras, construido en la Guía de Práctica N.° 4 aplicando
/// LayoutBuilder y MediaQuery (Sesión 9) para adaptar el ancho de
/// contenido entre teléfono y tablet (Sesión 10).
///
/// En anchos de tipo tablet (>= 700 lógicos), el contenido se centra
/// y se limita a un ancho máximo legible, evitando que las tarjetas
/// se estiren de borde a borde de la pantalla, como sí ocurre en
/// mobile.
class AppLayout extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Ancho lógico a partir del cual se considera "tablet". El mismo
  /// umbral usado en la Sesión 10 para el resto de pantallas.
  static const double anchoTablet = 700;

  /// Ancho máximo del contenido cuando se detecta un layout de tipo
  /// tablet, para no perder legibilidad en pantallas muy anchas.
  static const double anchoMaximoContenido = 640;

  const AppLayout({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final esTablet = constraints.maxWidth >= anchoTablet;

        if (!esTablet) {
          // Mobile: el contenido ocupa todo el ancho disponible.
          return Padding(padding: padding, child: child);
        }

        // Tablet: se centra el contenido y se limita su ancho máximo,
        // usando MediaQuery para confirmar el ancho total de pantalla
        // (útil, por ejemplo, si se quisiera además distinguir
        // orientación en una futura iteración).
        final anchoPantalla = MediaQuery.of(context).size.width;
        final anchoEfectivo = anchoPantalla < anchoMaximoContenido
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
