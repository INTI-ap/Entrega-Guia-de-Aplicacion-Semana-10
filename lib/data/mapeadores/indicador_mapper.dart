import 'package:drift/drift.dart' show Value;

import '../../domain/entidades/indicador_higiene.dart' as dm;
import '../local/manos_seguras_db.dart' as db;


/// Traduce el indicador de la OMS entre sus tres representaciones:
/// JSON del API → entidad de dominio → fila de `indicadores_cache`.
///
/// Es **defensivo**: cada campo se convierte con un método auxiliar que
/// tolera valores nulos o de tipo inesperado, de modo que un solo registro
/// malformado no tumbe toda la lista (lección de la Sesión 16).
///
/// Este archivo **no importa** `manos_seguras_db.dart`… salvo para los tipos
/// generados, que es inevitable. Por eso la base de datos no lo importa a
/// él, sino que usa la función [IndicadorMapper.desdeJson] directamente para
/// el respaldo. Esa asimetría es deliberada (ver `mapeadores.dart`).
abstract final class IndicadorMapper {
  static dm.IndicadorHigiene desdeJson(Map<String, dynamic> json) {
    return dm.IndicadorHigiene(
      codigoIndicador: json['IndicatorCode'] as String? ?? 'SIN_CODIGO',
      pais: json['SpatialDim'] as String? ?? 'N/D',
      anio: _aEntero(json['TimeDim']),
      ambito: _ambitoLegible(json['Dim1'] as String?),
      valor: _aDecimal(json['NumericValue']),
    );
  }

  static dm.IndicadorHigiene desdeFila(db.IndicadoresCacheData fila) {
    return dm.IndicadorHigiene(
      codigoIndicador: fila.codigoIndicador,
      pais: fila.pais,
      anio: fila.anio,
      ambito: fila.ambito,
      valor: fila.valor,
    );
  }

  static db.IndicadoresCacheCompanion aFila(
    dm.IndicadorHigiene indicador, {
    DateTime? descargadoEn,
  }) {
    return db.IndicadoresCacheCompanion.insert(
      clave: indicador.clave,
      codigoIndicador: indicador.codigoIndicador,
      pais: indicador.pais,
      anio: indicador.anio,
      ambito: indicador.ambito,
      valor: Value<double?>(indicador.valor),
      descargadoEn: Value<DateTime>(descargadoEn ?? DateTime.now()),
    );
  }

  static int _aEntero(Object? valorCrudo) {
    if (valorCrudo is int) return valorCrudo;
    if (valorCrudo is num) return valorCrudo.toInt();
    if (valorCrudo is String) return int.tryParse(valorCrudo) ?? 0;
    return 0;
  }

  static double? _aDecimal(Object? valorCrudo) {
    if (valorCrudo is num) return valorCrudo.toDouble();
    if (valorCrudo is String) return double.tryParse(valorCrudo);
    return null;
  }

  static String _ambitoLegible(String? dim1) {
    switch (dim1) {
      case 'RESIDENCEAREATYPE_RUR':
        return 'Rural';
      case 'RESIDENCEAREATYPE_URB':
        return 'Urbano';
      case 'RESIDENCEAREATYPE_TOTL':
        return 'Total';
      default:
        return 'No especificado';
    }
  }
}
