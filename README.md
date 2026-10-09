# ManosSeguras — Semana 10: Persistencia Local (Offline-First)

Proyecto Flutter del **proyecto integrador** de **SIS048 – Desarrollo de Software II**
(Universidad Andina del Cusco, semestre 2026-II), correspondiente a la
**Unidad de Aprendizaje II: Arquitectura Limpia, Persistencia y Gestión de
Estado Avanzada**.

Esta entrega implementa la **Guía de Aplicación N.° 07**:

| Temática del sílabo | Qué se implementa aquí |
|---|---|
| 2.2.1. SQL vs NoSQL en móvil: introducción a drift (SQLite) | `lib/data/local/` con drift sobre SQLite, más la tabla clave-valor `preferencias` para comparar ambos enfoques. |
| 2.2.2. Definición de tablas con drift | `lib/data/local/tablas/` — 7 tablas con claves primarias, claves foráneas, índices, valores por omisión y `nullable` explícito. |
| 2.2.3. Patrón DAO y migraciones básicas | `lib/data/local/daos/` + `InfraestructuraLocal` + `schemaVersion` y `MigrationStrategy` en `manos_seguras_db.dart`. |
| Repaso 2.1.2–2.1.3 (Semana 8) | Arquitectura por capas `domain/`, `data/`, `presentation/`. |
| Repaso 2.1.5–2.1.7 (Semana 9) | SRP, DIP y contenedor de inyección con `get_it`. |

Además, el proyecto **integra explícitamente lo construido en las semanas 8 y 9**:
el catálogo oficial de establecimientos, personal, Momentos y Acciones se
mantiene en el proyecto, y el consumo del API de la OMS de la Sesión 16 se
convierte en un repositorio *offline-first* con tres niveles de degradación.

## Cómo ejecutarlo

```bash
flutter --version      # verificado con Flutter 3.41.1 / Dart 3.11.0
flutter pub get
dart run build_runner build        # genera lib/data/local/manos_seguras_db.g.dart
flutter run
```

> **El paso de `build_runner` es obligatorio** cada vez que se modifica una
> tabla, un DAO o la `schemaVersion`. El archivo `*.g.dart` es código generado:
> no se edita a mano, pero **sí se versiona** en este repositorio para que el
> docente pueda leer el esquema sin ejecutar el generador.

## Cómo verificarlo

```bash
flutter analyze     # sin hallazgos
flutter test        # 67 pruebas: dominio, datos, preferencias y widget
```

Las pruebas **no necesitan Internet ni un emulador**: usan
`NativeDatabase.memory()` y `MockClient`.

## Estructura del proyecto

```
lib/
├── main.dart                        Arranque: DI + tema persistido + siembra
├── router/app_router.dart           Rutas (go_router) de todas las pantallas
├── core/
│   ├── fallos.dart                  Jerarquía sellada de errores del dominio
│   ├── id.dart                      UUID v4 y formateadores sin dependencias
│   ├── tema_app.dart                Preferencia de tema persistida en SQLite
│   └── theme/app_theme.dart         Tema institucional claro/oscuro
├── domain/                          ← capa Domain (Semana 8): Dart puro
│   ├── entidades/                   Auditoria, OportunidadRegistro, catalogos, …
│   ├── repositorios/                Contratos (AuditoriaRepository, …)
│   └── servicios/                   CalculadoraAdherencia
├── data/                            ← capa Data (Semana 8)
│   ├── local/
│   │   ├── tablas/                  Esquema drift (7 tablas)
│   │   ├── daos/                    Patrón DAO (Auditorias, Indicadores, Preferencias)
│   │   ├── aliases.dart             Alias públicos de las tablas generadas
│   │   ├── conexion.dart            Apertura del archivo .sqlite (o memoria)
│   │   ├── infraestructura.dart     Wiring de la base y sus DAO
│   │   ├── sembrador.dart           Datos de ejemplo reproducibles
│   │   └── manos_seguras_db.dart    @DriftDatabase, versión y migraciones
│   ├── mapeadores/                  Fila ↔ dominio  /  JSON ↔ dominio
│   ├── remoto/                      HigieneApiService (API de la OMS) + respaldo
│   └── repositorios/                Implementaciones de los contratos (offline-first)
└── presentation/                    ← capa Presentation (Semana 8)
    ├── di.dart                      Contenedor get_it (Semana 9)
    ├── pantallas/                   Bienvenida, establecimiento, oportunidades,
    │                                auditorías, detalle, indicadores, diagnóstico
    └── widgets/                     AppLayout, TarjetaBase, estados y tarjetas
```

