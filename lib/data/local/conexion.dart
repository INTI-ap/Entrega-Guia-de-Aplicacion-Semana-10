import 'dart:io';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'manos_seguras_db.dart';

/// **Fábrica de conexiones de la base de datos local.**
///
/// Semana 10 — temática 2.2.1. Este archivo es el único lugar del proyecto
/// que sabe *dónde* vive el archivo `.sqlite`. Separar la conexión del
/// esquema permite tres escenarios con el mismo código de tablas y DAO:
///
/// | Escenario        | Función                     | Archivo               |
/// |------------------|-----------------------------|-----------------------|
/// | Aplicación real  | [abrirBaseDeDatos]          | documentos del dispositivo |
/// | Pruebas de datos | [abrirBaseDeDatosEnMemoria] | RAM (se descarta)     |
/// | Inspección       | [abrirBaseDeDatosDeArchivo] | ruta indicada         |
///
/// Las pruebas usan `NativeDatabase.memory()`: la base se crea y se destruye
/// en cada prueba, de modo que `flutter test` no deja basura ni depende del
/// estado dejado por otra prueba (aislamiento).
Future<ManosSegurasDb> abrirBaseDeDatos() async {
  final Directory carpeta = await getApplicationDocumentsDirectory();
  final File archivo = File(p.join(carpeta.path, 'manos_seguras.sqlite'));
  return ManosSegurasDb(NativeDatabase.createInBackground(archivo));
}

/// Conexión en memoria, para pruebas y para la demostración en clase.
ManosSegurasDb abrirBaseDeDatosEnMemoria() {
  return ManosSegurasDb(NativeDatabase.memory());
}

/// Conexión a un archivo concreto (útil para inspeccionar la base con
/// `sqlite3` o DB Browser for SQLite desde la terminal del laboratorio).
ManosSegurasDb abrirBaseDeDatosDeArchivo(String ruta) {
  return ManosSegurasDb(NativeDatabase(File(ruta)));
}

/// Ruta del archivo que usa la aplicación en el dispositivo, solo para
/// mostrarla en pantalla durante la demostración.
Future<String> rutaDeLaBaseDeDatos() async {
  final Directory carpeta = await getApplicationDocumentsDirectory();
  return p.join(carpeta.path, 'manos_seguras.sqlite');
}
