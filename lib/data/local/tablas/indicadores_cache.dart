import 'package:drift/drift.dart';

/// Tabla `indicadores_cache`: copia local de la serie histórica del
/// indicador `WSH_HYGIENE_BASIC` (OMS).
///
/// **Semana 10 — temática 2.2.1-2.2.2 y núcleo del Reto 2.** Es la tabla
/// que convierte la pantalla "Contexto nacional" de la Sesión 16 en una
/// pantalla *offline-first*: la primera vez que hay Internet se descarga y
/// se guarda aquí; a partir de entonces la app abre con datos aunque no
/// haya red.
///
/// La clave primaria es un texto compuesto con el formato
/// `PER|2019|Rural`, construido por `IndicadorHigiene.clave`. Se prefirió
/// a una clave primaria de tres columnas porque simplifica el
/// `insertOnConflictUpdate` de drift y porque el domain ya expone esa
/// clave.
class IndicadoresCache extends Table {
  TextColumn get clave => text()();

  TextColumn get codigoIndicador => text()();
  TextColumn get pais => text()();
  IntColumn get anio => integer()();
  TextColumn get ambito => text()();

  /// `nullable()` porque el API entrega años sin dato (`NumericValue: null`).
  RealColumn get valor => real().nullable()();

  /// Momento exacto en que el registro se descargó del servicio.
  DateTimeColumn get descargadoEn =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{clave};
}

/// Tabla `sincronizaciones`: una fila por recurso remoto, con la fecha de
/// la última descarga exitosa.
///
/// **Por qué no basta `descargadoEn` en `indicadores_cache`.** Porque la
/// caché puede quedar parcialmente actualizada (el servicio devuelve 15 de
/// 16 registros); la marca de sincronización representa el resultado de la
/// *operación completa* y es la que decide si la caché está vigente.
/// Separar "dato" de "metadato de sincronización" es una decisión de
/// normalización explicable en el informe.
class Sincronizaciones extends Table {
  /// Código del recurso: 'WSH_HYGIENE_BASIC', 'establecimientos', etc.
  TextColumn get codigo => text()();

  DateTimeColumn get ultimaSincronizacion => dateTime()();

  /// Cantidad de registros escritos en la última descarga exitosa.
  IntColumn get registros => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{codigo};
}
