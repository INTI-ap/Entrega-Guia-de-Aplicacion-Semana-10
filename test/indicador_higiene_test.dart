import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:manos_seguras/models/indicador_higiene.dart';
import 'package:manos_seguras/services/higiene_api_service.dart';

/// Pruebas de la capa de datos de la Sesión 15-16.
///
/// Se ejecutan con `flutter test` y NO requieren Internet: `MockClient`
/// (incluido en el paquete `http`) intercepta la petición y devuelve la
/// respuesta que se quiera simular. Esto es lo que permitirá, en la
/// Unidad III, automatizar las pruebas dentro de un pipeline de CI.
void main() {
  // Fragmento real de la respuesta del Observatorio Mundial de la Salud.
  const String respuestaReal =
      '{"@odata.context":"https://ghoapi.azureedge.net/api/\$metadata#WSH_HYGIENE_BASIC",'
      '"value":['
      '{"IndicatorCode":"WSH_HYGIENE_BASIC","SpatialDim":"PER","TimeDim":2024,'
      '"Dim1":"RESIDENCEAREATYPE_RUR","NumericValue":72.273238897,"Value":"72"},'
      '{"IndicatorCode":"WSH_HYGIENE_BASIC","SpatialDim":"PER","TimeDim":2009,'
      '"Dim1":"RESIDENCEAREATYPE_RUR","NumericValue":46.995566574,"Value":"47"},'
      '{"IndicatorCode":"WSH_HYGIENE_BASIC","SpatialDim":"PER","TimeDim":2010,'
      '"Dim1":"RESIDENCEAREATYPE_RUR","NumericValue":null,"Value":"47"}'
      ']}';

  group('IndicadorHigiene.fromJson', () {
    test('traduce los campos del API al modelo de dominio', () {
      final IndicadorHigiene indicador =
          IndicadorHigiene.fromJson(<String, dynamic>{
            'IndicatorCode': 'WSH_HYGIENE_BASIC',
            'SpatialDim': 'PER',
            'TimeDim': 2024,
            'Dim1': 'RESIDENCEAREATYPE_RUR',
            'NumericValue': 72.273238897,
          });

      expect(indicador.codigoIndicador, 'WSH_HYGIENE_BASIC');
      expect(indicador.pais, 'PER');
      expect(indicador.anio, 2024);
      expect(indicador.ambito, 'Rural');
      expect(indicador.valor, closeTo(72.27, 0.01));
      expect(indicador.valorTexto, '72.3 %');
      expect(indicador.fraccion, closeTo(0.7227, 0.001));
    });

    test('no falla cuando NumericValue viene nulo', () {
      final IndicadorHigiene indicador = IndicadorHigiene.fromJson(
        <String, dynamic>{'SpatialDim': 'PER', 'TimeDim': 2010},
      );

      expect(indicador.tieneValor, isFalse);
      expect(indicador.valorTexto, 'Sin dato');
      expect(indicador.fraccion, 0);
      expect(indicador.codigoIndicador, 'SIN_CODIGO');
      expect(indicador.ambito, 'No especificado');
    });

    test('acepta valores numéricos enviados como texto', () {
      final IndicadorHigiene indicador = IndicadorHigiene.fromJson(
        <String, dynamic>{
          'SpatialDim': 'PER',
          'TimeDim': '2024',
          'NumericValue': '72',
        },
      );

      expect(indicador.anio, 2024);
      expect(indicador.valor, 72);
    });

    test('tolera textos con tipos inesperados', () {
      final indicador = IndicadorHigiene.fromJson({
        'IndicatorCode': 15,
        'SpatialDim': true,
        'TimeDim': null,
        'Dim1': 2024,
      });
      expect(indicador.codigoIndicador, 'SIN_CODIGO');
      expect(indicador.pais, 'N/D');
      expect(indicador.anio, 0);
      expect(indicador.ambito, 'No especificado');
    });
  });

  group('HigieneApiService', () {
    test(
      'devuelve la lista ordenada por año cuando el API responde 200',
      () async {
        final HigieneApiService servicio = HigieneApiService(
          cliente: MockClient((http.Request peticion) async {
            // Verifica que la URL se construya con el filtro esperado.
            expect(peticion.url.host, 'ghoapi.azureedge.net');
            expect(
              peticion.url.queryParameters[r'$filter'],
              "SpatialDim eq 'PER'",
            );
            return http.Response(
              respuestaReal,
              200,
              headers: <String, String>{
                'content-type': 'application/json; charset=utf-8',
              },
            );
          }),
        );

        final List<IndicadorHigiene> indicadores = await servicio
            .obtenerIndicadoresPeru();

        expect(indicadores, hasLength(3));
        expect(indicadores.first.anio, 2009);
        expect(indicadores.last.anio, 2024);
      },
    );

    test('lanza ApiException cuando el servicio responde 404', () async {
      final HigieneApiService servicio = HigieneApiService(
        cliente: MockClient((_) async => http.Response('No encontrado', 404)),
      );

      expect(
        () => servicio.obtenerIndicadoresPeru(),
        throwsA(isA<ApiException>()),
      );
    });

    test('lanza ApiException cuando el cuerpo no es JSON válido', () async {
      final HigieneApiService servicio = HigieneApiService(
        cliente: MockClient(
          (_) async => http.Response('<html>error</html>', 200),
        ),
      );

      expect(
        () => servicio.obtenerIndicadoresPeru(),
        throwsA(isA<ApiException>()),
      );
    });

    test('lanza ApiException cuando value no es una lista', () async {
      final servicio = HigieneApiService(
        cliente: MockClient((_) async => http.Response('{"value":{}}', 200)),
      );
      expect(servicio.obtenerIndicadoresPeru(), throwsA(isA<ApiException>()));
    });

    test('lanza ApiException cuando falla la conexión', () async {
      final HigieneApiService servicio = HigieneApiService(
        cliente: MockClient(
          (_) async => throw http.ClientException('Fallo de red simulado'),
        ),
      );

      expect(
        () => servicio.obtenerIndicadoresPeru(),
        throwsA(isA<ApiException>()),
      );
    });

    test('el respaldo local devuelve 16 registros sin usar la red', () async {
      final HigieneApiService servicio = HigieneApiService(
        usarRespaldoLocal: true,
        cliente: MockClient(
          (_) async => throw StateError('No debe llamarse a la red'),
        ),
      );

      final List<IndicadorHigiene> indicadores = await servicio
          .obtenerIndicadoresPeru();

      expect(indicadores, hasLength(16));
      expect(indicadores.first.anio, 2009);
      expect(indicadores.last.anio, 2024);
      expect(indicadores.last.valor, greaterThan(indicadores.first.valor!));
    });

    test('decodifica correctamente los acentos del cuerpo (utf8)', () async {
      final String cuerpoConAcentos = jsonEncode(<String, dynamic>{
        'value': <Map<String, dynamic>>[
          <String, dynamic>{
            'IndicatorCode': 'INDICADOR_Ñ',
            'SpatialDim': 'PER',
            'TimeDim': 2024,
            'Dim1': 'RESIDENCEAREATYPE_TOTL',
            'NumericValue': 50,
          },
        ],
      });

      final HigieneApiService servicio = HigieneApiService(
        cliente: MockClient(
          (_) async => http.Response.bytes(utf8.encode(cuerpoConAcentos), 200),
        ),
      );

      final List<IndicadorHigiene> indicadores = await servicio
          .obtenerIndicadoresPeru();

      expect(indicadores.single.codigoIndicador, 'INDICADOR_Ñ');
      expect(indicadores.single.ambito, 'Total');
    });
  });
}
