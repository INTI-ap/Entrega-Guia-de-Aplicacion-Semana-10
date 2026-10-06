import 'package:get_it/get_it.dart';

import '../core/tema_app.dart';
import '../data/local/conexion.dart';
import '../data/local/daos/auditorias_dao.dart';
import '../data/local/daos/indicadores_dao.dart';
import '../data/local/daos/preferencias_dao.dart';
import '../data/local/infraestructura.dart';
import '../data/local/manos_seguras_db.dart';
import '../data/local/sembrador.dart';
import '../data/remoto/higiene_api_service.dart';
import '../data/repositorios/auditoria_repository_drift.dart';
import '../data/repositorios/indicador_repository_offline_first.dart';
import '../data/repositorios/preferencias_repository_drift.dart';
import '../domain/repositorios/auditoria_repository.dart';
import '../domain/repositorios/indicador_repository.dart';

/// **Contenedor de inyección de dependencias (get_it).**
///
/// Semana 9 — temática 2.1.6. Es el único archivo del proyecto que conoce
/// las clases concretas (`DriftAuditoriasDao`, `HigieneApiService`,
/// `ManosSegurasDb`) y las conecta entre sí. Todo lo demás pide
/// abstracciones: `getIt<AuditoriaRepository>()`.
///
/// ## El grafo de dependencias
///
/// ```
///   ManosSegurasDb  (singleton asíncrono)
///        ├── auditoriasDao   ──► AuditoriaRepositoryDrift      ──► AuditoriaRepository
///        ├── indicadoresDao  ──► IndicadorRepositoryOfflineFirst
///        │        ▲                        ▲
///        │        └── HigieneApiService ───┘
///        └── preferenciasDao ──► PreferenciasRepositoryDrift
///                                        ▲
///   TemaApp ─────────────────────────────┘
/// ```
///
/// ## Reglas del contenedor que conviene respetar
///
///  1. **Una sola instancia de la base** (`registerLazySingletonAsync`).
///     Abrir dos conexiones al mismo archivo SQLite provoca bloqueos
///     (`database is locked`).
///  2. **Dependencias perezosas.** Los repositorios no se construyen hasta
///     que alguien los pide.
///  3. **Nada de estado global mutable.** [getIt] se expone como variable
///     global por comodidad didáctica; en una aplicación grande conviene
///     pasar el `GetIt` por constructor o usar un `InheritedWidget`.
final GetIt getIt = GetIt.instance;

/// Registra todas las dependencias de la aplicación.
///
/// Se llama una sola vez, desde `main()`, y **antes** de `runApp`.
Future<void> configurarDependencias({
  /// Permite sustituir la base de datos en las pruebas y en la demostración
  /// en memoria sin tocar el resto del grafo.
  Future<ManosSegurasDb> Function()? abrirBase,
  bool usarRespaldoLocal = false,
}) async {
  if (getIt.isRegistered<ManosSegurasDb>()) {
    await getIt.reset();
  }

  // --- Capa de infraestructura: la base de datos ----------------------
  //
  // `registerLazySingletonAsync` acepta una función asíncrona; get_it
  // espera a que se complete antes de entregar la instancia a quien la
  // pida. Es lo que permite que `main()` haga `await getIt.allReady()`.
  //
  // TODO(reto-1a, mejora): agregue aquí el registro del sembrador de datos
  // (`SembradorDatos`) y de cualquier servicio nuevo que incorpore su
  // equipo, siempre **contra su interfaz del dominio**.
  //
  // La versión base registra la base local como singleton asíncrono.
  // `registerLazySingletonAsync` acepta una función asíncrona y get_it
  // espera a que se complete antes de entregar la instancia a quien la pida.
  getIt.registerLazySingletonAsync<ManosSegurasDb>(
    () => (abrirBase ?? abrirBaseDeDatos)(),
    dispose: (ManosSegurasDb base) => base.close(),
  );
}

/// Completa el grafo **después** de que la base está abierta.
///
/// Este método se entrega resuelto porque su patrón se repite en todas las
/// aplicaciones: cada DAO se construye sobre la MISMA instancia de la base y
/// cada repositorio se registra **contra su interfaz del dominio**, que es
/// la esencia del DIP de la Semana 9.
Future<void> _registrarRepositorios({
  required bool usarRespaldoLocal,
}) async {
  final ManosSegurasDb base = await getIt.getAsync<ManosSegurasDb>();
  final InfraestructuraLocal infra = InfraestructuraLocal(base);

  getIt
    ..registerSingleton<AuditoriasDao>(infra.auditoriasDao)
    ..registerSingleton<IndicadoresDao>(infra.indicadoresDao)
    ..registerSingleton<PreferenciasDao>(infra.preferenciasDao)
    ..registerSingleton<HigieneApiService>(
      HigieneApiService(usarRespaldoLocal: usarRespaldoLocal),
      dispose: (HigieneApiService servicio) => servicio.cerrar(),
    )
    ..registerLazySingleton<AuditoriaRepository>(
      () => AuditoriaRepositoryDrift(getIt<AuditoriasDao>()),
    )
    ..registerLazySingleton<IndicadorRepository>(
      () => IndicadorRepositoryOfflineFirst(
        dao: getIt<IndicadoresDao>(),
        servicio: getIt<HigieneApiService>(),
      ),
    )
    ..registerLazySingleton<PreferenciasRepository>(
      () => PreferenciasRepositoryDrift(getIt<PreferenciasDao>()),
    )
    ..registerLazySingleton<TemaApp>(
      () => TemaApp(getIt<PreferenciasRepository>()),
    )
    ..registerLazySingleton<SembradorDatos>(
      () => SembradorDatos(
        base: base,
        repositorio: getIt<AuditoriaRepository>(),
      ),
    );
}

/// Atajo para `main()` y para las pruebas: configura, espera a que todo esté
/// listo y devuelve la base ya abierta.
Future<ManosSegurasDb> iniciarDependencias({
  Future<ManosSegurasDb> Function()? abrirBase,
  bool usarRespaldoLocal = false,
}) async {
  await configurarDependencias(
    abrirBase: abrirBase,
    usarRespaldoLocal: usarRespaldoLocal,
  );
  await getIt.allReady();
  await _registrarRepositorios(usarRespaldoLocal: usarRespaldoLocal);
  return getIt.get<ManosSegurasDb>();
}
