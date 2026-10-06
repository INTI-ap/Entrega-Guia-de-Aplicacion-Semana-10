import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/fallos.dart';
import '../../domain/entidades/indicador_higiene.dart';
import '../mapeadores/mapeadores.dart';
import 'datos_respaldo.dart';

/// **Servicio REST del Observatorio Mundial de la Salud (OMS).**
///
/// Semana 6 / temática 1.4.2, ahora reubicado en la capa Data de la
/// arquitectura por capas (Semana 8).
///
/// Cambios respecto de la Sesión 16:
///
///  * ya **no** conoce el respaldo local ni la caché: solo sabe descargar.
///    La decisión "de dónde vienen los datos" es responsabilidad del
///    repositorio (SRP, Semana 9);
///  * los errores se traducen a [FalloRemoto] en lugar de `ApiException`,
///    para que toda la capa de datos hable el mismo idioma;
///  * recibe el `http.Client` por constructor: es lo que permite inyectar
///    un `MockClient` en las pruebas sin tocar la red.
///
/// Endpoint (no requiere API key):
/// ```
/// GET https://ghoapi.azureedge.net/api/WSH_HYGIENE_BASIC?$filter=SpatialDim eq 'PER'
/// ```
class HigieneApiService {
  HigieneApiService({http.Client? cliente, this.usarRespaldoLocal = false})
      : _cliente = cliente ?? http.Client();

  static const String host = 'ghoapi.azureedge.net';
  static const String codigoIndicador = 'WSH_HYGIENE_BASIC';
  static const Duration tiempoLimite = Duration(seconds: 12);

  final http.Client _cliente;

  /// Cuando es `true` la red se evita por completo y se devuelven los 16
  /// registros de `datos_respaldo.dart`. Es el plan B del laboratorio sin
  /// Internet (tercer nivel de degradación del patrón offline-first).
  final bool usarRespaldoLocal;

  /// `Uri.https` codifica el `$filter` (el `$` viaja como `%24`) y los
  /// espacios. Nunca se concatenan cadenas para construir una URL.
  Uri get urlIndicadores => Uri.https(host, '/api/$codigoIndicador', {
        r'$filter': "SpatialDim eq 'PER'",
      });

  /// Descarga la serie histórica completa, ordenada por año.
  ///
  /// Lanza [FalloRemoto] cuando algo sale mal; el repositorio decide si eso
  /// es fatal o si puede servir datos locales.
  Future<List<IndicadorHigiene>> obtenerIndicadoresPeru() async {
    if (usarRespaldoLocal) {
      return _desdeRespaldo();
    }

    try {
      final http.Response respuesta =
          await _cliente.get(urlIndicadores).timeout(tiempoLimite);

      if (respuesta.statusCode != 200) {
        throw FalloRemoto(
          'El servicio respondió con el código HTTP '
          '${respuesta.statusCode}. Verifique la disponibilidad del API.',
        );
      }

      // Se decodifica SIEMPRE con utf8.decode(bodyBytes) para no perder
      // los acentos: `response.body` cae a latin-1 si el servidor no
      // declara el charset.
      final Object? decodificado =
          jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (decodificado is! Map<String, dynamic>) {
        throw const FalloRemoto(
          'La respuesta del servicio no tiene el formato esperado.',
        );
      }

      final List<dynamic> crudos =
          decodificado['value'] as List<dynamic>? ?? const <dynamic>[];

      return crudos
          .whereType<Map<String, dynamic>>()
          .map(IndicadorMapper.desdeJson)
          .toList()
        ..sort((IndicadorHigiene a, IndicadorHigiene b) =>
            a.anio.compareTo(b.anio));
    } on FalloRemoto {
      rethrow;
    } on TimeoutException catch (error) {
      throw FalloRemoto(
        'La consulta tardó más de lo permitido. '
        'Revise su conexión e intente nuevamente.',
        causa: error,
      );
    } on http.ClientException catch (error) {
      throw FalloRemoto(
        'No se pudo conectar con el servicio. '
        'Verifique su conexión a Internet o su proxy institucional.',
        causa: error,
      );
    } on FormatException catch (error) {
      throw FalloRemoto(
        'El servicio devolvió información ilegible (JSON inválido).',
        causa: error,
      );
    }
  }

  /// Los mismos 16 registros, pasando por el mismo mapeador.
  List<IndicadorHigiene> respaldoLocal() => _desdeRespaldo();

  void cerrar() => _cliente.close();

  List<IndicadorHigiene> _desdeRespaldo() {
    return indicadoresPeruCrudos
        .map(IndicadorMapper.desdeJson)
        .toList()
      ..sort((IndicadorHigiene a, IndicadorHigiene b) =>
          a.anio.compareTo(b.anio));
  }
}