## Modelo de datos

| Tabla | Filas que guarda | Clave primaria | Notas |
|---|---|---|---|
| `establecimientos` | Catálogo de IPRESS auditadas | `codigo_unico` (natural) | Coordenadas `nullable` |
| `personal` | Observadores y personal observado | `dni` | Discriminada por `rol` |
| `auditorias` | Cabecera de cada observación | `id` (UUID v4 local) | Borrado lógico (`eliminada`) |
| `oportunidades` | Una fila por Momento observado | `id` autoincremental | FK a `auditorias` con `ON DELETE CASCADE`, índice y `UNIQUE (auditoria_id, numero)` |
| `indicadores_cache` | Serie histórica de la OMS | `clave` (`PER|2024|Rural`) | Copia local para modo offline |
| `sincronizaciones` | Metadatos de descarga | `codigo` | Decide si la caché está vigente |
| `preferencias` | Almacén **clave-valor** | `clave` | Tema, último establecimiento |

## El patrón offline-first (Reto 2)

```
                  obtenerIndicadores()
                          │
   ¿caché vigente (< 24 h)? ──sí──► OrigenDatos.cacheLocal
                          │no
                          ▼
             HigieneApiService (API de la OMS)
                    │éxito          │fallo
                    ▼               ▼
        guardar + OrigenDatos.red    ¿hay caché vieja? ──sí──► cacheLocal
                                              │no
                                              ▼
                                     OrigenDatos.respaldo (assets)
```

La pantalla informa **siempre** el origen de los datos con `InsigniaOrigen`.

## Cómo inspeccionar la base de datos

```bash
# En Linux/macOS, la base vive en el directorio de documentos de la app.
sqlite3 manos_seguras.sqlite
sqlite> .tables
sqlite> SELECT id, establecimiento_nombre, estado FROM auditorias;
sqlite> PRAGMA foreign_keys;       -- debe devolver 1
sqlite> PRAGMA user_version;       -- versión del esquema
```

En la aplicación, la ruta `/diagnostico` muestra lo mismo en pantalla (conteo
de filas por tabla, estado de las claves foráneas, versión del esquema y
preferencias guardadas): es la evidencia más rápida para el informe.

## Los 5 retos

Cada reto tiene su punto de partida en el código, marcado con
`TODO(reto-n)` y con el detalle en la guía:

| Reto | Tema | Archivos de partida |
|---|---|---|
| 1 | Modelo de datos y ensamblado del grafo de dependencias | `domain/entidades/`, `data/local/tablas/`, `presentation/di.dart`, `core/tema_app.dart` |
| 2 | Caché offline-first con vigencia (TTL) | `data/local/daos/indicadores_dao.dart`, `data/repositorios/indicador_repository_offline_first.dart` |
| 3 | CRUD completo: edición, borrado lógico y restauración | `data/local/daos/auditorias_dao.dart`, `data/repositorios/auditoria_repository_drift.dart`, `presentation/pantallas/pantalla_auditorias.dart` |
| 4 | Migración de esquema v1 → v2 sin pérdida de datos | `data/local/manos_seguras_db.dart`, `test/data/migracion_test.dart` |
| 5 | Integridad referencial, índices y rendimiento | `data/local/tablas/oportunidades.dart`, `data/local/daos/auditorias_dao.dart`, `presentation/pantallas/pantalla_diagnostico.dart` |

## Entrega

1. **Repositorio en GitHub** con este proyecto. El `README.md` debe incluir:
   capturas, instrucciones de ejecución, la tabla de retos y el enlace al
   tablero de Scrum.
2. **Informe técnico** en el formato entregado por el docente
   (`Estructura_Informe_Tecnico_Semana10.docx`), con la sección de metodología
   ágil (Scrum: roles, backlog, sprints, tablero, velocidades y retrospectiva).
3. **Capturas o video** que evidencien: la aplicación funcionando, el listado
   local, el detalle, el origen de datos de la pantalla de indicadores y los
   resultados de `flutter test`.

## Nota sobre el uso de IA generativa

