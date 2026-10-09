import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manos_seguras/core/theme/app_theme.dart';
import 'package:manos_seguras/domain/entidades/indicador_higiene.dart';
import 'package:manos_seguras/domain/repositorios/indicador_repository.dart';
import 'package:manos_seguras/presentation/di.dart';
import 'package:manos_seguras/presentation/pantallas/pantalla_indicadores.dart';
import 'package:manos_seguras/presentation/widgets/estados_vista.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final fuente = Platform.environment['RETO2_FUENTE'];
    if (fuente != null) {
      final loader = FontLoader('Roboto');
      loader.addFont(
        Future.value(ByteData.sublistView(await File(fuente).readAsBytes())),
      );
      await loader.load();
    }
    final iconos = Platform.environment['RETO2_ICONOS'];
    if (iconos != null) {
      final loader = FontLoader('MaterialIcons');
      loader.addFont(
        Future.value(ByteData.sublistView(await File(iconos).readAsBytes())),
      );
      await loader.load();
    }
  });
  final fecha = DateTime(2026, 10, 8, 10);
  const datos = [
    IndicadorHigiene(
      codigoIndicador: 'WSH_HYGIENE_BASIC',
      pais: 'PER',
      anio: 2023,
      ambito: 'Rural',
      valor: 72,
    ),
    IndicadorHigiene(
      codigoIndicador: 'WSH_HYGIENE_BASIC',
      pais: 'PER',
      anio: 2024,
      ambito: 'Rural',
      valor: 75,
    ),
  ];
  final escenarios = <String, ResultadoIndicadores>{
    'R2_01_indicadores_red': ResultadoIndicadores(
      indicadores: datos,
      origen: OrigenDatos.red,
      actualizadoEn: fecha,
    ),
    'R2_02_indicadores_cache': ResultadoIndicadores(
      indicadores: datos,
      origen: OrigenDatos.cacheLocal,
      actualizadoEn: fecha,
    ),
    'R2_03_cache_vencida_ambar': ResultadoIndicadores(
      indicadores: datos,
      origen: OrigenDatos.cacheLocal,
      actualizadoEn: fecha.subtract(const Duration(days: 2)),
      datosObsoletos: true,
    ),
    'R2_04_indicadores_respaldo': const ResultadoIndicadores(
      indicadores: datos,
      origen: OrigenDatos.respaldo,
    ),
  };
  for (final e in escenarios.entries) {
    testWidgets('indicadores muestran origen, fecha y vigencia: ${e.key}', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      getIt.registerSingleton<IndicadorRepository>(_ResultadoFijo(e.value));
      addTearDown(getIt.reset);
      final captura = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: captura,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            home: const PantallaIndicadores(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        find.text(
          e.value.datosObsoletos
              ? 'Caché vencida · Datos obsoletos'
              : e.value.origen.etiqueta,
        ),
        findsOneWidget,
      );
      expect(
        find.textContaining('Actualizado:'),
        e.value.actualizadoEn == null ? findsNothing : findsOneWidget,
      );
      if (e.value.datosObsoletos) {
        final badge = tester.widget<InsigniaOrigen>(
          find.byType(InsigniaOrigen),
        );
        expect(badge.datosObsoletos, true);
        expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      }
      // Exportación opcional; ninguna imagen se guarda dentro del repositorio.
      final destino = Platform.environment['RETO2_EVIDENCIAS'];
      if (destino != null) {
        await tester.runAsync(() async {
          final boundary =
              captura.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary;
          final imagen = await boundary.toImage(pixelRatio: 2);
          final bytes = await imagen.toByteData(format: ui.ImageByteFormat.png);
          await File(
            '$destino/${e.key}.png',
          ).writeAsBytes(bytes!.buffer.asUint8List());
          imagen.dispose();
        });
      }
    });
  }
}

class _ResultadoFijo implements IndicadorRepository {
  _ResultadoFijo(this.resultado);
  final ResultadoIndicadores resultado;
  @override
  Future<ResultadoIndicadores> obtenerIndicadores({
    bool forzarRefresco = false,
  }) async => resultado;
  @override
  bool cacheEsVigente(
    DateTime? ultimaSincronizacion, {
    DateTime? ahora,
    String codigo = 'WSH_HYGIENE_BASIC',
  }) => !resultado.datosObsoletos;
  @override
  Future<List<IndicadorHigiene>> leerCache() async => resultado.indicadores;
  @override
  Future<DateTime?> ultimaSincronizacion() async => resultado.actualizadoEn;
  @override
  Future<void> guardarEnCache(
    List<IndicadorHigiene> indicadores, {
    DateTime? momento,
  }) async {}
  @override
  Future<void> limpiarCache() async {}
  @override
  Future<void> invalidar(String codigo) async {}
}
