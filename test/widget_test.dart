import 'package:flutter_test/flutter_test.dart';

import 'package:manos_seguras/main.dart';

void main() {
  testWidgets('La app arranca en PantallaBienvenida y muestra el título', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ManosSegurasApp());

    expect(find.text('ManosSeguras'), findsWidgets);
    expect(find.text('Los 5 Momentos'), findsOneWidget);
    expect(find.text('Comenzar auditoría'), findsOneWidget);
  });

  testWidgets('Navega de Bienvenida a Establecimiento al presionar el botón', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ManosSegurasApp());

    await tester.ensureVisible(find.text('Comenzar auditoría'));
    await tester.tap(find.text('Comenzar auditoría'));
    await tester.pumpAndSettle();

    expect(find.text('Hospital Regional del Cusco'), findsOneWidget);
  });
}
