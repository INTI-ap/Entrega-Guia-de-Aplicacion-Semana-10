import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../datos/datos_respaldo.dart';
import '../models/indicador_higiene.dart';

/// Error de dominio producido por la capa de acceso a datos.
///
/// La interfaz de usuario nunca ve un `SocketException`, un
/// `TimeoutException` ni un `FormatException`: el servicio los traduce
/// a este único tipo con un mensaje en español apto para el usuario.
/// Así, la pantalla puede mostrar un error comprensible sin conocer los
/// detalles del paquete `http`.
class ApiException implements Exception {
  final String mensaje;

  const ApiException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Servicio de acceso al API REST público del Observatorio Mundial de la
/// Salud (OMS). Corresponde a la temática 1.4.2 del sílabo: conexión a un
/// API y consumo de un servicio REST con el paquete `http`.
///
/// Endpoint consumido (no requiere API key ni registro):
///   GET https://ghoapi.azureedge.net/api/WSH_HYGIENE_BASIC?$filter=SpatialDim eq 'PER'
///
/// Nota de arquitectura: esta clase es el antecedente directo de la capa
/// *Data* de Clean Architecture que se estudiará en la Unidad II; por eso
/// recibe el `http.Client` por parámetro (inyección de dependencias) en
/// lugar de crearlo internamente, lo que permite sustituirlo por un
/// doble de prueba sin tocar la interfaz.
class HigieneApiService {
  /// Permite inyectar un cliente falso en las pruebas unitarias.
  HigieneApiService({http.Client? cliente, this.usarRespaldoLocal = false})
    : _cliente = cliente ?? http.Client();

  // --- Configuración del servicio ---------------------------------------
  static const String host = 'ghoapi.azureedge.net';
  static const String codigoIndicador = 'WSH_HYGIENE_BASIC';
  static const Duration tiempoLimite = Duration(seconds: 12);

  final http.Client _cliente;

  /// Cuando es `true`, el servicio no toca la red y devuelve los datos de
  /// `lib/datos/datos_respaldo.dart`. Es el *plan B* para laboratorios sin
  /// Internet (ver Anexo B de la guía).
  final bool usarRespaldoLocal;

  /// Arma la URL de forma segura: `Uri.https` codifica automáticamente el
  /// parámetro `$filter` (el `$` se envía como `%24`) y los espacios.
  /// Nunca se concatenan cadenas a mano para construir una URL.
  Uri get urlIndicadores => Uri.https(host, '/api/$codigoIndicador', {
    r'$filter': "SpatialDim eq 'PER'",
  });

  /// Descarga los registros históricos del indicador para el Perú y los
  /// devuelve como una lista de objetos de dominio ordenada por año.
  ///
  /// Es `async`: devuelve un `Future` que se completa con la lista cuando
  /// la respuesta llega por la red, o se completa con error
  /// ([ApiException]) si algo falla.
  Future<List<IndicadorHigiene>> obtenerIndicadoresPeru() async {
    if (usarRespaldoLocal) {
      return _desdeRespaldo();
    }

    try {
      // 1. Petición HTTP con tiempo límite: sin timeout, una red lenta
      //    dejaría el spinner girando indefinidamente.
      final http.Response respuesta = await _cliente
          .get(urlIndicadores)
          .timeout(tiempoLimite);

      // 2. El código de estado es parte del contrato REST: 200 = éxito.
      if (respuesta.statusCode != 200) {
        throw ApiException(
          'El servicio respondió con el código HTTP ${respuesta.statusCode}. '
          'Verifique la disponibilidad del API e intente nuevamente.',
        );
      }

      // 3. Se decodifica SIEMPRE con utf8.decode(bodyBytes) para no perder
      //    los acentos: response.body usa latin-1 cuando el servidor no
      //    declara el charset.
      final dynamic decodificado = jsonDecode(utf8.decode(respuesta.bodyBytes));
      if (decodificado is! Map<String, dynamic>) {
        throw const ApiException(
          'La respuesta del servicio no tiene el formato esperado.',
        );
      }

      // 4. En este API la lista viene dentro de la clave "value".
      final dynamic valor = decodificado['value'];
      if (valor is! List<dynamic>) {
        throw const ApiException(
          'La lista de indicadores no tiene el formato esperado.',
        );
      }
      final List<dynamic> crudos = valor;

      // 5. Cada elemento se traduce a un objeto de dominio. Se aplica
      //    .map().toList() (Sesión 2) y sort() por año (Sesión 3).
      final List<IndicadorHigiene> indicadores =
          crudos
              .whereType<Map<String, dynamic>>()
              .map(IndicadorHigiene.fromJson)
              .toList()
            ..sort((a, b) => a.anio.compareTo(b.anio));

      return indicadores;
    } on ApiException {
      // Un ApiException ya tiene un mensaje para el usuario: se propaga.
      rethrow;
    } on TimeoutException {
      throw const ApiException(
        'La consulta tardó más de lo permitido. '
        'Revise su conexión e intente nuevamente.',
      );
    } on http.ClientException {
      throw const ApiException(
        'No se pudo conectar con el servicio. '
        'Verifique su conexión a Internet o su proxy institucional.',
      );
    } on FormatException {
      throw const ApiException(
        'El servicio devolvió información ilegible (JSON inválido).',
      );
    }
  }

  /// Libera los recursos del cliente HTTP. Se invoca desde `dispose()` de
  /// la pantalla o desde el contenedor de dependencias (Unidad II).
  void cerrar() => _cliente.close();

  List<IndicadorHigiene> _desdeRespaldo() {
    return indicadoresPeruCrudos.map(IndicadorHigiene.fromJson).toList()
      ..sort((a, b) => a.anio.compareTo(b.anio));
  }
}
