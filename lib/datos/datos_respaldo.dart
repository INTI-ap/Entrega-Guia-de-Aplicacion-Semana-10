/// Datos de respaldo (*offline*) del indicador WSH_HYGIENE_BASIC para el
/// Perú, capturados del Observatorio Mundial de la Salud (OMS) el 24 de
/// setiembre de 2026.
///
/// Se usan como **plan B** cuando el laboratorio no tiene salida a
/// Internet: el servicio los devuelve pasando por el mismo constructor
/// `IndicadorHigiene.fromJson()`, de modo que la lógica de la aplicación
/// que se practica hoy es idéntica en ambos escenarios.
///
/// En la Unidad II estos datos se reemplazarán por un repositorio local
/// (drift/SQLite) aplicando el patrón *offline-first*.
library;

/// Registros crudos, con la misma forma que la respuesta del API.
const List<Map<String, dynamic>> indicadoresPeruCrudos = [
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2009,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 46.995566574,
    'Value': '47',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2010,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 46.995566574,
    'Value': '47',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2011,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 46.995566574,
    'Value': '47',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2012,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 46.995566574,
    'Value': '47',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2013,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 46.995566574,
    'Value': '47',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2014,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 49.293536785,
    'Value': '49',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2015,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 51.591506996,
    'Value': '52',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2016,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 53.889477207,
    'Value': '54',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2017,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 56.187447419,
    'Value': '56',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2018,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 58.48541763,
    'Value': '58',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2019,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 60.783387841,
    'Value': '61',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2020,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 63.081358052,
    'Value': '63',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2021,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 65.379328263,
    'Value': '65',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2022,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 67.677298475,
    'Value': '68',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2023,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 69.975268686,
    'Value': '70',
  },
  {
    'IndicatorCode': 'WSH_HYGIENE_BASIC',
    'SpatialDim': 'PER',
    'TimeDim': 2024,
    'Dim1': 'RESIDENCEAREATYPE_RUR',
    'NumericValue': 72.273238897,
    'Value': '72',
  },
];
