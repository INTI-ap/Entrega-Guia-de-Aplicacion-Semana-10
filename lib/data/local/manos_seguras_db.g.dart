// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manos_seguras_db.dart';

// ignore_for_file: type=lint
class $EstablecimientosTable extends Establecimientos
    with TableInfo<$EstablecimientosTable, Establecimiento> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EstablecimientosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codigoUnicoMeta = const VerificationMeta(
    'codigoUnico',
  );
  @override
  late final GeneratedColumn<String> codigoUnico = GeneratedColumn<String>(
    'codigo_unico',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaMeta = const VerificationMeta(
    'categoria',
  );
  @override
  late final GeneratedColumn<String> categoria = GeneratedColumn<String>(
    'categoria',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _redMeta = const VerificationMeta('red');
  @override
  late final GeneratedColumn<String> red = GeneratedColumn<String>(
    'red',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _microredMeta = const VerificationMeta(
    'microred',
  );
  @override
  late final GeneratedColumn<String> microred = GeneratedColumn<String>(
    'microred',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _departamentoMeta = const VerificationMeta(
    'departamento',
  );
  @override
  late final GeneratedColumn<String> departamento = GeneratedColumn<String>(
    'departamento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _provinciaMeta = const VerificationMeta(
    'provincia',
  );
  @override
  late final GeneratedColumn<String> provincia = GeneratedColumn<String>(
    'provincia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _distritoMeta = const VerificationMeta(
    'distrito',
  );
  @override
  late final GeneratedColumn<String> distrito = GeneratedColumn<String>(
    'distrito',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _latitudMeta = const VerificationMeta(
    'latitud',
  );
  @override
  late final GeneratedColumn<double> latitud = GeneratedColumn<double>(
    'latitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudMeta = const VerificationMeta(
    'longitud',
  );
  @override
  late final GeneratedColumn<double> longitud = GeneratedColumn<double>(
    'longitud',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    codigoUnico,
    nombre,
    categoria,
    red,
    microred,
    departamento,
    provincia,
    distrito,
    latitud,
    longitud,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'establecimientos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Establecimiento> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('codigo_unico')) {
      context.handle(
        _codigoUnicoMeta,
        codigoUnico.isAcceptableOrUnknown(
          data['codigo_unico']!,
          _codigoUnicoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_codigoUnicoMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('categoria')) {
      context.handle(
        _categoriaMeta,
        categoria.isAcceptableOrUnknown(data['categoria']!, _categoriaMeta),
      );
    } else if (isInserting) {
      context.missing(_categoriaMeta);
    }
    if (data.containsKey('red')) {
      context.handle(
        _redMeta,
        red.isAcceptableOrUnknown(data['red']!, _redMeta),
      );
    }
    if (data.containsKey('microred')) {
      context.handle(
        _microredMeta,
        microred.isAcceptableOrUnknown(data['microred']!, _microredMeta),
      );
    }
    if (data.containsKey('departamento')) {
      context.handle(
        _departamentoMeta,
        departamento.isAcceptableOrUnknown(
          data['departamento']!,
          _departamentoMeta,
        ),
      );
    }
    if (data.containsKey('provincia')) {
      context.handle(
        _provinciaMeta,
        provincia.isAcceptableOrUnknown(data['provincia']!, _provinciaMeta),
      );
    }
    if (data.containsKey('distrito')) {
      context.handle(
        _distritoMeta,
        distrito.isAcceptableOrUnknown(data['distrito']!, _distritoMeta),
      );
    }
    if (data.containsKey('latitud')) {
      context.handle(
        _latitudMeta,
        latitud.isAcceptableOrUnknown(data['latitud']!, _latitudMeta),
      );
    }
    if (data.containsKey('longitud')) {
      context.handle(
        _longitudMeta,
        longitud.isAcceptableOrUnknown(data['longitud']!, _longitudMeta),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {codigoUnico};
  @override
  Establecimiento map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Establecimiento(
      codigoUnico: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_unico'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      categoria: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria'],
      )!,
      red: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}red'],
      )!,
      microred: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}microred'],
      )!,
      departamento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}departamento'],
      )!,
      provincia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provincia'],
      )!,
      distrito: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}distrito'],
      )!,
      latitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitud'],
      ),
      longitud: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitud'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $EstablecimientosTable createAlias(String alias) {
    return $EstablecimientosTable(attachedDatabase, alias);
  }
}

class Establecimiento extends DataClass implements Insertable<Establecimiento> {
  /// Clave primaria natural: el `CODIGO_UNICO` del formulario oficial.
  /// Se usa `text()` y no un autoincremental porque el código lo asigna
  /// el MINSA, no la aplicación.
  final String codigoUnico;
  final String nombre;

  /// Nivel de complejidad: 'I-1' … 'III-2'.
  final String categoria;
  final String red;
  final String microred;
  final String departamento;
  final String provincia;
  final String distrito;

