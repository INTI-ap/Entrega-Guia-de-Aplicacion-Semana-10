/// Servicio de dominio que convierte una lista de auditorías en las cifras
/// que muestran los tableros locales.
///
/// **SRP (Semana 9).** Ni la pantalla ni el repositorio deberían saber
/// cómo se calcula el promedio de adherencia: eso es una regla de negocio
/// y vive aquí. Es *plain Dart*, por lo que se prueba sin Flutter.
library;

import '../entidades/auditoria.dart';

class CalculadoraAdherencia {
  const CalculadoraAdherencia();

  /// Construye el resumen global a partir de auditorías ya cargadas con
  /// sus oportunidades.
  ///
  /// El promedio se calcula **solo** sobre auditorías con datos: incluir
  /// auditorías vacías (0 %) hundiría artificialmente el indicador.
  ResumenAdherencia resumir(List<Auditoria> auditorias) {
    final List<Auditoria> activas = auditorias
        .where((Auditoria a) => !a.eliminada)
        .toList();

    if (activas.isEmpty) return ResumenAdherencia.vacio();

    final List<Auditoria> conDatos = activas
        .where((Auditoria a) => a.tieneDatos)
        .toList();

    final int totalOportunidades = conDatos.fold<int>(
      0,
      (int suma, Auditoria a) => suma + a.totalOportunidades,
    );
    final int totalCumplidas = conDatos.fold<int>(
      0,
      (int suma, Auditoria a) => suma + a.oportunidadesCumplidas,
    );

    final DateTime ultima = activas
        .map((Auditoria a) => a.fecha)
        .reduce((DateTime a, DateTime b) => a.isAfter(b) ? a : b);

    return ResumenAdherencia(
      totalAuditorias: activas.length,
      totalOportunidades: totalOportunidades,
      totalCumplidas: totalCumplidas,
      promedioAdherencia: conDatos.isEmpty
          ? null
          : conDatos.fold<double>(
                  0,
                  (double s, Auditoria a) => s + a.porcentajeAdherencia,
                ) /
                conDatos.length,
      ultimaAuditoria: ultima,
    );
  }

  /// Agrupa el cumplimiento por Momento para el gráfico de barras del
  /// tablero local.
  ///
  /// **Reto 5 (opcional):** reescriba esta agregación como una consulta
  /// SQL con `GROUP BY` en `AuditoriasDao.resumenPorMomento()` y compare
  /// el rendimiento con 1 000 registros sembrados.
  Map<String, ({int total, int cumplidas})> porMomento(
    List<Auditoria> auditorias,
  ) {
    final Map<String, ({int total, int cumplidas})> acumulado =
        <String, ({int total, int cumplidas})>{};

    for (final Auditoria auditoria in auditorias) {
      if (auditoria.eliminada) continue;
      for (final oportunidad in auditoria.oportunidades) {
        final String clave = oportunidad.momento.clave;
        final actual =
            acumulado[clave] ?? (total: 0, cumplidas: 0);
        acumulado[clave] = (
          total: actual.total + 1,
          cumplidas: actual.cumplidas + (oportunidad.cumplio ? 1 : 0),
        );
      }
    }

    return acumulado;
  }
}