Se permite y recomienda usar asistentes de código para comprender errores y
explorar alternativas. En la revisión se pedirá modificar en vivo un fragmento
del código entregado: **código que el estudiante no puede explicar se califica
como no presentado**.

## Referencias principales

- drift. (s. f.). *Drift — Reactive persistence library for Flutter and Dart*.
  https://drift.simonbinder.eu/
- Flutter. (s. f.). *SQLite in Flutter* y *Persist data with SQLite*.
  https://docs.flutter.dev/cookbook/persistence/sqlite
- GeeksforGeeks. (2024, 7 de julio). *SQLite in Flutter*.
- Martin, R. C. (2018). *Clean Architecture: A Craftsman's Guide to Software
  Structure*. Prentice Hall.
- Organización Mundial de la Salud. (2026). *Global Health Observatory:
  indicador WSH_HYGIENE_BASIC*. https://www.who.int/data/gho


## Aporte del Reto 2: política de vigencia y resiliencia

Rama: `feature/reto-2-offline-first`. Historias asociadas: HU-05 (5 puntos) y
HU-07 (2 puntos); tarea T-04 y parte de T-06 del Sprint Semana 10,
del 6 al 9 de octubre de 2026.
Tablero: https://trello.com/b/rKcJwBEc/manosseguras-scrum-semana-10-base-2-06-09-oct-2026

| Recurso | Vigencia por defecto | Motivo |
|---|---|---|
| WSH_HYGIENE_BASIC | 24 horas | Reutilizar la serie anual y limitar consumo de red; revisarla diariamente. |
| establecimientos | 7 días | El catálogo cambia con menor frecuencia. |
| auditorias | 5 minutos | Las observaciones en curso cambian con mayor frecuencia. |

El mapa es inyectable. El repositorio de indicadores utiliza la política del
indicador OMS; los otros recursos tienen su política definida para que sus
repositorios la utilicen cuando se incorporen fuentes remotas. No se implementa
sincronización remota de auditorías ni establecimientos en este reto.
La caché expira cuando su edad alcanza el límite. Una marca futura o un recurso
sin política no se considera vigente.

`ResultadoIndicadores.datosObsoletos` advierte cuando se entrega una caché vencida
(o invalidada) después de un fallo remoto. La pantalla muestra una insignia ámbar
con advertencia; conserva la fecha real de descarga. El refresco forzado que falla
no vuelve obsoleta una caché que todavía está vigente. Sin datos locales, el
respaldo empaquetado evita una excepción por falta de red.

`invalidar(codigo)` establece la marca de sincronización en NULL sin eliminar
los datos, la fecha de descarga ni los fallos consecutivos. El contador aumenta
atómicamente por fallo y se reinicia en la misma transacción que reemplaza la
caché tras una descarga exitosa.

### Esquema y coordinación con Reto 4

La base recibida ya contiene el esquema v2 de los Retos 1 y 4. El Reto 2 introduce
v3: `sincronizaciones.intentos_fallidos` con valor inicial 0 y
`ultima_sincronizacion` nullable. La migración reconstruye únicamente esa tabla
con Drift y conserva sus filas; las migraciones v1 a v2 se mantienen.
Hay pruebas de v1 al esquema actual y de v2 a v3, incluyendo lectura y escritura
posteriores. Para revertir una instalación se necesita restaurar una copia de
seguridad compatible; no se implementa una migración descendente.

### Validación y evidencias

```bash
dart run build_runner build
flutter analyze --fatal-infos
flutter test
flutter test test/data/reto_2_offline_first_test.dart test/presentation/reto_2_indicadores_test.dart
```

Se añaden 11 pruebas de datos y 4 de pantalla: los cinco caminos exigidos,
contador de fallos, invalidación, aislamiento por recurso, límites de vigencia y
migración. Las pruebas no consultan Internet ni requieren emulador.

Las evidencias y la guía de inserción en el informe se conservan en un directorio
externo al proyecto. El repositorio contiene el código y las pruebas. Los renders
de widget permiten verificar automáticamente el origen, la fecha y la insignia;
las capturas del emulador y de la terminal documentan la ejecución del incremento.
Para exportar los renders de pruebas se puede definir `RETO2_EVIDENCIAS` con una
ruta externa; `RETO2_FUENTE` y `RETO2_ICONOS` permiten proporcionar fuentes locales.
