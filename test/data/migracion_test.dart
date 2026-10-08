import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manos_seguras/data/local/infraestructura.dart';
import 'package:manos_seguras/data/local/manos_seguras_db.dart'
    hide Auditoria, AuditoriasCompanion;
import 'package:manos_seguras/data/repositorios/auditoria_repository_drift.dart';
import 'package:manos_seguras/domain/entidades/auditoria.dart';
import 'package:manos_seguras/domain/repositorios/auditoria_repository.dart';
import 'package:sqlite3/sqlite3.dart';

/// **Prueba de migración de esquema (Reto 4).**
///
/// Verifica, de forma automatizada, que una base creada con el esquema de la
/// **versión 1** puede abrirse con la versión que declara hoy
/// `ManosSegurasDb.schemaVersion` **sin perder datos**.
///
/// Cómo la usa el equipo (procedimiento del Reto 4):
///
///  1. agregue la columna nueva a la tabla correspondiente en
///     `lib/data/local/tablas/` (por ejemplo `observacionGeneral` en
///     `Auditorias`);
///  2. suba `schemaVersion` a 2 en `manos_seguras_db.dart`;
///  3. implemente `onUpgrade`:
///     `if (desde < 2) await m.addColumn(auditorias, auditorias.observacionGeneral);`
///  4. ejecute `flutter test test/data/migracion_test.dart`.
///
/// La prueba está escrita para ser **útil hoy y exigente mañana**: mientras
/// `schemaVersion` siga siendo 1 pasa (no hay nada que migrar), y en cuanto el
/// equipo lo suba empieza a exigir que `onUpgrade` esté implementado.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late Directory carpeta;
  late File archivo;

  setUp(() async {
    carpeta = await Directory.systemTemp.createTemp('manos_seguras_migracion');
    archivo = File('${carpeta.path}/manos_seguras.sqlite');
  });

  tearDown(() async {
    if (await carpeta.exists()) {
      await carpeta.delete(recursive: true);
    }
  });

  test('una base v1 con datos se abre con el esquema actual sin perder nada',
      () async {
    // 1. Base creada a mano con el esquema v1 y con datos reales.
    _crearBaseVersion1(archivo);

    // 2. Se abre con la clase actual (drift ejecutará onCreate o onUpgrade
    //    según el `user_version` que encontró).
    final ManosSegurasDb base = ManosSegurasDb(NativeDatabase(archivo));
    addTearDown(base.close);

    final AuditoriaRepository repositorio = AuditoriaRepositoryDrift(
      InfraestructuraLocal(base).auditoriasDao,
    );

    // 3. Si el esquema no cambió, esto se cumple trivialmente. Si el equipo
    //    subió schemaVersion sin escribir la migración, aquí se ve el fallo.
    final List<Auditoria> auditorias = await repositorio.listarAuditorias();
    expect(
      auditorias,
      hasLength(1),
      reason: 'La migración perdió las auditorías existentes.',
    );
    expect(auditorias.single.id, 'auditoria-preexistente');
    expect(auditorias.single.totalOportunidades, 2);
    expect(auditorias.single.oportunidadesCumplidas, 1);

    // 4. La cabecera sigue siendo escribible después de migrar.
    await repositorio.actualizar(
      auditorias.single.copyWith(estado: EstadoAuditoria.finalizada),
    );
    final Auditoria actualizada =
        await repositorio.obtenerPorId('auditoria-preexistente');
    expect(actualizada.estado, EstadoAuditoria.finalizada);
  });

  // Test que documenta el estado final esperado del Reto 4. Se deja "saltado"
  // a propósito: el equipo debe quitar el `skip` cuando suba el esquema a la
  // versión 2 y la comparación tenga sentido.
  test(
    'la versión del esquema es 2 (Reto 4 completado)',
    () {
      final ManosSegurasDb base = ManosSegurasDb(NativeDatabase.memory());
      addTearDown(base.close);
      expect(
        base.schemaVersion,
        2,
        reason: 'Suba schemaVersion a 2 y descomente la migración en '
            'manos_seguras_db.dart para completar el Reto 4.',
      );
    },
  );
}