  /// `nullable()` porque no toda auditoría captura coordenadas.
  final double? latitud;
  final double? longitud;
  final DateTime creadoEn;
  const Establecimiento({
    required this.codigoUnico,
    required this.nombre,
    required this.categoria,
    required this.red,
    required this.microred,
    required this.departamento,
    required this.provincia,
    required this.distrito,
    this.latitud,
    this.longitud,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['codigo_unico'] = Variable<String>(codigoUnico);
    map['nombre'] = Variable<String>(nombre);
    map['categoria'] = Variable<String>(categoria);
    map['red'] = Variable<String>(red);
    map['microred'] = Variable<String>(microred);
    map['departamento'] = Variable<String>(departamento);
    map['provincia'] = Variable<String>(provincia);
    map['distrito'] = Variable<String>(distrito);
    if (!nullToAbsent || latitud != null) {
      map['latitud'] = Variable<double>(latitud);
    }
    if (!nullToAbsent || longitud != null) {
      map['longitud'] = Variable<double>(longitud);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  EstablecimientosCompanion toCompanion(bool nullToAbsent) {
    return EstablecimientosCompanion(
      codigoUnico: Value(codigoUnico),
      nombre: Value(nombre),
      categoria: Value(categoria),
      red: Value(red),
      microred: Value(microred),
      departamento: Value(departamento),
      provincia: Value(provincia),
      distrito: Value(distrito),
      latitud: latitud == null && nullToAbsent
          ? const Value.absent()
          : Value(latitud),
      longitud: longitud == null && nullToAbsent
          ? const Value.absent()
          : Value(longitud),
      creadoEn: Value(creadoEn),
    );
  }

  factory Establecimiento.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Establecimiento(
      codigoUnico: serializer.fromJson<String>(json['codigoUnico']),
      nombre: serializer.fromJson<String>(json['nombre']),
      categoria: serializer.fromJson<String>(json['categoria']),
      red: serializer.fromJson<String>(json['red']),
      microred: serializer.fromJson<String>(json['microred']),
      departamento: serializer.fromJson<String>(json['departamento']),
      provincia: serializer.fromJson<String>(json['provincia']),
      distrito: serializer.fromJson<String>(json['distrito']),
      latitud: serializer.fromJson<double?>(json['latitud']),
      longitud: serializer.fromJson<double?>(json['longitud']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'codigoUnico': serializer.toJson<String>(codigoUnico),
      'nombre': serializer.toJson<String>(nombre),
      'categoria': serializer.toJson<String>(categoria),
      'red': serializer.toJson<String>(red),
      'microred': serializer.toJson<String>(microred),
      'departamento': serializer.toJson<String>(departamento),
      'provincia': serializer.toJson<String>(provincia),
      'distrito': serializer.toJson<String>(distrito),
      'latitud': serializer.toJson<double?>(latitud),
      'longitud': serializer.toJson<double?>(longitud),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  Establecimiento copyWith({
    String? codigoUnico,
    String? nombre,
    String? categoria,
    String? red,
    String? microred,
    String? departamento,
    String? provincia,
    String? distrito,
    Value<double?> latitud = const Value.absent(),
    Value<double?> longitud = const Value.absent(),
    DateTime? creadoEn,
  }) => Establecimiento(
    codigoUnico: codigoUnico ?? this.codigoUnico,
    nombre: nombre ?? this.nombre,
    categoria: categoria ?? this.categoria,
    red: red ?? this.red,
    microred: microred ?? this.microred,
    departamento: departamento ?? this.departamento,
    provincia: provincia ?? this.provincia,
    distrito: distrito ?? this.distrito,
    latitud: latitud.present ? latitud.value : this.latitud,
    longitud: longitud.present ? longitud.value : this.longitud,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  Establecimiento copyWithCompanion(EstablecimientosCompanion data) {
    return Establecimiento(
      codigoUnico: data.codigoUnico.present
          ? data.codigoUnico.value
          : this.codigoUnico,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      categoria: data.categoria.present ? data.categoria.value : this.categoria,
      red: data.red.present ? data.red.value : this.red,
      microred: data.microred.present ? data.microred.value : this.microred,
      departamento: data.departamento.present
          ? data.departamento.value
          : this.departamento,
      provincia: data.provincia.present ? data.provincia.value : this.provincia,
      distrito: data.distrito.present ? data.distrito.value : this.distrito,
      latitud: data.latitud.present ? data.latitud.value : this.latitud,
      longitud: data.longitud.present ? data.longitud.value : this.longitud,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Establecimiento(')
          ..write('codigoUnico: $codigoUnico, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('red: $red, ')
          ..write('microred: $microred, ')
          ..write('departamento: $departamento, ')
          ..write('provincia: $provincia, ')
          ..write('distrito: $distrito, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    codigoUnico,
    nombre,
    categoria,
    red,
    microred,
    departamento,
    provincia,
    distrito,
    latitud,
    longitud,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Establecimiento &&
          other.codigoUnico == this.codigoUnico &&
          other.nombre == this.nombre &&
          other.categoria == this.categoria &&
          other.red == this.red &&
          other.microred == this.microred &&
          other.departamento == this.departamento &&
          other.provincia == this.provincia &&
          other.distrito == this.distrito &&
          other.latitud == this.latitud &&
          other.longitud == this.longitud &&
          other.creadoEn == this.creadoEn);
}

class EstablecimientosCompanion extends UpdateCompanion<Establecimiento> {
  final Value<String> codigoUnico;
  final Value<String> nombre;
  final Value<String> categoria;
  final Value<String> red;
  final Value<String> microred;
  final Value<String> departamento;
  final Value<String> provincia;
  final Value<String> distrito;
  final Value<double?> latitud;
  final Value<double?> longitud;
  final Value<DateTime> creadoEn;
  final Value<int> rowid;
  const EstablecimientosCompanion({
    this.codigoUnico = const Value.absent(),
    this.nombre = const Value.absent(),
    this.categoria = const Value.absent(),
    this.red = const Value.absent(),
    this.microred = const Value.absent(),
    this.departamento = const Value.absent(),
    this.provincia = const Value.absent(),
    this.distrito = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EstablecimientosCompanion.insert({
    required String codigoUnico,
    required String nombre,
    required String categoria,
    this.red = const Value.absent(),
    this.microred = const Value.absent(),
    this.departamento = const Value.absent(),
    this.provincia = const Value.absent(),
    this.distrito = const Value.absent(),
    this.latitud = const Value.absent(),
    this.longitud = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : codigoUnico = Value(codigoUnico),
       nombre = Value(nombre),
       categoria = Value(categoria);
  static Insertable<Establecimiento> custom({
    Expression<String>? codigoUnico,
    Expression<String>? nombre,
    Expression<String>? categoria,
    Expression<String>? red,
    Expression<String>? microred,
    Expression<String>? departamento,
    Expression<String>? provincia,
    Expression<String>? distrito,
    Expression<double>? latitud,
    Expression<double>? longitud,
    Expression<DateTime>? creadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (codigoUnico != null) 'codigo_unico': codigoUnico,
      if (nombre != null) 'nombre': nombre,
      if (categoria != null) 'categoria': categoria,
      if (red != null) 'red': red,
      if (microred != null) 'microred': microred,
      if (departamento != null) 'departamento': departamento,
      if (provincia != null) 'provincia': provincia,
      if (distrito != null) 'distrito': distrito,
      if (latitud != null) 'latitud': latitud,
      if (longitud != null) 'longitud': longitud,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EstablecimientosCompanion copyWith({
    Value<String>? codigoUnico,
    Value<String>? nombre,
    Value<String>? categoria,
    Value<String>? red,
    Value<String>? microred,
    Value<String>? departamento,
    Value<String>? provincia,
    Value<String>? distrito,
    Value<double?>? latitud,
    Value<double?>? longitud,
    Value<DateTime>? creadoEn,
    Value<int>? rowid,
  }) {
    return EstablecimientosCompanion(
      codigoUnico: codigoUnico ?? this.codigoUnico,
      nombre: nombre ?? this.nombre,
      categoria: categoria ?? this.categoria,
      red: red ?? this.red,
      microred: microred ?? this.microred,
      departamento: departamento ?? this.departamento,
      provincia: provincia ?? this.provincia,
      distrito: distrito ?? this.distrito,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      creadoEn: creadoEn ?? this.creadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (codigoUnico.present) {
      map['codigo_unico'] = Variable<String>(codigoUnico.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (categoria.present) {
      map['categoria'] = Variable<String>(categoria.value);
    }
    if (red.present) {
      map['red'] = Variable<String>(red.value);
    }
    if (microred.present) {
      map['microred'] = Variable<String>(microred.value);
    }
    if (departamento.present) {
      map['departamento'] = Variable<String>(departamento.value);
    }
    if (provincia.present) {
      map['provincia'] = Variable<String>(provincia.value);
    }
    if (distrito.present) {
      map['distrito'] = Variable<String>(distrito.value);
    }
    if (latitud.present) {
      map['latitud'] = Variable<double>(latitud.value);
    }
    if (longitud.present) {
      map['longitud'] = Variable<double>(longitud.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EstablecimientosCompanion(')
          ..write('codigoUnico: $codigoUnico, ')
          ..write('nombre: $nombre, ')
          ..write('categoria: $categoria, ')
          ..write('red: $red, ')
          ..write('microred: $microred, ')
          ..write('departamento: $departamento, ')
          ..write('provincia: $provincia, ')
          ..write('distrito: $distrito, ')
          ..write('latitud: $latitud, ')
          ..write('longitud: $longitud, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalTable extends Personal
    with TableInfo<$PersonalTable, PersonalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dniMeta = const VerificationMeta('dni');
  @override
  late final GeneratedColumn<String> dni = GeneratedColumn<String>(
    'dni',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 8,
      maxTextLength: 8,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombresApellidosMeta = const VerificationMeta(
    'nombresApellidos',
  );
  @override
  late final GeneratedColumn<String> nombresApellidos = GeneratedColumn<String>(
    'nombres_apellidos',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 150,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rolMeta = const VerificationMeta('rol');
  @override
  late final GeneratedColumn<String> rol = GeneratedColumn<String>(
    'rol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('observado'),
  );
  static const VerificationMeta _categoriaProfesionalMeta =
      const VerificationMeta('categoriaProfesional');
  @override
  late final GeneratedColumn<String> categoriaProfesional =
      GeneratedColumn<String>(
        'categoria_profesional',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _servicioMedicoMeta = const VerificationMeta(
    'servicioMedico',
  );
  @override
  late final GeneratedColumn<String> servicioMedico = GeneratedColumn<String>(
    'servicio_medico',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    dni,
    nombresApellidos,
    rol,
    categoriaProfesional,
    servicioMedico,
    creadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dni')) {
      context.handle(
        _dniMeta,
        dni.isAcceptableOrUnknown(data['dni']!, _dniMeta),
      );
    } else if (isInserting) {
      context.missing(_dniMeta);
    }
    if (data.containsKey('nombres_apellidos')) {
      context.handle(
        _nombresApellidosMeta,
        nombresApellidos.isAcceptableOrUnknown(
          data['nombres_apellidos']!,
          _nombresApellidosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombresApellidosMeta);
    }
    if (data.containsKey('rol')) {
      context.handle(
        _rolMeta,
        rol.isAcceptableOrUnknown(data['rol']!, _rolMeta),
      );
    }
    if (data.containsKey('categoria_profesional')) {
      context.handle(
        _categoriaProfesionalMeta,
        categoriaProfesional.isAcceptableOrUnknown(
          data['categoria_profesional']!,
          _categoriaProfesionalMeta,
        ),
      );
    }
    if (data.containsKey('servicio_medico')) {
      context.handle(
        _servicioMedicoMeta,
        servicioMedico.isAcceptableOrUnknown(
          data['servicio_medico']!,
          _servicioMedicoMeta,
        ),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dni};
  @override
  PersonalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalData(
      dni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dni'],
      )!,
      nombresApellidos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombres_apellidos'],
      )!,
      rol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rol'],
      )!,
      categoriaProfesional: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria_profesional'],
      ),
      servicioMedico: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}servicio_medico'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
    );
  }

  @override
  $PersonalTable createAlias(String alias) {
    return $PersonalTable(attachedDatabase, alias);
  }
}

class PersonalData extends DataClass implements Insertable<PersonalData> {
  final String dni;
  final String nombresApellidos;

  /// 'observador' | 'observado'.
  final String rol;

  /// Solo aplica al rol 'observado'; queda `null` para los observadores.
  final String? categoriaProfesional;
  final String? servicioMedico;
  final DateTime creadoEn;
  const PersonalData({
    required this.dni,
    required this.nombresApellidos,
    required this.rol,
    this.categoriaProfesional,
    this.servicioMedico,
    required this.creadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dni'] = Variable<String>(dni);
    map['nombres_apellidos'] = Variable<String>(nombresApellidos);
    map['rol'] = Variable<String>(rol);
    if (!nullToAbsent || categoriaProfesional != null) {
      map['categoria_profesional'] = Variable<String>(categoriaProfesional);
    }
    if (!nullToAbsent || servicioMedico != null) {
      map['servicio_medico'] = Variable<String>(servicioMedico);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    return map;
  }

  PersonalCompanion toCompanion(bool nullToAbsent) {
    return PersonalCompanion(
      dni: Value(dni),
      nombresApellidos: Value(nombresApellidos),
      rol: Value(rol),
      categoriaProfesional: categoriaProfesional == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaProfesional),
      servicioMedico: servicioMedico == null && nullToAbsent
          ? const Value.absent()
          : Value(servicioMedico),
      creadoEn: Value(creadoEn),
    );
  }

  factory PersonalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalData(
      dni: serializer.fromJson<String>(json['dni']),
      nombresApellidos: serializer.fromJson<String>(json['nombresApellidos']),
      rol: serializer.fromJson<String>(json['rol']),
      categoriaProfesional: serializer.fromJson<String?>(
        json['categoriaProfesional'],
      ),
      servicioMedico: serializer.fromJson<String?>(json['servicioMedico']),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dni': serializer.toJson<String>(dni),
      'nombresApellidos': serializer.toJson<String>(nombresApellidos),
      'rol': serializer.toJson<String>(rol),
      'categoriaProfesional': serializer.toJson<String?>(categoriaProfesional),
      'servicioMedico': serializer.toJson<String?>(servicioMedico),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
    };
  }

  PersonalData copyWith({
    String? dni,
    String? nombresApellidos,
    String? rol,
    Value<String?> categoriaProfesional = const Value.absent(),
    Value<String?> servicioMedico = const Value.absent(),
    DateTime? creadoEn,
  }) => PersonalData(
    dni: dni ?? this.dni,
    nombresApellidos: nombresApellidos ?? this.nombresApellidos,
    rol: rol ?? this.rol,
    categoriaProfesional: categoriaProfesional.present
        ? categoriaProfesional.value
        : this.categoriaProfesional,
    servicioMedico: servicioMedico.present
        ? servicioMedico.value
        : this.servicioMedico,
    creadoEn: creadoEn ?? this.creadoEn,
  );
  PersonalData copyWithCompanion(PersonalCompanion data) {
    return PersonalData(
      dni: data.dni.present ? data.dni.value : this.dni,
      nombresApellidos: data.nombresApellidos.present
          ? data.nombresApellidos.value
          : this.nombresApellidos,
      rol: data.rol.present ? data.rol.value : this.rol,
      categoriaProfesional: data.categoriaProfesional.present
          ? data.categoriaProfesional.value
          : this.categoriaProfesional,
      servicioMedico: data.servicioMedico.present
          ? data.servicioMedico.value
          : this.servicioMedico,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalData(')
          ..write('dni: $dni, ')
          ..write('nombresApellidos: $nombresApellidos, ')
          ..write('rol: $rol, ')
          ..write('categoriaProfesional: $categoriaProfesional, ')
          ..write('servicioMedico: $servicioMedico, ')
          ..write('creadoEn: $creadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    dni,
    nombresApellidos,
    rol,
    categoriaProfesional,
    servicioMedico,
    creadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalData &&
          other.dni == this.dni &&
          other.nombresApellidos == this.nombresApellidos &&
          other.rol == this.rol &&
          other.categoriaProfesional == this.categoriaProfesional &&
          other.servicioMedico == this.servicioMedico &&
          other.creadoEn == this.creadoEn);
}

class PersonalCompanion extends UpdateCompanion<PersonalData> {
  final Value<String> dni;
  final Value<String> nombresApellidos;
  final Value<String> rol;
  final Value<String?> categoriaProfesional;
  final Value<String?> servicioMedico;
  final Value<DateTime> creadoEn;
  final Value<int> rowid;
  const PersonalCompanion({
    this.dni = const Value.absent(),
    this.nombresApellidos = const Value.absent(),
    this.rol = const Value.absent(),
    this.categoriaProfesional = const Value.absent(),
    this.servicioMedico = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalCompanion.insert({
    required String dni,
    required String nombresApellidos,
    this.rol = const Value.absent(),
    this.categoriaProfesional = const Value.absent(),
    this.servicioMedico = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : dni = Value(dni),
       nombresApellidos = Value(nombresApellidos);
  static Insertable<PersonalData> custom({
    Expression<String>? dni,
    Expression<String>? nombresApellidos,
    Expression<String>? rol,
    Expression<String>? categoriaProfesional,
    Expression<String>? servicioMedico,
    Expression<DateTime>? creadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dni != null) 'dni': dni,
      if (nombresApellidos != null) 'nombres_apellidos': nombresApellidos,
      if (rol != null) 'rol': rol,
      if (categoriaProfesional != null)
        'categoria_profesional': categoriaProfesional,
      if (servicioMedico != null) 'servicio_medico': servicioMedico,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalCompanion copyWith({
    Value<String>? dni,
    Value<String>? nombresApellidos,
    Value<String>? rol,
    Value<String?>? categoriaProfesional,
    Value<String?>? servicioMedico,
    Value<DateTime>? creadoEn,
    Value<int>? rowid,
  }) {
    return PersonalCompanion(
      dni: dni ?? this.dni,
      nombresApellidos: nombresApellidos ?? this.nombresApellidos,
      rol: rol ?? this.rol,
      categoriaProfesional: categoriaProfesional ?? this.categoriaProfesional,
      servicioMedico: servicioMedico ?? this.servicioMedico,
      creadoEn: creadoEn ?? this.creadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dni.present) {
      map['dni'] = Variable<String>(dni.value);
    }
    if (nombresApellidos.present) {
      map['nombres_apellidos'] = Variable<String>(nombresApellidos.value);
    }
    if (rol.present) {
      map['rol'] = Variable<String>(rol.value);
    }
    if (categoriaProfesional.present) {
      map['categoria_profesional'] = Variable<String>(
        categoriaProfesional.value,
      );
    }
    if (servicioMedico.present) {
      map['servicio_medico'] = Variable<String>(servicioMedico.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalCompanion(')
          ..write('dni: $dni, ')
          ..write('nombresApellidos: $nombresApellidos, ')
          ..write('rol: $rol, ')
          ..write('categoriaProfesional: $categoriaProfesional, ')
          ..write('servicioMedico: $servicioMedico, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditoriasTable extends Auditorias
    with TableInfo<$AuditoriasTable, Auditoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditoriasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _establecimientoIdMeta = const VerificationMeta(
    'establecimientoId',
  );
  @override
  late final GeneratedColumn<String> establecimientoId =
      GeneratedColumn<String>(
        'establecimiento_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES establecimientos (codigo_unico) ON DELETE RESTRICT',
        ),
      );
  static const VerificationMeta _establecimientoNombreMeta =
      const VerificationMeta('establecimientoNombre');
  @override
  late final GeneratedColumn<String> establecimientoNombre =
      GeneratedColumn<String>(
        'establecimiento_nombre',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _observadorDniMeta = const VerificationMeta(
    'observadorDni',
  );
  @override
  late final GeneratedColumn<String> observadorDni = GeneratedColumn<String>(
    'observador_dni',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personal (dni) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _observadorNombreMeta = const VerificationMeta(
    'observadorNombre',
  );
  @override
  late final GeneratedColumn<String> observadorNombre = GeneratedColumn<String>(
    'observador_nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observadoDniMeta = const VerificationMeta(
    'observadoDni',
  );
  @override
  late final GeneratedColumn<String> observadoDni = GeneratedColumn<String>(
    'observado_dni',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES personal (dni) ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _observadoNombreMeta = const VerificationMeta(
    'observadoNombre',
  );
  @override
  late final GeneratedColumn<String> observadoNombre = GeneratedColumn<String>(
    'observado_nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<String> estado = GeneratedColumn<String>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('borrador'),
  );
  static const VerificationMeta _eliminadaMeta = const VerificationMeta(
    'eliminada',
  );
  @override
  late final GeneratedColumn<bool> eliminada = GeneratedColumn<bool>(
    'eliminada',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("eliminada" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sincronizadaEnMeta = const VerificationMeta(
    'sincronizadaEn',
  );
  @override
  late final GeneratedColumn<DateTime> sincronizadaEn =
      GeneratedColumn<DateTime>(
        'sincronizada_en',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _fechaInicioMeta = const VerificationMeta(
    'fechaInicio',
  );
  @override
  late final GeneratedColumn<DateTime> fechaInicio = GeneratedColumn<DateTime>(
    'fecha_inicio',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaFinMeta = const VerificationMeta(
    'fechaFin',
  );
  @override
  late final GeneratedColumn<DateTime> fechaFin = GeneratedColumn<DateTime>(
    'fecha_fin',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _numeroCamasMeta = const VerificationMeta(
    'numeroCamas',
  );
  @override
  late final GeneratedColumn<int> numeroCamas = GeneratedColumn<int>(
    'numero_camas',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _consentimientoVerbalMeta =
      const VerificationMeta('consentimientoVerbal');
  @override
  late final GeneratedColumn<bool> consentimientoVerbal = GeneratedColumn<bool>(
    'consentimiento_verbal',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("consentimiento_verbal" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _observacionGeneralMeta =
      const VerificationMeta('observacionGeneral');
  @override
  late final GeneratedColumn<String> observacionGeneral =
      GeneratedColumn<String>(
        'observacion_general',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _creadoEnMeta = const VerificationMeta(
    'creadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> creadoEn = GeneratedColumn<DateTime>(
    'creado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    establecimientoId,
    establecimientoNombre,
    observadorDni,
    observadorNombre,
    observadoDni,
    observadoNombre,
    fecha,
    estado,
    eliminada,
    sincronizadaEn,
    fechaInicio,
    fechaFin,
    numeroCamas,
    consentimientoVerbal,
    observacionGeneral,
    creadoEn,
    actualizadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auditorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Auditoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('establecimiento_id')) {
      context.handle(
        _establecimientoIdMeta,
        establecimientoId.isAcceptableOrUnknown(
          data['establecimiento_id']!,
          _establecimientoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_establecimientoIdMeta);
    }
    if (data.containsKey('establecimiento_nombre')) {
      context.handle(
        _establecimientoNombreMeta,
        establecimientoNombre.isAcceptableOrUnknown(
          data['establecimiento_nombre']!,
          _establecimientoNombreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_establecimientoNombreMeta);
    }
    if (data.containsKey('observador_dni')) {
      context.handle(
        _observadorDniMeta,
        observadorDni.isAcceptableOrUnknown(
          data['observador_dni']!,
          _observadorDniMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observadorDniMeta);
    }
    if (data.containsKey('observador_nombre')) {
      context.handle(
        _observadorNombreMeta,
        observadorNombre.isAcceptableOrUnknown(
          data['observador_nombre']!,
          _observadorNombreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observadorNombreMeta);
    }
    if (data.containsKey('observado_dni')) {
      context.handle(
        _observadoDniMeta,
        observadoDni.isAcceptableOrUnknown(
          data['observado_dni']!,
          _observadoDniMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observadoDniMeta);
    }
    if (data.containsKey('observado_nombre')) {
      context.handle(
        _observadoNombreMeta,
        observadoNombre.isAcceptableOrUnknown(
          data['observado_nombre']!,
          _observadoNombreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_observadoNombreMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    }
    if (data.containsKey('eliminada')) {
      context.handle(
        _eliminadaMeta,
        eliminada.isAcceptableOrUnknown(data['eliminada']!, _eliminadaMeta),
      );
    }
    if (data.containsKey('sincronizada_en')) {
      context.handle(
        _sincronizadaEnMeta,
        sincronizadaEn.isAcceptableOrUnknown(
          data['sincronizada_en']!,
          _sincronizadaEnMeta,
        ),
      );
    }
    if (data.containsKey('fecha_inicio')) {
      context.handle(
        _fechaInicioMeta,
        fechaInicio.isAcceptableOrUnknown(
          data['fecha_inicio']!,
          _fechaInicioMeta,
        ),
      );
    }
    if (data.containsKey('fecha_fin')) {
      context.handle(
        _fechaFinMeta,
        fechaFin.isAcceptableOrUnknown(data['fecha_fin']!, _fechaFinMeta),
      );
    }
    if (data.containsKey('numero_camas')) {
      context.handle(
        _numeroCamasMeta,
        numeroCamas.isAcceptableOrUnknown(
          data['numero_camas']!,
          _numeroCamasMeta,
        ),
      );
    }
    if (data.containsKey('consentimiento_verbal')) {
      context.handle(
        _consentimientoVerbalMeta,
        consentimientoVerbal.isAcceptableOrUnknown(
          data['consentimiento_verbal']!,
          _consentimientoVerbalMeta,
        ),
      );
    }
    if (data.containsKey('observacion_general')) {
      context.handle(
        _observacionGeneralMeta,
        observacionGeneral.isAcceptableOrUnknown(
          data['observacion_general']!,
          _observacionGeneralMeta,
        ),
      );
    }
    if (data.containsKey('creado_en')) {
      context.handle(
        _creadoEnMeta,
        creadoEn.isAcceptableOrUnknown(data['creado_en']!, _creadoEnMeta),
      );
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Auditoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Auditoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      establecimientoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establecimiento_id'],
      )!,
      establecimientoNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}establecimiento_nombre'],
      )!,
      observadorDni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observador_dni'],
      )!,
      observadorNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observador_nombre'],
      )!,
      observadoDni: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observado_dni'],
      )!,
      observadoNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observado_nombre'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado'],
      )!,
      eliminada: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}eliminada'],
      )!,
      sincronizadaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sincronizada_en'],
      ),
      fechaInicio: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_inicio'],
      ),
      fechaFin: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha_fin'],
      ),
      numeroCamas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero_camas'],
      ),
      consentimientoVerbal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}consentimiento_verbal'],
      ),
      observacionGeneral: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion_general'],
      ),
      creadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}creado_en'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $AuditoriasTable createAlias(String alias) {
    return $AuditoriasTable(attachedDatabase, alias);
  }
}

class Auditoria extends DataClass implements Insertable<Auditoria> {
  final String id;
  final String establecimientoId;

  /// Nombre desnormalizado (trade-off documentado): evita un JOIN en el
  /// listado offline y conserva el nombre histórico del establecimiento.
  final String establecimientoNombre;
  final String observadorDni;
  final String observadorNombre;
  final String observadoDni;
  final String observadoNombre;
  final DateTime fecha;

  /// 'borrador' | 'finalizada' | 'sincronizada'.
  final String estado;

  /// Borrado lógico.
  final bool eliminada;

  /// Marca temporal del último envío exitoso al servidor.
  final DateTime? sincronizadaEn;

  /// Campos requeridos por el formulario oficial (Reto 1):
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final int? numeroCamas;
  final bool? consentimientoVerbal;

  /// Observación general de la auditoría (Reto 4):
  final String? observacionGeneral;
  final DateTime creadoEn;
  final DateTime actualizadoEn;
  const Auditoria({
    required this.id,
    required this.establecimientoId,
    required this.establecimientoNombre,
    required this.observadorDni,
    required this.observadorNombre,
    required this.observadoDni,
    required this.observadoNombre,
    required this.fecha,
    required this.estado,
    required this.eliminada,
    this.sincronizadaEn,
    this.fechaInicio,
    this.fechaFin,
    this.numeroCamas,
    this.consentimientoVerbal,
    this.observacionGeneral,
    required this.creadoEn,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['establecimiento_id'] = Variable<String>(establecimientoId);
    map['establecimiento_nombre'] = Variable<String>(establecimientoNombre);
    map['observador_dni'] = Variable<String>(observadorDni);
    map['observador_nombre'] = Variable<String>(observadorNombre);
    map['observado_dni'] = Variable<String>(observadoDni);
    map['observado_nombre'] = Variable<String>(observadoNombre);
    map['fecha'] = Variable<DateTime>(fecha);
    map['estado'] = Variable<String>(estado);
    map['eliminada'] = Variable<bool>(eliminada);
    if (!nullToAbsent || sincronizadaEn != null) {
      map['sincronizada_en'] = Variable<DateTime>(sincronizadaEn);
    }
    if (!nullToAbsent || fechaInicio != null) {
      map['fecha_inicio'] = Variable<DateTime>(fechaInicio);
    }
    if (!nullToAbsent || fechaFin != null) {
      map['fecha_fin'] = Variable<DateTime>(fechaFin);
    }
    if (!nullToAbsent || numeroCamas != null) {
      map['numero_camas'] = Variable<int>(numeroCamas);
    }
    if (!nullToAbsent || consentimientoVerbal != null) {
      map['consentimiento_verbal'] = Variable<bool>(consentimientoVerbal);
    }
    if (!nullToAbsent || observacionGeneral != null) {
      map['observacion_general'] = Variable<String>(observacionGeneral);
    }
    map['creado_en'] = Variable<DateTime>(creadoEn);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  AuditoriasCompanion toCompanion(bool nullToAbsent) {
    return AuditoriasCompanion(
      id: Value(id),
      establecimientoId: Value(establecimientoId),
      establecimientoNombre: Value(establecimientoNombre),
      observadorDni: Value(observadorDni),
      observadorNombre: Value(observadorNombre),
      observadoDni: Value(observadoDni),
      observadoNombre: Value(observadoNombre),
      fecha: Value(fecha),
      estado: Value(estado),
      eliminada: Value(eliminada),
      sincronizadaEn: sincronizadaEn == null && nullToAbsent
          ? const Value.absent()
          : Value(sincronizadaEn),
      fechaInicio: fechaInicio == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaInicio),
      fechaFin: fechaFin == null && nullToAbsent
          ? const Value.absent()
          : Value(fechaFin),
      numeroCamas: numeroCamas == null && nullToAbsent
          ? const Value.absent()
          : Value(numeroCamas),
      consentimientoVerbal: consentimientoVerbal == null && nullToAbsent
          ? const Value.absent()
          : Value(consentimientoVerbal),
      observacionGeneral: observacionGeneral == null && nullToAbsent
          ? const Value.absent()
          : Value(observacionGeneral),
      creadoEn: Value(creadoEn),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory Auditoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Auditoria(
      id: serializer.fromJson<String>(json['id']),
      establecimientoId: serializer.fromJson<String>(json['establecimientoId']),
      establecimientoNombre: serializer.fromJson<String>(
        json['establecimientoNombre'],
      ),
      observadorDni: serializer.fromJson<String>(json['observadorDni']),
      observadorNombre: serializer.fromJson<String>(json['observadorNombre']),
      observadoDni: serializer.fromJson<String>(json['observadoDni']),
      observadoNombre: serializer.fromJson<String>(json['observadoNombre']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      estado: serializer.fromJson<String>(json['estado']),
      eliminada: serializer.fromJson<bool>(json['eliminada']),
      sincronizadaEn: serializer.fromJson<DateTime?>(json['sincronizadaEn']),
      fechaInicio: serializer.fromJson<DateTime?>(json['fechaInicio']),
      fechaFin: serializer.fromJson<DateTime?>(json['fechaFin']),
      numeroCamas: serializer.fromJson<int?>(json['numeroCamas']),
      consentimientoVerbal: serializer.fromJson<bool?>(
        json['consentimientoVerbal'],
      ),
      observacionGeneral: serializer.fromJson<String?>(
        json['observacionGeneral'],
      ),
      creadoEn: serializer.fromJson<DateTime>(json['creadoEn']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'establecimientoId': serializer.toJson<String>(establecimientoId),
      'establecimientoNombre': serializer.toJson<String>(establecimientoNombre),
      'observadorDni': serializer.toJson<String>(observadorDni),
      'observadorNombre': serializer.toJson<String>(observadorNombre),
      'observadoDni': serializer.toJson<String>(observadoDni),
      'observadoNombre': serializer.toJson<String>(observadoNombre),
      'fecha': serializer.toJson<DateTime>(fecha),
      'estado': serializer.toJson<String>(estado),
      'eliminada': serializer.toJson<bool>(eliminada),
      'sincronizadaEn': serializer.toJson<DateTime?>(sincronizadaEn),
      'fechaInicio': serializer.toJson<DateTime?>(fechaInicio),
      'fechaFin': serializer.toJson<DateTime?>(fechaFin),
      'numeroCamas': serializer.toJson<int?>(numeroCamas),
      'consentimientoVerbal': serializer.toJson<bool?>(consentimientoVerbal),
      'observacionGeneral': serializer.toJson<String?>(observacionGeneral),
      'creadoEn': serializer.toJson<DateTime>(creadoEn),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  Auditoria copyWith({
    String? id,
    String? establecimientoId,
    String? establecimientoNombre,
    String? observadorDni,
    String? observadorNombre,
    String? observadoDni,
    String? observadoNombre,
    DateTime? fecha,
    String? estado,
    bool? eliminada,
    Value<DateTime?> sincronizadaEn = const Value.absent(),
    Value<DateTime?> fechaInicio = const Value.absent(),
    Value<DateTime?> fechaFin = const Value.absent(),
    Value<int?> numeroCamas = const Value.absent(),
    Value<bool?> consentimientoVerbal = const Value.absent(),
    Value<String?> observacionGeneral = const Value.absent(),
    DateTime? creadoEn,
    DateTime? actualizadoEn,
  }) => Auditoria(
    id: id ?? this.id,
    establecimientoId: establecimientoId ?? this.establecimientoId,
    establecimientoNombre: establecimientoNombre ?? this.establecimientoNombre,
    observadorDni: observadorDni ?? this.observadorDni,
    observadorNombre: observadorNombre ?? this.observadorNombre,
    observadoDni: observadoDni ?? this.observadoDni,
    observadoNombre: observadoNombre ?? this.observadoNombre,
    fecha: fecha ?? this.fecha,
    estado: estado ?? this.estado,
    eliminada: eliminada ?? this.eliminada,
    sincronizadaEn: sincronizadaEn.present
        ? sincronizadaEn.value
        : this.sincronizadaEn,
    fechaInicio: fechaInicio.present ? fechaInicio.value : this.fechaInicio,
    fechaFin: fechaFin.present ? fechaFin.value : this.fechaFin,
    numeroCamas: numeroCamas.present ? numeroCamas.value : this.numeroCamas,
    consentimientoVerbal: consentimientoVerbal.present
        ? consentimientoVerbal.value
        : this.consentimientoVerbal,
    observacionGeneral: observacionGeneral.present
        ? observacionGeneral.value
        : this.observacionGeneral,
    creadoEn: creadoEn ?? this.creadoEn,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  Auditoria copyWithCompanion(AuditoriasCompanion data) {
    return Auditoria(
      id: data.id.present ? data.id.value : this.id,
      establecimientoId: data.establecimientoId.present
          ? data.establecimientoId.value
          : this.establecimientoId,
      establecimientoNombre: data.establecimientoNombre.present
          ? data.establecimientoNombre.value
          : this.establecimientoNombre,
      observadorDni: data.observadorDni.present
          ? data.observadorDni.value
          : this.observadorDni,
      observadorNombre: data.observadorNombre.present
          ? data.observadorNombre.value
          : this.observadorNombre,
      observadoDni: data.observadoDni.present
          ? data.observadoDni.value
          : this.observadoDni,
      observadoNombre: data.observadoNombre.present
          ? data.observadoNombre.value
          : this.observadoNombre,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      estado: data.estado.present ? data.estado.value : this.estado,
      eliminada: data.eliminada.present ? data.eliminada.value : this.eliminada,
      sincronizadaEn: data.sincronizadaEn.present
          ? data.sincronizadaEn.value
          : this.sincronizadaEn,
      fechaInicio: data.fechaInicio.present
          ? data.fechaInicio.value
          : this.fechaInicio,
      fechaFin: data.fechaFin.present ? data.fechaFin.value : this.fechaFin,
      numeroCamas: data.numeroCamas.present
          ? data.numeroCamas.value
          : this.numeroCamas,
      consentimientoVerbal: data.consentimientoVerbal.present
          ? data.consentimientoVerbal.value
          : this.consentimientoVerbal,
      observacionGeneral: data.observacionGeneral.present
          ? data.observacionGeneral.value
          : this.observacionGeneral,
      creadoEn: data.creadoEn.present ? data.creadoEn.value : this.creadoEn,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Auditoria(')
          ..write('id: $id, ')
          ..write('establecimientoId: $establecimientoId, ')
          ..write('establecimientoNombre: $establecimientoNombre, ')
          ..write('observadorDni: $observadorDni, ')
          ..write('observadorNombre: $observadorNombre, ')
          ..write('observadoDni: $observadoDni, ')
          ..write('observadoNombre: $observadoNombre, ')
          ..write('fecha: $fecha, ')
          ..write('estado: $estado, ')
          ..write('eliminada: $eliminada, ')
          ..write('sincronizadaEn: $sincronizadaEn, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('numeroCamas: $numeroCamas, ')
          ..write('consentimientoVerbal: $consentimientoVerbal, ')
          ..write('observacionGeneral: $observacionGeneral, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    establecimientoId,
    establecimientoNombre,
    observadorDni,
    observadorNombre,
    observadoDni,
    observadoNombre,
    fecha,
    estado,
    eliminada,
    sincronizadaEn,
    fechaInicio,
    fechaFin,
    numeroCamas,
    consentimientoVerbal,
    observacionGeneral,
    creadoEn,
    actualizadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Auditoria &&
          other.id == this.id &&
          other.establecimientoId == this.establecimientoId &&
          other.establecimientoNombre == this.establecimientoNombre &&
          other.observadorDni == this.observadorDni &&
          other.observadorNombre == this.observadorNombre &&
          other.observadoDni == this.observadoDni &&
          other.observadoNombre == this.observadoNombre &&
          other.fecha == this.fecha &&
          other.estado == this.estado &&
          other.eliminada == this.eliminada &&
          other.sincronizadaEn == this.sincronizadaEn &&
          other.fechaInicio == this.fechaInicio &&
          other.fechaFin == this.fechaFin &&
          other.numeroCamas == this.numeroCamas &&
          other.consentimientoVerbal == this.consentimientoVerbal &&
          other.observacionGeneral == this.observacionGeneral &&
          other.creadoEn == this.creadoEn &&
          other.actualizadoEn == this.actualizadoEn);
}

class AuditoriasCompanion extends UpdateCompanion<Auditoria> {
  final Value<String> id;
  final Value<String> establecimientoId;
  final Value<String> establecimientoNombre;
  final Value<String> observadorDni;
  final Value<String> observadorNombre;
  final Value<String> observadoDni;
  final Value<String> observadoNombre;
  final Value<DateTime> fecha;
  final Value<String> estado;
  final Value<bool> eliminada;
  final Value<DateTime?> sincronizadaEn;
  final Value<DateTime?> fechaInicio;
  final Value<DateTime?> fechaFin;
  final Value<int?> numeroCamas;
  final Value<bool?> consentimientoVerbal;
  final Value<String?> observacionGeneral;
  final Value<DateTime> creadoEn;
  final Value<DateTime> actualizadoEn;
  final Value<int> rowid;
  const AuditoriasCompanion({
    this.id = const Value.absent(),
    this.establecimientoId = const Value.absent(),
    this.establecimientoNombre = const Value.absent(),
    this.observadorDni = const Value.absent(),
    this.observadorNombre = const Value.absent(),
    this.observadoDni = const Value.absent(),
    this.observadoNombre = const Value.absent(),
    this.fecha = const Value.absent(),
    this.estado = const Value.absent(),
    this.eliminada = const Value.absent(),
    this.sincronizadaEn = const Value.absent(),
    this.fechaInicio = const Value.absent(),
    this.fechaFin = const Value.absent(),
    this.numeroCamas = const Value.absent(),
    this.consentimientoVerbal = const Value.absent(),
    this.observacionGeneral = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AuditoriasCompanion.insert({
    required String id,
    required String establecimientoId,
    required String establecimientoNombre,
    required String observadorDni,
    required String observadorNombre,
    required String observadoDni,
    required String observadoNombre,
    required DateTime fecha,
    this.estado = const Value.absent(),
    this.eliminada = const Value.absent(),
    this.sincronizadaEn = const Value.absent(),
    this.fechaInicio = const Value.absent(),
    this.fechaFin = const Value.absent(),
    this.numeroCamas = const Value.absent(),
    this.consentimientoVerbal = const Value.absent(),
    this.observacionGeneral = const Value.absent(),
    this.creadoEn = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       establecimientoId = Value(establecimientoId),
       establecimientoNombre = Value(establecimientoNombre),
       observadorDni = Value(observadorDni),
       observadorNombre = Value(observadorNombre),
       observadoDni = Value(observadoDni),
       observadoNombre = Value(observadoNombre),
       fecha = Value(fecha);
  static Insertable<Auditoria> custom({
    Expression<String>? id,
    Expression<String>? establecimientoId,
    Expression<String>? establecimientoNombre,
    Expression<String>? observadorDni,
    Expression<String>? observadorNombre,
    Expression<String>? observadoDni,
    Expression<String>? observadoNombre,
    Expression<DateTime>? fecha,
    Expression<String>? estado,
    Expression<bool>? eliminada,
    Expression<DateTime>? sincronizadaEn,
    Expression<DateTime>? fechaInicio,
    Expression<DateTime>? fechaFin,
    Expression<int>? numeroCamas,
    Expression<bool>? consentimientoVerbal,
    Expression<String>? observacionGeneral,
    Expression<DateTime>? creadoEn,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (establecimientoId != null) 'establecimiento_id': establecimientoId,
      if (establecimientoNombre != null)
        'establecimiento_nombre': establecimientoNombre,
      if (observadorDni != null) 'observador_dni': observadorDni,
      if (observadorNombre != null) 'observador_nombre': observadorNombre,
      if (observadoDni != null) 'observado_dni': observadoDni,
      if (observadoNombre != null) 'observado_nombre': observadoNombre,
      if (fecha != null) 'fecha': fecha,
      if (estado != null) 'estado': estado,
      if (eliminada != null) 'eliminada': eliminada,
      if (sincronizadaEn != null) 'sincronizada_en': sincronizadaEn,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio,
      if (fechaFin != null) 'fecha_fin': fechaFin,
      if (numeroCamas != null) 'numero_camas': numeroCamas,
      if (consentimientoVerbal != null)
        'consentimiento_verbal': consentimientoVerbal,
      if (observacionGeneral != null) 'observacion_general': observacionGeneral,
      if (creadoEn != null) 'creado_en': creadoEn,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AuditoriasCompanion copyWith({
    Value<String>? id,
    Value<String>? establecimientoId,
    Value<String>? establecimientoNombre,
    Value<String>? observadorDni,
    Value<String>? observadorNombre,
    Value<String>? observadoDni,
    Value<String>? observadoNombre,
    Value<DateTime>? fecha,
    Value<String>? estado,
    Value<bool>? eliminada,
    Value<DateTime?>? sincronizadaEn,
    Value<DateTime?>? fechaInicio,
    Value<DateTime?>? fechaFin,
    Value<int?>? numeroCamas,
    Value<bool?>? consentimientoVerbal,
    Value<String?>? observacionGeneral,
    Value<DateTime>? creadoEn,
    Value<DateTime>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return AuditoriasCompanion(
      id: id ?? this.id,
      establecimientoId: establecimientoId ?? this.establecimientoId,
      establecimientoNombre:
          establecimientoNombre ?? this.establecimientoNombre,
      observadorDni: observadorDni ?? this.observadorDni,
      observadorNombre: observadorNombre ?? this.observadorNombre,
      observadoDni: observadoDni ?? this.observadoDni,
      observadoNombre: observadoNombre ?? this.observadoNombre,
      fecha: fecha ?? this.fecha,
      estado: estado ?? this.estado,
      eliminada: eliminada ?? this.eliminada,
      sincronizadaEn: sincronizadaEn ?? this.sincronizadaEn,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      numeroCamas: numeroCamas ?? this.numeroCamas,
      consentimientoVerbal: consentimientoVerbal ?? this.consentimientoVerbal,
      observacionGeneral: observacionGeneral ?? this.observacionGeneral,
      creadoEn: creadoEn ?? this.creadoEn,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (establecimientoId.present) {
      map['establecimiento_id'] = Variable<String>(establecimientoId.value);
    }
    if (establecimientoNombre.present) {
      map['establecimiento_nombre'] = Variable<String>(
        establecimientoNombre.value,
      );
    }
    if (observadorDni.present) {
      map['observador_dni'] = Variable<String>(observadorDni.value);
    }
    if (observadorNombre.present) {
      map['observador_nombre'] = Variable<String>(observadorNombre.value);
    }
    if (observadoDni.present) {
      map['observado_dni'] = Variable<String>(observadoDni.value);
    }
    if (observadoNombre.present) {
      map['observado_nombre'] = Variable<String>(observadoNombre.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (estado.present) {
      map['estado'] = Variable<String>(estado.value);
    }
    if (eliminada.present) {
      map['eliminada'] = Variable<bool>(eliminada.value);
    }
    if (sincronizadaEn.present) {
      map['sincronizada_en'] = Variable<DateTime>(sincronizadaEn.value);
    }
    if (fechaInicio.present) {
      map['fecha_inicio'] = Variable<DateTime>(fechaInicio.value);
    }
    if (fechaFin.present) {
      map['fecha_fin'] = Variable<DateTime>(fechaFin.value);
    }
    if (numeroCamas.present) {
      map['numero_camas'] = Variable<int>(numeroCamas.value);
    }
    if (consentimientoVerbal.present) {
      map['consentimiento_verbal'] = Variable<bool>(consentimientoVerbal.value);
    }
    if (observacionGeneral.present) {
      map['observacion_general'] = Variable<String>(observacionGeneral.value);
    }
    if (creadoEn.present) {
      map['creado_en'] = Variable<DateTime>(creadoEn.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditoriasCompanion(')
          ..write('id: $id, ')
          ..write('establecimientoId: $establecimientoId, ')
          ..write('establecimientoNombre: $establecimientoNombre, ')
          ..write('observadorDni: $observadorDni, ')
          ..write('observadorNombre: $observadorNombre, ')
          ..write('observadoDni: $observadoDni, ')
          ..write('observadoNombre: $observadoNombre, ')
          ..write('fecha: $fecha, ')
          ..write('estado: $estado, ')
          ..write('eliminada: $eliminada, ')
          ..write('sincronizadaEn: $sincronizadaEn, ')
          ..write('fechaInicio: $fechaInicio, ')
          ..write('fechaFin: $fechaFin, ')
          ..write('numeroCamas: $numeroCamas, ')
          ..write('consentimientoVerbal: $consentimientoVerbal, ')
          ..write('observacionGeneral: $observacionGeneral, ')
          ..write('creadoEn: $creadoEn, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AuditoriasHistorialTable extends AuditoriasHistorial
    with TableInfo<$AuditoriasHistorialTable, AuditoriasHistorialData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditoriasHistorialTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _auditoriaIdMeta = const VerificationMeta(
    'auditoriaId',
  );
  @override
  late final GeneratedColumn<String> auditoriaId = GeneratedColumn<String>(
    'auditoria_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES auditorias (id)',
    ),
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campoMeta = const VerificationMeta('campo');
  @override
  late final GeneratedColumn<String> campo = GeneratedColumn<String>(
    'campo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorAnteriorMeta = const VerificationMeta(
    'valorAnterior',
  );
  @override
  late final GeneratedColumn<String> valorAnterior = GeneratedColumn<String>(
    'valor_anterior',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valorNuevoMeta = const VerificationMeta(
    'valorNuevo',
  );
  @override
  late final GeneratedColumn<String> valorNuevo = GeneratedColumn<String>(
    'valor_nuevo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditoriaId,
    fecha,
    campo,
    valorAnterior,
    valorNuevo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'auditorias_historial';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditoriasHistorialData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('auditoria_id')) {
      context.handle(
        _auditoriaIdMeta,
        auditoriaId.isAcceptableOrUnknown(
          data['auditoria_id']!,
          _auditoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_auditoriaIdMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('campo')) {
      context.handle(
        _campoMeta,
        campo.isAcceptableOrUnknown(data['campo']!, _campoMeta),
      );
    } else if (isInserting) {
      context.missing(_campoMeta);
    }
    if (data.containsKey('valor_anterior')) {
      context.handle(
        _valorAnteriorMeta,
        valorAnterior.isAcceptableOrUnknown(
          data['valor_anterior']!,
          _valorAnteriorMeta,
        ),
      );
    }
    if (data.containsKey('valor_nuevo')) {
      context.handle(
        _valorNuevoMeta,
        valorNuevo.isAcceptableOrUnknown(data['valor_nuevo']!, _valorNuevoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditoriasHistorialData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditoriasHistorialData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      auditoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auditoria_id'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      campo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campo'],
      )!,
      valorAnterior: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor_anterior'],
      ),
      valorNuevo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor_nuevo'],
      ),
    );
  }

  @override
  $AuditoriasHistorialTable createAlias(String alias) {
    return $AuditoriasHistorialTable(attachedDatabase, alias);
  }
}

class AuditoriasHistorialData extends DataClass
    implements Insertable<AuditoriasHistorialData> {
  final int id;
  final String auditoriaId;
  final DateTime fecha;
  final String campo;
  final String? valorAnterior;
  final String? valorNuevo;
  const AuditoriasHistorialData({
    required this.id,
    required this.auditoriaId,
    required this.fecha,
    required this.campo,
    this.valorAnterior,
    this.valorNuevo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['auditoria_id'] = Variable<String>(auditoriaId);
    map['fecha'] = Variable<DateTime>(fecha);
    map['campo'] = Variable<String>(campo);
    if (!nullToAbsent || valorAnterior != null) {
      map['valor_anterior'] = Variable<String>(valorAnterior);
    }
    if (!nullToAbsent || valorNuevo != null) {
      map['valor_nuevo'] = Variable<String>(valorNuevo);
    }
    return map;
  }

  AuditoriasHistorialCompanion toCompanion(bool nullToAbsent) {
    return AuditoriasHistorialCompanion(
      id: Value(id),
      auditoriaId: Value(auditoriaId),
      fecha: Value(fecha),
      campo: Value(campo),
      valorAnterior: valorAnterior == null && nullToAbsent
          ? const Value.absent()
          : Value(valorAnterior),
      valorNuevo: valorNuevo == null && nullToAbsent
          ? const Value.absent()
          : Value(valorNuevo),
    );
  }

  factory AuditoriasHistorialData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditoriasHistorialData(
      id: serializer.fromJson<int>(json['id']),
      auditoriaId: serializer.fromJson<String>(json['auditoriaId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      campo: serializer.fromJson<String>(json['campo']),
      valorAnterior: serializer.fromJson<String?>(json['valorAnterior']),
      valorNuevo: serializer.fromJson<String?>(json['valorNuevo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'auditoriaId': serializer.toJson<String>(auditoriaId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'campo': serializer.toJson<String>(campo),
      'valorAnterior': serializer.toJson<String?>(valorAnterior),
      'valorNuevo': serializer.toJson<String?>(valorNuevo),
    };
  }

  AuditoriasHistorialData copyWith({
    int? id,
    String? auditoriaId,
    DateTime? fecha,
    String? campo,
    Value<String?> valorAnterior = const Value.absent(),
    Value<String?> valorNuevo = const Value.absent(),
  }) => AuditoriasHistorialData(
    id: id ?? this.id,
    auditoriaId: auditoriaId ?? this.auditoriaId,
    fecha: fecha ?? this.fecha,
    campo: campo ?? this.campo,
    valorAnterior: valorAnterior.present
        ? valorAnterior.value
        : this.valorAnterior,
    valorNuevo: valorNuevo.present ? valorNuevo.value : this.valorNuevo,
  );
  AuditoriasHistorialData copyWithCompanion(AuditoriasHistorialCompanion data) {
    return AuditoriasHistorialData(
      id: data.id.present ? data.id.value : this.id,
      auditoriaId: data.auditoriaId.present
          ? data.auditoriaId.value
          : this.auditoriaId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      campo: data.campo.present ? data.campo.value : this.campo,
      valorAnterior: data.valorAnterior.present
          ? data.valorAnterior.value
          : this.valorAnterior,
      valorNuevo: data.valorNuevo.present
          ? data.valorNuevo.value
          : this.valorNuevo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditoriasHistorialData(')
          ..write('id: $id, ')
          ..write('auditoriaId: $auditoriaId, ')
          ..write('fecha: $fecha, ')
          ..write('campo: $campo, ')
          ..write('valorAnterior: $valorAnterior, ')
          ..write('valorNuevo: $valorNuevo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, auditoriaId, fecha, campo, valorAnterior, valorNuevo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditoriasHistorialData &&
          other.id == this.id &&
          other.auditoriaId == this.auditoriaId &&
          other.fecha == this.fecha &&
          other.campo == this.campo &&
          other.valorAnterior == this.valorAnterior &&
          other.valorNuevo == this.valorNuevo);
}

class AuditoriasHistorialCompanion
    extends UpdateCompanion<AuditoriasHistorialData> {
  final Value<int> id;
  final Value<String> auditoriaId;
  final Value<DateTime> fecha;
  final Value<String> campo;
  final Value<String?> valorAnterior;
  final Value<String?> valorNuevo;
  const AuditoriasHistorialCompanion({
    this.id = const Value.absent(),
    this.auditoriaId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.campo = const Value.absent(),
    this.valorAnterior = const Value.absent(),
    this.valorNuevo = const Value.absent(),
  });
  AuditoriasHistorialCompanion.insert({
    this.id = const Value.absent(),
    required String auditoriaId,
    required DateTime fecha,
    required String campo,
    this.valorAnterior = const Value.absent(),
    this.valorNuevo = const Value.absent(),
  }) : auditoriaId = Value(auditoriaId),
       fecha = Value(fecha),
       campo = Value(campo);
  static Insertable<AuditoriasHistorialData> custom({
    Expression<int>? id,
    Expression<String>? auditoriaId,
    Expression<DateTime>? fecha,
    Expression<String>? campo,
    Expression<String>? valorAnterior,
    Expression<String>? valorNuevo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditoriaId != null) 'auditoria_id': auditoriaId,
      if (fecha != null) 'fecha': fecha,
      if (campo != null) 'campo': campo,
      if (valorAnterior != null) 'valor_anterior': valorAnterior,
      if (valorNuevo != null) 'valor_nuevo': valorNuevo,
    });
  }

  AuditoriasHistorialCompanion copyWith({
    Value<int>? id,
    Value<String>? auditoriaId,
    Value<DateTime>? fecha,
    Value<String>? campo,
    Value<String?>? valorAnterior,
    Value<String?>? valorNuevo,
  }) {
    return AuditoriasHistorialCompanion(
      id: id ?? this.id,
      auditoriaId: auditoriaId ?? this.auditoriaId,
      fecha: fecha ?? this.fecha,
      campo: campo ?? this.campo,
      valorAnterior: valorAnterior ?? this.valorAnterior,
      valorNuevo: valorNuevo ?? this.valorNuevo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (auditoriaId.present) {
      map['auditoria_id'] = Variable<String>(auditoriaId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (campo.present) {
      map['campo'] = Variable<String>(campo.value);
    }
    if (valorAnterior.present) {
      map['valor_anterior'] = Variable<String>(valorAnterior.value);
    }
    if (valorNuevo.present) {
      map['valor_nuevo'] = Variable<String>(valorNuevo.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditoriasHistorialCompanion(')
          ..write('id: $id, ')
          ..write('auditoriaId: $auditoriaId, ')
          ..write('fecha: $fecha, ')
          ..write('campo: $campo, ')
          ..write('valorAnterior: $valorAnterior, ')
          ..write('valorNuevo: $valorNuevo')
          ..write(')'))
        .toString();
  }
}

class $OportunidadesTable extends Oportunidades
    with TableInfo<$OportunidadesTable, Oportunidade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OportunidadesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _auditoriaIdMeta = const VerificationMeta(
    'auditoriaId',
  );
  @override
  late final GeneratedColumn<String> auditoriaId = GeneratedColumn<String>(
    'auditoria_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES auditorias (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _numeroMeta = const VerificationMeta('numero');
  @override
  late final GeneratedColumn<int> numero = GeneratedColumn<int>(
    'numero',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _momentoClaveMeta = const VerificationMeta(
    'momentoClave',
  );
  @override
  late final GeneratedColumn<String> momentoClave = GeneratedColumn<String>(
    'momento_clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accionClaveMeta = const VerificationMeta(
    'accionClave',
  );
  @override
  late final GeneratedColumn<String> accionClave = GeneratedColumn<String>(
    'accion_clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observacionMeta = const VerificationMeta(
    'observacion',
  );
  @override
  late final GeneratedColumn<String> observacion = GeneratedColumn<String>(
    'observacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _duracionSegundosMeta = const VerificationMeta(
    'duracionSegundos',
  );
  @override
  late final GeneratedColumn<int> duracionSegundos = GeneratedColumn<int>(
    'duracion_segundos',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _registradoEnMeta = const VerificationMeta(
    'registradoEn',
  );
  @override
  late final GeneratedColumn<DateTime> registradoEn = GeneratedColumn<DateTime>(
    'registrado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditoriaId,
    numero,
    momentoClave,
    accionClave,
    observacion,
    duracionSegundos,
    registradoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'oportunidades';
  @override
  VerificationContext validateIntegrity(
    Insertable<Oportunidade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('auditoria_id')) {
      context.handle(
        _auditoriaIdMeta,
        auditoriaId.isAcceptableOrUnknown(
          data['auditoria_id']!,
          _auditoriaIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_auditoriaIdMeta);
    }
    if (data.containsKey('numero')) {
      context.handle(
        _numeroMeta,
        numero.isAcceptableOrUnknown(data['numero']!, _numeroMeta),
      );
    } else if (isInserting) {
      context.missing(_numeroMeta);
    }
    if (data.containsKey('momento_clave')) {
      context.handle(
        _momentoClaveMeta,
        momentoClave.isAcceptableOrUnknown(
          data['momento_clave']!,
          _momentoClaveMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_momentoClaveMeta);
    }
    if (data.containsKey('accion_clave')) {
      context.handle(
        _accionClaveMeta,
        accionClave.isAcceptableOrUnknown(
          data['accion_clave']!,
          _accionClaveMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accionClaveMeta);
    }
    if (data.containsKey('observacion')) {
      context.handle(
        _observacionMeta,
        observacion.isAcceptableOrUnknown(
          data['observacion']!,
          _observacionMeta,
        ),
      );
    }
    if (data.containsKey('duracion_segundos')) {
      context.handle(
        _duracionSegundosMeta,
        duracionSegundos.isAcceptableOrUnknown(
          data['duracion_segundos']!,
          _duracionSegundosMeta,
        ),
      );
    }
    if (data.containsKey('registrado_en')) {
      context.handle(
        _registradoEnMeta,
        registradoEn.isAcceptableOrUnknown(
          data['registrado_en']!,
          _registradoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {auditoriaId, numero},
  ];
  @override
  Oportunidade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Oportunidade(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      auditoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}auditoria_id'],
      )!,
      numero: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}numero'],
      )!,
      momentoClave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}momento_clave'],
      )!,
      accionClave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accion_clave'],
      )!,
      observacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observacion'],
      ),
      duracionSegundos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duracion_segundos'],
      ),
      registradoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}registrado_en'],
      )!,
    );
  }

  @override
  $OportunidadesTable createAlias(String alias) {
    return $OportunidadesTable(attachedDatabase, alias);
  }
}

class Oportunidade extends DataClass implements Insertable<Oportunidade> {
  final int id;
  final String auditoriaId;

  /// Número correlativo de la oportunidad dentro de la auditoría (1..n).
  final int numero;

  /// Clave textual del enum `Momento` ('antes_paciente', 'despues_entorno'…).
  final String momentoClave;

  /// Clave textual del enum `Accion` ('guantes', 'lavado', 'omision'…).
  final String accionClave;

  /// Nota libre opcional del observador.
  final String? observacion;

  /// Duración en segundos de la observación (Reto 4):
  final int? duracionSegundos;
  final DateTime registradoEn;
  const Oportunidade({
    required this.id,
    required this.auditoriaId,
    required this.numero,
    required this.momentoClave,
    required this.accionClave,
    this.observacion,
    this.duracionSegundos,
    required this.registradoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['auditoria_id'] = Variable<String>(auditoriaId);
    map['numero'] = Variable<int>(numero);
    map['momento_clave'] = Variable<String>(momentoClave);
    map['accion_clave'] = Variable<String>(accionClave);
    if (!nullToAbsent || observacion != null) {
      map['observacion'] = Variable<String>(observacion);
    }
    if (!nullToAbsent || duracionSegundos != null) {
      map['duracion_segundos'] = Variable<int>(duracionSegundos);
    }
    map['registrado_en'] = Variable<DateTime>(registradoEn);
    return map;
  }

  OportunidadesCompanion toCompanion(bool nullToAbsent) {
    return OportunidadesCompanion(
      id: Value(id),
      auditoriaId: Value(auditoriaId),
      numero: Value(numero),
      momentoClave: Value(momentoClave),
      accionClave: Value(accionClave),
      observacion: observacion == null && nullToAbsent
          ? const Value.absent()
          : Value(observacion),
      duracionSegundos: duracionSegundos == null && nullToAbsent
          ? const Value.absent()
          : Value(duracionSegundos),
      registradoEn: Value(registradoEn),
    );
  }

  factory Oportunidade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Oportunidade(
      id: serializer.fromJson<int>(json['id']),
      auditoriaId: serializer.fromJson<String>(json['auditoriaId']),
      numero: serializer.fromJson<int>(json['numero']),
      momentoClave: serializer.fromJson<String>(json['momentoClave']),
      accionClave: serializer.fromJson<String>(json['accionClave']),
      observacion: serializer.fromJson<String?>(json['observacion']),
      duracionSegundos: serializer.fromJson<int?>(json['duracionSegundos']),
      registradoEn: serializer.fromJson<DateTime>(json['registradoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'auditoriaId': serializer.toJson<String>(auditoriaId),
      'numero': serializer.toJson<int>(numero),
      'momentoClave': serializer.toJson<String>(momentoClave),
      'accionClave': serializer.toJson<String>(accionClave),
      'observacion': serializer.toJson<String?>(observacion),
      'duracionSegundos': serializer.toJson<int?>(duracionSegundos),
      'registradoEn': serializer.toJson<DateTime>(registradoEn),
    };
  }

  Oportunidade copyWith({
    int? id,
    String? auditoriaId,
    int? numero,
    String? momentoClave,
    String? accionClave,
    Value<String?> observacion = const Value.absent(),
    Value<int?> duracionSegundos = const Value.absent(),
    DateTime? registradoEn,
  }) => Oportunidade(
    id: id ?? this.id,
    auditoriaId: auditoriaId ?? this.auditoriaId,
    numero: numero ?? this.numero,
    momentoClave: momentoClave ?? this.momentoClave,
    accionClave: accionClave ?? this.accionClave,
    observacion: observacion.present ? observacion.value : this.observacion,
    duracionSegundos: duracionSegundos.present
        ? duracionSegundos.value
        : this.duracionSegundos,
    registradoEn: registradoEn ?? this.registradoEn,
  );
  Oportunidade copyWithCompanion(OportunidadesCompanion data) {
    return Oportunidade(
      id: data.id.present ? data.id.value : this.id,
      auditoriaId: data.auditoriaId.present
          ? data.auditoriaId.value
          : this.auditoriaId,
      numero: data.numero.present ? data.numero.value : this.numero,
      momentoClave: data.momentoClave.present
          ? data.momentoClave.value
          : this.momentoClave,
      accionClave: data.accionClave.present
          ? data.accionClave.value
          : this.accionClave,
      observacion: data.observacion.present
          ? data.observacion.value
          : this.observacion,
      duracionSegundos: data.duracionSegundos.present
          ? data.duracionSegundos.value
          : this.duracionSegundos,
      registradoEn: data.registradoEn.present
          ? data.registradoEn.value
          : this.registradoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Oportunidade(')
          ..write('id: $id, ')
          ..write('auditoriaId: $auditoriaId, ')
          ..write('numero: $numero, ')
          ..write('momentoClave: $momentoClave, ')
          ..write('accionClave: $accionClave, ')
          ..write('observacion: $observacion, ')
          ..write('duracionSegundos: $duracionSegundos, ')
          ..write('registradoEn: $registradoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    auditoriaId,
    numero,
    momentoClave,
    accionClave,
    observacion,
    duracionSegundos,
    registradoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Oportunidade &&
          other.id == this.id &&
          other.auditoriaId == this.auditoriaId &&
          other.numero == this.numero &&
          other.momentoClave == this.momentoClave &&
          other.accionClave == this.accionClave &&
          other.observacion == this.observacion &&
          other.duracionSegundos == this.duracionSegundos &&
          other.registradoEn == this.registradoEn);
}

class OportunidadesCompanion extends UpdateCompanion<Oportunidade> {
  final Value<int> id;
  final Value<String> auditoriaId;
  final Value<int> numero;
  final Value<String> momentoClave;
  final Value<String> accionClave;
  final Value<String?> observacion;
  final Value<int?> duracionSegundos;
  final Value<DateTime> registradoEn;
  const OportunidadesCompanion({
    this.id = const Value.absent(),
    this.auditoriaId = const Value.absent(),
    this.numero = const Value.absent(),
    this.momentoClave = const Value.absent(),
    this.accionClave = const Value.absent(),
    this.observacion = const Value.absent(),
    this.duracionSegundos = const Value.absent(),
    this.registradoEn = const Value.absent(),
  });
  OportunidadesCompanion.insert({
    this.id = const Value.absent(),
    required String auditoriaId,
    required int numero,
    required String momentoClave,
    required String accionClave,
    this.observacion = const Value.absent(),
    this.duracionSegundos = const Value.absent(),
    this.registradoEn = const Value.absent(),
  }) : auditoriaId = Value(auditoriaId),
       numero = Value(numero),
       momentoClave = Value(momentoClave),
       accionClave = Value(accionClave);
  static Insertable<Oportunidade> custom({
    Expression<int>? id,
    Expression<String>? auditoriaId,
    Expression<int>? numero,
    Expression<String>? momentoClave,
    Expression<String>? accionClave,
    Expression<String>? observacion,
    Expression<int>? duracionSegundos,
    Expression<DateTime>? registradoEn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditoriaId != null) 'auditoria_id': auditoriaId,
      if (numero != null) 'numero': numero,
      if (momentoClave != null) 'momento_clave': momentoClave,
      if (accionClave != null) 'accion_clave': accionClave,
      if (observacion != null) 'observacion': observacion,
      if (duracionSegundos != null) 'duracion_segundos': duracionSegundos,
      if (registradoEn != null) 'registrado_en': registradoEn,
    });
  }

  OportunidadesCompanion copyWith({
    Value<int>? id,
    Value<String>? auditoriaId,
    Value<int>? numero,
    Value<String>? momentoClave,
    Value<String>? accionClave,
    Value<String?>? observacion,
    Value<int?>? duracionSegundos,
    Value<DateTime>? registradoEn,
  }) {
    return OportunidadesCompanion(
      id: id ?? this.id,
      auditoriaId: auditoriaId ?? this.auditoriaId,
      numero: numero ?? this.numero,
      momentoClave: momentoClave ?? this.momentoClave,
      accionClave: accionClave ?? this.accionClave,
      observacion: observacion ?? this.observacion,
      duracionSegundos: duracionSegundos ?? this.duracionSegundos,
      registradoEn: registradoEn ?? this.registradoEn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (auditoriaId.present) {
      map['auditoria_id'] = Variable<String>(auditoriaId.value);
    }
    if (numero.present) {
      map['numero'] = Variable<int>(numero.value);
    }
    if (momentoClave.present) {
      map['momento_clave'] = Variable<String>(momentoClave.value);
    }
    if (accionClave.present) {
      map['accion_clave'] = Variable<String>(accionClave.value);
    }
    if (observacion.present) {
      map['observacion'] = Variable<String>(observacion.value);
    }
    if (duracionSegundos.present) {
      map['duracion_segundos'] = Variable<int>(duracionSegundos.value);
    }
    if (registradoEn.present) {
      map['registrado_en'] = Variable<DateTime>(registradoEn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OportunidadesCompanion(')
          ..write('id: $id, ')
          ..write('auditoriaId: $auditoriaId, ')
          ..write('numero: $numero, ')
          ..write('momentoClave: $momentoClave, ')
          ..write('accionClave: $accionClave, ')
          ..write('observacion: $observacion, ')
          ..write('duracionSegundos: $duracionSegundos, ')
          ..write('registradoEn: $registradoEn')
          ..write(')'))
        .toString();
  }
}

class $IndicadoresCacheTable extends IndicadoresCache
    with TableInfo<$IndicadoresCacheTable, IndicadoresCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IndicadoresCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codigoIndicadorMeta = const VerificationMeta(
    'codigoIndicador',
  );
  @override
  late final GeneratedColumn<String> codigoIndicador = GeneratedColumn<String>(
    'codigo_indicador',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paisMeta = const VerificationMeta('pais');
  @override
  late final GeneratedColumn<String> pais = GeneratedColumn<String>(
    'pais',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _anioMeta = const VerificationMeta('anio');
  @override
  late final GeneratedColumn<int> anio = GeneratedColumn<int>(
    'anio',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ambitoMeta = const VerificationMeta('ambito');
  @override
  late final GeneratedColumn<String> ambito = GeneratedColumn<String>(
    'ambito',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<double> valor = GeneratedColumn<double>(
    'valor',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descargadoEnMeta = const VerificationMeta(
    'descargadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> descargadoEn = GeneratedColumn<DateTime>(
    'descargado_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    clave,
    codigoIndicador,
    pais,
    anio,
    ambito,
    valor,
    descargadoEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'indicadores_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<IndicadoresCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('codigo_indicador')) {
      context.handle(
        _codigoIndicadorMeta,
        codigoIndicador.isAcceptableOrUnknown(
          data['codigo_indicador']!,
          _codigoIndicadorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_codigoIndicadorMeta);
    }
    if (data.containsKey('pais')) {
      context.handle(
        _paisMeta,
        pais.isAcceptableOrUnknown(data['pais']!, _paisMeta),
      );
    } else if (isInserting) {
      context.missing(_paisMeta);
    }
    if (data.containsKey('anio')) {
      context.handle(
        _anioMeta,
        anio.isAcceptableOrUnknown(data['anio']!, _anioMeta),
      );
    } else if (isInserting) {
      context.missing(_anioMeta);
    }
    if (data.containsKey('ambito')) {
      context.handle(
        _ambitoMeta,
        ambito.isAcceptableOrUnknown(data['ambito']!, _ambitoMeta),
      );
    } else if (isInserting) {
      context.missing(_ambitoMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    }
    if (data.containsKey('descargado_en')) {
      context.handle(
        _descargadoEnMeta,
        descargadoEn.isAcceptableOrUnknown(
          data['descargado_en']!,
          _descargadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clave};
  @override
  IndicadoresCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IndicadoresCacheData(
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      codigoIndicador: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_indicador'],
      )!,
      pais: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pais'],
      )!,
      anio: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anio'],
      )!,
      ambito: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ambito'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valor'],
      ),
      descargadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}descargado_en'],
      )!,
    );
  }

  @override
  $IndicadoresCacheTable createAlias(String alias) {
    return $IndicadoresCacheTable(attachedDatabase, alias);
  }
}

class IndicadoresCacheData extends DataClass
    implements Insertable<IndicadoresCacheData> {
  final String clave;
  final String codigoIndicador;
  final String pais;
  final int anio;
  final String ambito;

  /// `nullable()` porque el API entrega años sin dato (`NumericValue: null`).
  final double? valor;

  /// Momento exacto en que el registro se descargó del servicio.
  final DateTime descargadoEn;
  const IndicadoresCacheData({
    required this.clave,
    required this.codigoIndicador,
    required this.pais,
    required this.anio,
    required this.ambito,
    this.valor,
    required this.descargadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clave'] = Variable<String>(clave);
    map['codigo_indicador'] = Variable<String>(codigoIndicador);
    map['pais'] = Variable<String>(pais);
    map['anio'] = Variable<int>(anio);
    map['ambito'] = Variable<String>(ambito);
    if (!nullToAbsent || valor != null) {
      map['valor'] = Variable<double>(valor);
    }
    map['descargado_en'] = Variable<DateTime>(descargadoEn);
    return map;
  }

  IndicadoresCacheCompanion toCompanion(bool nullToAbsent) {
    return IndicadoresCacheCompanion(
      clave: Value(clave),
      codigoIndicador: Value(codigoIndicador),
      pais: Value(pais),
      anio: Value(anio),
      ambito: Value(ambito),
      valor: valor == null && nullToAbsent
          ? const Value.absent()
          : Value(valor),
      descargadoEn: Value(descargadoEn),
    );
  }

  factory IndicadoresCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IndicadoresCacheData(
      clave: serializer.fromJson<String>(json['clave']),
      codigoIndicador: serializer.fromJson<String>(json['codigoIndicador']),
      pais: serializer.fromJson<String>(json['pais']),
      anio: serializer.fromJson<int>(json['anio']),
      ambito: serializer.fromJson<String>(json['ambito']),
      valor: serializer.fromJson<double?>(json['valor']),
      descargadoEn: serializer.fromJson<DateTime>(json['descargadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clave': serializer.toJson<String>(clave),
      'codigoIndicador': serializer.toJson<String>(codigoIndicador),
      'pais': serializer.toJson<String>(pais),
      'anio': serializer.toJson<int>(anio),
      'ambito': serializer.toJson<String>(ambito),
      'valor': serializer.toJson<double?>(valor),
      'descargadoEn': serializer.toJson<DateTime>(descargadoEn),
    };
  }

  IndicadoresCacheData copyWith({
    String? clave,
    String? codigoIndicador,
    String? pais,
    int? anio,
    String? ambito,
    Value<double?> valor = const Value.absent(),
    DateTime? descargadoEn,
  }) => IndicadoresCacheData(
    clave: clave ?? this.clave,
    codigoIndicador: codigoIndicador ?? this.codigoIndicador,
    pais: pais ?? this.pais,
    anio: anio ?? this.anio,
    ambito: ambito ?? this.ambito,
    valor: valor.present ? valor.value : this.valor,
    descargadoEn: descargadoEn ?? this.descargadoEn,
  );
  IndicadoresCacheData copyWithCompanion(IndicadoresCacheCompanion data) {
    return IndicadoresCacheData(
      clave: data.clave.present ? data.clave.value : this.clave,
      codigoIndicador: data.codigoIndicador.present
          ? data.codigoIndicador.value
          : this.codigoIndicador,
      pais: data.pais.present ? data.pais.value : this.pais,
      anio: data.anio.present ? data.anio.value : this.anio,
      ambito: data.ambito.present ? data.ambito.value : this.ambito,
      valor: data.valor.present ? data.valor.value : this.valor,
      descargadoEn: data.descargadoEn.present
          ? data.descargadoEn.value
          : this.descargadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IndicadoresCacheData(')
          ..write('clave: $clave, ')
          ..write('codigoIndicador: $codigoIndicador, ')
          ..write('pais: $pais, ')
          ..write('anio: $anio, ')
          ..write('ambito: $ambito, ')
          ..write('valor: $valor, ')
          ..write('descargadoEn: $descargadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    clave,
    codigoIndicador,
    pais,
    anio,
    ambito,
    valor,
    descargadoEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IndicadoresCacheData &&
          other.clave == this.clave &&
          other.codigoIndicador == this.codigoIndicador &&
          other.pais == this.pais &&
          other.anio == this.anio &&
          other.ambito == this.ambito &&
          other.valor == this.valor &&
          other.descargadoEn == this.descargadoEn);
}

class IndicadoresCacheCompanion extends UpdateCompanion<IndicadoresCacheData> {
  final Value<String> clave;
  final Value<String> codigoIndicador;
  final Value<String> pais;
  final Value<int> anio;
  final Value<String> ambito;
  final Value<double?> valor;
  final Value<DateTime> descargadoEn;
  final Value<int> rowid;
  const IndicadoresCacheCompanion({
    this.clave = const Value.absent(),
    this.codigoIndicador = const Value.absent(),
    this.pais = const Value.absent(),
    this.anio = const Value.absent(),
    this.ambito = const Value.absent(),
    this.valor = const Value.absent(),
    this.descargadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IndicadoresCacheCompanion.insert({
    required String clave,
    required String codigoIndicador,
    required String pais,
    required int anio,
    required String ambito,
    this.valor = const Value.absent(),
    this.descargadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clave = Value(clave),
       codigoIndicador = Value(codigoIndicador),
       pais = Value(pais),
       anio = Value(anio),
       ambito = Value(ambito);
  static Insertable<IndicadoresCacheData> custom({
    Expression<String>? clave,
    Expression<String>? codigoIndicador,
    Expression<String>? pais,
    Expression<int>? anio,
    Expression<String>? ambito,
    Expression<double>? valor,
    Expression<DateTime>? descargadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clave != null) 'clave': clave,
      if (codigoIndicador != null) 'codigo_indicador': codigoIndicador,
      if (pais != null) 'pais': pais,
      if (anio != null) 'anio': anio,
      if (ambito != null) 'ambito': ambito,
      if (valor != null) 'valor': valor,
      if (descargadoEn != null) 'descargado_en': descargadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IndicadoresCacheCompanion copyWith({
    Value<String>? clave,
    Value<String>? codigoIndicador,
    Value<String>? pais,
    Value<int>? anio,
    Value<String>? ambito,
    Value<double?>? valor,
    Value<DateTime>? descargadoEn,
    Value<int>? rowid,
  }) {
    return IndicadoresCacheCompanion(
      clave: clave ?? this.clave,
      codigoIndicador: codigoIndicador ?? this.codigoIndicador,
      pais: pais ?? this.pais,
      anio: anio ?? this.anio,
      ambito: ambito ?? this.ambito,
      valor: valor ?? this.valor,
      descargadoEn: descargadoEn ?? this.descargadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (codigoIndicador.present) {
      map['codigo_indicador'] = Variable<String>(codigoIndicador.value);
    }
    if (pais.present) {
      map['pais'] = Variable<String>(pais.value);
    }
    if (anio.present) {
      map['anio'] = Variable<int>(anio.value);
    }
    if (ambito.present) {
      map['ambito'] = Variable<String>(ambito.value);
    }
    if (valor.present) {
      map['valor'] = Variable<double>(valor.value);
    }
    if (descargadoEn.present) {
      map['descargado_en'] = Variable<DateTime>(descargadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IndicadoresCacheCompanion(')
          ..write('clave: $clave, ')
          ..write('codigoIndicador: $codigoIndicador, ')
          ..write('pais: $pais, ')
          ..write('anio: $anio, ')
          ..write('ambito: $ambito, ')
          ..write('valor: $valor, ')
          ..write('descargadoEn: $descargadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SincronizacionesTable extends Sincronizaciones
    with TableInfo<$SincronizacionesTable, Sincronizacione> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SincronizacionesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ultimaSincronizacionMeta =
      const VerificationMeta('ultimaSincronizacion');
  @override
  late final GeneratedColumn<DateTime> ultimaSincronizacion =
      GeneratedColumn<DateTime>(
        'ultima_sincronizacion',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _registrosMeta = const VerificationMeta(
    'registros',
  );
  @override
  late final GeneratedColumn<int> registros = GeneratedColumn<int>(
    'registros',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _intentosFallidosMeta = const VerificationMeta(
    'intentosFallidos',
  );
  @override
  late final GeneratedColumn<int> intentosFallidos = GeneratedColumn<int>(
    'intentos_fallidos',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    codigo,
    ultimaSincronizacion,
    registros,
    intentosFallidos,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sincronizaciones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Sincronizacione> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('ultima_sincronizacion')) {
      context.handle(
        _ultimaSincronizacionMeta,
        ultimaSincronizacion.isAcceptableOrUnknown(
          data['ultima_sincronizacion']!,
          _ultimaSincronizacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ultimaSincronizacionMeta);
    }
    if (data.containsKey('registros')) {
      context.handle(
        _registrosMeta,
        registros.isAcceptableOrUnknown(data['registros']!, _registrosMeta),
      );
    }
    if (data.containsKey('intentos_fallidos')) {
      context.handle(
        _intentosFallidosMeta,
        intentosFallidos.isAcceptableOrUnknown(
          data['intentos_fallidos']!,
          _intentosFallidosMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {codigo};
  @override
  Sincronizacione map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sincronizacione(
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      ultimaSincronizacion: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultima_sincronizacion'],
      )!,
      registros: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}registros'],
      )!,
      intentosFallidos: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intentos_fallidos'],
      )!,
    );
  }

  @override
  $SincronizacionesTable createAlias(String alias) {
    return $SincronizacionesTable(attachedDatabase, alias);
  }
}

class Sincronizacione extends DataClass implements Insertable<Sincronizacione> {
  /// Código del recurso: 'WSH_HYGIENE_BASIC', 'establecimientos', etc.
  final String codigo;
  final DateTime ultimaSincronizacion;

  /// Cantidad de registros escritos en la última descarga exitosa.
  final int registros;

  /// Reto 2: número de intentos fallidos consecutivos por recurso.
  /// Se reinicia a cero en cada descarga exitosa.
  final int intentosFallidos;
  const Sincronizacione({
    required this.codigo,
    required this.ultimaSincronizacion,
    required this.registros,
    required this.intentosFallidos,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['codigo'] = Variable<String>(codigo);
    map['ultima_sincronizacion'] = Variable<DateTime>(ultimaSincronizacion);
    map['registros'] = Variable<int>(registros);
    map['intentos_fallidos'] = Variable<int>(intentosFallidos);
    return map;
  }

  SincronizacionesCompanion toCompanion(bool nullToAbsent) {
    return SincronizacionesCompanion(
      codigo: Value(codigo),
      ultimaSincronizacion: Value(ultimaSincronizacion),
      registros: Value(registros),
      intentosFallidos: Value(intentosFallidos),
    );
  }

  factory Sincronizacione.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sincronizacione(
      codigo: serializer.fromJson<String>(json['codigo']),
      ultimaSincronizacion: serializer.fromJson<DateTime>(
        json['ultimaSincronizacion'],
      ),
      registros: serializer.fromJson<int>(json['registros']),
      intentosFallidos: serializer.fromJson<int>(json['intentosFallidos']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'codigo': serializer.toJson<String>(codigo),
      'ultimaSincronizacion': serializer.toJson<DateTime>(ultimaSincronizacion),
      'registros': serializer.toJson<int>(registros),
      'intentosFallidos': serializer.toJson<int>(intentosFallidos),
    };
  }

  Sincronizacione copyWith({
    String? codigo,
    DateTime? ultimaSincronizacion,
    int? registros,
    int? intentosFallidos,
  }) => Sincronizacione(
    codigo: codigo ?? this.codigo,
    ultimaSincronizacion: ultimaSincronizacion ?? this.ultimaSincronizacion,
    registros: registros ?? this.registros,
    intentosFallidos: intentosFallidos ?? this.intentosFallidos,
  );
  Sincronizacione copyWithCompanion(SincronizacionesCompanion data) {
    return Sincronizacione(
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      ultimaSincronizacion: data.ultimaSincronizacion.present
          ? data.ultimaSincronizacion.value
          : this.ultimaSincronizacion,
      registros: data.registros.present ? data.registros.value : this.registros,
      intentosFallidos: data.intentosFallidos.present
          ? data.intentosFallidos.value
          : this.intentosFallidos,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sincronizacione(')
          ..write('codigo: $codigo, ')
          ..write('ultimaSincronizacion: $ultimaSincronizacion, ')
          ..write('registros: $registros, ')
          ..write('intentosFallidos: $intentosFallidos')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(codigo, ultimaSincronizacion, registros, intentosFallidos);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sincronizacione &&
          other.codigo == this.codigo &&
          other.ultimaSincronizacion == this.ultimaSincronizacion &&
          other.registros == this.registros &&
          other.intentosFallidos == this.intentosFallidos);
}

class SincronizacionesCompanion extends UpdateCompanion<Sincronizacione> {
  final Value<String> codigo;
  final Value<DateTime> ultimaSincronizacion;
  final Value<int> registros;
  final Value<int> intentosFallidos;
  final Value<int> rowid;
  const SincronizacionesCompanion({
    this.codigo = const Value.absent(),
    this.ultimaSincronizacion = const Value.absent(),
    this.registros = const Value.absent(),
    this.intentosFallidos = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SincronizacionesCompanion.insert({
    required String codigo,
    required DateTime ultimaSincronizacion,
    this.registros = const Value.absent(),
    this.intentosFallidos = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : codigo = Value(codigo),
       ultimaSincronizacion = Value(ultimaSincronizacion);
  static Insertable<Sincronizacione> custom({
    Expression<String>? codigo,
    Expression<DateTime>? ultimaSincronizacion,
    Expression<int>? registros,
    Expression<int>? intentosFallidos,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (codigo != null) 'codigo': codigo,
      if (ultimaSincronizacion != null)
        'ultima_sincronizacion': ultimaSincronizacion,
      if (registros != null) 'registros': registros,
      if (intentosFallidos != null) 'intentos_fallidos': intentosFallidos,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SincronizacionesCompanion copyWith({
    Value<String>? codigo,
    Value<DateTime>? ultimaSincronizacion,
    Value<int>? registros,
    Value<int>? intentosFallidos,
    Value<int>? rowid,
  }) {
    return SincronizacionesCompanion(
      codigo: codigo ?? this.codigo,
      ultimaSincronizacion: ultimaSincronizacion ?? this.ultimaSincronizacion,
      registros: registros ?? this.registros,
      intentosFallidos: intentosFallidos ?? this.intentosFallidos,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (ultimaSincronizacion.present) {
      map['ultima_sincronizacion'] = Variable<DateTime>(
        ultimaSincronizacion.value,
      );
    }
    if (registros.present) {
      map['registros'] = Variable<int>(registros.value);
    }
    if (intentosFallidos.present) {
      map['intentos_fallidos'] = Variable<int>(intentosFallidos.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SincronizacionesCompanion(')
          ..write('codigo: $codigo, ')
          ..write('ultimaSincronizacion: $ultimaSincronizacion, ')
          ..write('registros: $registros, ')
          ..write('intentosFallidos: $intentosFallidos, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferenciasTable extends Preferencias
    with TableInfo<$PreferenciasTable, Preferencia> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferenciasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _claveMeta = const VerificationMeta('clave');
  @override
  late final GeneratedColumn<String> clave = GeneratedColumn<String>(
    'clave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualizadoEnMeta = const VerificationMeta(
    'actualizadoEn',
  );
  @override
  late final GeneratedColumn<DateTime> actualizadoEn =
      GeneratedColumn<DateTime>(
        'actualizado_en',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [clave, valor, actualizadoEn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preferencia> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('clave')) {
      context.handle(
        _claveMeta,
        clave.isAcceptableOrUnknown(data['clave']!, _claveMeta),
      );
    } else if (isInserting) {
      context.missing(_claveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    } else if (isInserting) {
      context.missing(_valorMeta);
    }
    if (data.containsKey('actualizado_en')) {
      context.handle(
        _actualizadoEnMeta,
        actualizadoEn.isAcceptableOrUnknown(
          data['actualizado_en']!,
          _actualizadoEnMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {clave};
  @override
  Preferencia map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preferencia(
      clave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}clave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      )!,
      actualizadoEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actualizado_en'],
      )!,
    );
  }

  @override
  $PreferenciasTable createAlias(String alias) {
    return $PreferenciasTable(attachedDatabase, alias);
  }
}

class Preferencia extends DataClass implements Insertable<Preferencia> {
  final String clave;
  final String valor;
  final DateTime actualizadoEn;
  const Preferencia({
    required this.clave,
    required this.valor,
    required this.actualizadoEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['clave'] = Variable<String>(clave);
    map['valor'] = Variable<String>(valor);
    map['actualizado_en'] = Variable<DateTime>(actualizadoEn);
    return map;
  }

  PreferenciasCompanion toCompanion(bool nullToAbsent) {
    return PreferenciasCompanion(
      clave: Value(clave),
      valor: Value(valor),
      actualizadoEn: Value(actualizadoEn),
    );
  }

  factory Preferencia.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preferencia(
      clave: serializer.fromJson<String>(json['clave']),
      valor: serializer.fromJson<String>(json['valor']),
      actualizadoEn: serializer.fromJson<DateTime>(json['actualizadoEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clave': serializer.toJson<String>(clave),
      'valor': serializer.toJson<String>(valor),
      'actualizadoEn': serializer.toJson<DateTime>(actualizadoEn),
    };
  }

  Preferencia copyWith({
    String? clave,
    String? valor,
    DateTime? actualizadoEn,
  }) => Preferencia(
    clave: clave ?? this.clave,
    valor: valor ?? this.valor,
    actualizadoEn: actualizadoEn ?? this.actualizadoEn,
  );
  Preferencia copyWithCompanion(PreferenciasCompanion data) {
    return Preferencia(
      clave: data.clave.present ? data.clave.value : this.clave,
      valor: data.valor.present ? data.valor.value : this.valor,
      actualizadoEn: data.actualizadoEn.present
          ? data.actualizadoEn.value
          : this.actualizadoEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preferencia(')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('actualizadoEn: $actualizadoEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clave, valor, actualizadoEn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preferencia &&
          other.clave == this.clave &&
          other.valor == this.valor &&
          other.actualizadoEn == this.actualizadoEn);
}

class PreferenciasCompanion extends UpdateCompanion<Preferencia> {
  final Value<String> clave;
  final Value<String> valor;
  final Value<DateTime> actualizadoEn;
  final Value<int> rowid;
  const PreferenciasCompanion({
    this.clave = const Value.absent(),
    this.valor = const Value.absent(),
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferenciasCompanion.insert({
    required String clave,
    required String valor,
    this.actualizadoEn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clave = Value(clave),
       valor = Value(valor);
  static Insertable<Preferencia> custom({
    Expression<String>? clave,
    Expression<String>? valor,
    Expression<DateTime>? actualizadoEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clave != null) 'clave': clave,
      if (valor != null) 'valor': valor,
      if (actualizadoEn != null) 'actualizado_en': actualizadoEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferenciasCompanion copyWith({
    Value<String>? clave,
    Value<String>? valor,
    Value<DateTime>? actualizadoEn,
    Value<int>? rowid,
  }) {
    return PreferenciasCompanion(
      clave: clave ?? this.clave,
      valor: valor ?? this.valor,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clave.present) {
      map['clave'] = Variable<String>(clave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (actualizadoEn.present) {
      map['actualizado_en'] = Variable<DateTime>(actualizadoEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferenciasCompanion(')
          ..write('clave: $clave, ')
          ..write('valor: $valor, ')
          ..write('actualizadoEn: $actualizadoEn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ManosSegurasDb extends GeneratedDatabase {
  _$ManosSegurasDb(QueryExecutor e) : super(e);
  late final $EstablecimientosTable establecimientos = $EstablecimientosTable(
    this,
  );
  late final $PersonalTable personal = $PersonalTable(this);
  late final $AuditoriasTable auditorias = $AuditoriasTable(this);
  late final $AuditoriasHistorialTable auditoriasHistorial =
      $AuditoriasHistorialTable(this);
  late final $OportunidadesTable oportunidades = $OportunidadesTable(this);
  late final $IndicadoresCacheTable indicadoresCache = $IndicadoresCacheTable(
    this,
  );
  late final $SincronizacionesTable sincronizaciones = $SincronizacionesTable(
    this,
  );
  late final $PreferenciasTable preferencias = $PreferenciasTable(this);
  late final Index idxAuditoriasEstadoFecha = Index(
    'idx_auditorias_estado_fecha',
    'CREATE INDEX idx_auditorias_estado_fecha ON auditorias (estado, fecha)',
  );
  late final Index idxOportunidadesAuditoria = Index(
    'idx_oportunidades_auditoria',
    'CREATE INDEX idx_oportunidades_auditoria ON oportunidades (auditoria_id)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    establecimientos,
    personal,
    auditorias,
    auditoriasHistorial,
    oportunidades,
    indicadoresCache,
    sincronizaciones,
    preferencias,
    idxAuditoriasEstadoFecha,
    idxOportunidadesAuditoria,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'auditorias',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('oportunidades', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}
