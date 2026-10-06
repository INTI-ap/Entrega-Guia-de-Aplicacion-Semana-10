import 'dart:math';

/// Generador de identificadores **UUID v4** sin dependencias externas.
///
/// ¿Por qué no usar el paquete `uuid`? Porque agregar una dependencia solo
/// para 12 líneas de código no se justifica en un proyecto didáctico, y
/// porque implementarlo obliga a entender *por qué* el identificador debe
/// generarse en el dispositivo: una auditoría capturada sin conexión
/// necesita una clave primaria única **antes** de llegar al servidor, de
/// modo que al sincronizar no colisione con la de otro dispositivo.
///
/// Se usa `Random.secure()` para que los identificadores no sean
/// predecibles (un `Random()` común produce secuencias repetibles).
String generarUuidV4() {
  final Random azar = Random.secure();
  final List<int> bytes = List<int>.generate(16, (_) => azar.nextInt(256));

  // Los bits 12-15 del byte 6 identifican la versión (4)…
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  // …y los dos bits más significativos del byte 8, la variante (10xx).
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  String hex(int valor) => valor.toRadixString(16).padLeft(2, '0');

  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < bytes.length; i++) {
    if (i == 4 || i == 6 || i == 8 || i == 10) buffer.write('-');
    buffer.write(hex(bytes[i]));
  }
  return buffer.toString();
}

/// Formatea una fecha como `dd/MM/yyyy HH:mm`, sin depender de `intl`.
String formatearFechaHora(DateTime fecha) {
  String dos(int valor) => valor.toString().padLeft(2, '0');
  return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year} '
      '${dos(fecha.hour)}:${dos(fecha.minute)}';
}

/// Formatea una fecha como `dd/MM/yyyy`.
String formatearFecha(DateTime fecha) {
  String dos(int valor) => valor.toString().padLeft(2, '0');
  return '${dos(fecha.day)}/${dos(fecha.month)}/${fecha.year}';
}

/// Porcentaje con un decimal: `87.5 %`.
String formatearPorcentaje(double? valor) {
  if (valor == null) return 'Sin datos';
  return '${valor.toStringAsFixed(1)} %';
}