/// Crea el archivo `*.sqlite` con el esquema de la **versión 1** y con datos,
/// usando `sqlite3` directamente (sin drift), para simular una instalación
/// antigua de la aplicación.
void _crearBaseVersion1(File archivo) {
  final Database db = sqlite3.open(archivo.path);
  try {
    db.execute('''
      CREATE TABLE establecimientos (
        codigo_unico TEXT NOT NULL PRIMARY KEY,
        nombre TEXT NOT NULL,
        categoria TEXT NOT NULL,
        red TEXT NOT NULL DEFAULT '',
        microred TEXT NOT NULL DEFAULT '',
        departamento TEXT NOT NULL DEFAULT '',
        provincia TEXT NOT NULL DEFAULT '',
        distrito TEXT NOT NULL DEFAULT '',
        latitud REAL,
        longitud REAL,
        creado_en TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP)
      );
    ''');
    db.execute('''
      CREATE TABLE personal (
        dni TEXT NOT NULL PRIMARY KEY,
        nombres_apellidos TEXT NOT NULL,
        rol TEXT NOT NULL DEFAULT 'observado',
        categoria_profesional TEXT,
        servicio_medico TEXT,
        creado_en TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP)
      );
    ''');
    db.execute('''
      CREATE TABLE auditorias (
        id TEXT NOT NULL PRIMARY KEY,
        establecimiento_id TEXT NOT NULL
          REFERENCES establecimientos (codigo_unico),
        establecimiento_nombre TEXT NOT NULL,
        observador_dni TEXT NOT NULL REFERENCES personal (dni),
        observador_nombre TEXT NOT NULL,
        observado_dni TEXT NOT NULL REFERENCES personal (dni),
        observado_nombre TEXT NOT NULL,
        fecha TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'borrador',
        eliminada INTEGER NOT NULL DEFAULT 0,
        sincronizada_en TEXT,
        creado_en TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
        actualizado_en TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP)
      );
    ''');
    db.execute('''
      CREATE TABLE oportunidades (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        auditoria_id TEXT NOT NULL
          REFERENCES auditorias (id) ON DELETE CASCADE,
        numero INTEGER NOT NULL,
        momento_clave TEXT NOT NULL,
        accion_clave TEXT NOT NULL,
        observacion TEXT,
        registrado_en TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP),
        UNIQUE (auditoria_id, numero)
      );
    ''');
    db.execute(
      'CREATE INDEX idx_oportunidades_auditoria '
      'ON oportunidades (auditoria_id);',
    );
    db.execute('''
      CREATE TABLE indicadores_cache (
        clave TEXT NOT NULL PRIMARY KEY,
        codigo_indicador TEXT NOT NULL,
        pais TEXT NOT NULL,
        anio INTEGER NOT NULL,
        ambito TEXT NOT NULL,
        valor REAL,
        descargado_en TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP)
      );
    ''');
    db.execute('''
      CREATE TABLE sincronizaciones (
        codigo TEXT NOT NULL PRIMARY KEY,
        ultima_sincronizacion TEXT NOT NULL,
        registros INTEGER NOT NULL DEFAULT 0
      );
    ''');
    db.execute('''
      CREATE TABLE preferencias (
        clave TEXT NOT NULL PRIMARY KEY,
        valor TEXT NOT NULL,
        actualizado_en TEXT NOT NULL DEFAULT (CURRENT_TIMESTAMP)
      );
    ''');

    db.execute('''
      INSERT INTO establecimientos (codigo_unico, nombre, categoria)
      VALUES ('00006405', 'Hospital Regional del Cusco', 'II-2');
    ''');
    db.execute('''
      INSERT INTO personal (dni, nombres_apellidos, rol)
      VALUES ('23456789', 'Ana Quispe Mamani', 'observador');
    ''');
    db.execute('''
      INSERT INTO personal (dni, nombres_apellidos, rol)
      VALUES ('45678912', 'Carlos Huamán Ttito', 'observado');
    ''');
    db.execute('''
      INSERT INTO auditorias (
        id, establecimiento_id, establecimiento_nombre,
        observador_dni, observador_nombre, observado_dni, observado_nombre,
        fecha, estado
      ) VALUES (
        'auditoria-preexistente', '00006405', 'Hospital Regional del Cusco',
        '23456789', 'Ana Quispe Mamani', '45678912', 'Carlos Huamán Ttito',
        '2026-10-01T09:00:00.000', 'borrador'
      );
    ''');
    db.execute('''
      INSERT INTO oportunidades (auditoria_id, numero, momento_clave, accion_clave)
      VALUES ('auditoria-preexistente', 1, 'antes_paciente', 'lavado');
    ''');
    db.execute('''
      INSERT INTO oportunidades (auditoria_id, numero, momento_clave, accion_clave)
      VALUES ('auditoria-preexistente', 2, 'despues_paciente', 'omision');
    ''');

    // Marca de versión del esquema: es la que drift lee para decidir si debe
    // ejecutar `onUpgrade`.
    db.execute('PRAGMA user_version = 1;');
  } finally {
    db.close();
  }
}
