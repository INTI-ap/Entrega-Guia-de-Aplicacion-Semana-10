/// **Mapeadores entre la capa Data y la capa Domain.**
///
/// Semana 8 (Clean Architecture) + Semana 9 (SRP).
///
/// El dominio no conoce `drift`, ni `http`, ni `Map<String, dynamic>`. Toda
/// la conversión ocurre en esta capa, que es la única autorizada a cambiar
/// cuando cambie el formato del API o el esquema de la base.
///
/// Se usa el prefijo `db.` en el import para que el nombre de la fila
/// generada (`db.Auditoria`) no colisione con la entidad de dominio
/// (`Auditoria`). Es una técnica habitual y evita renombrar tablas.
///
/// Este archivo se separó en dos módulos (`indicador_mapper.dart` y
/// `auditoria_mapper.dart`) y aquí solo se reexportan. El motivo es
/// importante y se explica en la guía: `manos_seguras_db.dart` necesita
/// convertir filas durante el sembrado de datos, y **no puede importar un
/// archivo que forme parte de su propio ciclo de imports**. Separar los
/// mapeadores que no dependen de la base rompe ese ciclo.
library;

export 'auditoria_mapper.dart';
export 'indicador_mapper.dart';
