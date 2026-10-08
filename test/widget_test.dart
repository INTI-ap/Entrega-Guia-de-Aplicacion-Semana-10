import 'package:flutter_test/flutter_test.dart';

import 'package:manos_seguras/core/tema_app.dart';
import 'package:manos_seguras/data/local/conexion.dart';
import 'package:manos_seguras/main.dart';
import 'package:manos_seguras/presentation/di.dart';

void main() {
  setUp(() async {
    await iniciarDependencias(
      abrirBase: () async => abrirBaseDeDatosEnMemoria(),
      usarRespaldoLocal: true,
    );
    await getIt<TemaApp>().cargarDesdeDisco();
  });

  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('La app arranca en PantallaBienvenida y muestra el título', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ManosSegurasApp());
    await tester.pumpAndSettle();

    expect(find.text('ManosSeguras'), findsWidgets);
    expect(find.text('Los 5 Momentos'), findsOneWidget);
    expect(find.text('Comenzar auditoría'), findsOneWidget);
  });

  testWidgets('Navega de Bienvenida a Establecimiento al presionar el botón', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ManosSegurasApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Comenzar auditoría'));
    await tester.tap(find.text('Comenzar auditoría'));
    await tester.pumpAndSettle();

    expect(find.text('Hospital Regional del Cusco'), findsOneWidget);
  });
}
