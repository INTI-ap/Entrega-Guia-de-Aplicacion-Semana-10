import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:manos_seguras/screens/pantalla_indicadores.dart';
import 'package:manos_seguras/services/higiene_api_service.dart';

/// Prueba de widget de la pantalla que consume el API (Sesión 16).
///
/// Gracias a que `PantallaIndicadores` acepta un servicio inyectado, la
/// prueba no depende de Internet y es 100 % reproducible.
void main() {
  const String respuestaSimulada =
      '{"value":['
      '{"IndicatorCode":"WSH_HYGIENE_BASIC","SpatialDim":"PER","TimeDim":2023,'
      '"Dim1":"RESIDENCEAREATYPE_RUR","NumericValue":69.97,"Value":"70"},'
      '{"IndicatorCode":"WSH_HYGIENE_BASIC","SpatialDim":"PER","TimeDim":2024,'
      '"Dim1":"RESIDENCEAREATYPE_RUR","NumericValue":72.27,"Value":"72"}'
      ']}';

  testWidgets('muestra el estado de carga y luego la lista de datos', (
    WidgetTester tester,
  ) async {
    final HigieneApiService servicioFalso = HigieneApiService(
      cliente: MockClient(
        (_) async => http.Response(
          respuestaSimulada,
          200,
          headers: <String, String>{
            'content-type': 'application/json; charset=utf-8',
          },
        ),
      ),
    );

    await tester.pumpWidget(
      MaterialApp(home: PantallaIndicadores(servicio: servicioFalso)),
    );

    // Primer fotograma: todavía no llegó la respuesta.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Se deja completar el Future y se reconstruye la interfaz.
    await tester.pumpAndSettle();

    // La lista renderizada muestra los dos años recibidos.
    expect(find.text('2023'), findsOneWidget);
    expect(find.text('2024'), findsOneWidget);
    expect(find.text('72.3 %'), findsWidgets);
  });

  testWidgets('muestra el estado de error cuando el servicio falla', (
    WidgetTester tester,
  ) async {
    final HigieneApiService servicioFalso = HigieneApiService(
      cliente: MockClient((_) async => http.Response('no disponible', 500)),
    );

    await tester.pumpWidget(
      MaterialApp(home: PantallaIndicadores(servicio: servicioFalso)),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron obtener los datos'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });
}
