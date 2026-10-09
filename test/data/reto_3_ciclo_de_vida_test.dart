import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manos_seguras/core/fallos.dart';
import 'package:manos_seguras/data/local/daos/auditorias_dao.dart';
import 'package:manos_seguras/data/local/manos_seguras_db.dart' as db;
import 'package:manos_seguras/data/mapeadores/mapeadores.dart';
import 'package:manos_seguras/data/repositorios/auditoria_repository_drift.dart';
import 'package:manos_seguras/domain/entidades/auditoria.dart';
import 'package:manos_seguras/domain/entidades/catalogos.dart';
import 'package:manos_seguras/domain/entidades/establecimiento.dart';
import 'package:manos_seguras/domain/entidades/oportunidad_registro.dart';
import 'package:manos_seguras/domain/entidades/personal.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  late db.ManosSegurasDb base;
  late AuditoriaRepositoryDrift repo;
  Future<void> catalogos() async {
    await base.insertarEstablecimiento(Establecimiento.ejemplo().aFila());
    await base.insertarPersonal(Observador.ejemplo().aFila());
    await base.insertarPersonal(Observado.ejemplo().aFila());
  }

  Auditoria original() => Auditoria(
    id: 'original',
    establecimientoId: Establecimiento.ejemplo().codigoUnico,
    establecimientoNombre: Establecimiento.ejemplo().nombre,
    observadorDni: Observador.ejemplo().dni,
    observadorNombre: 'Observador',
    observadoDni: Observado.ejemplo().dni,
    observadoNombre: 'Personal',
    fecha: DateTime(2026, 1, 1),
    estado: EstadoAuditoria.sincronizada,
    sincronizadaEn: DateTime(2026, 1, 2),
    observacionGeneral: 'Antes',
    oportunidades: [
      OportunidadRegistro(
        auditoriaId: 'original',
        numero: 1,
        momento: Momento.values.first,
        accion: Accion.values.first,
        observacion: 'Nota',
        duracionSegundos: 20,
      ),
    ],
  );
  setUp(() async {
    base = db.ManosSegurasDb(NativeDatabase.memory());
    repo = AuditoriaRepositoryDrift(
      DriftAuditoriasDao(base),
      generadorId: () => 'copia',
    );
    await catalogos();
    await repo.guardar(original());
  });
  tearDown(() async => base.close());

  test('editar conserva fecha, oportunidades e identificadores', () async {
    final antes = await repo.obtenerPorId('original');
    await repo.actualizar(antes.copyWith(observacionGeneral: 'Después'));
    final despues = await repo.obtenerPorId('original');
    expect(despues.fecha, antes.fecha);
    expect(despues.oportunidades.single.id, antes.oportunidades.single.id);
    expect(despues.oportunidades.single.observacion, 'Nota');
    expect(despues.oportunidades.single.duracionSegundos, 20);
    final fila = (await base.select(base.auditoriasHistorial).get()).single;
    expect(fila.campo, 'observacionGeneral');
    expect(fila.valorAnterior, 'Antes');
    expect(fila.valorNuevo, 'Después');
  });
  test(
    'anular oculta la auditoría en listados, rango, conteo y resumen',
    () async {
      await repo.eliminarLogicamente('original');
      expect(await repo.listarAuditorias(), isEmpty);
      expect(await repo.listarPaginado(limite: 20), isEmpty);
      expect(
        await repo.listarPorRango(DateTime(2025), DateTime(2027)),
        isEmpty,
      );
      expect(
        (await repo.conteoPorEstado()).values.fold(0, (int s, n) => s + n),
        0,
      );
      expect((await repo.resumenAdherencia()).totalOportunidades, 0);
      expect(await repo.observarAuditorias().first, isEmpty);
      expect(
        (await repo.listarAuditorias(incluirEliminadas: true)).single.eliminada,
        isTrue,
      );
    },
  );
  test('anular conserva físicamente cabecera y detalle', () async {
    await repo.eliminarLogicamente('original');
    final conteos = await base.contarFilas();
    expect(conteos['auditorias'], 1);
    expect(conteos['oportunidades'], 1);
  });
  test(
    'restaurar devuelve al listado activo y registra ambos cambios',
    () async {
      await repo.eliminarLogicamente('original');
      await repo.restaurar('original');
      expect((await repo.listarAuditorias()).single.totalOportunidades, 1);
      final historial = await base.select(base.auditoriasHistorial).get();
      expect(historial.map((h) => h.valorNuevo), ['true', 'false']);
    },
  );
  test(
    'duplicar crea borrador con nueva fecha, detalle y sin sincronización',
    () async {
      final id = await repo.duplicar('original');
      final copia = await repo.obtenerPorId(id);
      expect(id, isNot('original'));
      expect(copia.estado, EstadoAuditoria.borrador);
      expect(copia.sincronizadaEn, isNull);
      expect(copia.fechaFin, isNull);
      expect(copia.eliminada, isFalse);
      expect(copia.fecha.year, DateTime.now().year);
      expect(copia.totalOportunidades, 1);
      expect(copia.oportunidades.single.auditoriaId, id);
      expect(
        copia.oportunidades.single.id,
        isNot((await repo.obtenerPorId('original')).oportunidades.single.id),
      );
      expect(
        (await repo.obtenerPorId('original')).estado,
        EstadoAuditoria.sincronizada,
      );
    },
  );
  test(
    'fallo al escribir historial revierte la edición y sus oportunidades',
    () async {
      await base.customStatement(
        "CREATE TRIGGER rechazar_historial BEFORE INSERT ON auditorias_historial BEGIN SELECT RAISE(ABORT, 'fallo de prueba'); END",
      );
      final antes = await repo.obtenerPorId('original');
      await expectLater(
        repo.actualizar(
          antes.copyWith(
            observacionGeneral: 'Error',
            oportunidades: [
              antes.oportunidades.single.copyWith(observacion: 'Cambio'),
            ],
          ),
        ),
        throwsA(isA<FalloLocal>()),
      );
      final despues = await repo.obtenerPorId('original');
      expect(despues.observacionGeneral, 'Antes');
      expect(despues.oportunidades.single.id, antes.oportunidades.single.id);
      expect(despues.oportunidades.single.observacion, 'Nota');
    },
  );
  test('fallo de oportunidad revierte cabecera al guardar', () async {
    final a = original();
    await expectLater(
      repo.guardar(
        a.copyWith(
          id: 'fallida',
          oportunidades: [a.oportunidades.single, a.oportunidades.single],
        ),
      ),
      throwsA(isA<FalloLocal>()),
    );
    expect((await base.select(base.auditorias).get()).length, 1);
  });
  test('restaurar inexistente informa un fallo de dominio', () async {
    await expectLater(
      repo.restaurar('inexistente'),
      throwsA(isA<FalloNoEncontrado>()),
    );
  });
  test('repetir restauración no genera cambios ficticios', () async {
    await repo.restaurar('original');
    expect(await base.select(base.auditoriasHistorial).get(), isEmpty);
  });
  test(
    'migración v2 a v3 conserva las auditorías y habilita el historial',
    () async {
      final carpeta = await Directory.systemTemp.createTemp('reto3_migracion');
      final archivo = File('${carpeta.path}/base.sqlite');
      try {
        final antigua = db.ManosSegurasDb(NativeDatabase(archivo));
        await antigua.insertarEstablecimiento(
          Establecimiento.ejemplo().aFila(),
        );
        await antigua.insertarPersonal(Observador.ejemplo().aFila());
        await antigua.insertarPersonal(Observado.ejemplo().aFila());
        await AuditoriaRepositoryDrift(
          DriftAuditoriasDao(antigua),
        ).guardar(original());
        await antigua.close();
        final sqlite = sqlite3.open(archivo.path);
        sqlite.execute('DROP TABLE auditorias_historial');
        sqlite.execute('PRAGMA user_version = 2');
        sqlite.close();
        final migrada = db.ManosSegurasDb(NativeDatabase(archivo));
        try {
          expect((await migrada.contarFilas())['auditorias_historial'], 0);
          final repositorioMigrado = AuditoriaRepositoryDrift(
            DriftAuditoriasDao(migrada),
          );
          final conservada = await repositorioMigrado.obtenerPorId('original');
          expect(conservada.observacionGeneral, 'Antes');
          expect(conservada.totalOportunidades, 1);
          await repositorioMigrado.actualizar(
            conservada.copyWith(observacionGeneral: 'Migrada'),
          );
          expect(
            (await migrada.select(migrada.auditoriasHistorial).get()).length,
            1,
          );
          expect(
            (await migrada.customSelect('PRAGMA user_version').getSingle())
                .read<int>('user_version'),
            3,
          );
          expect(await migrada.estadoClavesForaneas(), 1);
        } finally {
          await migrada.close();
        }
      } finally {
        await carpeta.delete(recursive: true);
      }
    },
  );
}
