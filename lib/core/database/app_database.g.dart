// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CurrenciesTable extends Currencies
    with TableInfo<$CurrenciesTable, CurrencyRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CurrenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fractionDigitsMeta = const VerificationMeta(
    'fractionDigits',
  );
  @override
  late final GeneratedColumn<int> fractionDigits = GeneratedColumn<int>(
    'fraction_digits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (fraction_digits BETWEEN 0 AND 8)',
  );
  static const VerificationMeta _isPresetMeta = const VerificationMeta(
    'isPreset',
  );
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
    'is_preset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    code,
    name,
    normalizedName,
    fractionDigits,
    isPreset,
    isEnabled,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'currencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<CurrencyRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('fraction_digits')) {
      context.handle(
        _fractionDigitsMeta,
        fractionDigits.isAcceptableOrUnknown(
          data['fraction_digits']!,
          _fractionDigitsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fractionDigitsMeta);
    }
    if (data.containsKey('is_preset')) {
      context.handle(
        _isPresetMeta,
        isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {code};
  @override
  CurrencyRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CurrencyRow(
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      fractionDigits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fraction_digits'],
      )!,
      isPreset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preset'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
    );
  }

  @override
  $CurrenciesTable createAlias(String alias) {
    return $CurrenciesTable(attachedDatabase, alias);
  }
}

class CurrencyRow extends DataClass implements Insertable<CurrencyRow> {
  final String code;
  final String name;
  final String normalizedName;
  final int fractionDigits;
  final bool isPreset;
  final bool isEnabled;
  const CurrencyRow({
    required this.code,
    required this.name,
    required this.normalizedName,
    required this.fractionDigits,
    required this.isPreset,
    required this.isEnabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    map['fraction_digits'] = Variable<int>(fractionDigits);
    map['is_preset'] = Variable<bool>(isPreset);
    map['is_enabled'] = Variable<bool>(isEnabled);
    return map;
  }

  CurrenciesCompanion toCompanion(bool nullToAbsent) {
    return CurrenciesCompanion(
      code: Value(code),
      name: Value(name),
      normalizedName: Value(normalizedName),
      fractionDigits: Value(fractionDigits),
      isPreset: Value(isPreset),
      isEnabled: Value(isEnabled),
    );
  }

  factory CurrencyRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CurrencyRow(
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      fractionDigits: serializer.fromJson<int>(json['fractionDigits']),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'fractionDigits': serializer.toJson<int>(fractionDigits),
      'isPreset': serializer.toJson<bool>(isPreset),
      'isEnabled': serializer.toJson<bool>(isEnabled),
    };
  }

  CurrencyRow copyWith({
    String? code,
    String? name,
    String? normalizedName,
    int? fractionDigits,
    bool? isPreset,
    bool? isEnabled,
  }) => CurrencyRow(
    code: code ?? this.code,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    fractionDigits: fractionDigits ?? this.fractionDigits,
    isPreset: isPreset ?? this.isPreset,
    isEnabled: isEnabled ?? this.isEnabled,
  );
  CurrencyRow copyWithCompanion(CurrenciesCompanion data) {
    return CurrencyRow(
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      fractionDigits: data.fractionDigits.present
          ? data.fractionDigits.value
          : this.fractionDigits,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CurrencyRow(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('fractionDigits: $fractionDigits, ')
          ..write('isPreset: $isPreset, ')
          ..write('isEnabled: $isEnabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    code,
    name,
    normalizedName,
    fractionDigits,
    isPreset,
    isEnabled,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CurrencyRow &&
          other.code == this.code &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.fractionDigits == this.fractionDigits &&
          other.isPreset == this.isPreset &&
          other.isEnabled == this.isEnabled);
}

class CurrenciesCompanion extends UpdateCompanion<CurrencyRow> {
  final Value<String> code;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<int> fractionDigits;
  final Value<bool> isPreset;
  final Value<bool> isEnabled;
  final Value<int> rowid;
  const CurrenciesCompanion({
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.fractionDigits = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CurrenciesCompanion.insert({
    required String code,
    required String name,
    required String normalizedName,
    required int fractionDigits,
    this.isPreset = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : code = Value(code),
       name = Value(name),
       normalizedName = Value(normalizedName),
       fractionDigits = Value(fractionDigits);
  static Insertable<CurrencyRow> custom({
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<int>? fractionDigits,
    Expression<bool>? isPreset,
    Expression<bool>? isEnabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (fractionDigits != null) 'fraction_digits': fractionDigits,
      if (isPreset != null) 'is_preset': isPreset,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CurrenciesCompanion copyWith({
    Value<String>? code,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<int>? fractionDigits,
    Value<bool>? isPreset,
    Value<bool>? isEnabled,
    Value<int>? rowid,
  }) {
    return CurrenciesCompanion(
      code: code ?? this.code,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      fractionDigits: fractionDigits ?? this.fractionDigits,
      isPreset: isPreset ?? this.isPreset,
      isEnabled: isEnabled ?? this.isEnabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (fractionDigits.present) {
      map['fraction_digits'] = Variable<int>(fractionDigits.value);
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CurrenciesCompanion(')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('fractionDigits: $fractionDigits, ')
          ..write('isPreset: $isPreset, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetsTable extends Assets with TableInfo<$AssetsTable, AssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AssetKind, String>
  kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (kind IN (\'account\', \'investment\', \'property\'))',
  ).withConverter<AssetKind>($AssetsTable.$converterkind);
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _openingValueMinorMeta = const VerificationMeta(
    'openingValueMinor',
  );
  @override
  late final GeneratedColumn<int> openingValueMinor = GeneratedColumn<int>(
    'opening_value_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (opening_value_minor >= 0)',
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AssetsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> archivedAt =
      GeneratedColumn<String>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($AssetsTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    kind,
    currencyCode,
    openingValueMinor,
    createdAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('opening_value_minor')) {
      context.handle(
        _openingValueMinorMeta,
        openingValueMinor.isAcceptableOrUnknown(
          data['opening_value_minor']!,
          _openingValueMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingValueMinorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      kind: $AssetsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      openingValueMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_value_minor'],
      )!,
      createdAt: $AssetsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      archivedAt: $AssetsTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }

  static TypeConverter<AssetKind, String> $converterkind =
      const AssetKindConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterarchivedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime?, String?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class AssetRow extends DataClass implements Insertable<AssetRow> {
  final int id;
  final String name;
  final AssetKind kind;
  final String currencyCode;
  final int openingValueMinor;
  final DateTime createdAt;
  final DateTime? archivedAt;
  const AssetRow({
    required this.id,
    required this.name,
    required this.kind,
    required this.currencyCode,
    required this.openingValueMinor,
    required this.createdAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['kind'] = Variable<String>($AssetsTable.$converterkind.toSql(kind));
    }
    map['currency_code'] = Variable<String>(currencyCode);
    map['opening_value_minor'] = Variable<int>(openingValueMinor);
    {
      map['created_at'] = Variable<String>(
        $AssetsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(
        $AssetsTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      name: Value(name),
      kind: Value(kind),
      currencyCode: Value(currencyCode),
      openingValueMinor: Value(openingValueMinor),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory AssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      kind: serializer.fromJson<AssetKind>(json['kind']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      openingValueMinor: serializer.fromJson<int>(json['openingValueMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'kind': serializer.toJson<AssetKind>(kind),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'openingValueMinor': serializer.toJson<int>(openingValueMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  AssetRow copyWith({
    int? id,
    String? name,
    AssetKind? kind,
    String? currencyCode,
    int? openingValueMinor,
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => AssetRow(
    id: id ?? this.id,
    name: name ?? this.name,
    kind: kind ?? this.kind,
    currencyCode: currencyCode ?? this.currencyCode,
    openingValueMinor: openingValueMinor ?? this.openingValueMinor,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  AssetRow copyWithCompanion(AssetsCompanion data) {
    return AssetRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      kind: data.kind.present ? data.kind.value : this.kind,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      openingValueMinor: data.openingValueMinor.present
          ? data.openingValueMinor.value
          : this.openingValueMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('openingValueMinor: $openingValueMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    kind,
    currencyCode,
    openingValueMinor,
    createdAt,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.kind == this.kind &&
          other.currencyCode == this.currencyCode &&
          other.openingValueMinor == this.openingValueMinor &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt);
}

class AssetsCompanion extends UpdateCompanion<AssetRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<AssetKind> kind;
  final Value<String> currencyCode;
  final Value<int> openingValueMinor;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.kind = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.openingValueMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  AssetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required AssetKind kind,
    required String currencyCode,
    required int openingValueMinor,
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
  }) : name = Value(name),
       kind = Value(kind),
       currencyCode = Value(currencyCode),
       openingValueMinor = Value(openingValueMinor),
       createdAt = Value(createdAt);
  static Insertable<AssetRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? kind,
    Expression<String>? currencyCode,
    Expression<int>? openingValueMinor,
    Expression<String>? createdAt,
    Expression<String>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (kind != null) 'kind': kind,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (openingValueMinor != null) 'opening_value_minor': openingValueMinor,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  AssetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<AssetKind>? kind,
    Value<String>? currencyCode,
    Value<int>? openingValueMinor,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      currencyCode: currencyCode ?? this.currencyCode,
      openingValueMinor: openingValueMinor ?? this.openingValueMinor,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $AssetsTable.$converterkind.toSql(kind.value),
      );
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (openingValueMinor.present) {
      map['opening_value_minor'] = Variable<int>(openingValueMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $AssetsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(
        $AssetsTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('kind: $kind, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('openingValueMinor: $openingValueMinor, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $SubgroupsTable extends Subgroups
    with TableInfo<$SubgroupsTable, SubgroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubgroupsTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<SubgroupKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL CHECK (kind IN (\'bank\', \'broker\'))',
      ).withConverter<SubgroupKind>($SubgroupsTable.$converterkind);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($SubgroupsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    name,
    normalizedName,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subgroups';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubgroupRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kind, normalizedName},
  ];
  @override
  SubgroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubgroupRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: $SubgroupsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      createdAt: $SubgroupsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $SubgroupsTable createAlias(String alias) {
    return $SubgroupsTable(attachedDatabase, alias);
  }

  static TypeConverter<SubgroupKind, String> $converterkind =
      const SubgroupKindConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcTimestampConverter();
}

class SubgroupRow extends DataClass implements Insertable<SubgroupRow> {
  final int id;
  final SubgroupKind kind;
  final String name;
  final String normalizedName;
  final DateTime createdAt;
  const SubgroupRow({
    required this.id,
    required this.kind,
    required this.name,
    required this.normalizedName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<String>(
        $SubgroupsTable.$converterkind.toSql(kind),
      );
    }
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    {
      map['created_at'] = Variable<String>(
        $SubgroupsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  SubgroupsCompanion toCompanion(bool nullToAbsent) {
    return SubgroupsCompanion(
      id: Value(id),
      kind: Value(kind),
      name: Value(name),
      normalizedName: Value(normalizedName),
      createdAt: Value(createdAt),
    );
  }

  factory SubgroupRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubgroupRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<SubgroupKind>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<SubgroupKind>(kind),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SubgroupRow copyWith({
    int? id,
    SubgroupKind? kind,
    String? name,
    String? normalizedName,
    DateTime? createdAt,
  }) => SubgroupRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    createdAt: createdAt ?? this.createdAt,
  );
  SubgroupRow copyWithCompanion(SubgroupsCompanion data) {
    return SubgroupRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubgroupRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, name, normalizedName, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubgroupRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.createdAt == this.createdAt);
}

class SubgroupsCompanion extends UpdateCompanion<SubgroupRow> {
  final Value<int> id;
  final Value<SubgroupKind> kind;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<DateTime> createdAt;
  const SubgroupsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SubgroupsCompanion.insert({
    this.id = const Value.absent(),
    required SubgroupKind kind,
    required String name,
    required String normalizedName,
    required DateTime createdAt,
  }) : kind = Value(kind),
       name = Value(name),
       normalizedName = Value(normalizedName),
       createdAt = Value(createdAt);
  static Insertable<SubgroupRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SubgroupsCompanion copyWith({
    Value<int>? id,
    Value<SubgroupKind>? kind,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<DateTime>? createdAt,
  }) {
    return SubgroupsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $SubgroupsTable.$converterkind.toSql(kind.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $SubgroupsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubgroupsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AccountDetailsTable extends AccountDetails
    with TableInfo<$AccountDetailsTable, AccountDetailRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AccountDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _bankIdMeta = const VerificationMeta('bankId');
  @override
  late final GeneratedColumn<int> bankId = GeneratedColumn<int>(
    'bank_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subgroups (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> annualRate =
      GeneratedColumn<String>(
        'annual_rate',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($AccountDetailsTable.$converterannualRate);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($AccountDetailsTable.$converterstartDate);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> endDate =
      GeneratedColumn<String>(
        'end_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($AccountDetailsTable.$converterendDaten);
  @override
  List<GeneratedColumn> get $columns => [
    assetId,
    bankId,
    annualRate,
    startDate,
    endDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'account_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<AccountDetailRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    }
    if (data.containsKey('bank_id')) {
      context.handle(
        _bankIdMeta,
        bankId.isAcceptableOrUnknown(data['bank_id']!, _bankIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bankIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  AccountDetailRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AccountDetailRow(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      bankId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bank_id'],
      )!,
      annualRate: $AccountDetailsTable.$converterannualRate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}annual_rate'],
        )!,
      ),
      startDate: $AccountDetailsTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      endDate: $AccountDetailsTable.$converterendDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_date'],
        ),
      ),
    );
  }

  @override
  $AccountDetailsTable createAlias(String alias) {
    return $AccountDetailsTable(attachedDatabase, alias);
  }

  static TypeConverter<Decimal, String> $converterannualRate =
      const DecimalConverter();
  static TypeConverter<LocalDate, String> $converterstartDate =
      const LocalDateConverter();
  static TypeConverter<LocalDate, String> $converterendDate =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $converterendDaten =
      NullAwareTypeConverter.wrap($converterendDate);
}

class AccountDetailRow extends DataClass
    implements Insertable<AccountDetailRow> {
  final int assetId;
  final int bankId;
  final Decimal annualRate;
  final LocalDate startDate;
  final LocalDate? endDate;
  const AccountDetailRow({
    required this.assetId,
    required this.bankId,
    required this.annualRate,
    required this.startDate,
    this.endDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<int>(assetId);
    map['bank_id'] = Variable<int>(bankId);
    {
      map['annual_rate'] = Variable<String>(
        $AccountDetailsTable.$converterannualRate.toSql(annualRate),
      );
    }
    {
      map['start_date'] = Variable<String>(
        $AccountDetailsTable.$converterstartDate.toSql(startDate),
      );
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(
        $AccountDetailsTable.$converterendDaten.toSql(endDate),
      );
    }
    return map;
  }

  AccountDetailsCompanion toCompanion(bool nullToAbsent) {
    return AccountDetailsCompanion(
      assetId: Value(assetId),
      bankId: Value(bankId),
      annualRate: Value(annualRate),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
    );
  }

  factory AccountDetailRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AccountDetailRow(
      assetId: serializer.fromJson<int>(json['assetId']),
      bankId: serializer.fromJson<int>(json['bankId']),
      annualRate: serializer.fromJson<Decimal>(json['annualRate']),
      startDate: serializer.fromJson<LocalDate>(json['startDate']),
      endDate: serializer.fromJson<LocalDate?>(json['endDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<int>(assetId),
      'bankId': serializer.toJson<int>(bankId),
      'annualRate': serializer.toJson<Decimal>(annualRate),
      'startDate': serializer.toJson<LocalDate>(startDate),
      'endDate': serializer.toJson<LocalDate?>(endDate),
    };
  }

  AccountDetailRow copyWith({
    int? assetId,
    int? bankId,
    Decimal? annualRate,
    LocalDate? startDate,
    Value<LocalDate?> endDate = const Value.absent(),
  }) => AccountDetailRow(
    assetId: assetId ?? this.assetId,
    bankId: bankId ?? this.bankId,
    annualRate: annualRate ?? this.annualRate,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
  );
  AccountDetailRow copyWithCompanion(AccountDetailsCompanion data) {
    return AccountDetailRow(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      bankId: data.bankId.present ? data.bankId.value : this.bankId,
      annualRate: data.annualRate.present
          ? data.annualRate.value
          : this.annualRate,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AccountDetailRow(')
          ..write('assetId: $assetId, ')
          ..write('bankId: $bankId, ')
          ..write('annualRate: $annualRate, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(assetId, bankId, annualRate, startDate, endDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AccountDetailRow &&
          other.assetId == this.assetId &&
          other.bankId == this.bankId &&
          other.annualRate == this.annualRate &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate);
}

class AccountDetailsCompanion extends UpdateCompanion<AccountDetailRow> {
  final Value<int> assetId;
  final Value<int> bankId;
  final Value<Decimal> annualRate;
  final Value<LocalDate> startDate;
  final Value<LocalDate?> endDate;
  const AccountDetailsCompanion({
    this.assetId = const Value.absent(),
    this.bankId = const Value.absent(),
    this.annualRate = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
  });
  AccountDetailsCompanion.insert({
    this.assetId = const Value.absent(),
    required int bankId,
    required Decimal annualRate,
    required LocalDate startDate,
    this.endDate = const Value.absent(),
  }) : bankId = Value(bankId),
       annualRate = Value(annualRate),
       startDate = Value(startDate);
  static Insertable<AccountDetailRow> custom({
    Expression<int>? assetId,
    Expression<int>? bankId,
    Expression<String>? annualRate,
    Expression<String>? startDate,
    Expression<String>? endDate,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (bankId != null) 'bank_id': bankId,
      if (annualRate != null) 'annual_rate': annualRate,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
    });
  }

  AccountDetailsCompanion copyWith({
    Value<int>? assetId,
    Value<int>? bankId,
    Value<Decimal>? annualRate,
    Value<LocalDate>? startDate,
    Value<LocalDate?>? endDate,
  }) {
    return AccountDetailsCompanion(
      assetId: assetId ?? this.assetId,
      bankId: bankId ?? this.bankId,
      annualRate: annualRate ?? this.annualRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (bankId.present) {
      map['bank_id'] = Variable<int>(bankId.value);
    }
    if (annualRate.present) {
      map['annual_rate'] = Variable<String>(
        $AccountDetailsTable.$converterannualRate.toSql(annualRate.value),
      );
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $AccountDetailsTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(
        $AccountDetailsTable.$converterendDaten.toSql(endDate.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AccountDetailsCompanion(')
          ..write('assetId: $assetId, ')
          ..write('bankId: $bankId, ')
          ..write('annualRate: $annualRate, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate')
          ..write(')'))
        .toString();
  }
}

class $InvestmentDetailsTable extends InvestmentDetails
    with TableInfo<$InvestmentDetailsTable, InvestmentDetailRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _brokerIdMeta = const VerificationMeta(
    'brokerId',
  );
  @override
  late final GeneratedColumn<int> brokerId = GeneratedColumn<int>(
    'broker_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subgroups (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [assetId, brokerId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvestmentDetailRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    }
    if (data.containsKey('broker_id')) {
      context.handle(
        _brokerIdMeta,
        brokerId.isAcceptableOrUnknown(data['broker_id']!, _brokerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_brokerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  InvestmentDetailRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentDetailRow(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      brokerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}broker_id'],
      )!,
    );
  }

  @override
  $InvestmentDetailsTable createAlias(String alias) {
    return $InvestmentDetailsTable(attachedDatabase, alias);
  }
}

class InvestmentDetailRow extends DataClass
    implements Insertable<InvestmentDetailRow> {
  final int assetId;
  final int brokerId;
  const InvestmentDetailRow({required this.assetId, required this.brokerId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<int>(assetId);
    map['broker_id'] = Variable<int>(brokerId);
    return map;
  }

  InvestmentDetailsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentDetailsCompanion(
      assetId: Value(assetId),
      brokerId: Value(brokerId),
    );
  }

  factory InvestmentDetailRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentDetailRow(
      assetId: serializer.fromJson<int>(json['assetId']),
      brokerId: serializer.fromJson<int>(json['brokerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<int>(assetId),
      'brokerId': serializer.toJson<int>(brokerId),
    };
  }

  InvestmentDetailRow copyWith({int? assetId, int? brokerId}) =>
      InvestmentDetailRow(
        assetId: assetId ?? this.assetId,
        brokerId: brokerId ?? this.brokerId,
      );
  InvestmentDetailRow copyWithCompanion(InvestmentDetailsCompanion data) {
    return InvestmentDetailRow(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      brokerId: data.brokerId.present ? data.brokerId.value : this.brokerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentDetailRow(')
          ..write('assetId: $assetId, ')
          ..write('brokerId: $brokerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assetId, brokerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentDetailRow &&
          other.assetId == this.assetId &&
          other.brokerId == this.brokerId);
}

class InvestmentDetailsCompanion extends UpdateCompanion<InvestmentDetailRow> {
  final Value<int> assetId;
  final Value<int> brokerId;
  const InvestmentDetailsCompanion({
    this.assetId = const Value.absent(),
    this.brokerId = const Value.absent(),
  });
  InvestmentDetailsCompanion.insert({
    this.assetId = const Value.absent(),
    required int brokerId,
  }) : brokerId = Value(brokerId);
  static Insertable<InvestmentDetailRow> custom({
    Expression<int>? assetId,
    Expression<int>? brokerId,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (brokerId != null) 'broker_id': brokerId,
    });
  }

  InvestmentDetailsCompanion copyWith({
    Value<int>? assetId,
    Value<int>? brokerId,
  }) {
    return InvestmentDetailsCompanion(
      assetId: assetId ?? this.assetId,
      brokerId: brokerId ?? this.brokerId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (brokerId.present) {
      map['broker_id'] = Variable<int>(brokerId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentDetailsCompanion(')
          ..write('assetId: $assetId, ')
          ..write('brokerId: $brokerId')
          ..write(')'))
        .toString();
  }
}

class $PropertyDetailsTable extends PropertyDetails
    with TableInfo<$PropertyDetailsTable, PropertyDetailRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PropertyDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _purchasePriceMinorMeta =
      const VerificationMeta('purchasePriceMinor');
  @override
  late final GeneratedColumn<int> purchasePriceMinor = GeneratedColumn<int>(
    'purchase_price_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'CHECK (purchase_price_minor IS NULL OR purchase_price_minor >= 0)',
  );
  @override
  List<GeneratedColumn> get $columns => [assetId, address, purchasePriceMinor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'property_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<PropertyDetailRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('purchase_price_minor')) {
      context.handle(
        _purchasePriceMinorMeta,
        purchasePriceMinor.isAcceptableOrUnknown(
          data['purchase_price_minor']!,
          _purchasePriceMinorMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId};
  @override
  PropertyDetailRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PropertyDetailRow(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      purchasePriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_price_minor'],
      ),
    );
  }

  @override
  $PropertyDetailsTable createAlias(String alias) {
    return $PropertyDetailsTable(attachedDatabase, alias);
  }
}

class PropertyDetailRow extends DataClass
    implements Insertable<PropertyDetailRow> {
  final int assetId;
  final String? address;
  final int? purchasePriceMinor;
  const PropertyDetailRow({
    required this.assetId,
    this.address,
    this.purchasePriceMinor,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<int>(assetId);
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || purchasePriceMinor != null) {
      map['purchase_price_minor'] = Variable<int>(purchasePriceMinor);
    }
    return map;
  }

  PropertyDetailsCompanion toCompanion(bool nullToAbsent) {
    return PropertyDetailsCompanion(
      assetId: Value(assetId),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      purchasePriceMinor: purchasePriceMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePriceMinor),
    );
  }

  factory PropertyDetailRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PropertyDetailRow(
      assetId: serializer.fromJson<int>(json['assetId']),
      address: serializer.fromJson<String?>(json['address']),
      purchasePriceMinor: serializer.fromJson<int?>(json['purchasePriceMinor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<int>(assetId),
      'address': serializer.toJson<String?>(address),
      'purchasePriceMinor': serializer.toJson<int?>(purchasePriceMinor),
    };
  }

  PropertyDetailRow copyWith({
    int? assetId,
    Value<String?> address = const Value.absent(),
    Value<int?> purchasePriceMinor = const Value.absent(),
  }) => PropertyDetailRow(
    assetId: assetId ?? this.assetId,
    address: address.present ? address.value : this.address,
    purchasePriceMinor: purchasePriceMinor.present
        ? purchasePriceMinor.value
        : this.purchasePriceMinor,
  );
  PropertyDetailRow copyWithCompanion(PropertyDetailsCompanion data) {
    return PropertyDetailRow(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      address: data.address.present ? data.address.value : this.address,
      purchasePriceMinor: data.purchasePriceMinor.present
          ? data.purchasePriceMinor.value
          : this.purchasePriceMinor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PropertyDetailRow(')
          ..write('assetId: $assetId, ')
          ..write('address: $address, ')
          ..write('purchasePriceMinor: $purchasePriceMinor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assetId, address, purchasePriceMinor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PropertyDetailRow &&
          other.assetId == this.assetId &&
          other.address == this.address &&
          other.purchasePriceMinor == this.purchasePriceMinor);
}

class PropertyDetailsCompanion extends UpdateCompanion<PropertyDetailRow> {
  final Value<int> assetId;
  final Value<String?> address;
  final Value<int?> purchasePriceMinor;
  const PropertyDetailsCompanion({
    this.assetId = const Value.absent(),
    this.address = const Value.absent(),
    this.purchasePriceMinor = const Value.absent(),
  });
  PropertyDetailsCompanion.insert({
    this.assetId = const Value.absent(),
    this.address = const Value.absent(),
    this.purchasePriceMinor = const Value.absent(),
  });
  static Insertable<PropertyDetailRow> custom({
    Expression<int>? assetId,
    Expression<String>? address,
    Expression<int>? purchasePriceMinor,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (address != null) 'address': address,
      if (purchasePriceMinor != null)
        'purchase_price_minor': purchasePriceMinor,
    });
  }

  PropertyDetailsCompanion copyWith({
    Value<int>? assetId,
    Value<String?>? address,
    Value<int?>? purchasePriceMinor,
  }) {
    return PropertyDetailsCompanion(
      assetId: assetId ?? this.assetId,
      address: address ?? this.address,
      purchasePriceMinor: purchasePriceMinor ?? this.purchasePriceMinor,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (purchasePriceMinor.present) {
      map['purchase_price_minor'] = Variable<int>(purchasePriceMinor.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PropertyDetailsCompanion(')
          ..write('assetId: $assetId, ')
          ..write('address: $address, ')
          ..write('purchasePriceMinor: $purchasePriceMinor')
          ..write(')'))
        .toString();
  }
}

class $AssetValuationsTable extends AssetValuations
    with TableInfo<$AssetValuationsTable, AssetValuationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetValuationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> effectiveOn =
      GeneratedColumn<String>(
        'effective_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($AssetValuationsTable.$convertereffectiveOn);
  static const VerificationMeta _valueMinorMeta = const VerificationMeta(
    'valueMinor',
  );
  @override
  late final GeneratedColumn<int> valueMinor = GeneratedColumn<int>(
    'value_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (value_minor >= 0)',
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> rateToRub =
      GeneratedColumn<String>(
        'rate_to_rub',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($AssetValuationsTable.$converterrateToRub);
  static const VerificationMeta _valueRubMinorMeta = const VerificationMeta(
    'valueRubMinor',
  );
  @override
  late final GeneratedColumn<int> valueRubMinor = GeneratedColumn<int>(
    'value_rub_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (value_rub_minor >= 0)',
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AssetValuationsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    effectiveOn,
    valueMinor,
    currencyCode,
    rateToRub,
    valueRubMinor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_valuations';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetValuationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('value_minor')) {
      context.handle(
        _valueMinorMeta,
        valueMinor.isAcceptableOrUnknown(data['value_minor']!, _valueMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('value_rub_minor')) {
      context.handle(
        _valueRubMinorMeta,
        valueRubMinor.isAcceptableOrUnknown(
          data['value_rub_minor']!,
          _valueRubMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_valueRubMinorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetValuationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetValuationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      effectiveOn: $AssetValuationsTable.$convertereffectiveOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}effective_on'],
        )!,
      ),
      valueMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      ),
      rateToRub: $AssetValuationsTable.$converterrateToRub.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rate_to_rub'],
        )!,
      ),
      valueRubMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}value_rub_minor'],
      )!,
      createdAt: $AssetValuationsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $AssetValuationsTable createAlias(String alias) {
    return $AssetValuationsTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $convertereffectiveOn =
      const LocalDateConverter();
  static TypeConverter<Decimal, String> $converterrateToRub =
      const DecimalConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcTimestampConverter();
}

class AssetValuationRow extends DataClass
    implements Insertable<AssetValuationRow> {
  final int id;
  final int assetId;
  final LocalDate effectiveOn;
  final int valueMinor;

  /// Валюта оценки (M1); `NULL` — валюта актива.
  final String? currencyCode;
  final Decimal rateToRub;
  final int valueRubMinor;
  final DateTime createdAt;
  const AssetValuationRow({
    required this.id,
    required this.assetId,
    required this.effectiveOn,
    required this.valueMinor,
    this.currencyCode,
    required this.rateToRub,
    required this.valueRubMinor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    {
      map['effective_on'] = Variable<String>(
        $AssetValuationsTable.$convertereffectiveOn.toSql(effectiveOn),
      );
    }
    map['value_minor'] = Variable<int>(valueMinor);
    if (!nullToAbsent || currencyCode != null) {
      map['currency_code'] = Variable<String>(currencyCode);
    }
    {
      map['rate_to_rub'] = Variable<String>(
        $AssetValuationsTable.$converterrateToRub.toSql(rateToRub),
      );
    }
    map['value_rub_minor'] = Variable<int>(valueRubMinor);
    {
      map['created_at'] = Variable<String>(
        $AssetValuationsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  AssetValuationsCompanion toCompanion(bool nullToAbsent) {
    return AssetValuationsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      effectiveOn: Value(effectiveOn),
      valueMinor: Value(valueMinor),
      currencyCode: currencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyCode),
      rateToRub: Value(rateToRub),
      valueRubMinor: Value(valueRubMinor),
      createdAt: Value(createdAt),
    );
  }

  factory AssetValuationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetValuationRow(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      effectiveOn: serializer.fromJson<LocalDate>(json['effectiveOn']),
      valueMinor: serializer.fromJson<int>(json['valueMinor']),
      currencyCode: serializer.fromJson<String?>(json['currencyCode']),
      rateToRub: serializer.fromJson<Decimal>(json['rateToRub']),
      valueRubMinor: serializer.fromJson<int>(json['valueRubMinor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'effectiveOn': serializer.toJson<LocalDate>(effectiveOn),
      'valueMinor': serializer.toJson<int>(valueMinor),
      'currencyCode': serializer.toJson<String?>(currencyCode),
      'rateToRub': serializer.toJson<Decimal>(rateToRub),
      'valueRubMinor': serializer.toJson<int>(valueRubMinor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AssetValuationRow copyWith({
    int? id,
    int? assetId,
    LocalDate? effectiveOn,
    int? valueMinor,
    Value<String?> currencyCode = const Value.absent(),
    Decimal? rateToRub,
    int? valueRubMinor,
    DateTime? createdAt,
  }) => AssetValuationRow(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    effectiveOn: effectiveOn ?? this.effectiveOn,
    valueMinor: valueMinor ?? this.valueMinor,
    currencyCode: currencyCode.present ? currencyCode.value : this.currencyCode,
    rateToRub: rateToRub ?? this.rateToRub,
    valueRubMinor: valueRubMinor ?? this.valueRubMinor,
    createdAt: createdAt ?? this.createdAt,
  );
  AssetValuationRow copyWithCompanion(AssetValuationsCompanion data) {
    return AssetValuationRow(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      effectiveOn: data.effectiveOn.present
          ? data.effectiveOn.value
          : this.effectiveOn,
      valueMinor: data.valueMinor.present
          ? data.valueMinor.value
          : this.valueMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      rateToRub: data.rateToRub.present ? data.rateToRub.value : this.rateToRub,
      valueRubMinor: data.valueRubMinor.present
          ? data.valueRubMinor.value
          : this.valueRubMinor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetValuationRow(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('effectiveOn: $effectiveOn, ')
          ..write('valueMinor: $valueMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('rateToRub: $rateToRub, ')
          ..write('valueRubMinor: $valueRubMinor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetId,
    effectiveOn,
    valueMinor,
    currencyCode,
    rateToRub,
    valueRubMinor,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetValuationRow &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.effectiveOn == this.effectiveOn &&
          other.valueMinor == this.valueMinor &&
          other.currencyCode == this.currencyCode &&
          other.rateToRub == this.rateToRub &&
          other.valueRubMinor == this.valueRubMinor &&
          other.createdAt == this.createdAt);
}

class AssetValuationsCompanion extends UpdateCompanion<AssetValuationRow> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<LocalDate> effectiveOn;
  final Value<int> valueMinor;
  final Value<String?> currencyCode;
  final Value<Decimal> rateToRub;
  final Value<int> valueRubMinor;
  final Value<DateTime> createdAt;
  const AssetValuationsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.effectiveOn = const Value.absent(),
    this.valueMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.rateToRub = const Value.absent(),
    this.valueRubMinor = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssetValuationsCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    required LocalDate effectiveOn,
    required int valueMinor,
    this.currencyCode = const Value.absent(),
    required Decimal rateToRub,
    required int valueRubMinor,
    required DateTime createdAt,
  }) : assetId = Value(assetId),
       effectiveOn = Value(effectiveOn),
       valueMinor = Value(valueMinor),
       rateToRub = Value(rateToRub),
       valueRubMinor = Value(valueRubMinor),
       createdAt = Value(createdAt);
  static Insertable<AssetValuationRow> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<String>? effectiveOn,
    Expression<int>? valueMinor,
    Expression<String>? currencyCode,
    Expression<String>? rateToRub,
    Expression<int>? valueRubMinor,
    Expression<String>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (effectiveOn != null) 'effective_on': effectiveOn,
      if (valueMinor != null) 'value_minor': valueMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (rateToRub != null) 'rate_to_rub': rateToRub,
      if (valueRubMinor != null) 'value_rub_minor': valueRubMinor,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssetValuationsCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<LocalDate>? effectiveOn,
    Value<int>? valueMinor,
    Value<String?>? currencyCode,
    Value<Decimal>? rateToRub,
    Value<int>? valueRubMinor,
    Value<DateTime>? createdAt,
  }) {
    return AssetValuationsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      effectiveOn: effectiveOn ?? this.effectiveOn,
      valueMinor: valueMinor ?? this.valueMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      rateToRub: rateToRub ?? this.rateToRub,
      valueRubMinor: valueRubMinor ?? this.valueRubMinor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (effectiveOn.present) {
      map['effective_on'] = Variable<String>(
        $AssetValuationsTable.$convertereffectiveOn.toSql(effectiveOn.value),
      );
    }
    if (valueMinor.present) {
      map['value_minor'] = Variable<int>(valueMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (rateToRub.present) {
      map['rate_to_rub'] = Variable<String>(
        $AssetValuationsTable.$converterrateToRub.toSql(rateToRub.value),
      );
    }
    if (valueRubMinor.present) {
      map['value_rub_minor'] = Variable<int>(valueRubMinor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $AssetValuationsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetValuationsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('effectiveOn: $effectiveOn, ')
          ..write('valueMinor: $valueMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('rateToRub: $rateToRub, ')
          ..write('valueRubMinor: $valueRubMinor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AssetTransfersTable extends AssetTransfers
    with TableInfo<$AssetTransfersTable, AssetTransferRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetTransfersTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AssetTransfersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AssetTransfersTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_transfers';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetTransferRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetTransferRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetTransferRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      createdAt: $AssetTransfersTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $AssetTransfersTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $AssetTransfersTable createAlias(String alias) {
    return $AssetTransfersTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcTimestampConverter();
}

class AssetTransferRow extends DataClass
    implements Insertable<AssetTransferRow> {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AssetTransferRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['created_at'] = Variable<String>(
        $AssetTransfersTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $AssetTransfersTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  AssetTransfersCompanion toCompanion(bool nullToAbsent) {
    return AssetTransfersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AssetTransferRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetTransferRow(
      id: serializer.fromJson<int>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AssetTransferRow copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AssetTransferRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AssetTransferRow copyWithCompanion(AssetTransfersCompanion data) {
    return AssetTransferRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetTransferRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetTransferRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AssetTransfersCompanion extends UpdateCompanion<AssetTransferRow> {
  final Value<int> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AssetTransfersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AssetTransfersCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AssetTransferRow> custom({
    Expression<int>? id,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AssetTransfersCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AssetTransfersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $AssetTransfersTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $AssetTransfersTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetTransfersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AssetTransactionsTable extends AssetTransactions
    with TableInfo<$AssetTransactionsTable, AssetTransactionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetTransactionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AssetTransactionKind, String>
  kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'deposit\', \'withdrawal\', \'transferOut\', \'transferIn\'))',
  ).withConverter<AssetTransactionKind>($AssetTransactionsTable.$converterkind);
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_minor > 0)',
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> occurredOn =
      GeneratedColumn<String>(
        'occurred_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($AssetTransactionsTable.$converteroccurredOn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> rateToRub =
      GeneratedColumn<String>(
        'rate_to_rub',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($AssetTransactionsTable.$converterrateToRub);
  static const VerificationMeta _amountRubMinorMeta = const VerificationMeta(
    'amountRubMinor',
  );
  @override
  late final GeneratedColumn<int> amountRubMinor = GeneratedColumn<int>(
    'amount_rub_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_rub_minor > 0)',
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transferIdMeta = const VerificationMeta(
    'transferId',
  );
  @override
  late final GeneratedColumn<int> transferId = GeneratedColumn<int>(
    'transfer_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asset_transfers (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _revisionNoMeta = const VerificationMeta(
    'revisionNo',
  );
  @override
  late final GeneratedColumn<int> revisionNo = GeneratedColumn<int>(
    'revision_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (revision_no >= 1)',
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AssetTransactionsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AssetTransactionsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($AssetTransactionsTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    kind,
    amountMinor,
    currencyCode,
    occurredOn,
    rateToRub,
    amountRubMinor,
    comment,
    transferId,
    revisionNo,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetTransactionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('amount_rub_minor')) {
      context.handle(
        _amountRubMinorMeta,
        amountRubMinor.isAcceptableOrUnknown(
          data['amount_rub_minor']!,
          _amountRubMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountRubMinorMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('transfer_id')) {
      context.handle(
        _transferIdMeta,
        transferId.isAcceptableOrUnknown(data['transfer_id']!, _transferIdMeta),
      );
    }
    if (data.containsKey('revision_no')) {
      context.handle(
        _revisionNoMeta,
        revisionNo.isAcceptableOrUnknown(data['revision_no']!, _revisionNoMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionNoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetTransactionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetTransactionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      kind: $AssetTransactionsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      ),
      occurredOn: $AssetTransactionsTable.$converteroccurredOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}occurred_on'],
        )!,
      ),
      rateToRub: $AssetTransactionsTable.$converterrateToRub.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rate_to_rub'],
        )!,
      ),
      amountRubMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_rub_minor'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      transferId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transfer_id'],
      ),
      revisionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_no'],
      )!,
      createdAt: $AssetTransactionsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $AssetTransactionsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $AssetTransactionsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $AssetTransactionsTable createAlias(String alias) {
    return $AssetTransactionsTable(attachedDatabase, alias);
  }

  static TypeConverter<AssetTransactionKind, String> $converterkind =
      const AssetTransactionKindConverter();
  static TypeConverter<LocalDate, String> $converteroccurredOn =
      const LocalDateConverter();
  static TypeConverter<Decimal, String> $converterrateToRub =
      const DecimalConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class AssetTransactionRow extends DataClass
    implements Insertable<AssetTransactionRow> {
  final int id;
  final int assetId;
  final AssetTransactionKind kind;
  final int amountMinor;

  /// Валюта операции (M1); `NULL` — валюта актива.
  final String? currencyCode;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final int amountRubMinor;
  final String? comment;
  final int? transferId;
  final int revisionNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const AssetTransactionRow({
    required this.id,
    required this.assetId,
    required this.kind,
    required this.amountMinor,
    this.currencyCode,
    required this.occurredOn,
    required this.rateToRub,
    required this.amountRubMinor,
    this.comment,
    this.transferId,
    required this.revisionNo,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    {
      map['kind'] = Variable<String>(
        $AssetTransactionsTable.$converterkind.toSql(kind),
      );
    }
    map['amount_minor'] = Variable<int>(amountMinor);
    if (!nullToAbsent || currencyCode != null) {
      map['currency_code'] = Variable<String>(currencyCode);
    }
    {
      map['occurred_on'] = Variable<String>(
        $AssetTransactionsTable.$converteroccurredOn.toSql(occurredOn),
      );
    }
    {
      map['rate_to_rub'] = Variable<String>(
        $AssetTransactionsTable.$converterrateToRub.toSql(rateToRub),
      );
    }
    map['amount_rub_minor'] = Variable<int>(amountRubMinor);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || transferId != null) {
      map['transfer_id'] = Variable<int>(transferId);
    }
    map['revision_no'] = Variable<int>(revisionNo);
    {
      map['created_at'] = Variable<String>(
        $AssetTransactionsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $AssetTransactionsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $AssetTransactionsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  AssetTransactionsCompanion toCompanion(bool nullToAbsent) {
    return AssetTransactionsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      kind: Value(kind),
      amountMinor: Value(amountMinor),
      currencyCode: currencyCode == null && nullToAbsent
          ? const Value.absent()
          : Value(currencyCode),
      occurredOn: Value(occurredOn),
      rateToRub: Value(rateToRub),
      amountRubMinor: Value(amountRubMinor),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      transferId: transferId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferId),
      revisionNo: Value(revisionNo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory AssetTransactionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetTransactionRow(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      kind: serializer.fromJson<AssetTransactionKind>(json['kind']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String?>(json['currencyCode']),
      occurredOn: serializer.fromJson<LocalDate>(json['occurredOn']),
      rateToRub: serializer.fromJson<Decimal>(json['rateToRub']),
      amountRubMinor: serializer.fromJson<int>(json['amountRubMinor']),
      comment: serializer.fromJson<String?>(json['comment']),
      transferId: serializer.fromJson<int?>(json['transferId']),
      revisionNo: serializer.fromJson<int>(json['revisionNo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'kind': serializer.toJson<AssetTransactionKind>(kind),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String?>(currencyCode),
      'occurredOn': serializer.toJson<LocalDate>(occurredOn),
      'rateToRub': serializer.toJson<Decimal>(rateToRub),
      'amountRubMinor': serializer.toJson<int>(amountRubMinor),
      'comment': serializer.toJson<String?>(comment),
      'transferId': serializer.toJson<int?>(transferId),
      'revisionNo': serializer.toJson<int>(revisionNo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  AssetTransactionRow copyWith({
    int? id,
    int? assetId,
    AssetTransactionKind? kind,
    int? amountMinor,
    Value<String?> currencyCode = const Value.absent(),
    LocalDate? occurredOn,
    Decimal? rateToRub,
    int? amountRubMinor,
    Value<String?> comment = const Value.absent(),
    Value<int?> transferId = const Value.absent(),
    int? revisionNo,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => AssetTransactionRow(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    kind: kind ?? this.kind,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode.present ? currencyCode.value : this.currencyCode,
    occurredOn: occurredOn ?? this.occurredOn,
    rateToRub: rateToRub ?? this.rateToRub,
    amountRubMinor: amountRubMinor ?? this.amountRubMinor,
    comment: comment.present ? comment.value : this.comment,
    transferId: transferId.present ? transferId.value : this.transferId,
    revisionNo: revisionNo ?? this.revisionNo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  AssetTransactionRow copyWithCompanion(AssetTransactionsCompanion data) {
    return AssetTransactionRow(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      kind: data.kind.present ? data.kind.value : this.kind,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      occurredOn: data.occurredOn.present
          ? data.occurredOn.value
          : this.occurredOn,
      rateToRub: data.rateToRub.present ? data.rateToRub.value : this.rateToRub,
      amountRubMinor: data.amountRubMinor.present
          ? data.amountRubMinor.value
          : this.amountRubMinor,
      comment: data.comment.present ? data.comment.value : this.comment,
      transferId: data.transferId.present
          ? data.transferId.value
          : this.transferId,
      revisionNo: data.revisionNo.present
          ? data.revisionNo.value
          : this.revisionNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetTransactionRow(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('rateToRub: $rateToRub, ')
          ..write('amountRubMinor: $amountRubMinor, ')
          ..write('comment: $comment, ')
          ..write('transferId: $transferId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetId,
    kind,
    amountMinor,
    currencyCode,
    occurredOn,
    rateToRub,
    amountRubMinor,
    comment,
    transferId,
    revisionNo,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetTransactionRow &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.kind == this.kind &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.occurredOn == this.occurredOn &&
          other.rateToRub == this.rateToRub &&
          other.amountRubMinor == this.amountRubMinor &&
          other.comment == this.comment &&
          other.transferId == this.transferId &&
          other.revisionNo == this.revisionNo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class AssetTransactionsCompanion extends UpdateCompanion<AssetTransactionRow> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<AssetTransactionKind> kind;
  final Value<int> amountMinor;
  final Value<String?> currencyCode;
  final Value<LocalDate> occurredOn;
  final Value<Decimal> rateToRub;
  final Value<int> amountRubMinor;
  final Value<String?> comment;
  final Value<int?> transferId;
  final Value<int> revisionNo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const AssetTransactionsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.kind = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.rateToRub = const Value.absent(),
    this.amountRubMinor = const Value.absent(),
    this.comment = const Value.absent(),
    this.transferId = const Value.absent(),
    this.revisionNo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  AssetTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    required AssetTransactionKind kind,
    required int amountMinor,
    this.currencyCode = const Value.absent(),
    required LocalDate occurredOn,
    required Decimal rateToRub,
    required int amountRubMinor,
    this.comment = const Value.absent(),
    this.transferId = const Value.absent(),
    required int revisionNo,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : assetId = Value(assetId),
       kind = Value(kind),
       amountMinor = Value(amountMinor),
       occurredOn = Value(occurredOn),
       rateToRub = Value(rateToRub),
       amountRubMinor = Value(amountRubMinor),
       revisionNo = Value(revisionNo),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AssetTransactionRow> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<String>? kind,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? occurredOn,
    Expression<String>? rateToRub,
    Expression<int>? amountRubMinor,
    Expression<String>? comment,
    Expression<int>? transferId,
    Expression<int>? revisionNo,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (kind != null) 'kind': kind,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (rateToRub != null) 'rate_to_rub': rateToRub,
      if (amountRubMinor != null) 'amount_rub_minor': amountRubMinor,
      if (comment != null) 'comment': comment,
      if (transferId != null) 'transfer_id': transferId,
      if (revisionNo != null) 'revision_no': revisionNo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  AssetTransactionsCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<AssetTransactionKind>? kind,
    Value<int>? amountMinor,
    Value<String?>? currencyCode,
    Value<LocalDate>? occurredOn,
    Value<Decimal>? rateToRub,
    Value<int>? amountRubMinor,
    Value<String?>? comment,
    Value<int?>? transferId,
    Value<int>? revisionNo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return AssetTransactionsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      kind: kind ?? this.kind,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      occurredOn: occurredOn ?? this.occurredOn,
      rateToRub: rateToRub ?? this.rateToRub,
      amountRubMinor: amountRubMinor ?? this.amountRubMinor,
      comment: comment ?? this.comment,
      transferId: transferId ?? this.transferId,
      revisionNo: revisionNo ?? this.revisionNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $AssetTransactionsTable.$converterkind.toSql(kind.value),
      );
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<String>(
        $AssetTransactionsTable.$converteroccurredOn.toSql(occurredOn.value),
      );
    }
    if (rateToRub.present) {
      map['rate_to_rub'] = Variable<String>(
        $AssetTransactionsTable.$converterrateToRub.toSql(rateToRub.value),
      );
    }
    if (amountRubMinor.present) {
      map['amount_rub_minor'] = Variable<int>(amountRubMinor.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (transferId.present) {
      map['transfer_id'] = Variable<int>(transferId.value);
    }
    if (revisionNo.present) {
      map['revision_no'] = Variable<int>(revisionNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $AssetTransactionsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $AssetTransactionsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $AssetTransactionsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('kind: $kind, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('rateToRub: $rateToRub, ')
          ..write('amountRubMinor: $amountRubMinor, ')
          ..write('comment: $comment, ')
          ..write('transferId: $transferId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $AssetTransactionRevisionsTable extends AssetTransactionRevisions
    with
        TableInfo<
          $AssetTransactionRevisionsTable,
          AssetTransactionRevisionRow
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetTransactionRevisionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<int> transactionId = GeneratedColumn<int>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asset_transactions (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _revisionNoMeta = const VerificationMeta(
    'revisionNo',
  );
  @override
  late final GeneratedColumn<int> revisionNo = GeneratedColumn<int>(
    'revision_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (revision_no >= 1)',
  );
  @override
  late final GeneratedColumnWithTypeConverter<RevisionAction, String> action =
      GeneratedColumn<String>(
        'action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RevisionAction>(
        $AssetTransactionRevisionsTable.$converteraction,
      );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> changedAt =
      GeneratedColumn<String>(
        'changed_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $AssetTransactionRevisionsTable.$converterchangedAt,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    revisionNo,
    action,
    snapshotJson,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_transaction_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetTransactionRevisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('revision_no')) {
      context.handle(
        _revisionNoMeta,
        revisionNo.isAcceptableOrUnknown(data['revision_no']!, _revisionNoMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionNoMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {transactionId, revisionNo},
  ];
  @override
  AssetTransactionRevisionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetTransactionRevisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_id'],
      )!,
      revisionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_no'],
      )!,
      action: $AssetTransactionRevisionsTable.$converteraction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action'],
        )!,
      ),
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      )!,
      changedAt: $AssetTransactionRevisionsTable.$converterchangedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}changed_at'],
        )!,
      ),
    );
  }

  @override
  $AssetTransactionRevisionsTable createAlias(String alias) {
    return $AssetTransactionRevisionsTable(attachedDatabase, alias);
  }

  static TypeConverter<RevisionAction, String> $converteraction =
      const RevisionActionConverter();
  static TypeConverter<DateTime, String> $converterchangedAt =
      const UtcTimestampConverter();
}

class AssetTransactionRevisionRow extends DataClass
    implements Insertable<AssetTransactionRevisionRow> {
  final int id;
  final int transactionId;
  final int revisionNo;
  final RevisionAction action;
  final String snapshotJson;
  final DateTime changedAt;
  const AssetTransactionRevisionRow({
    required this.id,
    required this.transactionId,
    required this.revisionNo,
    required this.action,
    required this.snapshotJson,
    required this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['transaction_id'] = Variable<int>(transactionId);
    map['revision_no'] = Variable<int>(revisionNo);
    {
      map['action'] = Variable<String>(
        $AssetTransactionRevisionsTable.$converteraction.toSql(action),
      );
    }
    map['snapshot_json'] = Variable<String>(snapshotJson);
    {
      map['changed_at'] = Variable<String>(
        $AssetTransactionRevisionsTable.$converterchangedAt.toSql(changedAt),
      );
    }
    return map;
  }

  AssetTransactionRevisionsCompanion toCompanion(bool nullToAbsent) {
    return AssetTransactionRevisionsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      revisionNo: Value(revisionNo),
      action: Value(action),
      snapshotJson: Value(snapshotJson),
      changedAt: Value(changedAt),
    );
  }

  factory AssetTransactionRevisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetTransactionRevisionRow(
      id: serializer.fromJson<int>(json['id']),
      transactionId: serializer.fromJson<int>(json['transactionId']),
      revisionNo: serializer.fromJson<int>(json['revisionNo']),
      action: serializer.fromJson<RevisionAction>(json['action']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'transactionId': serializer.toJson<int>(transactionId),
      'revisionNo': serializer.toJson<int>(revisionNo),
      'action': serializer.toJson<RevisionAction>(action),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'changedAt': serializer.toJson<DateTime>(changedAt),
    };
  }

  AssetTransactionRevisionRow copyWith({
    int? id,
    int? transactionId,
    int? revisionNo,
    RevisionAction? action,
    String? snapshotJson,
    DateTime? changedAt,
  }) => AssetTransactionRevisionRow(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    revisionNo: revisionNo ?? this.revisionNo,
    action: action ?? this.action,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    changedAt: changedAt ?? this.changedAt,
  );
  AssetTransactionRevisionRow copyWithCompanion(
    AssetTransactionRevisionsCompanion data,
  ) {
    return AssetTransactionRevisionRow(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      revisionNo: data.revisionNo.present
          ? data.revisionNo.value
          : this.revisionNo,
      action: data.action.present ? data.action.value : this.action,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetTransactionRevisionRow(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('action: $action, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    revisionNo,
    action,
    snapshotJson,
    changedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetTransactionRevisionRow &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.revisionNo == this.revisionNo &&
          other.action == this.action &&
          other.snapshotJson == this.snapshotJson &&
          other.changedAt == this.changedAt);
}

class AssetTransactionRevisionsCompanion
    extends UpdateCompanion<AssetTransactionRevisionRow> {
  final Value<int> id;
  final Value<int> transactionId;
  final Value<int> revisionNo;
  final Value<RevisionAction> action;
  final Value<String> snapshotJson;
  final Value<DateTime> changedAt;
  const AssetTransactionRevisionsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.revisionNo = const Value.absent(),
    this.action = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.changedAt = const Value.absent(),
  });
  AssetTransactionRevisionsCompanion.insert({
    this.id = const Value.absent(),
    required int transactionId,
    required int revisionNo,
    required RevisionAction action,
    required String snapshotJson,
    required DateTime changedAt,
  }) : transactionId = Value(transactionId),
       revisionNo = Value(revisionNo),
       action = Value(action),
       snapshotJson = Value(snapshotJson),
       changedAt = Value(changedAt);
  static Insertable<AssetTransactionRevisionRow> custom({
    Expression<int>? id,
    Expression<int>? transactionId,
    Expression<int>? revisionNo,
    Expression<String>? action,
    Expression<String>? snapshotJson,
    Expression<String>? changedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (revisionNo != null) 'revision_no': revisionNo,
      if (action != null) 'action': action,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (changedAt != null) 'changed_at': changedAt,
    });
  }

  AssetTransactionRevisionsCompanion copyWith({
    Value<int>? id,
    Value<int>? transactionId,
    Value<int>? revisionNo,
    Value<RevisionAction>? action,
    Value<String>? snapshotJson,
    Value<DateTime>? changedAt,
  }) {
    return AssetTransactionRevisionsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      revisionNo: revisionNo ?? this.revisionNo,
      action: action ?? this.action,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<int>(transactionId.value);
    }
    if (revisionNo.present) {
      map['revision_no'] = Variable<int>(revisionNo.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(
        $AssetTransactionRevisionsTable.$converteraction.toSql(action.value),
      );
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<String>(
        $AssetTransactionRevisionsTable.$converterchangedAt.toSql(
          changedAt.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetTransactionRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('action: $action, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<CashflowKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL CHECK (kind IN (\'income\', \'expense\'))',
      ).withConverter<CashflowKind>($CategoriesTable.$converterkind);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorKeyMeta = const VerificationMeta(
    'colorKey',
  );
  @override
  late final GeneratedColumn<String> colorKey = GeneratedColumn<String>(
    'color_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPresetMeta = const VerificationMeta(
    'isPreset',
  );
  @override
  late final GeneratedColumn<bool> isPreset = GeneratedColumn<bool>(
    'is_preset',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_preset" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> archivedAt =
      GeneratedColumn<String>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CategoriesTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    name,
    normalizedName,
    colorKey,
    iconKey,
    isPreset,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('color_key')) {
      context.handle(
        _colorKeyMeta,
        colorKey.isAcceptableOrUnknown(data['color_key']!, _colorKeyMeta),
      );
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    }
    if (data.containsKey('is_preset')) {
      context.handle(
        _isPresetMeta,
        isPreset.isAcceptableOrUnknown(data['is_preset']!, _isPresetMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: $CategoriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      colorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_key'],
      ),
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      ),
      isPreset: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_preset'],
      )!,
      archivedAt: $CategoriesTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }

  static TypeConverter<CashflowKind, String> $converterkind =
      const CashflowKindConverter();
  static TypeConverter<DateTime, String> $converterarchivedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime?, String?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final CashflowKind kind;
  final String name;
  final String normalizedName;
  final String? colorKey;
  final String? iconKey;
  final bool isPreset;
  final DateTime? archivedAt;
  const CategoryRow({
    required this.id,
    required this.kind,
    required this.name,
    required this.normalizedName,
    this.colorKey,
    this.iconKey,
    required this.isPreset,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind),
      );
    }
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || colorKey != null) {
      map['color_key'] = Variable<String>(colorKey);
    }
    if (!nullToAbsent || iconKey != null) {
      map['icon_key'] = Variable<String>(iconKey);
    }
    map['is_preset'] = Variable<bool>(isPreset);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<String>(
        $CategoriesTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      kind: Value(kind),
      name: Value(name),
      normalizedName: Value(normalizedName),
      colorKey: colorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(colorKey),
      iconKey: iconKey == null && nullToAbsent
          ? const Value.absent()
          : Value(iconKey),
      isPreset: Value(isPreset),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<CashflowKind>(json['kind']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      colorKey: serializer.fromJson<String?>(json['colorKey']),
      iconKey: serializer.fromJson<String?>(json['iconKey']),
      isPreset: serializer.fromJson<bool>(json['isPreset']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<CashflowKind>(kind),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'colorKey': serializer.toJson<String?>(colorKey),
      'iconKey': serializer.toJson<String?>(iconKey),
      'isPreset': serializer.toJson<bool>(isPreset),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  CategoryRow copyWith({
    int? id,
    CashflowKind? kind,
    String? name,
    String? normalizedName,
    Value<String?> colorKey = const Value.absent(),
    Value<String?> iconKey = const Value.absent(),
    bool? isPreset,
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => CategoryRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    colorKey: colorKey.present ? colorKey.value : this.colorKey,
    iconKey: iconKey.present ? iconKey.value : this.iconKey,
    isPreset: isPreset ?? this.isPreset,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      colorKey: data.colorKey.present ? data.colorKey.value : this.colorKey,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      isPreset: data.isPreset.present ? data.isPreset.value : this.isPreset,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('colorKey: $colorKey, ')
          ..write('iconKey: $iconKey, ')
          ..write('isPreset: $isPreset, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    name,
    normalizedName,
    colorKey,
    iconKey,
    isPreset,
    archivedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.colorKey == this.colorKey &&
          other.iconKey == this.iconKey &&
          other.isPreset == this.isPreset &&
          other.archivedAt == this.archivedAt);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<CashflowKind> kind;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<String?> colorKey;
  final Value<String?> iconKey;
  final Value<bool> isPreset;
  final Value<DateTime?> archivedAt;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.archivedAt = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required CashflowKind kind,
    required String name,
    required String normalizedName,
    this.colorKey = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.isPreset = const Value.absent(),
    this.archivedAt = const Value.absent(),
  }) : kind = Value(kind),
       name = Value(name),
       normalizedName = Value(normalizedName);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<String>? colorKey,
    Expression<String>? iconKey,
    Expression<bool>? isPreset,
    Expression<String>? archivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (colorKey != null) 'color_key': colorKey,
      if (iconKey != null) 'icon_key': iconKey,
      if (isPreset != null) 'is_preset': isPreset,
      if (archivedAt != null) 'archived_at': archivedAt,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<CashflowKind>? kind,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<String?>? colorKey,
    Value<String?>? iconKey,
    Value<bool>? isPreset,
    Value<DateTime?>? archivedAt,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      colorKey: colorKey ?? this.colorKey,
      iconKey: iconKey ?? this.iconKey,
      isPreset: isPreset ?? this.isPreset,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CategoriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (colorKey.present) {
      map['color_key'] = Variable<String>(colorKey.value);
    }
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (isPreset.present) {
      map['is_preset'] = Variable<bool>(isPreset.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<String>(
        $CategoriesTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('colorKey: $colorKey, ')
          ..write('iconKey: $iconKey, ')
          ..write('isPreset: $isPreset, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }
}

class $RecurringCashflowRulesTable extends RecurringCashflowRules
    with TableInfo<$RecurringCashflowRulesTable, RecurringCashflowRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringCashflowRulesTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<RecurringStrategy, String>
  strategy =
      GeneratedColumn<String>(
        'strategy',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL CHECK (strategy IN (\'fixed\', \'deposit_interest\'))',
      ).withConverter<RecurringStrategy>(
        $RecurringCashflowRulesTable.$converterstrategy,
      );
  @override
  late final GeneratedColumnWithTypeConverter<CashflowKind, String>
  kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (kind IN (\'income\', \'expense\'))',
  ).withConverter<CashflowKind>($RecurringCashflowRulesTable.$converterkind);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (amount_minor IS NULL OR amount_minor > 0)',
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<int> propertyId = GeneratedColumn<int>(
    'property_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _affectsBalanceMeta = const VerificationMeta(
    'affectsBalance',
  );
  @override
  late final GeneratedColumn<bool> affectsBalance = GeneratedColumn<bool>(
    'affects_balance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("affects_balance" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> startDate =
      GeneratedColumn<String>(
        'start_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>(
        $RecurringCashflowRulesTable.$converterstartDate,
      );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> endDate =
      GeneratedColumn<String>(
        'end_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>(
        $RecurringCashflowRulesTable.$converterendDaten,
      );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastGeneratedPeriodMeta =
      const VerificationMeta('lastGeneratedPeriod');
  @override
  late final GeneratedColumn<String> lastGeneratedPeriod =
      GeneratedColumn<String>(
        'last_generated_period',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $RecurringCashflowRulesTable.$convertercreatedAt,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $RecurringCashflowRulesTable.$converterupdatedAt,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>(
        $RecurringCashflowRulesTable.$converterdeletedAtn,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    strategy,
    kind,
    categoryId,
    amountMinor,
    currencyCode,
    accountId,
    propertyId,
    affectsBalance,
    startDate,
    endDate,
    comment,
    lastGeneratedPeriod,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_cashflow_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringCashflowRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    }
    if (data.containsKey('affects_balance')) {
      context.handle(
        _affectsBalanceMeta,
        affectsBalance.isAcceptableOrUnknown(
          data['affects_balance']!,
          _affectsBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_affectsBalanceMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('last_generated_period')) {
      context.handle(
        _lastGeneratedPeriodMeta,
        lastGeneratedPeriod.isAcceptableOrUnknown(
          data['last_generated_period']!,
          _lastGeneratedPeriodMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringCashflowRuleRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringCashflowRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      strategy: $RecurringCashflowRulesTable.$converterstrategy.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}strategy'],
        )!,
      ),
      kind: $RecurringCashflowRulesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}property_id'],
      ),
      affectsBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}affects_balance'],
      )!,
      startDate: $RecurringCashflowRulesTable.$converterstartDate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}start_date'],
        )!,
      ),
      endDate: $RecurringCashflowRulesTable.$converterendDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}end_date'],
        ),
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      lastGeneratedPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_generated_period'],
      ),
      createdAt: $RecurringCashflowRulesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $RecurringCashflowRulesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $RecurringCashflowRulesTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $RecurringCashflowRulesTable createAlias(String alias) {
    return $RecurringCashflowRulesTable(attachedDatabase, alias);
  }

  static TypeConverter<RecurringStrategy, String> $converterstrategy =
      const RecurringStrategyConverter();
  static TypeConverter<CashflowKind, String> $converterkind =
      const CashflowKindConverter();
  static TypeConverter<LocalDate, String> $converterstartDate =
      const LocalDateConverter();
  static TypeConverter<LocalDate, String> $converterendDate =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $converterendDaten =
      NullAwareTypeConverter.wrap($converterendDate);
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class RecurringCashflowRuleRow extends DataClass
    implements Insertable<RecurringCashflowRuleRow> {
  final int id;
  final RecurringStrategy strategy;
  final CashflowKind kind;
  final int categoryId;
  final int? amountMinor;
  final String currencyCode;
  final int? accountId;
  final int? propertyId;
  final bool affectsBalance;
  final LocalDate startDate;
  final LocalDate? endDate;
  final String? comment;
  final String? lastGeneratedPeriod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const RecurringCashflowRuleRow({
    required this.id,
    required this.strategy,
    required this.kind,
    required this.categoryId,
    this.amountMinor,
    required this.currencyCode,
    this.accountId,
    this.propertyId,
    required this.affectsBalance,
    required this.startDate,
    this.endDate,
    this.comment,
    this.lastGeneratedPeriod,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['strategy'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterstrategy.toSql(strategy),
      );
    }
    {
      map['kind'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterkind.toSql(kind),
      );
    }
    map['category_id'] = Variable<int>(categoryId);
    if (!nullToAbsent || amountMinor != null) {
      map['amount_minor'] = Variable<int>(amountMinor);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || propertyId != null) {
      map['property_id'] = Variable<int>(propertyId);
    }
    map['affects_balance'] = Variable<bool>(affectsBalance);
    {
      map['start_date'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterstartDate.toSql(startDate),
      );
    }
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterendDaten.toSql(endDate),
      );
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || lastGeneratedPeriod != null) {
      map['last_generated_period'] = Variable<String>(lastGeneratedPeriod);
    }
    {
      map['created_at'] = Variable<String>(
        $RecurringCashflowRulesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  RecurringCashflowRulesCompanion toCompanion(bool nullToAbsent) {
    return RecurringCashflowRulesCompanion(
      id: Value(id),
      strategy: Value(strategy),
      kind: Value(kind),
      categoryId: Value(categoryId),
      amountMinor: amountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(amountMinor),
      currencyCode: Value(currencyCode),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      propertyId: propertyId == null && nullToAbsent
          ? const Value.absent()
          : Value(propertyId),
      affectsBalance: Value(affectsBalance),
      startDate: Value(startDate),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      lastGeneratedPeriod: lastGeneratedPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(lastGeneratedPeriod),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory RecurringCashflowRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringCashflowRuleRow(
      id: serializer.fromJson<int>(json['id']),
      strategy: serializer.fromJson<RecurringStrategy>(json['strategy']),
      kind: serializer.fromJson<CashflowKind>(json['kind']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      amountMinor: serializer.fromJson<int?>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      propertyId: serializer.fromJson<int?>(json['propertyId']),
      affectsBalance: serializer.fromJson<bool>(json['affectsBalance']),
      startDate: serializer.fromJson<LocalDate>(json['startDate']),
      endDate: serializer.fromJson<LocalDate?>(json['endDate']),
      comment: serializer.fromJson<String?>(json['comment']),
      lastGeneratedPeriod: serializer.fromJson<String?>(
        json['lastGeneratedPeriod'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'strategy': serializer.toJson<RecurringStrategy>(strategy),
      'kind': serializer.toJson<CashflowKind>(kind),
      'categoryId': serializer.toJson<int>(categoryId),
      'amountMinor': serializer.toJson<int?>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'accountId': serializer.toJson<int?>(accountId),
      'propertyId': serializer.toJson<int?>(propertyId),
      'affectsBalance': serializer.toJson<bool>(affectsBalance),
      'startDate': serializer.toJson<LocalDate>(startDate),
      'endDate': serializer.toJson<LocalDate?>(endDate),
      'comment': serializer.toJson<String?>(comment),
      'lastGeneratedPeriod': serializer.toJson<String?>(lastGeneratedPeriod),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  RecurringCashflowRuleRow copyWith({
    int? id,
    RecurringStrategy? strategy,
    CashflowKind? kind,
    int? categoryId,
    Value<int?> amountMinor = const Value.absent(),
    String? currencyCode,
    Value<int?> accountId = const Value.absent(),
    Value<int?> propertyId = const Value.absent(),
    bool? affectsBalance,
    LocalDate? startDate,
    Value<LocalDate?> endDate = const Value.absent(),
    Value<String?> comment = const Value.absent(),
    Value<String?> lastGeneratedPeriod = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => RecurringCashflowRuleRow(
    id: id ?? this.id,
    strategy: strategy ?? this.strategy,
    kind: kind ?? this.kind,
    categoryId: categoryId ?? this.categoryId,
    amountMinor: amountMinor.present ? amountMinor.value : this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    accountId: accountId.present ? accountId.value : this.accountId,
    propertyId: propertyId.present ? propertyId.value : this.propertyId,
    affectsBalance: affectsBalance ?? this.affectsBalance,
    startDate: startDate ?? this.startDate,
    endDate: endDate.present ? endDate.value : this.endDate,
    comment: comment.present ? comment.value : this.comment,
    lastGeneratedPeriod: lastGeneratedPeriod.present
        ? lastGeneratedPeriod.value
        : this.lastGeneratedPeriod,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  RecurringCashflowRuleRow copyWithCompanion(
    RecurringCashflowRulesCompanion data,
  ) {
    return RecurringCashflowRuleRow(
      id: data.id.present ? data.id.value : this.id,
      strategy: data.strategy.present ? data.strategy.value : this.strategy,
      kind: data.kind.present ? data.kind.value : this.kind,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      affectsBalance: data.affectsBalance.present
          ? data.affectsBalance.value
          : this.affectsBalance,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      comment: data.comment.present ? data.comment.value : this.comment,
      lastGeneratedPeriod: data.lastGeneratedPeriod.present
          ? data.lastGeneratedPeriod.value
          : this.lastGeneratedPeriod,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringCashflowRuleRow(')
          ..write('id: $id, ')
          ..write('strategy: $strategy, ')
          ..write('kind: $kind, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('accountId: $accountId, ')
          ..write('propertyId: $propertyId, ')
          ..write('affectsBalance: $affectsBalance, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('comment: $comment, ')
          ..write('lastGeneratedPeriod: $lastGeneratedPeriod, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    strategy,
    kind,
    categoryId,
    amountMinor,
    currencyCode,
    accountId,
    propertyId,
    affectsBalance,
    startDate,
    endDate,
    comment,
    lastGeneratedPeriod,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringCashflowRuleRow &&
          other.id == this.id &&
          other.strategy == this.strategy &&
          other.kind == this.kind &&
          other.categoryId == this.categoryId &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.accountId == this.accountId &&
          other.propertyId == this.propertyId &&
          other.affectsBalance == this.affectsBalance &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.comment == this.comment &&
          other.lastGeneratedPeriod == this.lastGeneratedPeriod &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class RecurringCashflowRulesCompanion
    extends UpdateCompanion<RecurringCashflowRuleRow> {
  final Value<int> id;
  final Value<RecurringStrategy> strategy;
  final Value<CashflowKind> kind;
  final Value<int> categoryId;
  final Value<int?> amountMinor;
  final Value<String> currencyCode;
  final Value<int?> accountId;
  final Value<int?> propertyId;
  final Value<bool> affectsBalance;
  final Value<LocalDate> startDate;
  final Value<LocalDate?> endDate;
  final Value<String?> comment;
  final Value<String?> lastGeneratedPeriod;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const RecurringCashflowRulesCompanion({
    this.id = const Value.absent(),
    this.strategy = const Value.absent(),
    this.kind = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.accountId = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.affectsBalance = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.comment = const Value.absent(),
    this.lastGeneratedPeriod = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  RecurringCashflowRulesCompanion.insert({
    this.id = const Value.absent(),
    required RecurringStrategy strategy,
    required CashflowKind kind,
    required int categoryId,
    this.amountMinor = const Value.absent(),
    required String currencyCode,
    this.accountId = const Value.absent(),
    this.propertyId = const Value.absent(),
    required bool affectsBalance,
    required LocalDate startDate,
    this.endDate = const Value.absent(),
    this.comment = const Value.absent(),
    this.lastGeneratedPeriod = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : strategy = Value(strategy),
       kind = Value(kind),
       categoryId = Value(categoryId),
       currencyCode = Value(currencyCode),
       affectsBalance = Value(affectsBalance),
       startDate = Value(startDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<RecurringCashflowRuleRow> custom({
    Expression<int>? id,
    Expression<String>? strategy,
    Expression<String>? kind,
    Expression<int>? categoryId,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<int>? accountId,
    Expression<int>? propertyId,
    Expression<bool>? affectsBalance,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<String>? comment,
    Expression<String>? lastGeneratedPeriod,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (strategy != null) 'strategy': strategy,
      if (kind != null) 'kind': kind,
      if (categoryId != null) 'category_id': categoryId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (accountId != null) 'account_id': accountId,
      if (propertyId != null) 'property_id': propertyId,
      if (affectsBalance != null) 'affects_balance': affectsBalance,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (comment != null) 'comment': comment,
      if (lastGeneratedPeriod != null)
        'last_generated_period': lastGeneratedPeriod,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  RecurringCashflowRulesCompanion copyWith({
    Value<int>? id,
    Value<RecurringStrategy>? strategy,
    Value<CashflowKind>? kind,
    Value<int>? categoryId,
    Value<int?>? amountMinor,
    Value<String>? currencyCode,
    Value<int?>? accountId,
    Value<int?>? propertyId,
    Value<bool>? affectsBalance,
    Value<LocalDate>? startDate,
    Value<LocalDate?>? endDate,
    Value<String?>? comment,
    Value<String?>? lastGeneratedPeriod,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return RecurringCashflowRulesCompanion(
      id: id ?? this.id,
      strategy: strategy ?? this.strategy,
      kind: kind ?? this.kind,
      categoryId: categoryId ?? this.categoryId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      accountId: accountId ?? this.accountId,
      propertyId: propertyId ?? this.propertyId,
      affectsBalance: affectsBalance ?? this.affectsBalance,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      comment: comment ?? this.comment,
      lastGeneratedPeriod: lastGeneratedPeriod ?? this.lastGeneratedPeriod,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (strategy.present) {
      map['strategy'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterstrategy.toSql(strategy.value),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterkind.toSql(kind.value),
      );
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<int>(propertyId.value);
    }
    if (affectsBalance.present) {
      map['affects_balance'] = Variable<bool>(affectsBalance.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterstartDate.toSql(startDate.value),
      );
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterendDaten.toSql(endDate.value),
      );
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (lastGeneratedPeriod.present) {
      map['last_generated_period'] = Variable<String>(
        lastGeneratedPeriod.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $RecurringCashflowRulesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $RecurringCashflowRulesTable.$converterdeletedAtn.toSql(
          deletedAt.value,
        ),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringCashflowRulesCompanion(')
          ..write('id: $id, ')
          ..write('strategy: $strategy, ')
          ..write('kind: $kind, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('accountId: $accountId, ')
          ..write('propertyId: $propertyId, ')
          ..write('affectsBalance: $affectsBalance, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('comment: $comment, ')
          ..write('lastGeneratedPeriod: $lastGeneratedPeriod, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $CashflowEntriesTable extends CashflowEntries
    with TableInfo<$CashflowEntriesTable, CashflowEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashflowEntriesTable(this.attachedDatabase, [this._alias]);
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
  @override
  late final GeneratedColumnWithTypeConverter<CashflowKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL CHECK (kind IN (\'income\', \'expense\'))',
      ).withConverter<CashflowKind>($CashflowEntriesTable.$converterkind);
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _amountMinorMeta = const VerificationMeta(
    'amountMinor',
  );
  @override
  late final GeneratedColumn<int> amountMinor = GeneratedColumn<int>(
    'amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_minor > 0)',
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> occurredOn =
      GeneratedColumn<String>(
        'occurred_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($CashflowEntriesTable.$converteroccurredOn);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> rateToRub =
      GeneratedColumn<String>(
        'rate_to_rub',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($CashflowEntriesTable.$converterrateToRub);
  static const VerificationMeta _amountRubMinorMeta = const VerificationMeta(
    'amountRubMinor',
  );
  @override
  late final GeneratedColumn<int> amountRubMinor = GeneratedColumn<int>(
    'amount_rub_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (amount_rub_minor > 0)',
  );
  static const VerificationMeta _affectsBalanceMeta = const VerificationMeta(
    'affectsBalance',
  );
  @override
  late final GeneratedColumn<bool> affectsBalance = GeneratedColumn<bool>(
    'affects_balance',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("affects_balance" IN (0, 1))',
    ),
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<int> propertyId = GeneratedColumn<int>(
    'property_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _assetTransactionIdMeta =
      const VerificationMeta('assetTransactionId');
  @override
  late final GeneratedColumn<int> assetTransactionId = GeneratedColumn<int>(
    'asset_transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES asset_transactions (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _recurringRuleIdMeta = const VerificationMeta(
    'recurringRuleId',
  );
  @override
  late final GeneratedColumn<int> recurringRuleId = GeneratedColumn<int>(
    'recurring_rule_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES recurring_cashflow_rules (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _revisionNoMeta = const VerificationMeta(
    'revisionNo',
  );
  @override
  late final GeneratedColumn<int> revisionNo = GeneratedColumn<int>(
    'revision_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (revision_no >= 1)',
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CashflowEntriesTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CashflowEntriesTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CashflowEntriesTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    categoryId,
    amountMinor,
    currencyCode,
    occurredOn,
    rateToRub,
    amountRubMinor,
    affectsBalance,
    comment,
    propertyId,
    accountId,
    assetTransactionId,
    recurringRuleId,
    revisionNo,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cashflow_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashflowEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('amount_minor')) {
      context.handle(
        _amountMinorMeta,
        amountMinor.isAcceptableOrUnknown(
          data['amount_minor']!,
          _amountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('amount_rub_minor')) {
      context.handle(
        _amountRubMinorMeta,
        amountRubMinor.isAcceptableOrUnknown(
          data['amount_rub_minor']!,
          _amountRubMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountRubMinorMeta);
    }
    if (data.containsKey('affects_balance')) {
      context.handle(
        _affectsBalanceMeta,
        affectsBalance.isAcceptableOrUnknown(
          data['affects_balance']!,
          _affectsBalanceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_affectsBalanceMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('asset_transaction_id')) {
      context.handle(
        _assetTransactionIdMeta,
        assetTransactionId.isAcceptableOrUnknown(
          data['asset_transaction_id']!,
          _assetTransactionIdMeta,
        ),
      );
    }
    if (data.containsKey('recurring_rule_id')) {
      context.handle(
        _recurringRuleIdMeta,
        recurringRuleId.isAcceptableOrUnknown(
          data['recurring_rule_id']!,
          _recurringRuleIdMeta,
        ),
      );
    }
    if (data.containsKey('revision_no')) {
      context.handle(
        _revisionNoMeta,
        revisionNo.isAcceptableOrUnknown(data['revision_no']!, _revisionNoMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionNoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashflowEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashflowEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: $CashflowEntriesTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      amountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      occurredOn: $CashflowEntriesTable.$converteroccurredOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}occurred_on'],
        )!,
      ),
      rateToRub: $CashflowEntriesTable.$converterrateToRub.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rate_to_rub'],
        )!,
      ),
      amountRubMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_rub_minor'],
      )!,
      affectsBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}affects_balance'],
      )!,
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}property_id'],
      ),
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      assetTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_transaction_id'],
      ),
      recurringRuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurring_rule_id'],
      ),
      revisionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_no'],
      )!,
      createdAt: $CashflowEntriesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $CashflowEntriesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $CashflowEntriesTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $CashflowEntriesTable createAlias(String alias) {
    return $CashflowEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<CashflowKind, String> $converterkind =
      const CashflowKindConverter();
  static TypeConverter<LocalDate, String> $converteroccurredOn =
      const LocalDateConverter();
  static TypeConverter<Decimal, String> $converterrateToRub =
      const DecimalConverter();
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class CashflowEntryRow extends DataClass
    implements Insertable<CashflowEntryRow> {
  final int id;
  final CashflowKind kind;
  final int categoryId;
  final int amountMinor;
  final String currencyCode;
  final LocalDate occurredOn;
  final Decimal rateToRub;
  final int amountRubMinor;
  final bool affectsBalance;
  final String? comment;
  final int? propertyId;
  final int? accountId;
  final int? assetTransactionId;

  /// Правило, создавшее автооперацию (BR-RC-5); null — ручная запись.
  final int? recurringRuleId;
  final int revisionNo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CashflowEntryRow({
    required this.id,
    required this.kind,
    required this.categoryId,
    required this.amountMinor,
    required this.currencyCode,
    required this.occurredOn,
    required this.rateToRub,
    required this.amountRubMinor,
    required this.affectsBalance,
    this.comment,
    this.propertyId,
    this.accountId,
    this.assetTransactionId,
    this.recurringRuleId,
    required this.revisionNo,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<String>(
        $CashflowEntriesTable.$converterkind.toSql(kind),
      );
    }
    map['category_id'] = Variable<int>(categoryId);
    map['amount_minor'] = Variable<int>(amountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    {
      map['occurred_on'] = Variable<String>(
        $CashflowEntriesTable.$converteroccurredOn.toSql(occurredOn),
      );
    }
    {
      map['rate_to_rub'] = Variable<String>(
        $CashflowEntriesTable.$converterrateToRub.toSql(rateToRub),
      );
    }
    map['amount_rub_minor'] = Variable<int>(amountRubMinor);
    map['affects_balance'] = Variable<bool>(affectsBalance);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || propertyId != null) {
      map['property_id'] = Variable<int>(propertyId);
    }
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || assetTransactionId != null) {
      map['asset_transaction_id'] = Variable<int>(assetTransactionId);
    }
    if (!nullToAbsent || recurringRuleId != null) {
      map['recurring_rule_id'] = Variable<int>(recurringRuleId);
    }
    map['revision_no'] = Variable<int>(revisionNo);
    {
      map['created_at'] = Variable<String>(
        $CashflowEntriesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $CashflowEntriesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $CashflowEntriesTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  CashflowEntriesCompanion toCompanion(bool nullToAbsent) {
    return CashflowEntriesCompanion(
      id: Value(id),
      kind: Value(kind),
      categoryId: Value(categoryId),
      amountMinor: Value(amountMinor),
      currencyCode: Value(currencyCode),
      occurredOn: Value(occurredOn),
      rateToRub: Value(rateToRub),
      amountRubMinor: Value(amountRubMinor),
      affectsBalance: Value(affectsBalance),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      propertyId: propertyId == null && nullToAbsent
          ? const Value.absent()
          : Value(propertyId),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      assetTransactionId: assetTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(assetTransactionId),
      recurringRuleId: recurringRuleId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRuleId),
      revisionNo: Value(revisionNo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CashflowEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashflowEntryRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<CashflowKind>(json['kind']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      amountMinor: serializer.fromJson<int>(json['amountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      occurredOn: serializer.fromJson<LocalDate>(json['occurredOn']),
      rateToRub: serializer.fromJson<Decimal>(json['rateToRub']),
      amountRubMinor: serializer.fromJson<int>(json['amountRubMinor']),
      affectsBalance: serializer.fromJson<bool>(json['affectsBalance']),
      comment: serializer.fromJson<String?>(json['comment']),
      propertyId: serializer.fromJson<int?>(json['propertyId']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      assetTransactionId: serializer.fromJson<int?>(json['assetTransactionId']),
      recurringRuleId: serializer.fromJson<int?>(json['recurringRuleId']),
      revisionNo: serializer.fromJson<int>(json['revisionNo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<CashflowKind>(kind),
      'categoryId': serializer.toJson<int>(categoryId),
      'amountMinor': serializer.toJson<int>(amountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'occurredOn': serializer.toJson<LocalDate>(occurredOn),
      'rateToRub': serializer.toJson<Decimal>(rateToRub),
      'amountRubMinor': serializer.toJson<int>(amountRubMinor),
      'affectsBalance': serializer.toJson<bool>(affectsBalance),
      'comment': serializer.toJson<String?>(comment),
      'propertyId': serializer.toJson<int?>(propertyId),
      'accountId': serializer.toJson<int?>(accountId),
      'assetTransactionId': serializer.toJson<int?>(assetTransactionId),
      'recurringRuleId': serializer.toJson<int?>(recurringRuleId),
      'revisionNo': serializer.toJson<int>(revisionNo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CashflowEntryRow copyWith({
    int? id,
    CashflowKind? kind,
    int? categoryId,
    int? amountMinor,
    String? currencyCode,
    LocalDate? occurredOn,
    Decimal? rateToRub,
    int? amountRubMinor,
    bool? affectsBalance,
    Value<String?> comment = const Value.absent(),
    Value<int?> propertyId = const Value.absent(),
    Value<int?> accountId = const Value.absent(),
    Value<int?> assetTransactionId = const Value.absent(),
    Value<int?> recurringRuleId = const Value.absent(),
    int? revisionNo,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CashflowEntryRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    categoryId: categoryId ?? this.categoryId,
    amountMinor: amountMinor ?? this.amountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    occurredOn: occurredOn ?? this.occurredOn,
    rateToRub: rateToRub ?? this.rateToRub,
    amountRubMinor: amountRubMinor ?? this.amountRubMinor,
    affectsBalance: affectsBalance ?? this.affectsBalance,
    comment: comment.present ? comment.value : this.comment,
    propertyId: propertyId.present ? propertyId.value : this.propertyId,
    accountId: accountId.present ? accountId.value : this.accountId,
    assetTransactionId: assetTransactionId.present
        ? assetTransactionId.value
        : this.assetTransactionId,
    recurringRuleId: recurringRuleId.present
        ? recurringRuleId.value
        : this.recurringRuleId,
    revisionNo: revisionNo ?? this.revisionNo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CashflowEntryRow copyWithCompanion(CashflowEntriesCompanion data) {
    return CashflowEntryRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      amountMinor: data.amountMinor.present
          ? data.amountMinor.value
          : this.amountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      occurredOn: data.occurredOn.present
          ? data.occurredOn.value
          : this.occurredOn,
      rateToRub: data.rateToRub.present ? data.rateToRub.value : this.rateToRub,
      amountRubMinor: data.amountRubMinor.present
          ? data.amountRubMinor.value
          : this.amountRubMinor,
      affectsBalance: data.affectsBalance.present
          ? data.affectsBalance.value
          : this.affectsBalance,
      comment: data.comment.present ? data.comment.value : this.comment,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      assetTransactionId: data.assetTransactionId.present
          ? data.assetTransactionId.value
          : this.assetTransactionId,
      recurringRuleId: data.recurringRuleId.present
          ? data.recurringRuleId.value
          : this.recurringRuleId,
      revisionNo: data.revisionNo.present
          ? data.revisionNo.value
          : this.revisionNo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashflowEntryRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('rateToRub: $rateToRub, ')
          ..write('amountRubMinor: $amountRubMinor, ')
          ..write('affectsBalance: $affectsBalance, ')
          ..write('comment: $comment, ')
          ..write('propertyId: $propertyId, ')
          ..write('accountId: $accountId, ')
          ..write('assetTransactionId: $assetTransactionId, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    categoryId,
    amountMinor,
    currencyCode,
    occurredOn,
    rateToRub,
    amountRubMinor,
    affectsBalance,
    comment,
    propertyId,
    accountId,
    assetTransactionId,
    recurringRuleId,
    revisionNo,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashflowEntryRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.categoryId == this.categoryId &&
          other.amountMinor == this.amountMinor &&
          other.currencyCode == this.currencyCode &&
          other.occurredOn == this.occurredOn &&
          other.rateToRub == this.rateToRub &&
          other.amountRubMinor == this.amountRubMinor &&
          other.affectsBalance == this.affectsBalance &&
          other.comment == this.comment &&
          other.propertyId == this.propertyId &&
          other.accountId == this.accountId &&
          other.assetTransactionId == this.assetTransactionId &&
          other.recurringRuleId == this.recurringRuleId &&
          other.revisionNo == this.revisionNo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CashflowEntriesCompanion extends UpdateCompanion<CashflowEntryRow> {
  final Value<int> id;
  final Value<CashflowKind> kind;
  final Value<int> categoryId;
  final Value<int> amountMinor;
  final Value<String> currencyCode;
  final Value<LocalDate> occurredOn;
  final Value<Decimal> rateToRub;
  final Value<int> amountRubMinor;
  final Value<bool> affectsBalance;
  final Value<String?> comment;
  final Value<int?> propertyId;
  final Value<int?> accountId;
  final Value<int?> assetTransactionId;
  final Value<int?> recurringRuleId;
  final Value<int> revisionNo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const CashflowEntriesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.amountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.occurredOn = const Value.absent(),
    this.rateToRub = const Value.absent(),
    this.amountRubMinor = const Value.absent(),
    this.affectsBalance = const Value.absent(),
    this.comment = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.assetTransactionId = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    this.revisionNo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  CashflowEntriesCompanion.insert({
    this.id = const Value.absent(),
    required CashflowKind kind,
    required int categoryId,
    required int amountMinor,
    required String currencyCode,
    required LocalDate occurredOn,
    required Decimal rateToRub,
    required int amountRubMinor,
    required bool affectsBalance,
    this.comment = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.assetTransactionId = const Value.absent(),
    this.recurringRuleId = const Value.absent(),
    required int revisionNo,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : kind = Value(kind),
       categoryId = Value(categoryId),
       amountMinor = Value(amountMinor),
       currencyCode = Value(currencyCode),
       occurredOn = Value(occurredOn),
       rateToRub = Value(rateToRub),
       amountRubMinor = Value(amountRubMinor),
       affectsBalance = Value(affectsBalance),
       revisionNo = Value(revisionNo),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CashflowEntryRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? categoryId,
    Expression<int>? amountMinor,
    Expression<String>? currencyCode,
    Expression<String>? occurredOn,
    Expression<String>? rateToRub,
    Expression<int>? amountRubMinor,
    Expression<bool>? affectsBalance,
    Expression<String>? comment,
    Expression<int>? propertyId,
    Expression<int>? accountId,
    Expression<int>? assetTransactionId,
    Expression<int>? recurringRuleId,
    Expression<int>? revisionNo,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (categoryId != null) 'category_id': categoryId,
      if (amountMinor != null) 'amount_minor': amountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (occurredOn != null) 'occurred_on': occurredOn,
      if (rateToRub != null) 'rate_to_rub': rateToRub,
      if (amountRubMinor != null) 'amount_rub_minor': amountRubMinor,
      if (affectsBalance != null) 'affects_balance': affectsBalance,
      if (comment != null) 'comment': comment,
      if (propertyId != null) 'property_id': propertyId,
      if (accountId != null) 'account_id': accountId,
      if (assetTransactionId != null)
        'asset_transaction_id': assetTransactionId,
      if (recurringRuleId != null) 'recurring_rule_id': recurringRuleId,
      if (revisionNo != null) 'revision_no': revisionNo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  CashflowEntriesCompanion copyWith({
    Value<int>? id,
    Value<CashflowKind>? kind,
    Value<int>? categoryId,
    Value<int>? amountMinor,
    Value<String>? currencyCode,
    Value<LocalDate>? occurredOn,
    Value<Decimal>? rateToRub,
    Value<int>? amountRubMinor,
    Value<bool>? affectsBalance,
    Value<String?>? comment,
    Value<int?>? propertyId,
    Value<int?>? accountId,
    Value<int?>? assetTransactionId,
    Value<int?>? recurringRuleId,
    Value<int>? revisionNo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return CashflowEntriesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      categoryId: categoryId ?? this.categoryId,
      amountMinor: amountMinor ?? this.amountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      occurredOn: occurredOn ?? this.occurredOn,
      rateToRub: rateToRub ?? this.rateToRub,
      amountRubMinor: amountRubMinor ?? this.amountRubMinor,
      affectsBalance: affectsBalance ?? this.affectsBalance,
      comment: comment ?? this.comment,
      propertyId: propertyId ?? this.propertyId,
      accountId: accountId ?? this.accountId,
      assetTransactionId: assetTransactionId ?? this.assetTransactionId,
      recurringRuleId: recurringRuleId ?? this.recurringRuleId,
      revisionNo: revisionNo ?? this.revisionNo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CashflowEntriesTable.$converterkind.toSql(kind.value),
      );
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (amountMinor.present) {
      map['amount_minor'] = Variable<int>(amountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (occurredOn.present) {
      map['occurred_on'] = Variable<String>(
        $CashflowEntriesTable.$converteroccurredOn.toSql(occurredOn.value),
      );
    }
    if (rateToRub.present) {
      map['rate_to_rub'] = Variable<String>(
        $CashflowEntriesTable.$converterrateToRub.toSql(rateToRub.value),
      );
    }
    if (amountRubMinor.present) {
      map['amount_rub_minor'] = Variable<int>(amountRubMinor.value);
    }
    if (affectsBalance.present) {
      map['affects_balance'] = Variable<bool>(affectsBalance.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<int>(propertyId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (assetTransactionId.present) {
      map['asset_transaction_id'] = Variable<int>(assetTransactionId.value);
    }
    if (recurringRuleId.present) {
      map['recurring_rule_id'] = Variable<int>(recurringRuleId.value);
    }
    if (revisionNo.present) {
      map['revision_no'] = Variable<int>(revisionNo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $CashflowEntriesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $CashflowEntriesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $CashflowEntriesTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashflowEntriesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('categoryId: $categoryId, ')
          ..write('amountMinor: $amountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('occurredOn: $occurredOn, ')
          ..write('rateToRub: $rateToRub, ')
          ..write('amountRubMinor: $amountRubMinor, ')
          ..write('affectsBalance: $affectsBalance, ')
          ..write('comment: $comment, ')
          ..write('propertyId: $propertyId, ')
          ..write('accountId: $accountId, ')
          ..write('assetTransactionId: $assetTransactionId, ')
          ..write('recurringRuleId: $recurringRuleId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $CashflowEntryRevisionsTable extends CashflowEntryRevisions
    with TableInfo<$CashflowEntryRevisionsTable, CashflowEntryRevisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashflowEntryRevisionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<int> entryId = GeneratedColumn<int>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cashflow_entries (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _revisionNoMeta = const VerificationMeta(
    'revisionNo',
  );
  @override
  late final GeneratedColumn<int> revisionNo = GeneratedColumn<int>(
    'revision_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (revision_no >= 1)',
  );
  @override
  late final GeneratedColumnWithTypeConverter<RevisionAction, String> action =
      GeneratedColumn<String>(
        'action',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<RevisionAction>(
        $CashflowEntryRevisionsTable.$converteraction,
      );
  static const VerificationMeta _snapshotJsonMeta = const VerificationMeta(
    'snapshotJson',
  );
  @override
  late final GeneratedColumn<String> snapshotJson = GeneratedColumn<String>(
    'snapshot_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> changedAt =
      GeneratedColumn<String>(
        'changed_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $CashflowEntryRevisionsTable.$converterchangedAt,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entryId,
    revisionNo,
    action,
    snapshotJson,
    changedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cashflow_entry_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<CashflowEntryRevisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('revision_no')) {
      context.handle(
        _revisionNoMeta,
        revisionNo.isAcceptableOrUnknown(data['revision_no']!, _revisionNoMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionNoMeta);
    }
    if (data.containsKey('snapshot_json')) {
      context.handle(
        _snapshotJsonMeta,
        snapshotJson.isAcceptableOrUnknown(
          data['snapshot_json']!,
          _snapshotJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_snapshotJsonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {entryId, revisionNo},
  ];
  @override
  CashflowEntryRevisionRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashflowEntryRevisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entry_id'],
      )!,
      revisionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_no'],
      )!,
      action: $CashflowEntryRevisionsTable.$converteraction.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}action'],
        )!,
      ),
      snapshotJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}snapshot_json'],
      )!,
      changedAt: $CashflowEntryRevisionsTable.$converterchangedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}changed_at'],
        )!,
      ),
    );
  }

  @override
  $CashflowEntryRevisionsTable createAlias(String alias) {
    return $CashflowEntryRevisionsTable(attachedDatabase, alias);
  }

  static TypeConverter<RevisionAction, String> $converteraction =
      const RevisionActionConverter();
  static TypeConverter<DateTime, String> $converterchangedAt =
      const UtcTimestampConverter();
}

class CashflowEntryRevisionRow extends DataClass
    implements Insertable<CashflowEntryRevisionRow> {
  final int id;
  final int entryId;
  final int revisionNo;
  final RevisionAction action;
  final String snapshotJson;
  final DateTime changedAt;
  const CashflowEntryRevisionRow({
    required this.id,
    required this.entryId,
    required this.revisionNo,
    required this.action,
    required this.snapshotJson,
    required this.changedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entry_id'] = Variable<int>(entryId);
    map['revision_no'] = Variable<int>(revisionNo);
    {
      map['action'] = Variable<String>(
        $CashflowEntryRevisionsTable.$converteraction.toSql(action),
      );
    }
    map['snapshot_json'] = Variable<String>(snapshotJson);
    {
      map['changed_at'] = Variable<String>(
        $CashflowEntryRevisionsTable.$converterchangedAt.toSql(changedAt),
      );
    }
    return map;
  }

  CashflowEntryRevisionsCompanion toCompanion(bool nullToAbsent) {
    return CashflowEntryRevisionsCompanion(
      id: Value(id),
      entryId: Value(entryId),
      revisionNo: Value(revisionNo),
      action: Value(action),
      snapshotJson: Value(snapshotJson),
      changedAt: Value(changedAt),
    );
  }

  factory CashflowEntryRevisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashflowEntryRevisionRow(
      id: serializer.fromJson<int>(json['id']),
      entryId: serializer.fromJson<int>(json['entryId']),
      revisionNo: serializer.fromJson<int>(json['revisionNo']),
      action: serializer.fromJson<RevisionAction>(json['action']),
      snapshotJson: serializer.fromJson<String>(json['snapshotJson']),
      changedAt: serializer.fromJson<DateTime>(json['changedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entryId': serializer.toJson<int>(entryId),
      'revisionNo': serializer.toJson<int>(revisionNo),
      'action': serializer.toJson<RevisionAction>(action),
      'snapshotJson': serializer.toJson<String>(snapshotJson),
      'changedAt': serializer.toJson<DateTime>(changedAt),
    };
  }

  CashflowEntryRevisionRow copyWith({
    int? id,
    int? entryId,
    int? revisionNo,
    RevisionAction? action,
    String? snapshotJson,
    DateTime? changedAt,
  }) => CashflowEntryRevisionRow(
    id: id ?? this.id,
    entryId: entryId ?? this.entryId,
    revisionNo: revisionNo ?? this.revisionNo,
    action: action ?? this.action,
    snapshotJson: snapshotJson ?? this.snapshotJson,
    changedAt: changedAt ?? this.changedAt,
  );
  CashflowEntryRevisionRow copyWithCompanion(
    CashflowEntryRevisionsCompanion data,
  ) {
    return CashflowEntryRevisionRow(
      id: data.id.present ? data.id.value : this.id,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      revisionNo: data.revisionNo.present
          ? data.revisionNo.value
          : this.revisionNo,
      action: data.action.present ? data.action.value : this.action,
      snapshotJson: data.snapshotJson.present
          ? data.snapshotJson.value
          : this.snapshotJson,
      changedAt: data.changedAt.present ? data.changedAt.value : this.changedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashflowEntryRevisionRow(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('action: $action, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, entryId, revisionNo, action, snapshotJson, changedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashflowEntryRevisionRow &&
          other.id == this.id &&
          other.entryId == this.entryId &&
          other.revisionNo == this.revisionNo &&
          other.action == this.action &&
          other.snapshotJson == this.snapshotJson &&
          other.changedAt == this.changedAt);
}

class CashflowEntryRevisionsCompanion
    extends UpdateCompanion<CashflowEntryRevisionRow> {
  final Value<int> id;
  final Value<int> entryId;
  final Value<int> revisionNo;
  final Value<RevisionAction> action;
  final Value<String> snapshotJson;
  final Value<DateTime> changedAt;
  const CashflowEntryRevisionsCompanion({
    this.id = const Value.absent(),
    this.entryId = const Value.absent(),
    this.revisionNo = const Value.absent(),
    this.action = const Value.absent(),
    this.snapshotJson = const Value.absent(),
    this.changedAt = const Value.absent(),
  });
  CashflowEntryRevisionsCompanion.insert({
    this.id = const Value.absent(),
    required int entryId,
    required int revisionNo,
    required RevisionAction action,
    required String snapshotJson,
    required DateTime changedAt,
  }) : entryId = Value(entryId),
       revisionNo = Value(revisionNo),
       action = Value(action),
       snapshotJson = Value(snapshotJson),
       changedAt = Value(changedAt);
  static Insertable<CashflowEntryRevisionRow> custom({
    Expression<int>? id,
    Expression<int>? entryId,
    Expression<int>? revisionNo,
    Expression<String>? action,
    Expression<String>? snapshotJson,
    Expression<String>? changedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryId != null) 'entry_id': entryId,
      if (revisionNo != null) 'revision_no': revisionNo,
      if (action != null) 'action': action,
      if (snapshotJson != null) 'snapshot_json': snapshotJson,
      if (changedAt != null) 'changed_at': changedAt,
    });
  }

  CashflowEntryRevisionsCompanion copyWith({
    Value<int>? id,
    Value<int>? entryId,
    Value<int>? revisionNo,
    Value<RevisionAction>? action,
    Value<String>? snapshotJson,
    Value<DateTime>? changedAt,
  }) {
    return CashflowEntryRevisionsCompanion(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      revisionNo: revisionNo ?? this.revisionNo,
      action: action ?? this.action,
      snapshotJson: snapshotJson ?? this.snapshotJson,
      changedAt: changedAt ?? this.changedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<int>(entryId.value);
    }
    if (revisionNo.present) {
      map['revision_no'] = Variable<int>(revisionNo.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(
        $CashflowEntryRevisionsTable.$converteraction.toSql(action.value),
      );
    }
    if (snapshotJson.present) {
      map['snapshot_json'] = Variable<String>(snapshotJson.value);
    }
    if (changedAt.present) {
      map['changed_at'] = Variable<String>(
        $CashflowEntryRevisionsTable.$converterchangedAt.toSql(changedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashflowEntryRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('entryId: $entryId, ')
          ..write('revisionNo: $revisionNo, ')
          ..write('action: $action, ')
          ..write('snapshotJson: $snapshotJson, ')
          ..write('changedAt: $changedAt')
          ..write(')'))
        .toString();
  }
}

class $ExchangeRatesTable extends ExchangeRates
    with TableInfo<$ExchangeRatesTable, ExchangeRateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExchangeRatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($ExchangeRatesTable.$converterdate);
  @override
  late final GeneratedColumnWithTypeConverter<Decimal, String> rateToRub =
      GeneratedColumn<String>(
        'rate_to_rub',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<Decimal>($ExchangeRatesTable.$converterrateToRub);
  @override
  late final GeneratedColumnWithTypeConverter<ExchangeRateSource, String>
  source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (source IN (\'cbr\', \'manual\'))',
  ).withConverter<ExchangeRateSource>($ExchangeRatesTable.$convertersource);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> fetchedAt =
      GeneratedColumn<String>(
        'fetched_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ExchangeRatesTable.$converterfetchedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    currencyCode,
    date,
    rateToRub,
    source,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exchange_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExchangeRateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {currencyCode, date},
  ];
  @override
  ExchangeRateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExchangeRateRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      date: $ExchangeRatesTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      rateToRub: $ExchangeRatesTable.$converterrateToRub.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rate_to_rub'],
        )!,
      ),
      source: $ExchangeRatesTable.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}source'],
        )!,
      ),
      fetchedAt: $ExchangeRatesTable.$converterfetchedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fetched_at'],
        )!,
      ),
    );
  }

  @override
  $ExchangeRatesTable createAlias(String alias) {
    return $ExchangeRatesTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterdate =
      const LocalDateConverter();
  static TypeConverter<Decimal, String> $converterrateToRub =
      const DecimalConverter();
  static TypeConverter<ExchangeRateSource, String> $convertersource =
      const ExchangeRateSourceConverter();
  static TypeConverter<DateTime, String> $converterfetchedAt =
      const UtcTimestampConverter();
}

class ExchangeRateRow extends DataClass implements Insertable<ExchangeRateRow> {
  final int id;
  final String currencyCode;
  final LocalDate date;
  final Decimal rateToRub;
  final ExchangeRateSource source;
  final DateTime fetchedAt;
  const ExchangeRateRow({
    required this.id,
    required this.currencyCode,
    required this.date,
    required this.rateToRub,
    required this.source,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['currency_code'] = Variable<String>(currencyCode);
    {
      map['date'] = Variable<String>(
        $ExchangeRatesTable.$converterdate.toSql(date),
      );
    }
    {
      map['rate_to_rub'] = Variable<String>(
        $ExchangeRatesTable.$converterrateToRub.toSql(rateToRub),
      );
    }
    {
      map['source'] = Variable<String>(
        $ExchangeRatesTable.$convertersource.toSql(source),
      );
    }
    {
      map['fetched_at'] = Variable<String>(
        $ExchangeRatesTable.$converterfetchedAt.toSql(fetchedAt),
      );
    }
    return map;
  }

  ExchangeRatesCompanion toCompanion(bool nullToAbsent) {
    return ExchangeRatesCompanion(
      id: Value(id),
      currencyCode: Value(currencyCode),
      date: Value(date),
      rateToRub: Value(rateToRub),
      source: Value(source),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory ExchangeRateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExchangeRateRow(
      id: serializer.fromJson<int>(json['id']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      date: serializer.fromJson<LocalDate>(json['date']),
      rateToRub: serializer.fromJson<Decimal>(json['rateToRub']),
      source: serializer.fromJson<ExchangeRateSource>(json['source']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'date': serializer.toJson<LocalDate>(date),
      'rateToRub': serializer.toJson<Decimal>(rateToRub),
      'source': serializer.toJson<ExchangeRateSource>(source),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  ExchangeRateRow copyWith({
    int? id,
    String? currencyCode,
    LocalDate? date,
    Decimal? rateToRub,
    ExchangeRateSource? source,
    DateTime? fetchedAt,
  }) => ExchangeRateRow(
    id: id ?? this.id,
    currencyCode: currencyCode ?? this.currencyCode,
    date: date ?? this.date,
    rateToRub: rateToRub ?? this.rateToRub,
    source: source ?? this.source,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  ExchangeRateRow copyWithCompanion(ExchangeRatesCompanion data) {
    return ExchangeRateRow(
      id: data.id.present ? data.id.value : this.id,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      date: data.date.present ? data.date.value : this.date,
      rateToRub: data.rateToRub.present ? data.rateToRub.value : this.rateToRub,
      source: data.source.present ? data.source.value : this.source,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRateRow(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('date: $date, ')
          ..write('rateToRub: $rateToRub, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, currencyCode, date, rateToRub, source, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExchangeRateRow &&
          other.id == this.id &&
          other.currencyCode == this.currencyCode &&
          other.date == this.date &&
          other.rateToRub == this.rateToRub &&
          other.source == this.source &&
          other.fetchedAt == this.fetchedAt);
}

class ExchangeRatesCompanion extends UpdateCompanion<ExchangeRateRow> {
  final Value<int> id;
  final Value<String> currencyCode;
  final Value<LocalDate> date;
  final Value<Decimal> rateToRub;
  final Value<ExchangeRateSource> source;
  final Value<DateTime> fetchedAt;
  const ExchangeRatesCompanion({
    this.id = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.date = const Value.absent(),
    this.rateToRub = const Value.absent(),
    this.source = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  ExchangeRatesCompanion.insert({
    this.id = const Value.absent(),
    required String currencyCode,
    required LocalDate date,
    required Decimal rateToRub,
    required ExchangeRateSource source,
    required DateTime fetchedAt,
  }) : currencyCode = Value(currencyCode),
       date = Value(date),
       rateToRub = Value(rateToRub),
       source = Value(source),
       fetchedAt = Value(fetchedAt);
  static Insertable<ExchangeRateRow> custom({
    Expression<int>? id,
    Expression<String>? currencyCode,
    Expression<String>? date,
    Expression<String>? rateToRub,
    Expression<String>? source,
    Expression<String>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (date != null) 'date': date,
      if (rateToRub != null) 'rate_to_rub': rateToRub,
      if (source != null) 'source': source,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  ExchangeRatesCompanion copyWith({
    Value<int>? id,
    Value<String>? currencyCode,
    Value<LocalDate>? date,
    Value<Decimal>? rateToRub,
    Value<ExchangeRateSource>? source,
    Value<DateTime>? fetchedAt,
  }) {
    return ExchangeRatesCompanion(
      id: id ?? this.id,
      currencyCode: currencyCode ?? this.currencyCode,
      date: date ?? this.date,
      rateToRub: rateToRub ?? this.rateToRub,
      source: source ?? this.source,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $ExchangeRatesTable.$converterdate.toSql(date.value),
      );
    }
    if (rateToRub.present) {
      map['rate_to_rub'] = Variable<String>(
        $ExchangeRatesTable.$converterrateToRub.toSql(rateToRub.value),
      );
    }
    if (source.present) {
      map['source'] = Variable<String>(
        $ExchangeRatesTable.$convertersource.toSql(source.value),
      );
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<String>(
        $ExchangeRatesTable.$converterfetchedAt.toSql(fetchedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExchangeRatesCompanion(')
          ..write('id: $id, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('date: $date, ')
          ..write('rateToRub: $rateToRub, ')
          ..write('source: $source, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<GoalCategory, String> category =
      GeneratedColumn<String>(
        'category',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL CHECK (category IN (\'accounts\', \'investments\'))',
      ).withConverter<GoalCategory>($GoalsTable.$convertercategory);
  static const VerificationMeta _targetAmountMinorMeta = const VerificationMeta(
    'targetAmountMinor',
  );
  @override
  late final GeneratedColumn<int> targetAmountMinor = GeneratedColumn<int>(
    'target_amount_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (target_amount_minor > 0)',
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES currencies (code) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<GoalStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL CHECK (status IN (\'active\', \'achieved\', \'closed\'))',
      ).withConverter<GoalStatus>($GoalsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> targetDate =
      GeneratedColumn<String>(
        'target_date',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($GoalsTable.$convertertargetDaten);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($GoalsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($GoalsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> deletedAt =
      GeneratedColumn<String>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($GoalsTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    targetAmountMinor,
    currencyCode,
    status,
    targetDate,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount_minor')) {
      context.handle(
        _targetAmountMinorMeta,
        targetAmountMinor.isAcceptableOrUnknown(
          data['target_amount_minor']!,
          _targetAmountMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMinorMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: $GoalsTable.$convertercategory.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}category'],
        )!,
      ),
      targetAmountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_amount_minor'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      status: $GoalsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      targetDate: $GoalsTable.$convertertargetDaten.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}target_date'],
        ),
      ),
      createdAt: $GoalsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $GoalsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $GoalsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }

  static TypeConverter<GoalCategory, String> $convertercategory =
      const GoalCategoryConverter();
  static TypeConverter<GoalStatus, String> $converterstatus =
      const GoalStatusConverter();
  static TypeConverter<LocalDate, String> $convertertargetDate =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $convertertargetDaten =
      NullAwareTypeConverter.wrap($convertertargetDate);
  static TypeConverter<DateTime, String> $convertercreatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime, String> $converterdeletedAt =
      const UtcTimestampConverter();
  static TypeConverter<DateTime?, String?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final int id;
  final String name;
  final GoalCategory category;
  final int targetAmountMinor;
  final String currencyCode;
  final GoalStatus status;
  final LocalDate? targetDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const GoalRow({
    required this.id,
    required this.name,
    required this.category,
    required this.targetAmountMinor,
    required this.currencyCode,
    required this.status,
    this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['category'] = Variable<String>(
        $GoalsTable.$convertercategory.toSql(category),
      );
    }
    map['target_amount_minor'] = Variable<int>(targetAmountMinor);
    map['currency_code'] = Variable<String>(currencyCode);
    {
      map['status'] = Variable<String>(
        $GoalsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<String>(
        $GoalsTable.$convertertargetDaten.toSql(targetDate),
      );
    }
    {
      map['created_at'] = Variable<String>(
        $GoalsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<String>(
        $GoalsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(
        $GoalsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      targetAmountMinor: Value(targetAmountMinor),
      currencyCode: Value(currencyCode),
      status: Value(status),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory GoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<GoalCategory>(json['category']),
      targetAmountMinor: serializer.fromJson<int>(json['targetAmountMinor']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      status: serializer.fromJson<GoalStatus>(json['status']),
      targetDate: serializer.fromJson<LocalDate?>(json['targetDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<GoalCategory>(category),
      'targetAmountMinor': serializer.toJson<int>(targetAmountMinor),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'status': serializer.toJson<GoalStatus>(status),
      'targetDate': serializer.toJson<LocalDate?>(targetDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  GoalRow copyWith({
    int? id,
    String? name,
    GoalCategory? category,
    int? targetAmountMinor,
    String? currencyCode,
    GoalStatus? status,
    Value<LocalDate?> targetDate = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => GoalRow(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    targetAmountMinor: targetAmountMinor ?? this.targetAmountMinor,
    currencyCode: currencyCode ?? this.currencyCode,
    status: status ?? this.status,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      targetAmountMinor: data.targetAmountMinor.present
          ? data.targetAmountMinor.value
          : this.targetAmountMinor,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      status: data.status.present ? data.status.value : this.status,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('targetAmountMinor: $targetAmountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('status: $status, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    targetAmountMinor,
    currencyCode,
    status,
    targetDate,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.targetAmountMinor == this.targetAmountMinor &&
          other.currencyCode == this.currencyCode &&
          other.status == this.status &&
          other.targetDate == this.targetDate &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<GoalCategory> category;
  final Value<int> targetAmountMinor;
  final Value<String> currencyCode;
  final Value<GoalStatus> status;
  final Value<LocalDate?> targetDate;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.targetAmountMinor = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.status = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required GoalCategory category,
    required int targetAmountMinor,
    required String currencyCode,
    required GoalStatus status,
    this.targetDate = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
  }) : name = Value(name),
       category = Value(category),
       targetAmountMinor = Value(targetAmountMinor),
       currencyCode = Value(currencyCode),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<GoalRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<int>? targetAmountMinor,
    Expression<String>? currencyCode,
    Expression<String>? status,
    Expression<String>? targetDate,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (targetAmountMinor != null) 'target_amount_minor': targetAmountMinor,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (status != null) 'status': status,
      if (targetDate != null) 'target_date': targetDate,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  GoalsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<GoalCategory>? category,
    Value<int>? targetAmountMinor,
    Value<String>? currencyCode,
    Value<GoalStatus>? status,
    Value<LocalDate?>? targetDate,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      targetAmountMinor: targetAmountMinor ?? this.targetAmountMinor,
      currencyCode: currencyCode ?? this.currencyCode,
      status: status ?? this.status,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
        $GoalsTable.$convertercategory.toSql(category.value),
      );
    }
    if (targetAmountMinor.present) {
      map['target_amount_minor'] = Variable<int>(targetAmountMinor.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $GoalsTable.$converterstatus.toSql(status.value),
      );
    }
    if (targetDate.present) {
      map['target_date'] = Variable<String>(
        $GoalsTable.$convertertargetDaten.toSql(targetDate.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(
        $GoalsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $GoalsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(
        $GoalsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('targetAmountMinor: $targetAmountMinor, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('status: $status, ')
          ..write('targetDate: $targetDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $GoalAssetsTable extends GoalAssets
    with TableInfo<$GoalAssetsTable, GoalAssetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<int> goalId = GeneratedColumn<int>(
    'goal_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES goals (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<int> assetId = GeneratedColumn<int>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON UPDATE RESTRICT ON DELETE RESTRICT',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [goalId, assetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalAssetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('goal_id')) {
      context.handle(
        _goalIdMeta,
        goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {goalId, assetId};
  @override
  GoalAssetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalAssetRow(
      goalId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}goal_id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
    );
  }

  @override
  $GoalAssetsTable createAlias(String alias) {
    return $GoalAssetsTable(attachedDatabase, alias);
  }
}

class GoalAssetRow extends DataClass implements Insertable<GoalAssetRow> {
  final int goalId;
  final int assetId;
  const GoalAssetRow({required this.goalId, required this.assetId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['goal_id'] = Variable<int>(goalId);
    map['asset_id'] = Variable<int>(assetId);
    return map;
  }

  GoalAssetsCompanion toCompanion(bool nullToAbsent) {
    return GoalAssetsCompanion(goalId: Value(goalId), assetId: Value(assetId));
  }

  factory GoalAssetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalAssetRow(
      goalId: serializer.fromJson<int>(json['goalId']),
      assetId: serializer.fromJson<int>(json['assetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'goalId': serializer.toJson<int>(goalId),
      'assetId': serializer.toJson<int>(assetId),
    };
  }

  GoalAssetRow copyWith({int? goalId, int? assetId}) => GoalAssetRow(
    goalId: goalId ?? this.goalId,
    assetId: assetId ?? this.assetId,
  );
  GoalAssetRow copyWithCompanion(GoalAssetsCompanion data) {
    return GoalAssetRow(
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalAssetRow(')
          ..write('goalId: $goalId, ')
          ..write('assetId: $assetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(goalId, assetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalAssetRow &&
          other.goalId == this.goalId &&
          other.assetId == this.assetId);
}

class GoalAssetsCompanion extends UpdateCompanion<GoalAssetRow> {
  final Value<int> goalId;
  final Value<int> assetId;
  final Value<int> rowid;
  const GoalAssetsCompanion({
    this.goalId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalAssetsCompanion.insert({
    required int goalId,
    required int assetId,
    this.rowid = const Value.absent(),
  }) : goalId = Value(goalId),
       assetId = Value(assetId);
  static Insertable<GoalAssetRow> custom({
    Expression<int>? goalId,
    Expression<int>? assetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (goalId != null) 'goal_id': goalId,
      if (assetId != null) 'asset_id': assetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalAssetsCompanion copyWith({
    Value<int>? goalId,
    Value<int>? assetId,
    Value<int>? rowid,
  }) {
    return GoalAssetsCompanion(
      goalId: goalId ?? this.goalId,
      assetId: assetId ?? this.assetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (goalId.present) {
      map['goal_id'] = Variable<int>(goalId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<int>(assetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalAssetsCompanion(')
          ..write('goalId: $goalId, ')
          ..write('assetId: $assetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($AppSettingsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: $AppSettingsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterupdatedAt =
      const UtcTimestampConverter();
}

class AppSettingRow extends DataClass implements Insertable<AppSettingRow> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const AppSettingRow({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    {
      map['updated_at'] = Variable<String>(
        $AppSettingsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingRow copyWith({String? key, String? value, DateTime? updatedAt}) =>
      AppSettingRow(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AppSettingRow copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingRow(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingRow &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(
        $AppSettingsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CurrenciesTable currencies = $CurrenciesTable(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $SubgroupsTable subgroups = $SubgroupsTable(this);
  late final $AccountDetailsTable accountDetails = $AccountDetailsTable(this);
  late final $InvestmentDetailsTable investmentDetails =
      $InvestmentDetailsTable(this);
  late final $PropertyDetailsTable propertyDetails = $PropertyDetailsTable(
    this,
  );
  late final $AssetValuationsTable assetValuations = $AssetValuationsTable(
    this,
  );
  late final $AssetTransfersTable assetTransfers = $AssetTransfersTable(this);
  late final $AssetTransactionsTable assetTransactions =
      $AssetTransactionsTable(this);
  late final $AssetTransactionRevisionsTable assetTransactionRevisions =
      $AssetTransactionRevisionsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $RecurringCashflowRulesTable recurringCashflowRules =
      $RecurringCashflowRulesTable(this);
  late final $CashflowEntriesTable cashflowEntries = $CashflowEntriesTable(
    this,
  );
  late final $CashflowEntryRevisionsTable cashflowEntryRevisions =
      $CashflowEntryRevisionsTable(this);
  late final $ExchangeRatesTable exchangeRates = $ExchangeRatesTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $GoalAssetsTable goalAssets = $GoalAssetsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index assetsKindArchived = Index(
    'assets_kind_archived',
    'CREATE INDEX assets_kind_archived ON assets (kind, archived_at)',
  );
  late final Index assetsCurrency = Index(
    'assets_currency',
    'CREATE INDEX assets_currency ON assets (currency_code)',
  );
  late final Index assetsArchivedName = Index(
    'assets_archived_name',
    'CREATE INDEX assets_archived_name ON assets (archived_at, name)',
  );
  late final Index accountDetailsBank = Index(
    'account_details_bank',
    'CREATE INDEX account_details_bank ON account_details (bank_id)',
  );
  late final Index investmentDetailsBroker = Index(
    'investment_details_broker',
    'CREATE INDEX investment_details_broker ON investment_details (broker_id)',
  );
  late final Index assetValuationsAssetEffective = Index(
    'asset_valuations_asset_effective',
    'CREATE INDEX asset_valuations_asset_effective ON asset_valuations (asset_id, effective_on DESC, id DESC)',
  );
  late final Index assetValuationsEffective = Index(
    'asset_valuations_effective',
    'CREATE INDEX asset_valuations_effective ON asset_valuations (effective_on)',
  );
  late final Index assetValuationsAssetCreated = Index(
    'asset_valuations_asset_created',
    'CREATE INDEX asset_valuations_asset_created ON asset_valuations (asset_id, created_at)',
  );
  late final Index assetTransactionsAssetOccurred = Index(
    'asset_transactions_asset_occurred',
    'CREATE INDEX asset_transactions_asset_occurred ON asset_transactions (asset_id, occurred_on, id)',
  );
  late final Index assetTransactionsOccurred = Index(
    'asset_transactions_occurred',
    'CREATE INDEX asset_transactions_occurred ON asset_transactions (occurred_on)',
  );
  late final Index assetTransactionsKind = Index(
    'asset_transactions_kind',
    'CREATE INDEX asset_transactions_kind ON asset_transactions (kind)',
  );
  late final Index assetTransactionsTransfer = Index(
    'asset_transactions_transfer',
    'CREATE INDEX asset_transactions_transfer ON asset_transactions (transfer_id)',
  );
  late final Index assetTransactionsDeletedOccurred = Index(
    'asset_transactions_deleted_occurred',
    'CREATE INDEX asset_transactions_deleted_occurred ON asset_transactions (deleted_at, occurred_on)',
  );
  late final Index assetTransactionRevisionsTxChanged = Index(
    'asset_transaction_revisions_tx_changed',
    'CREATE INDEX asset_transaction_revisions_tx_changed ON asset_transaction_revisions (transaction_id, changed_at, id)',
  );
  late final Index cashflowOccurred = Index(
    'cashflow_occurred',
    'CREATE INDEX cashflow_occurred ON cashflow_entries (occurred_on, id)',
  );
  late final Index cashflowKindOccurred = Index(
    'cashflow_kind_occurred',
    'CREATE INDEX cashflow_kind_occurred ON cashflow_entries (kind, occurred_on)',
  );
  late final Index cashflowCategoryOccurred = Index(
    'cashflow_category_occurred',
    'CREATE INDEX cashflow_category_occurred ON cashflow_entries (category_id, occurred_on)',
  );
  late final Index cashflowCurrencyOccurred = Index(
    'cashflow_currency_occurred',
    'CREATE INDEX cashflow_currency_occurred ON cashflow_entries (currency_code, occurred_on)',
  );
  late final Index cashflowPropertyOccurred = Index(
    'cashflow_property_occurred',
    'CREATE INDEX cashflow_property_occurred ON cashflow_entries (property_id, occurred_on)',
  );
  late final Index cashflowAccountOccurred = Index(
    'cashflow_account_occurred',
    'CREATE INDEX cashflow_account_occurred ON cashflow_entries (account_id, occurred_on)',
  );
  late final Index cashflowAssetTx = Index(
    'cashflow_asset_tx',
    'CREATE INDEX cashflow_asset_tx ON cashflow_entries (asset_transaction_id)',
  );
  late final Index cashflowDeletedOccurred = Index(
    'cashflow_deleted_occurred',
    'CREATE INDEX cashflow_deleted_occurred ON cashflow_entries (deleted_at, occurred_on)',
  );
  late final Index cashflowRevisionsEntryChanged = Index(
    'cashflow_revisions_entry_changed',
    'CREATE INDEX cashflow_revisions_entry_changed ON cashflow_entry_revisions (entry_id, changed_at, id)',
  );
  late final Index subgroupsKindName = Index(
    'subgroups_kind_name',
    'CREATE INDEX subgroups_kind_name ON subgroups (kind, name)',
  );
  late final Index exchangeRatesCurrencyDate = Index(
    'exchange_rates_currency_date',
    'CREATE INDEX exchange_rates_currency_date ON exchange_rates (currency_code, date)',
  );
  late final Index categoriesKindArchivedName = Index(
    'categories_kind_archived_name',
    'CREATE INDEX categories_kind_archived_name ON categories (kind, archived_at, name)',
  );
  late final Index categoriesArchived = Index(
    'categories_archived',
    'CREATE INDEX categories_archived ON categories (archived_at)',
  );
  late final Index goalsStatusDeleted = Index(
    'goals_status_deleted',
    'CREATE INDEX goals_status_deleted ON goals (status, deleted_at)',
  );
  late final Index goalsTargetDate = Index(
    'goals_target_date',
    'CREATE INDEX goals_target_date ON goals (target_date)',
  );
  late final Index goalsCurrency = Index(
    'goals_currency',
    'CREATE INDEX goals_currency ON goals (currency_code)',
  );
  late final Index goalAssetsAssetGoal = Index(
    'goal_assets_asset_goal',
    'CREATE INDEX goal_assets_asset_goal ON goal_assets (asset_id, goal_id)',
  );
  late final Index recurringDeleted = Index(
    'recurring_deleted',
    'CREATE INDEX recurring_deleted ON recurring_cashflow_rules (deleted_at)',
  );
  late final Index recurringAccount = Index(
    'recurring_account',
    'CREATE INDEX recurring_account ON recurring_cashflow_rules (account_id)',
  );
  late final Index recurringProperty = Index(
    'recurring_property',
    'CREATE INDEX recurring_property ON recurring_cashflow_rules (property_id)',
  );
  late final AssetsDao assetsDao = AssetsDao(this as AppDatabase);
  late final ValuationsDao valuationsDao = ValuationsDao(this as AppDatabase);
  late final TransactionsDao transactionsDao = TransactionsDao(
    this as AppDatabase,
  );
  late final CashflowDao cashflowDao = CashflowDao(this as AppDatabase);
  late final RecurringDao recurringDao = RecurringDao(this as AppDatabase);
  late final ReferencesDao referencesDao = ReferencesDao(this as AppDatabase);
  late final CurrenciesDao currenciesDao = CurrenciesDao(this as AppDatabase);
  late final GoalsDao goalsDao = GoalsDao(this as AppDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final AuditDao auditDao = AuditDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    currencies,
    assets,
    subgroups,
    accountDetails,
    investmentDetails,
    propertyDetails,
    assetValuations,
    assetTransfers,
    assetTransactions,
    assetTransactionRevisions,
    categories,
    recurringCashflowRules,
    cashflowEntries,
    cashflowEntryRevisions,
    exchangeRates,
    goals,
    goalAssets,
    appSettings,
    assetsKindArchived,
    assetsCurrency,
    assetsArchivedName,
    accountDetailsBank,
    investmentDetailsBroker,
    assetValuationsAssetEffective,
    assetValuationsEffective,
    assetValuationsAssetCreated,
    assetTransactionsAssetOccurred,
    assetTransactionsOccurred,
    assetTransactionsKind,
    assetTransactionsTransfer,
    assetTransactionsDeletedOccurred,
    assetTransactionRevisionsTxChanged,
    cashflowOccurred,
    cashflowKindOccurred,
    cashflowCategoryOccurred,
    cashflowCurrencyOccurred,
    cashflowPropertyOccurred,
    cashflowAccountOccurred,
    cashflowAssetTx,
    cashflowDeletedOccurred,
    cashflowRevisionsEntryChanged,
    subgroupsKindName,
    exchangeRatesCurrencyDate,
    categoriesKindArchivedName,
    categoriesArchived,
    goalsStatusDeleted,
    goalsTargetDate,
    goalsCurrency,
    goalAssetsAssetGoal,
    recurringDeleted,
    recurringAccount,
    recurringProperty,
  ];
}

typedef $$CurrenciesTableCreateCompanionBuilder = CurrenciesCompanion Function({
  required String code,
  required String name,
  required String normalizedName,
  required int fractionDigits,
  Value<bool> isPreset,
  Value<bool> isEnabled,
  Value<int> rowid,
});
typedef $$CurrenciesTableUpdateCompanionBuilder = CurrenciesCompanion Function({
  Value<String> code,
  Value<String> name,
  Value<String> normalizedName,
  Value<int> fractionDigits,
  Value<bool> isPreset,
  Value<bool> isEnabled,
  Value<int> rowid,
});

final class $$CurrenciesTableReferences
    extends BaseReferences<_$AppDatabase, $CurrenciesTable, CurrencyRow> {
  $$CurrenciesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssetsTable, List<AssetRow>> _assetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.assets,
    aliasName: 'currencies__code__assets__currency_code',
  );

  $$AssetsTableProcessedTableManager get assetsRefs {
    final manager = $$AssetsTableTableManager($_db, $_db.assets).filter(
      (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
    );

    final cache = $_typedResult.readTableOrNull(_assetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssetValuationsTable, List<AssetValuationRow>>
  _assetValuationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assetValuations,
    aliasName: 'currencies__code__asset_valuations__currency_code',
  );

  $$AssetValuationsTableProcessedTableManager get assetValuationsRefs {
    final manager =
        $$AssetValuationsTableTableManager($_db, $_db.assetValuations).filter(
          (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _assetValuationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssetTransactionsTable, List<AssetTransactionRow>>
  _assetTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.assetTransactions,
        aliasName: 'currencies__code__asset_transactions__currency_code',
      );

  $$AssetTransactionsTableProcessedTableManager get assetTransactionsRefs {
    final manager =
        $$AssetTransactionsTableTableManager(
          $_db,
          $_db.assetTransactions,
        ).filter(
          (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _assetTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringCashflowRulesTable,
    List<RecurringCashflowRuleRow>
  >
  _recurringCashflowRulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringCashflowRules,
        aliasName: 'currencies__code__recurring_cashflow_rules__currency_code',
      );

  $$RecurringCashflowRulesTableProcessedTableManager
  get recurringCashflowRulesRefs {
    final manager =
        $$RecurringCashflowRulesTableTableManager(
          $_db,
          $_db.recurringCashflowRules,
        ).filter(
          (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _recurringCashflowRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashflowEntriesTable, List<CashflowEntryRow>>
  _cashflowEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashflowEntries,
    aliasName: 'currencies__code__cashflow_entries__currency_code',
  );

  $$CashflowEntriesTableProcessedTableManager get cashflowEntriesRefs {
    final manager =
        $$CashflowEntriesTableTableManager($_db, $_db.cashflowEntries).filter(
          (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _cashflowEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExchangeRatesTable, List<ExchangeRateRow>>
  _exchangeRatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exchangeRates,
    aliasName: 'currencies__code__exchange_rates__currency_code',
  );

  $$ExchangeRatesTableProcessedTableManager get exchangeRatesRefs {
    final manager = $$ExchangeRatesTableTableManager($_db, $_db.exchangeRates)
        .filter(
          (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
        );

    final cache = $_typedResult.readTableOrNull(_exchangeRatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalsTable, List<GoalRow>> _goalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.goals,
    aliasName: 'currencies__code__goals__currency_code',
  );

  $$GoalsTableProcessedTableManager get goalsRefs {
    final manager = $$GoalsTableTableManager($_db, $_db.goals).filter(
      (f) => f.currencyCode.code.sqlEquals($_itemColumn<String>('code')!),
    );

    final cache = $_typedResult.readTableOrNull(_goalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CurrenciesTableFilterComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fractionDigits => $composableBuilder(
    column: $table.fractionDigits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assetsRefs(
    Expression<bool> Function($$AssetsTableFilterComposer f) f,
  ) {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assetValuationsRefs(
    Expression<bool> Function($$AssetValuationsTableFilterComposer f) f,
  ) {
    final $$AssetValuationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.assetValuations,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetValuationsTableFilterComposer(
            $db: $db,
            $table: $db.assetValuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assetTransactionsRefs(
    Expression<bool> Function($$AssetTransactionsTableFilterComposer f) f,
  ) {
    final $$AssetTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.assetTransactions,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.assetTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringCashflowRulesRefs(
    Expression<bool> Function($$RecurringCashflowRulesTableFilterComposer f) f,
  ) {
    final $$RecurringCashflowRulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.code,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.currencyCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableFilterComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> cashflowEntriesRefs(
    Expression<bool> Function($$CashflowEntriesTableFilterComposer f) f,
  ) {
    final $$CashflowEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> exchangeRatesRefs(
    Expression<bool> Function($$ExchangeRatesTableFilterComposer f) f,
  ) {
    final $$ExchangeRatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.exchangeRates,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExchangeRatesTableFilterComposer(
            $db: $db,
            $table: $db.exchangeRates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalsRefs(
    Expression<bool> Function($$GoalsTableFilterComposer f) f,
  ) {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CurrenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fractionDigits => $composableBuilder(
    column: $table.fractionDigits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CurrenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CurrenciesTable> {
  $$CurrenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fractionDigits => $composableBuilder(
    column: $table.fractionDigits,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPreset =>
      $composableBuilder(column: $table.isPreset, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  Expression<T> assetsRefs<T extends Object>(
    Expression<T> Function($$AssetsTableAnnotationComposer a) f,
  ) {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> assetValuationsRefs<T extends Object>(
    Expression<T> Function($$AssetValuationsTableAnnotationComposer a) f,
  ) {
    final $$AssetValuationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.assetValuations,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetValuationsTableAnnotationComposer(
            $db: $db,
            $table: $db.assetValuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> assetTransactionsRefs<T extends Object>(
    Expression<T> Function($$AssetTransactionsTableAnnotationComposer a) f,
  ) {
    final $$AssetTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.code,
          referencedTable: $db.assetTransactions,
          getReferencedColumn: (t) => t.currencyCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.assetTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recurringCashflowRulesRefs<T extends Object>(
    Expression<T> Function($$RecurringCashflowRulesTableAnnotationComposer a) f,
  ) {
    final $$RecurringCashflowRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.code,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.currencyCode,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> cashflowEntriesRefs<T extends Object>(
    Expression<T> Function($$CashflowEntriesTableAnnotationComposer a) f,
  ) {
    final $$CashflowEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> exchangeRatesRefs<T extends Object>(
    Expression<T> Function($$ExchangeRatesTableAnnotationComposer a) f,
  ) {
    final $$ExchangeRatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.exchangeRates,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExchangeRatesTableAnnotationComposer(
            $db: $db,
            $table: $db.exchangeRates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalsRefs<T extends Object>(
    Expression<T> Function($$GoalsTableAnnotationComposer a) f,
  ) {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.code,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.currencyCode,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CurrenciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CurrenciesTable,
          CurrencyRow,
          $$CurrenciesTableFilterComposer,
          $$CurrenciesTableOrderingComposer,
          $$CurrenciesTableAnnotationComposer,
          $$CurrenciesTableCreateCompanionBuilder,
          $$CurrenciesTableUpdateCompanionBuilder,
          (CurrencyRow, $$CurrenciesTableReferences),
          CurrencyRow,
          PrefetchHooks Function({
            bool assetsRefs,
            bool assetValuationsRefs,
            bool assetTransactionsRefs,
            bool recurringCashflowRulesRefs,
            bool cashflowEntriesRefs,
            bool exchangeRatesRefs,
            bool goalsRefs,
          })
        > {
  $$CurrenciesTableTableManager(_$AppDatabase db, $CurrenciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CurrenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CurrenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CurrenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<int> fractionDigits = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurrenciesCompanion(
                code: code,
                name: name,
                normalizedName: normalizedName,
                fractionDigits: fractionDigits,
                isPreset: isPreset,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String code,
                required String name,
                required String normalizedName,
                required int fractionDigits,
                Value<bool> isPreset = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CurrenciesCompanion.insert(
                code: code,
                name: name,
                normalizedName: normalizedName,
                fractionDigits: fractionDigits,
                isPreset: isPreset,
                isEnabled: isEnabled,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CurrenciesTable, CurrencyRow>(table),
                  $$CurrenciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                assetsRefs = false,
                assetValuationsRefs = false,
                assetTransactionsRefs = false,
                recurringCashflowRulesRefs = false,
                cashflowEntriesRefs = false,
                exchangeRatesRefs = false,
                goalsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (assetsRefs) db.assets,
                    if (assetValuationsRefs) db.assetValuations,
                    if (assetTransactionsRefs) db.assetTransactions,
                    if (recurringCashflowRulesRefs) db.recurringCashflowRules,
                    if (cashflowEntriesRefs) db.cashflowEntries,
                    if (exchangeRatesRefs) db.exchangeRates,
                    if (goalsRefs) db.goals,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (assetsRefs)
                        await $_getPrefetchedDataByColumns<
                          CurrencyRow,
                          $CurrenciesTable,
                          AssetRow,
                          $AssetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._assetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).assetsRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                      if (assetValuationsRefs)
                        await $_getPrefetchedDataByColumns<
                          CurrencyRow,
                          $CurrenciesTable,
                          AssetValuationRow,
                          $AssetValuationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._assetValuationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).assetValuationsRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                      if (assetTransactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          CurrencyRow,
                          $CurrenciesTable,
                          AssetTransactionRow,
                          $AssetTransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._assetTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).assetTransactionsRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                      if (recurringCashflowRulesRefs)
                        await $_getPrefetchedDataByColumns<
                          CurrencyRow,
                          $CurrenciesTable,
                          RecurringCashflowRuleRow,
                          $RecurringCashflowRulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._recurringCashflowRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringCashflowRulesRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                      if (cashflowEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          CurrencyRow,
                          $CurrenciesTable,
                          CashflowEntryRow,
                          $CashflowEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._cashflowEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).cashflowEntriesRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                      if (exchangeRatesRefs)
                        await $_getPrefetchedDataByColumns<
                          CurrencyRow,
                          $CurrenciesTable,
                          ExchangeRateRow,
                          $ExchangeRatesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._exchangeRatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).exchangeRatesRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                      if (goalsRefs)
                        await $_getPrefetchedDataByColumns<
                          CurrencyRow,
                          $CurrenciesTable,
                          GoalRow,
                          $GoalsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CurrenciesTableReferences
                              ._goalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CurrenciesTableReferences(
                                db,
                                table,
                                p0,
                              ).goalsRefs,
                          currentColumn: 'code',
                          referencedColumn: 'currency_code',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CurrenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CurrenciesTable,
      CurrencyRow,
      $$CurrenciesTableFilterComposer,
      $$CurrenciesTableOrderingComposer,
      $$CurrenciesTableAnnotationComposer,
      $$CurrenciesTableCreateCompanionBuilder,
      $$CurrenciesTableUpdateCompanionBuilder,
      (CurrencyRow, $$CurrenciesTableReferences),
      CurrencyRow,
      PrefetchHooks Function({
        bool assetsRefs,
        bool assetValuationsRefs,
        bool assetTransactionsRefs,
        bool recurringCashflowRulesRefs,
        bool cashflowEntriesRefs,
        bool exchangeRatesRefs,
        bool goalsRefs,
      })
    >;
typedef $$AssetsTableCreateCompanionBuilder = AssetsCompanion Function({
  Value<int> id,
  required String name,
  required AssetKind kind,
  required String currencyCode,
  required int openingValueMinor,
  required DateTime createdAt,
  Value<DateTime?> archivedAt,
});
typedef $$AssetsTableUpdateCompanionBuilder = AssetsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<AssetKind> kind,
  Value<String> currencyCode,
  Value<int> openingValueMinor,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
});

final class $$AssetsTableReferences
    extends BaseReferences<_$AppDatabase, $AssetsTable, AssetRow> {
  $$AssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) =>
      db.currencies.createAlias('assets__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$AccountDetailsTable, List<AccountDetailRow>>
  _accountDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.accountDetails,
    aliasName: 'assets__id__account_details__asset_id',
  );

  $$AccountDetailsTableProcessedTableManager get accountDetailsRefs {
    final manager = $$AccountDetailsTableTableManager(
      $_db,
      $_db.accountDetails,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountDetailsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestmentDetailsTable, List<InvestmentDetailRow>>
  _investmentDetailsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.investmentDetails,
        aliasName: 'assets__id__investment_details__asset_id',
      );

  $$InvestmentDetailsTableProcessedTableManager get investmentDetailsRefs {
    final manager = $$InvestmentDetailsTableTableManager(
      $_db,
      $_db.investmentDetails,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _investmentDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PropertyDetailsTable, List<PropertyDetailRow>>
  _propertyDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.propertyDetails,
    aliasName: 'assets__id__property_details__asset_id',
  );

  $$PropertyDetailsTableProcessedTableManager get propertyDetailsRefs {
    final manager = $$PropertyDetailsTableTableManager(
      $_db,
      $_db.propertyDetails,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _propertyDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssetValuationsTable, List<AssetValuationRow>>
  _assetValuationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assetValuations,
    aliasName: 'assets__id__asset_valuations__asset_id',
  );

  $$AssetValuationsTableProcessedTableManager get assetValuationsRefs {
    final manager = $$AssetValuationsTableTableManager(
      $_db,
      $_db.assetValuations,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assetValuationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssetTransactionsTable, List<AssetTransactionRow>>
  _assetTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.assetTransactions,
        aliasName: 'assets__id__asset_transactions__asset_id',
      );

  $$AssetTransactionsTableProcessedTableManager get assetTransactionsRefs {
    final manager = $$AssetTransactionsTableTableManager(
      $_db,
      $_db.assetTransactions,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assetTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringCashflowRulesTable,
    List<RecurringCashflowRuleRow>
  >
  _recurringAccountRulesTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringCashflowRules,
        aliasName: 'assets__id__recurring_cashflow_rules__account_id',
      );

  $$RecurringCashflowRulesTableProcessedTableManager get recurringAccountRules {
    final manager = $$RecurringCashflowRulesTableTableManager(
      $_db,
      $_db.recurringCashflowRules,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringAccountRulesTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RecurringCashflowRulesTable,
    List<RecurringCashflowRuleRow>
  >
  _recurringPropertyRulesTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringCashflowRules,
        aliasName: 'assets__id__recurring_cashflow_rules__property_id',
      );

  $$RecurringCashflowRulesTableProcessedTableManager
  get recurringPropertyRules {
    final manager = $$RecurringCashflowRulesTableTableManager(
      $_db,
      $_db.recurringCashflowRules,
    ).filter((f) => f.propertyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringPropertyRulesTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashflowEntriesTable, List<CashflowEntryRow>>
  _propertyEntriesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashflowEntries,
    aliasName: 'assets__id__cashflow_entries__property_id',
  );

  $$CashflowEntriesTableProcessedTableManager get propertyEntries {
    final manager = $$CashflowEntriesTableTableManager(
      $_db,
      $_db.cashflowEntries,
    ).filter((f) => f.propertyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_propertyEntriesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashflowEntriesTable, List<CashflowEntryRow>>
  _accountEntriesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashflowEntries,
    aliasName: 'assets__id__cashflow_entries__account_id',
  );

  $$CashflowEntriesTableProcessedTableManager get accountEntries {
    final manager = $$CashflowEntriesTableTableManager(
      $_db,
      $_db.cashflowEntries,
    ).filter((f) => f.accountId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountEntriesTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$GoalAssetsTable, List<GoalAssetRow>>
  _goalAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.goalAssets,
    aliasName: 'assets__id__goal_assets__asset_id',
  );

  $$GoalAssetsTableProcessedTableManager get goalAssetsRefs {
    final manager = $$GoalAssetsTableTableManager(
      $_db,
      $_db.goalAssets,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AssetKind, AssetKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get openingValueMinor => $composableBuilder(
    column: $table.openingValueMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> accountDetailsRefs(
    Expression<bool> Function($$AccountDetailsTableFilterComposer f) f,
  ) {
    final $$AccountDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accountDetails,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountDetailsTableFilterComposer(
            $db: $db,
            $table: $db.accountDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investmentDetailsRefs(
    Expression<bool> Function($$InvestmentDetailsTableFilterComposer f) f,
  ) {
    final $$InvestmentDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentDetails,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentDetailsTableFilterComposer(
            $db: $db,
            $table: $db.investmentDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> propertyDetailsRefs(
    Expression<bool> Function($$PropertyDetailsTableFilterComposer f) f,
  ) {
    final $$PropertyDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.propertyDetails,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PropertyDetailsTableFilterComposer(
            $db: $db,
            $table: $db.propertyDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assetValuationsRefs(
    Expression<bool> Function($$AssetValuationsTableFilterComposer f) f,
  ) {
    final $$AssetValuationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetValuations,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetValuationsTableFilterComposer(
            $db: $db,
            $table: $db.assetValuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assetTransactionsRefs(
    Expression<bool> Function($$AssetTransactionsTableFilterComposer f) f,
  ) {
    final $$AssetTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetTransactions,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.assetTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringAccountRules(
    Expression<bool> Function($$RecurringCashflowRulesTableFilterComposer f) f,
  ) {
    final $$RecurringCashflowRulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableFilterComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> recurringPropertyRules(
    Expression<bool> Function($$RecurringCashflowRulesTableFilterComposer f) f,
  ) {
    final $$RecurringCashflowRulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.propertyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableFilterComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> propertyEntries(
    Expression<bool> Function($$CashflowEntriesTableFilterComposer f) f,
  ) {
    final $$CashflowEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.propertyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> accountEntries(
    Expression<bool> Function($$CashflowEntriesTableFilterComposer f) f,
  ) {
    final $$CashflowEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> goalAssetsRefs(
    Expression<bool> Function($$GoalAssetsTableFilterComposer f) f,
  ) {
    final $$GoalAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalAssets,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalAssetsTableFilterComposer(
            $db: $db,
            $table: $db.goalAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingValueMinor => $composableBuilder(
    column: $table.openingValueMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AssetKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get openingValueMinor => $composableBuilder(
    column: $table.openingValueMinor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> accountDetailsRefs<T extends Object>(
    Expression<T> Function($$AccountDetailsTableAnnotationComposer a) f,
  ) {
    final $$AccountDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accountDetails,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.accountDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investmentDetailsRefs<T extends Object>(
    Expression<T> Function($$InvestmentDetailsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentDetailsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.investmentDetails,
          getReferencedColumn: (t) => t.assetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InvestmentDetailsTableAnnotationComposer(
                $db: $db,
                $table: $db.investmentDetails,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> propertyDetailsRefs<T extends Object>(
    Expression<T> Function($$PropertyDetailsTableAnnotationComposer a) f,
  ) {
    final $$PropertyDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.propertyDetails,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PropertyDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.propertyDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> assetValuationsRefs<T extends Object>(
    Expression<T> Function($$AssetValuationsTableAnnotationComposer a) f,
  ) {
    final $$AssetValuationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetValuations,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetValuationsTableAnnotationComposer(
            $db: $db,
            $table: $db.assetValuations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> assetTransactionsRefs<T extends Object>(
    Expression<T> Function($$AssetTransactionsTableAnnotationComposer a) f,
  ) {
    final $$AssetTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assetTransactions,
          getReferencedColumn: (t) => t.assetId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.assetTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recurringAccountRules<T extends Object>(
    Expression<T> Function($$RecurringCashflowRulesTableAnnotationComposer a) f,
  ) {
    final $$RecurringCashflowRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.accountId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recurringPropertyRules<T extends Object>(
    Expression<T> Function($$RecurringCashflowRulesTableAnnotationComposer a) f,
  ) {
    final $$RecurringCashflowRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.propertyId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> propertyEntries<T extends Object>(
    Expression<T> Function($$CashflowEntriesTableAnnotationComposer a) f,
  ) {
    final $$CashflowEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.propertyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> accountEntries<T extends Object>(
    Expression<T> Function($$CashflowEntriesTableAnnotationComposer a) f,
  ) {
    final $$CashflowEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.accountId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> goalAssetsRefs<T extends Object>(
    Expression<T> Function($$GoalAssetsTableAnnotationComposer a) f,
  ) {
    final $$GoalAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalAssets,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.goalAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetsTable,
          AssetRow,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (AssetRow, $$AssetsTableReferences),
          AssetRow,
          PrefetchHooks Function({
            bool currencyCode,
            bool accountDetailsRefs,
            bool investmentDetailsRefs,
            bool propertyDetailsRefs,
            bool assetValuationsRefs,
            bool assetTransactionsRefs,
            bool recurringAccountRules,
            bool recurringPropertyRules,
            bool propertyEntries,
            bool accountEntries,
            bool goalAssetsRefs,
          })
        > {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AssetKind> kind = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int> openingValueMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                name: name,
                kind: kind,
                currencyCode: currencyCode,
                openingValueMinor: openingValueMinor,
                createdAt: createdAt,
                archivedAt: archivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required AssetKind kind,
                required String currencyCode,
                required int openingValueMinor,
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                name: name,
                kind: kind,
                currencyCode: currencyCode,
                openingValueMinor: openingValueMinor,
                createdAt: createdAt,
                archivedAt: archivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetsTable, AssetRow>(table),
                  $$AssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                currencyCode = false,
                accountDetailsRefs = false,
                investmentDetailsRefs = false,
                propertyDetailsRefs = false,
                assetValuationsRefs = false,
                assetTransactionsRefs = false,
                recurringAccountRules = false,
                recurringPropertyRules = false,
                propertyEntries = false,
                accountEntries = false,
                goalAssetsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (accountDetailsRefs) db.accountDetails,
                    if (investmentDetailsRefs) db.investmentDetails,
                    if (propertyDetailsRefs) db.propertyDetails,
                    if (assetValuationsRefs) db.assetValuations,
                    if (assetTransactionsRefs) db.assetTransactions,
                    if (recurringAccountRules) db.recurringCashflowRules,
                    if (recurringPropertyRules) db.recurringCashflowRules,
                    if (propertyEntries) db.cashflowEntries,
                    if (accountEntries) db.cashflowEntries,
                    if (goalAssetsRefs) db.goalAssets,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (currencyCode) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.currencyCode,
                            referencedTable: $$AssetsTableReferences
                                ._currencyCodeTable(db),
                            referencedColumn: $$AssetsTableReferences
                                ._currencyCodeTable(db)
                                .code,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (accountDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          AccountDetailRow,
                          $AccountDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._accountDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).accountDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                      if (investmentDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          InvestmentDetailRow,
                          $InvestmentDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._investmentDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                      if (propertyDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          PropertyDetailRow,
                          $PropertyDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._propertyDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).propertyDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                      if (assetValuationsRefs)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          AssetValuationRow,
                          $AssetValuationsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._assetValuationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).assetValuationsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                      if (assetTransactionsRefs)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          AssetTransactionRow,
                          $AssetTransactionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._assetTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).assetTransactionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                      if (recurringAccountRules)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          RecurringCashflowRuleRow,
                          $RecurringCashflowRulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._recurringAccountRulesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringAccountRules,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (recurringPropertyRules)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          RecurringCashflowRuleRow,
                          $RecurringCashflowRulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._recurringPropertyRulesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringPropertyRules,
                          currentColumn: 'id',
                          referencedColumn: 'property_id',
                          typedResults: items,
                        ),
                      if (propertyEntries)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          CashflowEntryRow,
                          $CashflowEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._propertyEntriesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).propertyEntries,
                          currentColumn: 'id',
                          referencedColumn: 'property_id',
                          typedResults: items,
                        ),
                      if (accountEntries)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          CashflowEntryRow,
                          $CashflowEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._accountEntriesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).accountEntries,
                          currentColumn: 'id',
                          referencedColumn: 'account_id',
                          typedResults: items,
                        ),
                      if (goalAssetsRefs)
                        await $_getPrefetchedDataByColumns<
                          AssetRow,
                          $AssetsTable,
                          GoalAssetRow,
                          $GoalAssetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._goalAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalAssetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetsTable,
      AssetRow,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (AssetRow, $$AssetsTableReferences),
      AssetRow,
      PrefetchHooks Function({
        bool currencyCode,
        bool accountDetailsRefs,
        bool investmentDetailsRefs,
        bool propertyDetailsRefs,
        bool assetValuationsRefs,
        bool assetTransactionsRefs,
        bool recurringAccountRules,
        bool recurringPropertyRules,
        bool propertyEntries,
        bool accountEntries,
        bool goalAssetsRefs,
      })
    >;
typedef $$SubgroupsTableCreateCompanionBuilder = SubgroupsCompanion Function({
  Value<int> id,
  required SubgroupKind kind,
  required String name,
  required String normalizedName,
  required DateTime createdAt,
});
typedef $$SubgroupsTableUpdateCompanionBuilder = SubgroupsCompanion Function({
  Value<int> id,
  Value<SubgroupKind> kind,
  Value<String> name,
  Value<String> normalizedName,
  Value<DateTime> createdAt,
});

final class $$SubgroupsTableReferences
    extends BaseReferences<_$AppDatabase, $SubgroupsTable, SubgroupRow> {
  $$SubgroupsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AccountDetailsTable, List<AccountDetailRow>>
  _accountDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.accountDetails,
    aliasName: 'subgroups__id__account_details__bank_id',
  );

  $$AccountDetailsTableProcessedTableManager get accountDetailsRefs {
    final manager = $$AccountDetailsTableTableManager(
      $_db,
      $_db.accountDetails,
    ).filter((f) => f.bankId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_accountDetailsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvestmentDetailsTable, List<InvestmentDetailRow>>
  _investmentDetailsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.investmentDetails,
        aliasName: 'subgroups__id__investment_details__broker_id',
      );

  $$InvestmentDetailsTableProcessedTableManager get investmentDetailsRefs {
    final manager = $$InvestmentDetailsTableTableManager(
      $_db,
      $_db.investmentDetails,
    ).filter((f) => f.brokerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _investmentDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubgroupsTableFilterComposer
    extends Composer<_$AppDatabase, $SubgroupsTable> {
  $$SubgroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<SubgroupKind, SubgroupKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> accountDetailsRefs(
    Expression<bool> Function($$AccountDetailsTableFilterComposer f) f,
  ) {
    final $$AccountDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accountDetails,
      getReferencedColumn: (t) => t.bankId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountDetailsTableFilterComposer(
            $db: $db,
            $table: $db.accountDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> investmentDetailsRefs(
    Expression<bool> Function($$InvestmentDetailsTableFilterComposer f) f,
  ) {
    final $$InvestmentDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.investmentDetails,
      getReferencedColumn: (t) => t.brokerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvestmentDetailsTableFilterComposer(
            $db: $db,
            $table: $db.investmentDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubgroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubgroupsTable> {
  $$SubgroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubgroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubgroupsTable> {
  $$SubgroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<SubgroupKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> accountDetailsRefs<T extends Object>(
    Expression<T> Function($$AccountDetailsTableAnnotationComposer a) f,
  ) {
    final $$AccountDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.accountDetails,
      getReferencedColumn: (t) => t.bankId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AccountDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.accountDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> investmentDetailsRefs<T extends Object>(
    Expression<T> Function($$InvestmentDetailsTableAnnotationComposer a) f,
  ) {
    final $$InvestmentDetailsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.investmentDetails,
          getReferencedColumn: (t) => t.brokerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InvestmentDetailsTableAnnotationComposer(
                $db: $db,
                $table: $db.investmentDetails,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$SubgroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubgroupsTable,
          SubgroupRow,
          $$SubgroupsTableFilterComposer,
          $$SubgroupsTableOrderingComposer,
          $$SubgroupsTableAnnotationComposer,
          $$SubgroupsTableCreateCompanionBuilder,
          $$SubgroupsTableUpdateCompanionBuilder,
          (SubgroupRow, $$SubgroupsTableReferences),
          SubgroupRow,
          PrefetchHooks Function({
            bool accountDetailsRefs,
            bool investmentDetailsRefs,
          })
        > {
  $$SubgroupsTableTableManager(_$AppDatabase db, $SubgroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubgroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubgroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubgroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<SubgroupKind> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SubgroupsCompanion(
                id: id,
                kind: kind,
                name: name,
                normalizedName: normalizedName,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required SubgroupKind kind,
                required String name,
                required String normalizedName,
                required DateTime createdAt,
              }) => SubgroupsCompanion.insert(
                id: id,
                kind: kind,
                name: name,
                normalizedName: normalizedName,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SubgroupsTable, SubgroupRow>(table),
                  $$SubgroupsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({accountDetailsRefs = false, investmentDetailsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (accountDetailsRefs) db.accountDetails,
                    if (investmentDetailsRefs) db.investmentDetails,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (accountDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          SubgroupRow,
                          $SubgroupsTable,
                          AccountDetailRow,
                          $AccountDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SubgroupsTableReferences
                              ._accountDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubgroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).accountDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'bank_id',
                          typedResults: items,
                        ),
                      if (investmentDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          SubgroupRow,
                          $SubgroupsTable,
                          InvestmentDetailRow,
                          $InvestmentDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$SubgroupsTableReferences
                              ._investmentDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubgroupsTableReferences(
                                db,
                                table,
                                p0,
                              ).investmentDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'broker_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SubgroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubgroupsTable,
      SubgroupRow,
      $$SubgroupsTableFilterComposer,
      $$SubgroupsTableOrderingComposer,
      $$SubgroupsTableAnnotationComposer,
      $$SubgroupsTableCreateCompanionBuilder,
      $$SubgroupsTableUpdateCompanionBuilder,
      (SubgroupRow, $$SubgroupsTableReferences),
      SubgroupRow,
      PrefetchHooks Function({
        bool accountDetailsRefs,
        bool investmentDetailsRefs,
      })
    >;
typedef $$AccountDetailsTableCreateCompanionBuilder =
    AccountDetailsCompanion Function({
      Value<int> assetId,
      required int bankId,
      required Decimal annualRate,
      required LocalDate startDate,
      Value<LocalDate?> endDate,
    });
typedef $$AccountDetailsTableUpdateCompanionBuilder =
    AccountDetailsCompanion Function({
      Value<int> assetId,
      Value<int> bankId,
      Value<Decimal> annualRate,
      Value<LocalDate> startDate,
      Value<LocalDate?> endDate,
    });

final class $$AccountDetailsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AccountDetailsTable, AccountDetailRow> {
  $$AccountDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('account_details__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<int>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubgroupsTable _bankIdTable(_$AppDatabase db) =>
      db.subgroups.createAlias('account_details__bank_id__subgroups__id');

  $$SubgroupsTableProcessedTableManager get bankId {
    final $_column = $_itemColumn<int>('bank_id')!;

    final manager = $$SubgroupsTableTableManager(
      $_db,
      $_db.subgroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bankIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AccountDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $AccountDetailsTable> {
  $$AccountDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get annualRate =>
      $composableBuilder(
        column: $table.annualRate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get startDate =>
      $composableBuilder(
        column: $table.startDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String> get endDate =>
      $composableBuilder(
        column: $table.endDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubgroupsTableFilterComposer get bankId {
    final $$SubgroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bankId,
      referencedTable: $db.subgroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubgroupsTableFilterComposer(
            $db: $db,
            $table: $db.subgroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $AccountDetailsTable> {
  $$AccountDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get annualRate => $composableBuilder(
    column: $table.annualRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubgroupsTableOrderingComposer get bankId {
    final $$SubgroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bankId,
      referencedTable: $db.subgroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubgroupsTableOrderingComposer(
            $db: $db,
            $table: $db.subgroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AccountDetailsTable> {
  $$AccountDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Decimal, String> get annualRate =>
      $composableBuilder(
        column: $table.annualRate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<LocalDate, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate?, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubgroupsTableAnnotationComposer get bankId {
    final $$SubgroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bankId,
      referencedTable: $db.subgroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubgroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.subgroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AccountDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AccountDetailsTable,
          AccountDetailRow,
          $$AccountDetailsTableFilterComposer,
          $$AccountDetailsTableOrderingComposer,
          $$AccountDetailsTableAnnotationComposer,
          $$AccountDetailsTableCreateCompanionBuilder,
          $$AccountDetailsTableUpdateCompanionBuilder,
          (AccountDetailRow, $$AccountDetailsTableReferences),
          AccountDetailRow,
          PrefetchHooks Function({bool assetId, bool bankId})
        > {
  $$AccountDetailsTableTableManager(
    _$AppDatabase db,
    $AccountDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AccountDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AccountDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AccountDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> assetId = const Value.absent(),
                Value<int> bankId = const Value.absent(),
                Value<Decimal> annualRate = const Value.absent(),
                Value<LocalDate> startDate = const Value.absent(),
                Value<LocalDate?> endDate = const Value.absent(),
              }) => AccountDetailsCompanion(
                assetId: assetId,
                bankId: bankId,
                annualRate: annualRate,
                startDate: startDate,
                endDate: endDate,
              ),
          createCompanionCallback:
              ({
                Value<int> assetId = const Value.absent(),
                required int bankId,
                required Decimal annualRate,
                required LocalDate startDate,
                Value<LocalDate?> endDate = const Value.absent(),
              }) => AccountDetailsCompanion.insert(
                assetId: assetId,
                bankId: bankId,
                annualRate: annualRate,
                startDate: startDate,
                endDate: endDate,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AccountDetailsTable, AccountDetailRow>(table),
                  $$AccountDetailsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false, bankId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assetId,
                        referencedTable: $$AccountDetailsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$AccountDetailsTableReferences
                            ._assetIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (bankId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bankId,
                        referencedTable: $$AccountDetailsTableReferences
                            ._bankIdTable(db),
                        referencedColumn: $$AccountDetailsTableReferences
                            ._bankIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AccountDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AccountDetailsTable,
      AccountDetailRow,
      $$AccountDetailsTableFilterComposer,
      $$AccountDetailsTableOrderingComposer,
      $$AccountDetailsTableAnnotationComposer,
      $$AccountDetailsTableCreateCompanionBuilder,
      $$AccountDetailsTableUpdateCompanionBuilder,
      (AccountDetailRow, $$AccountDetailsTableReferences),
      AccountDetailRow,
      PrefetchHooks Function({bool assetId, bool bankId})
    >;
typedef $$InvestmentDetailsTableCreateCompanionBuilder =
    InvestmentDetailsCompanion Function({
      Value<int> assetId,
      required int brokerId,
    });
typedef $$InvestmentDetailsTableUpdateCompanionBuilder =
    InvestmentDetailsCompanion Function({
      Value<int> assetId,
      Value<int> brokerId,
    });

final class $$InvestmentDetailsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InvestmentDetailsTable,
          InvestmentDetailRow
        > {
  $$InvestmentDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('investment_details__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<int>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubgroupsTable _brokerIdTable(_$AppDatabase db) =>
      db.subgroups.createAlias('investment_details__broker_id__subgroups__id');

  $$SubgroupsTableProcessedTableManager get brokerId {
    final $_column = $_itemColumn<int>('broker_id')!;

    final manager = $$SubgroupsTableTableManager(
      $_db,
      $_db.subgroups,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_brokerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvestmentDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentDetailsTable> {
  $$InvestmentDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubgroupsTableFilterComposer get brokerId {
    final $$SubgroupsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.brokerId,
      referencedTable: $db.subgroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubgroupsTableFilterComposer(
            $db: $db,
            $table: $db.subgroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentDetailsTable> {
  $$InvestmentDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubgroupsTableOrderingComposer get brokerId {
    final $$SubgroupsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.brokerId,
      referencedTable: $db.subgroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubgroupsTableOrderingComposer(
            $db: $db,
            $table: $db.subgroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentDetailsTable> {
  $$InvestmentDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubgroupsTableAnnotationComposer get brokerId {
    final $$SubgroupsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.brokerId,
      referencedTable: $db.subgroups,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubgroupsTableAnnotationComposer(
            $db: $db,
            $table: $db.subgroups,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvestmentDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvestmentDetailsTable,
          InvestmentDetailRow,
          $$InvestmentDetailsTableFilterComposer,
          $$InvestmentDetailsTableOrderingComposer,
          $$InvestmentDetailsTableAnnotationComposer,
          $$InvestmentDetailsTableCreateCompanionBuilder,
          $$InvestmentDetailsTableUpdateCompanionBuilder,
          (InvestmentDetailRow, $$InvestmentDetailsTableReferences),
          InvestmentDetailRow,
          PrefetchHooks Function({bool assetId, bool brokerId})
        > {
  $$InvestmentDetailsTableTableManager(
    _$AppDatabase db,
    $InvestmentDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentDetailsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> assetId = const Value.absent(),
                Value<int> brokerId = const Value.absent(),
              }) => InvestmentDetailsCompanion(
                assetId: assetId,
                brokerId: brokerId,
              ),
          createCompanionCallback:
              ({
                Value<int> assetId = const Value.absent(),
                required int brokerId,
              }) => InvestmentDetailsCompanion.insert(
                assetId: assetId,
                brokerId: brokerId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$InvestmentDetailsTable, InvestmentDetailRow>(
                    table,
                  ),
                  $$InvestmentDetailsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false, brokerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assetId,
                        referencedTable: $$InvestmentDetailsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$InvestmentDetailsTableReferences
                            ._assetIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (brokerId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.brokerId,
                        referencedTable: $$InvestmentDetailsTableReferences
                            ._brokerIdTable(db),
                        referencedColumn: $$InvestmentDetailsTableReferences
                            ._brokerIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InvestmentDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvestmentDetailsTable,
      InvestmentDetailRow,
      $$InvestmentDetailsTableFilterComposer,
      $$InvestmentDetailsTableOrderingComposer,
      $$InvestmentDetailsTableAnnotationComposer,
      $$InvestmentDetailsTableCreateCompanionBuilder,
      $$InvestmentDetailsTableUpdateCompanionBuilder,
      (InvestmentDetailRow, $$InvestmentDetailsTableReferences),
      InvestmentDetailRow,
      PrefetchHooks Function({bool assetId, bool brokerId})
    >;
typedef $$PropertyDetailsTableCreateCompanionBuilder =
    PropertyDetailsCompanion Function({
      Value<int> assetId,
      Value<String?> address,
      Value<int?> purchasePriceMinor,
    });
typedef $$PropertyDetailsTableUpdateCompanionBuilder =
    PropertyDetailsCompanion Function({
      Value<int> assetId,
      Value<String?> address,
      Value<int?> purchasePriceMinor,
    });

final class $$PropertyDetailsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PropertyDetailsTable,
          PropertyDetailRow
        > {
  $$PropertyDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('property_details__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<int>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PropertyDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $PropertyDetailsTable> {
  $$PropertyDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchasePriceMinor => $composableBuilder(
    column: $table.purchasePriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PropertyDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $PropertyDetailsTable> {
  $$PropertyDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchasePriceMinor => $composableBuilder(
    column: $table.purchasePriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PropertyDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PropertyDetailsTable> {
  $$PropertyDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<int> get purchasePriceMinor => $composableBuilder(
    column: $table.purchasePriceMinor,
    builder: (column) => column,
  );

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PropertyDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PropertyDetailsTable,
          PropertyDetailRow,
          $$PropertyDetailsTableFilterComposer,
          $$PropertyDetailsTableOrderingComposer,
          $$PropertyDetailsTableAnnotationComposer,
          $$PropertyDetailsTableCreateCompanionBuilder,
          $$PropertyDetailsTableUpdateCompanionBuilder,
          (PropertyDetailRow, $$PropertyDetailsTableReferences),
          PropertyDetailRow,
          PrefetchHooks Function({bool assetId})
        > {
  $$PropertyDetailsTableTableManager(
    _$AppDatabase db,
    $PropertyDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PropertyDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PropertyDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PropertyDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> assetId = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int?> purchasePriceMinor = const Value.absent(),
              }) => PropertyDetailsCompanion(
                assetId: assetId,
                address: address,
                purchasePriceMinor: purchasePriceMinor,
              ),
          createCompanionCallback:
              ({
                Value<int> assetId = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int?> purchasePriceMinor = const Value.absent(),
              }) => PropertyDetailsCompanion.insert(
                assetId: assetId,
                address: address,
                purchasePriceMinor: purchasePriceMinor,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PropertyDetailsTable, PropertyDetailRow>(table),
                  $$PropertyDetailsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assetId,
                        referencedTable: $$PropertyDetailsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$PropertyDetailsTableReferences
                            ._assetIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PropertyDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PropertyDetailsTable,
      PropertyDetailRow,
      $$PropertyDetailsTableFilterComposer,
      $$PropertyDetailsTableOrderingComposer,
      $$PropertyDetailsTableAnnotationComposer,
      $$PropertyDetailsTableCreateCompanionBuilder,
      $$PropertyDetailsTableUpdateCompanionBuilder,
      (PropertyDetailRow, $$PropertyDetailsTableReferences),
      PropertyDetailRow,
      PrefetchHooks Function({bool assetId})
    >;
typedef $$AssetValuationsTableCreateCompanionBuilder =
    AssetValuationsCompanion Function({
      Value<int> id,
      required int assetId,
      required LocalDate effectiveOn,
      required int valueMinor,
      Value<String?> currencyCode,
      required Decimal rateToRub,
      required int valueRubMinor,
      required DateTime createdAt,
    });
typedef $$AssetValuationsTableUpdateCompanionBuilder =
    AssetValuationsCompanion Function({
      Value<int> id,
      Value<int> assetId,
      Value<LocalDate> effectiveOn,
      Value<int> valueMinor,
      Value<String?> currencyCode,
      Value<Decimal> rateToRub,
      Value<int> valueRubMinor,
      Value<DateTime> createdAt,
    });

final class $$AssetValuationsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssetValuationsTable,
          AssetValuationRow
        > {
  $$AssetValuationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('asset_valuations__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<int>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) => db.currencies
      .createAlias('asset_valuations__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager? get currencyCode {
    final $_column = $_itemColumn<String>('currency_code');
    if ($_column == null) return null;
    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssetValuationsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetValuationsTable> {
  $$AssetValuationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String>
  get effectiveOn => $composableBuilder(
    column: $table.effectiveOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get valueMinor => $composableBuilder(
    column: $table.valueMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get rateToRub =>
      $composableBuilder(
        column: $table.rateToRub,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get valueRubMinor => $composableBuilder(
    column: $table.valueRubMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetValuationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetValuationsTable> {
  $$AssetValuationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveOn => $composableBuilder(
    column: $table.effectiveOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueMinor => $composableBuilder(
    column: $table.valueMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateToRub => $composableBuilder(
    column: $table.rateToRub,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valueRubMinor => $composableBuilder(
    column: $table.valueRubMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetValuationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetValuationsTable> {
  $$AssetValuationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get effectiveOn =>
      $composableBuilder(
        column: $table.effectiveOn,
        builder: (column) => column,
      );

  GeneratedColumn<int> get valueMinor => $composableBuilder(
    column: $table.valueMinor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Decimal, String> get rateToRub =>
      $composableBuilder(column: $table.rateToRub, builder: (column) => column);

  GeneratedColumn<int> get valueRubMinor => $composableBuilder(
    column: $table.valueRubMinor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetValuationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetValuationsTable,
          AssetValuationRow,
          $$AssetValuationsTableFilterComposer,
          $$AssetValuationsTableOrderingComposer,
          $$AssetValuationsTableAnnotationComposer,
          $$AssetValuationsTableCreateCompanionBuilder,
          $$AssetValuationsTableUpdateCompanionBuilder,
          (AssetValuationRow, $$AssetValuationsTableReferences),
          AssetValuationRow,
          PrefetchHooks Function({bool assetId, bool currencyCode})
        > {
  $$AssetValuationsTableTableManager(
    _$AppDatabase db,
    $AssetValuationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetValuationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetValuationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetValuationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<LocalDate> effectiveOn = const Value.absent(),
                Value<int> valueMinor = const Value.absent(),
                Value<String?> currencyCode = const Value.absent(),
                Value<Decimal> rateToRub = const Value.absent(),
                Value<int> valueRubMinor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssetValuationsCompanion(
                id: id,
                assetId: assetId,
                effectiveOn: effectiveOn,
                valueMinor: valueMinor,
                currencyCode: currencyCode,
                rateToRub: rateToRub,
                valueRubMinor: valueRubMinor,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                required LocalDate effectiveOn,
                required int valueMinor,
                Value<String?> currencyCode = const Value.absent(),
                required Decimal rateToRub,
                required int valueRubMinor,
                required DateTime createdAt,
              }) => AssetValuationsCompanion.insert(
                id: id,
                assetId: assetId,
                effectiveOn: effectiveOn,
                valueMinor: valueMinor,
                currencyCode: currencyCode,
                rateToRub: rateToRub,
                valueRubMinor: valueRubMinor,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetValuationsTable, AssetValuationRow>(table),
                  $$AssetValuationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false, currencyCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assetId,
                        referencedTable: $$AssetValuationsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$AssetValuationsTableReferences
                            ._assetIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (currencyCode) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.currencyCode,
                        referencedTable: $$AssetValuationsTableReferences
                            ._currencyCodeTable(db),
                        referencedColumn: $$AssetValuationsTableReferences
                            ._currencyCodeTable(db)
                            .code,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AssetValuationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetValuationsTable,
      AssetValuationRow,
      $$AssetValuationsTableFilterComposer,
      $$AssetValuationsTableOrderingComposer,
      $$AssetValuationsTableAnnotationComposer,
      $$AssetValuationsTableCreateCompanionBuilder,
      $$AssetValuationsTableUpdateCompanionBuilder,
      (AssetValuationRow, $$AssetValuationsTableReferences),
      AssetValuationRow,
      PrefetchHooks Function({bool assetId, bool currencyCode})
    >;
typedef $$AssetTransfersTableCreateCompanionBuilder =
    AssetTransfersCompanion Function({
      Value<int> id,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$AssetTransfersTableUpdateCompanionBuilder =
    AssetTransfersCompanion Function({
      Value<int> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$AssetTransfersTableReferences
    extends
        BaseReferences<_$AppDatabase, $AssetTransfersTable, AssetTransferRow> {
  $$AssetTransfersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AssetTransactionsTable, List<AssetTransactionRow>>
  _assetTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.assetTransactions,
        aliasName: 'asset_transfers__id__asset_transactions__transfer_id',
      );

  $$AssetTransactionsTableProcessedTableManager get assetTransactionsRefs {
    final manager = $$AssetTransactionsTableTableManager(
      $_db,
      $_db.assetTransactions,
    ).filter((f) => f.transferId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assetTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssetTransfersTableFilterComposer
    extends Composer<_$AppDatabase, $AssetTransfersTable> {
  $$AssetTransfersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> assetTransactionsRefs(
    Expression<bool> Function($$AssetTransactionsTableFilterComposer f) f,
  ) {
    final $$AssetTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetTransactions,
      getReferencedColumn: (t) => t.transferId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.assetTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetTransfersTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetTransfersTable> {
  $$AssetTransfersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetTransfersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetTransfersTable> {
  $$AssetTransfersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> assetTransactionsRefs<T extends Object>(
    Expression<T> Function($$AssetTransactionsTableAnnotationComposer a) f,
  ) {
    final $$AssetTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assetTransactions,
          getReferencedColumn: (t) => t.transferId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.assetTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$AssetTransfersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetTransfersTable,
          AssetTransferRow,
          $$AssetTransfersTableFilterComposer,
          $$AssetTransfersTableOrderingComposer,
          $$AssetTransfersTableAnnotationComposer,
          $$AssetTransfersTableCreateCompanionBuilder,
          $$AssetTransfersTableUpdateCompanionBuilder,
          (AssetTransferRow, $$AssetTransfersTableReferences),
          AssetTransferRow,
          PrefetchHooks Function({bool assetTransactionsRefs})
        > {
  $$AssetTransfersTableTableManager(
    _$AppDatabase db,
    $AssetTransfersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetTransfersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetTransfersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetTransfersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AssetTransfersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => AssetTransfersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetTransfersTable, AssetTransferRow>(table),
                  $$AssetTransfersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assetTransactionsRefs) db.assetTransactions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assetTransactionsRefs)
                    await $_getPrefetchedDataByColumns<
                      AssetTransferRow,
                      $AssetTransfersTable,
                      AssetTransactionRow,
                      $AssetTransactionsTable
                    >(
                      currentTable: table,
                      referencedTable: $$AssetTransfersTableReferences
                          ._assetTransactionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AssetTransfersTableReferences(
                            db,
                            table,
                            p0,
                          ).assetTransactionsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'transfer_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AssetTransfersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetTransfersTable,
      AssetTransferRow,
      $$AssetTransfersTableFilterComposer,
      $$AssetTransfersTableOrderingComposer,
      $$AssetTransfersTableAnnotationComposer,
      $$AssetTransfersTableCreateCompanionBuilder,
      $$AssetTransfersTableUpdateCompanionBuilder,
      (AssetTransferRow, $$AssetTransfersTableReferences),
      AssetTransferRow,
      PrefetchHooks Function({bool assetTransactionsRefs})
    >;
typedef $$AssetTransactionsTableCreateCompanionBuilder =
    AssetTransactionsCompanion Function({
      Value<int> id,
      required int assetId,
      required AssetTransactionKind kind,
      required int amountMinor,
      Value<String?> currencyCode,
      required LocalDate occurredOn,
      required Decimal rateToRub,
      required int amountRubMinor,
      Value<String?> comment,
      Value<int?> transferId,
      required int revisionNo,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$AssetTransactionsTableUpdateCompanionBuilder =
    AssetTransactionsCompanion Function({
      Value<int> id,
      Value<int> assetId,
      Value<AssetTransactionKind> kind,
      Value<int> amountMinor,
      Value<String?> currencyCode,
      Value<LocalDate> occurredOn,
      Value<Decimal> rateToRub,
      Value<int> amountRubMinor,
      Value<String?> comment,
      Value<int?> transferId,
      Value<int> revisionNo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$AssetTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssetTransactionsTable,
          AssetTransactionRow
        > {
  $$AssetTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('asset_transactions__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<int>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) => db.currencies
      .createAlias('asset_transactions__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager? get currencyCode {
    final $_column = $_itemColumn<String>('currency_code');
    if ($_column == null) return null;
    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetTransfersTable _transferIdTable(_$AppDatabase db) => db
      .assetTransfers
      .createAlias('asset_transactions__transfer_id__asset_transfers__id');

  $$AssetTransfersTableProcessedTableManager? get transferId {
    final $_column = $_itemColumn<int>('transfer_id');
    if ($_column == null) return null;
    final manager = $$AssetTransfersTableTableManager(
      $_db,
      $_db.assetTransfers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transferIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $AssetTransactionRevisionsTable,
    List<AssetTransactionRevisionRow>
  >
  _assetTransactionRevisionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.assetTransactionRevisions,
    aliasName:
        'asset_transactions__id__asset_transaction_revisions__transaction_id',
  );

  $$AssetTransactionRevisionsTableProcessedTableManager
  get assetTransactionRevisionsRefs {
    final manager = $$AssetTransactionRevisionsTableTableManager(
      $_db,
      $_db.assetTransactionRevisions,
    ).filter((f) => f.transactionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assetTransactionRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashflowEntriesTable, List<CashflowEntryRow>>
  _cashflowEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashflowEntries,
    aliasName: 'asset_transactions__id__cashflow_entries__asset_transaction_id',
  );

  $$CashflowEntriesTableProcessedTableManager get cashflowEntriesRefs {
    final manager =
        $$CashflowEntriesTableTableManager($_db, $_db.cashflowEntries).filter(
          (f) => f.assetTransactionId.id.sqlEquals($_itemColumn<int>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _cashflowEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssetTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetTransactionsTable> {
  $$AssetTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    AssetTransactionKind,
    AssetTransactionKind,
    String
  >
  get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get occurredOn =>
      $composableBuilder(
        column: $table.occurredOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get rateToRub =>
      $composableBuilder(
        column: $table.rateToRub,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amountRubMinor => $composableBuilder(
    column: $table.amountRubMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetTransfersTableFilterComposer get transferId {
    final $$AssetTransfersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferId,
      referencedTable: $db.assetTransfers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransfersTableFilterComposer(
            $db: $db,
            $table: $db.assetTransfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> assetTransactionRevisionsRefs(
    Expression<bool> Function($$AssetTransactionRevisionsTableFilterComposer f)
    f,
  ) {
    final $$AssetTransactionRevisionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assetTransactionRevisions,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetTransactionRevisionsTableFilterComposer(
                $db: $db,
                $table: $db.assetTransactionRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> cashflowEntriesRefs(
    Expression<bool> Function($$CashflowEntriesTableFilterComposer f) f,
  ) {
    final $$CashflowEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.assetTransactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetTransactionsTable> {
  $$AssetTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateToRub => $composableBuilder(
    column: $table.rateToRub,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountRubMinor => $composableBuilder(
    column: $table.amountRubMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetTransfersTableOrderingComposer get transferId {
    final $$AssetTransfersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferId,
      referencedTable: $db.assetTransfers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransfersTableOrderingComposer(
            $db: $db,
            $table: $db.assetTransfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetTransactionsTable> {
  $$AssetTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AssetTransactionKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate, String> get occurredOn =>
      $composableBuilder(
        column: $table.occurredOn,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal, String> get rateToRub =>
      $composableBuilder(column: $table.rateToRub, builder: (column) => column);

  GeneratedColumn<int> get amountRubMinor => $composableBuilder(
    column: $table.amountRubMinor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetTransfersTableAnnotationComposer get transferId {
    final $$AssetTransfersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transferId,
      referencedTable: $db.assetTransfers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransfersTableAnnotationComposer(
            $db: $db,
            $table: $db.assetTransfers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> assetTransactionRevisionsRefs<T extends Object>(
    Expression<T> Function($$AssetTransactionRevisionsTableAnnotationComposer a)
    f,
  ) {
    final $$AssetTransactionRevisionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.assetTransactionRevisions,
          getReferencedColumn: (t) => t.transactionId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetTransactionRevisionsTableAnnotationComposer(
                $db: $db,
                $table: $db.assetTransactionRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> cashflowEntriesRefs<T extends Object>(
    Expression<T> Function($$CashflowEntriesTableAnnotationComposer a) f,
  ) {
    final $$CashflowEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.assetTransactionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetTransactionsTable,
          AssetTransactionRow,
          $$AssetTransactionsTableFilterComposer,
          $$AssetTransactionsTableOrderingComposer,
          $$AssetTransactionsTableAnnotationComposer,
          $$AssetTransactionsTableCreateCompanionBuilder,
          $$AssetTransactionsTableUpdateCompanionBuilder,
          (AssetTransactionRow, $$AssetTransactionsTableReferences),
          AssetTransactionRow,
          PrefetchHooks Function({
            bool assetId,
            bool currencyCode,
            bool transferId,
            bool assetTransactionRevisionsRefs,
            bool cashflowEntriesRefs,
          })
        > {
  $$AssetTransactionsTableTableManager(
    _$AppDatabase db,
    $AssetTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<AssetTransactionKind> kind = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String?> currencyCode = const Value.absent(),
                Value<LocalDate> occurredOn = const Value.absent(),
                Value<Decimal> rateToRub = const Value.absent(),
                Value<int> amountRubMinor = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int?> transferId = const Value.absent(),
                Value<int> revisionNo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AssetTransactionsCompanion(
                id: id,
                assetId: assetId,
                kind: kind,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                occurredOn: occurredOn,
                rateToRub: rateToRub,
                amountRubMinor: amountRubMinor,
                comment: comment,
                transferId: transferId,
                revisionNo: revisionNo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                required AssetTransactionKind kind,
                required int amountMinor,
                Value<String?> currencyCode = const Value.absent(),
                required LocalDate occurredOn,
                required Decimal rateToRub,
                required int amountRubMinor,
                Value<String?> comment = const Value.absent(),
                Value<int?> transferId = const Value.absent(),
                required int revisionNo,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AssetTransactionsCompanion.insert(
                id: id,
                assetId: assetId,
                kind: kind,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                occurredOn: occurredOn,
                rateToRub: rateToRub,
                amountRubMinor: amountRubMinor,
                comment: comment,
                transferId: transferId,
                revisionNo: revisionNo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetTransactionsTable, AssetTransactionRow>(
                    table,
                  ),
                  $$AssetTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                assetId = false,
                currencyCode = false,
                transferId = false,
                assetTransactionRevisionsRefs = false,
                cashflowEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (assetTransactionRevisionsRefs)
                      db.assetTransactionRevisions,
                    if (cashflowEntriesRefs) db.cashflowEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (assetId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.assetId,
                            referencedTable: $$AssetTransactionsTableReferences
                                ._assetIdTable(db),
                            referencedColumn: $$AssetTransactionsTableReferences
                                ._assetIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (currencyCode) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.currencyCode,
                            referencedTable: $$AssetTransactionsTableReferences
                                ._currencyCodeTable(db),
                            referencedColumn: $$AssetTransactionsTableReferences
                                ._currencyCodeTable(db)
                                .code,
                          ) as T;
                        }
                        if (transferId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.transferId,
                            referencedTable: $$AssetTransactionsTableReferences
                                ._transferIdTable(db),
                            referencedColumn: $$AssetTransactionsTableReferences
                                ._transferIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (assetTransactionRevisionsRefs)
                        await $_getPrefetchedDataByColumns<
                          AssetTransactionRow,
                          $AssetTransactionsTable,
                          AssetTransactionRevisionRow,
                          $AssetTransactionRevisionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetTransactionsTableReferences
                              ._assetTransactionRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetTransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).assetTransactionRevisionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'transaction_id',
                          typedResults: items,
                        ),
                      if (cashflowEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          AssetTransactionRow,
                          $AssetTransactionsTable,
                          CashflowEntryRow,
                          $CashflowEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetTransactionsTableReferences
                              ._cashflowEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetTransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).cashflowEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_transaction_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AssetTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetTransactionsTable,
      AssetTransactionRow,
      $$AssetTransactionsTableFilterComposer,
      $$AssetTransactionsTableOrderingComposer,
      $$AssetTransactionsTableAnnotationComposer,
      $$AssetTransactionsTableCreateCompanionBuilder,
      $$AssetTransactionsTableUpdateCompanionBuilder,
      (AssetTransactionRow, $$AssetTransactionsTableReferences),
      AssetTransactionRow,
      PrefetchHooks Function({
        bool assetId,
        bool currencyCode,
        bool transferId,
        bool assetTransactionRevisionsRefs,
        bool cashflowEntriesRefs,
      })
    >;
typedef $$AssetTransactionRevisionsTableCreateCompanionBuilder =
    AssetTransactionRevisionsCompanion Function({
      Value<int> id,
      required int transactionId,
      required int revisionNo,
      required RevisionAction action,
      required String snapshotJson,
      required DateTime changedAt,
    });
typedef $$AssetTransactionRevisionsTableUpdateCompanionBuilder =
    AssetTransactionRevisionsCompanion Function({
      Value<int> id,
      Value<int> transactionId,
      Value<int> revisionNo,
      Value<RevisionAction> action,
      Value<String> snapshotJson,
      Value<DateTime> changedAt,
    });

final class $$AssetTransactionRevisionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $AssetTransactionRevisionsTable,
          AssetTransactionRevisionRow
        > {
  $$AssetTransactionRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetTransactionsTable _transactionIdTable(_$AppDatabase db) =>
      db.assetTransactions.createAlias(
        'asset_transaction_revisions__transaction_id__asset_transactions__id',
      );

  $$AssetTransactionsTableProcessedTableManager get transactionId {
    final $_column = $_itemColumn<int>('transaction_id')!;

    final manager = $$AssetTransactionsTableTableManager(
      $_db,
      $_db.assetTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_transactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssetTransactionRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetTransactionRevisionsTable> {
  $$AssetTransactionRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RevisionAction, RevisionAction, String>
  get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get changedAt =>
      $composableBuilder(
        column: $table.changedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$AssetTransactionsTableFilterComposer get transactionId {
    final $$AssetTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.assetTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.assetTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetTransactionRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetTransactionRevisionsTable> {
  $$AssetTransactionRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetTransactionsTableOrderingComposer get transactionId {
    final $$AssetTransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.transactionId,
      referencedTable: $db.assetTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.assetTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetTransactionRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetTransactionRevisionsTable> {
  $$AssetTransactionRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RevisionAction, String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  $$AssetTransactionsTableAnnotationComposer get transactionId {
    final $$AssetTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.transactionId,
          referencedTable: $db.assetTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.assetTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AssetTransactionRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetTransactionRevisionsTable,
          AssetTransactionRevisionRow,
          $$AssetTransactionRevisionsTableFilterComposer,
          $$AssetTransactionRevisionsTableOrderingComposer,
          $$AssetTransactionRevisionsTableAnnotationComposer,
          $$AssetTransactionRevisionsTableCreateCompanionBuilder,
          $$AssetTransactionRevisionsTableUpdateCompanionBuilder,
          (
            AssetTransactionRevisionRow,
            $$AssetTransactionRevisionsTableReferences,
          ),
          AssetTransactionRevisionRow,
          PrefetchHooks Function({bool transactionId})
        > {
  $$AssetTransactionRevisionsTableTableManager(
    _$AppDatabase db,
    $AssetTransactionRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetTransactionRevisionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AssetTransactionRevisionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AssetTransactionRevisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> transactionId = const Value.absent(),
                Value<int> revisionNo = const Value.absent(),
                Value<RevisionAction> action = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
              }) => AssetTransactionRevisionsCompanion(
                id: id,
                transactionId: transactionId,
                revisionNo: revisionNo,
                action: action,
                snapshotJson: snapshotJson,
                changedAt: changedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int transactionId,
                required int revisionNo,
                required RevisionAction action,
                required String snapshotJson,
                required DateTime changedAt,
              }) => AssetTransactionRevisionsCompanion.insert(
                id: id,
                transactionId: transactionId,
                revisionNo: revisionNo,
                action: action,
                snapshotJson: snapshotJson,
                changedAt: changedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $AssetTransactionRevisionsTable,
                    AssetTransactionRevisionRow
                  >(table),
                  $$AssetTransactionRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({transactionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (transactionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.transactionId,
                        referencedTable:
                            $$AssetTransactionRevisionsTableReferences
                                ._transactionIdTable(db),
                        referencedColumn:
                            $$AssetTransactionRevisionsTableReferences
                                ._transactionIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AssetTransactionRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetTransactionRevisionsTable,
      AssetTransactionRevisionRow,
      $$AssetTransactionRevisionsTableFilterComposer,
      $$AssetTransactionRevisionsTableOrderingComposer,
      $$AssetTransactionRevisionsTableAnnotationComposer,
      $$AssetTransactionRevisionsTableCreateCompanionBuilder,
      $$AssetTransactionRevisionsTableUpdateCompanionBuilder,
      (AssetTransactionRevisionRow, $$AssetTransactionRevisionsTableReferences),
      AssetTransactionRevisionRow,
      PrefetchHooks Function({bool transactionId})
    >;
typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  required CashflowKind kind,
  required String name,
  required String normalizedName,
  Value<String?> colorKey,
  Value<String?> iconKey,
  Value<bool> isPreset,
  Value<DateTime?> archivedAt,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<int> id,
  Value<CashflowKind> kind,
  Value<String> name,
  Value<String> normalizedName,
  Value<String?> colorKey,
  Value<String?> iconKey,
  Value<bool> isPreset,
  Value<DateTime?> archivedAt,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RecurringCashflowRulesTable,
    List<RecurringCashflowRuleRow>
  >
  _recurringCashflowRulesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringCashflowRules,
        aliasName: 'categories__id__recurring_cashflow_rules__category_id',
      );

  $$RecurringCashflowRulesTableProcessedTableManager
  get recurringCashflowRulesRefs {
    final manager = $$RecurringCashflowRulesTableTableManager(
      $_db,
      $_db.recurringCashflowRules,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringCashflowRulesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CashflowEntriesTable, List<CashflowEntryRow>>
  _cashflowEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashflowEntries,
    aliasName: 'categories__id__cashflow_entries__category_id',
  );

  $$CashflowEntriesTableProcessedTableManager get cashflowEntriesRefs {
    final manager = $$CashflowEntriesTableTableManager(
      $_db,
      $_db.cashflowEntries,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cashflowEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CashflowKind, CashflowKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> recurringCashflowRulesRefs(
    Expression<bool> Function($$RecurringCashflowRulesTableFilterComposer f) f,
  ) {
    final $$RecurringCashflowRulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableFilterComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> cashflowEntriesRefs(
    Expression<bool> Function($$CashflowEntriesTableFilterComposer f) f,
  ) {
    final $$CashflowEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPreset => $composableBuilder(
    column: $table.isPreset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CashflowKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorKey =>
      $composableBuilder(column: $table.colorKey, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<bool> get isPreset =>
      $composableBuilder(column: $table.isPreset, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  Expression<T> recurringCashflowRulesRefs<T extends Object>(
    Expression<T> Function($$RecurringCashflowRulesTableAnnotationComposer a) f,
  ) {
    final $$RecurringCashflowRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> cashflowEntriesRefs<T extends Object>(
    Expression<T> Function($$CashflowEntriesTableAnnotationComposer a) f,
  ) {
    final $$CashflowEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({
            bool recurringCashflowRulesRefs,
            bool cashflowEntriesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<CashflowKind> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<String?> colorKey = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                kind: kind,
                name: name,
                normalizedName: normalizedName,
                colorKey: colorKey,
                iconKey: iconKey,
                isPreset: isPreset,
                archivedAt: archivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required CashflowKind kind,
                required String name,
                required String normalizedName,
                Value<String?> colorKey = const Value.absent(),
                Value<String?> iconKey = const Value.absent(),
                Value<bool> isPreset = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                kind: kind,
                name: name,
                normalizedName: normalizedName,
                colorKey: colorKey,
                iconKey: iconKey,
                isPreset: isPreset,
                archivedAt: archivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                recurringCashflowRulesRefs = false,
                cashflowEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recurringCashflowRulesRefs) db.recurringCashflowRules,
                    if (cashflowEntriesRefs) db.cashflowEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recurringCashflowRulesRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoryRow,
                          $CategoriesTable,
                          RecurringCashflowRuleRow,
                          $RecurringCashflowRulesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringCashflowRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringCashflowRulesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                      if (cashflowEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          CategoryRow,
                          $CategoriesTable,
                          CashflowEntryRow,
                          $CashflowEntriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._cashflowEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).cashflowEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'category_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({
        bool recurringCashflowRulesRefs,
        bool cashflowEntriesRefs,
      })
    >;
typedef $$RecurringCashflowRulesTableCreateCompanionBuilder =
    RecurringCashflowRulesCompanion Function({
      Value<int> id,
      required RecurringStrategy strategy,
      required CashflowKind kind,
      required int categoryId,
      Value<int?> amountMinor,
      required String currencyCode,
      Value<int?> accountId,
      Value<int?> propertyId,
      required bool affectsBalance,
      required LocalDate startDate,
      Value<LocalDate?> endDate,
      Value<String?> comment,
      Value<String?> lastGeneratedPeriod,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$RecurringCashflowRulesTableUpdateCompanionBuilder =
    RecurringCashflowRulesCompanion Function({
      Value<int> id,
      Value<RecurringStrategy> strategy,
      Value<CashflowKind> kind,
      Value<int> categoryId,
      Value<int?> amountMinor,
      Value<String> currencyCode,
      Value<int?> accountId,
      Value<int?> propertyId,
      Value<bool> affectsBalance,
      Value<LocalDate> startDate,
      Value<LocalDate?> endDate,
      Value<String?> comment,
      Value<String?> lastGeneratedPeriod,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$RecurringCashflowRulesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringCashflowRulesTable,
          RecurringCashflowRuleRow
        > {
  $$RecurringCashflowRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('recurring_cashflow_rules__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) => db.currencies
      .createAlias('recurring_cashflow_rules__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetsTable _accountIdTable(_$AppDatabase db) =>
      db.assets.createAlias('recurring_cashflow_rules__account_id__assets__id');

  $$AssetsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetsTable _propertyIdTable(_$AppDatabase db) => db.assets
      .createAlias('recurring_cashflow_rules__property_id__assets__id');

  $$AssetsTableProcessedTableManager? get propertyId {
    final $_column = $_itemColumn<int>('property_id');
    if ($_column == null) return null;
    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_propertyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CashflowEntriesTable, List<CashflowEntryRow>>
  _cashflowEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cashflowEntries,
    aliasName:
        'recurring_cashflow_rules__id__cashflow_entries__recurring_rule_id',
  );

  $$CashflowEntriesTableProcessedTableManager get cashflowEntriesRefs {
    final manager = $$CashflowEntriesTableTableManager(
      $_db,
      $_db.cashflowEntries,
    ).filter((f) => f.recurringRuleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cashflowEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringCashflowRulesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringCashflowRulesTable> {
  $$RecurringCashflowRulesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RecurringStrategy, RecurringStrategy, String>
  get strategy => $composableBuilder(
    column: $table.strategy,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<CashflowKind, CashflowKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get affectsBalance => $composableBuilder(
    column: $table.affectsBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get startDate =>
      $composableBuilder(
        column: $table.startDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String> get endDate =>
      $composableBuilder(
        column: $table.endDate,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastGeneratedPeriod => $composableBuilder(
    column: $table.lastGeneratedPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableFilterComposer get accountId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableFilterComposer get propertyId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cashflowEntriesRefs(
    Expression<bool> Function($$CashflowEntriesTableFilterComposer f) f,
  ) {
    final $$CashflowEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.recurringRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringCashflowRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringCashflowRulesTable> {
  $$RecurringCashflowRulesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strategy => $composableBuilder(
    column: $table.strategy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get affectsBalance => $composableBuilder(
    column: $table.affectsBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastGeneratedPeriod => $composableBuilder(
    column: $table.lastGeneratedPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableOrderingComposer get accountId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableOrderingComposer get propertyId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringCashflowRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringCashflowRulesTable> {
  $$RecurringCashflowRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<RecurringStrategy, String> get strategy =>
      $composableBuilder(column: $table.strategy, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CashflowKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get affectsBalance => $composableBuilder(
    column: $table.affectsBalance,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate, String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate?, String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<String> get lastGeneratedPeriod => $composableBuilder(
    column: $table.lastGeneratedPeriod,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableAnnotationComposer get accountId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableAnnotationComposer get propertyId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cashflowEntriesRefs<T extends Object>(
    Expression<T> Function($$CashflowEntriesTableAnnotationComposer a) f,
  ) {
    final $$CashflowEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.recurringRuleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringCashflowRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringCashflowRulesTable,
          RecurringCashflowRuleRow,
          $$RecurringCashflowRulesTableFilterComposer,
          $$RecurringCashflowRulesTableOrderingComposer,
          $$RecurringCashflowRulesTableAnnotationComposer,
          $$RecurringCashflowRulesTableCreateCompanionBuilder,
          $$RecurringCashflowRulesTableUpdateCompanionBuilder,
          (RecurringCashflowRuleRow, $$RecurringCashflowRulesTableReferences),
          RecurringCashflowRuleRow,
          PrefetchHooks Function({
            bool categoryId,
            bool currencyCode,
            bool accountId,
            bool propertyId,
            bool cashflowEntriesRefs,
          })
        > {
  $$RecurringCashflowRulesTableTableManager(
    _$AppDatabase db,
    $RecurringCashflowRulesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringCashflowRulesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringCashflowRulesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringCashflowRulesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<RecurringStrategy> strategy = const Value.absent(),
                Value<CashflowKind> kind = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int?> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<int?> propertyId = const Value.absent(),
                Value<bool> affectsBalance = const Value.absent(),
                Value<LocalDate> startDate = const Value.absent(),
                Value<LocalDate?> endDate = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> lastGeneratedPeriod = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => RecurringCashflowRulesCompanion(
                id: id,
                strategy: strategy,
                kind: kind,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                accountId: accountId,
                propertyId: propertyId,
                affectsBalance: affectsBalance,
                startDate: startDate,
                endDate: endDate,
                comment: comment,
                lastGeneratedPeriod: lastGeneratedPeriod,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required RecurringStrategy strategy,
                required CashflowKind kind,
                required int categoryId,
                Value<int?> amountMinor = const Value.absent(),
                required String currencyCode,
                Value<int?> accountId = const Value.absent(),
                Value<int?> propertyId = const Value.absent(),
                required bool affectsBalance,
                required LocalDate startDate,
                Value<LocalDate?> endDate = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<String?> lastGeneratedPeriod = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => RecurringCashflowRulesCompanion.insert(
                id: id,
                strategy: strategy,
                kind: kind,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                accountId: accountId,
                propertyId: propertyId,
                affectsBalance: affectsBalance,
                startDate: startDate,
                endDate: endDate,
                comment: comment,
                lastGeneratedPeriod: lastGeneratedPeriod,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RecurringCashflowRulesTable,
                    RecurringCashflowRuleRow
                  >(table),
                  $$RecurringCashflowRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                currencyCode = false,
                accountId = false,
                propertyId = false,
                cashflowEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cashflowEntriesRefs) db.cashflowEntries,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable:
                                $$RecurringCashflowRulesTableReferences
                                    ._categoryIdTable(db),
                            referencedColumn:
                                $$RecurringCashflowRulesTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (currencyCode) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.currencyCode,
                            referencedTable:
                                $$RecurringCashflowRulesTableReferences
                                    ._currencyCodeTable(db),
                            referencedColumn:
                                $$RecurringCashflowRulesTableReferences
                                    ._currencyCodeTable(db)
                                    .code,
                          ) as T;
                        }
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable:
                                $$RecurringCashflowRulesTableReferences
                                    ._accountIdTable(db),
                            referencedColumn:
                                $$RecurringCashflowRulesTableReferences
                                    ._accountIdTable(db)
                                    .id,
                          ) as T;
                        }
                        if (propertyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.propertyId,
                            referencedTable:
                                $$RecurringCashflowRulesTableReferences
                                    ._propertyIdTable(db),
                            referencedColumn:
                                $$RecurringCashflowRulesTableReferences
                                    ._propertyIdTable(db)
                                    .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cashflowEntriesRefs)
                        await $_getPrefetchedDataByColumns<
                          RecurringCashflowRuleRow,
                          $RecurringCashflowRulesTable,
                          CashflowEntryRow,
                          $CashflowEntriesTable
                        >(
                          currentTable: table,
                          referencedTable:
                              $$RecurringCashflowRulesTableReferences
                                  ._cashflowEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringCashflowRulesTableReferences(
                                db,
                                table,
                                p0,
                              ).cashflowEntriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'recurring_rule_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecurringCashflowRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringCashflowRulesTable,
      RecurringCashflowRuleRow,
      $$RecurringCashflowRulesTableFilterComposer,
      $$RecurringCashflowRulesTableOrderingComposer,
      $$RecurringCashflowRulesTableAnnotationComposer,
      $$RecurringCashflowRulesTableCreateCompanionBuilder,
      $$RecurringCashflowRulesTableUpdateCompanionBuilder,
      (RecurringCashflowRuleRow, $$RecurringCashflowRulesTableReferences),
      RecurringCashflowRuleRow,
      PrefetchHooks Function({
        bool categoryId,
        bool currencyCode,
        bool accountId,
        bool propertyId,
        bool cashflowEntriesRefs,
      })
    >;
typedef $$CashflowEntriesTableCreateCompanionBuilder =
    CashflowEntriesCompanion Function({
      Value<int> id,
      required CashflowKind kind,
      required int categoryId,
      required int amountMinor,
      required String currencyCode,
      required LocalDate occurredOn,
      required Decimal rateToRub,
      required int amountRubMinor,
      required bool affectsBalance,
      Value<String?> comment,
      Value<int?> propertyId,
      Value<int?> accountId,
      Value<int?> assetTransactionId,
      Value<int?> recurringRuleId,
      required int revisionNo,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$CashflowEntriesTableUpdateCompanionBuilder =
    CashflowEntriesCompanion Function({
      Value<int> id,
      Value<CashflowKind> kind,
      Value<int> categoryId,
      Value<int> amountMinor,
      Value<String> currencyCode,
      Value<LocalDate> occurredOn,
      Value<Decimal> rateToRub,
      Value<int> amountRubMinor,
      Value<bool> affectsBalance,
      Value<String?> comment,
      Value<int?> propertyId,
      Value<int?> accountId,
      Value<int?> assetTransactionId,
      Value<int?> recurringRuleId,
      Value<int> revisionNo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$CashflowEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CashflowEntriesTable, CashflowEntryRow> {
  $$CashflowEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('cashflow_entries__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) => db.currencies
      .createAlias('cashflow_entries__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetsTable _propertyIdTable(_$AppDatabase db) =>
      db.assets.createAlias('cashflow_entries__property_id__assets__id');

  $$AssetsTableProcessedTableManager? get propertyId {
    final $_column = $_itemColumn<int>('property_id');
    if ($_column == null) return null;
    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_propertyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetsTable _accountIdTable(_$AppDatabase db) =>
      db.assets.createAlias('cashflow_entries__account_id__assets__id');

  $$AssetsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<int>('account_id');
    if ($_column == null) return null;
    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetTransactionsTable _assetTransactionIdTable(_$AppDatabase db) =>
      db.assetTransactions.createAlias(
        'cashflow_entries__asset_transaction_id__asset_transactions__id',
      );

  $$AssetTransactionsTableProcessedTableManager? get assetTransactionId {
    final $_column = $_itemColumn<int>('asset_transaction_id');
    if ($_column == null) return null;
    final manager = $$AssetTransactionsTableTableManager(
      $_db,
      $_db.assetTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetTransactionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecurringCashflowRulesTable _recurringRuleIdTable(_$AppDatabase db) =>
      db.recurringCashflowRules.createAlias(
        'cashflow_entries__recurring_rule_id__recurring_cashflow_rules__id',
      );

  $$RecurringCashflowRulesTableProcessedTableManager? get recurringRuleId {
    final $_column = $_itemColumn<int>('recurring_rule_id');
    if ($_column == null) return null;
    final manager = $$RecurringCashflowRulesTableTableManager(
      $_db,
      $_db.recurringCashflowRules,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringRuleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $CashflowEntryRevisionsTable,
    List<CashflowEntryRevisionRow>
  >
  _cashflowEntryRevisionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cashflowEntryRevisions,
        aliasName: 'cashflow_entries__id__cashflow_entry_revisions__entry_id',
      );

  $$CashflowEntryRevisionsTableProcessedTableManager
  get cashflowEntryRevisionsRefs {
    final manager = $$CashflowEntryRevisionsTableTableManager(
      $_db,
      $_db.cashflowEntryRevisions,
    ).filter((f) => f.entryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _cashflowEntryRevisionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CashflowEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CashflowEntriesTable> {
  $$CashflowEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CashflowKind, CashflowKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get occurredOn =>
      $composableBuilder(
        column: $table.occurredOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get rateToRub =>
      $composableBuilder(
        column: $table.rateToRub,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amountRubMinor => $composableBuilder(
    column: $table.amountRubMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get affectsBalance => $composableBuilder(
    column: $table.affectsBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableFilterComposer get propertyId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableFilterComposer get accountId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetTransactionsTableFilterComposer get assetTransactionId {
    final $$AssetTransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetTransactionId,
      referencedTable: $db.assetTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransactionsTableFilterComposer(
            $db: $db,
            $table: $db.assetTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringCashflowRulesTableFilterComposer get recurringRuleId {
    final $$RecurringCashflowRulesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringRuleId,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableFilterComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<bool> cashflowEntryRevisionsRefs(
    Expression<bool> Function($$CashflowEntryRevisionsTableFilterComposer f) f,
  ) {
    final $$CashflowEntryRevisionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cashflowEntryRevisions,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CashflowEntryRevisionsTableFilterComposer(
                $db: $db,
                $table: $db.cashflowEntryRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CashflowEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CashflowEntriesTable> {
  $$CashflowEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occurredOn => $composableBuilder(
    column: $table.occurredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateToRub => $composableBuilder(
    column: $table.rateToRub,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountRubMinor => $composableBuilder(
    column: $table.amountRubMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get affectsBalance => $composableBuilder(
    column: $table.affectsBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableOrderingComposer get propertyId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableOrderingComposer get accountId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetTransactionsTableOrderingComposer get assetTransactionId {
    final $$AssetTransactionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetTransactionId,
      referencedTable: $db.assetTransactions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTransactionsTableOrderingComposer(
            $db: $db,
            $table: $db.assetTransactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringCashflowRulesTableOrderingComposer get recurringRuleId {
    final $$RecurringCashflowRulesTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringRuleId,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableOrderingComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$CashflowEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashflowEntriesTable> {
  $$CashflowEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CashflowKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amountMinor => $composableBuilder(
    column: $table.amountMinor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LocalDate, String> get occurredOn =>
      $composableBuilder(
        column: $table.occurredOn,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Decimal, String> get rateToRub =>
      $composableBuilder(column: $table.rateToRub, builder: (column) => column);

  GeneratedColumn<int> get amountRubMinor => $composableBuilder(
    column: $table.amountRubMinor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get affectsBalance => $composableBuilder(
    column: $table.affectsBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableAnnotationComposer get propertyId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableAnnotationComposer get accountId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.accountId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetTransactionsTableAnnotationComposer get assetTransactionId {
    final $$AssetTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.assetTransactionId,
          referencedTable: $db.assetTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$AssetTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.assetTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$RecurringCashflowRulesTableAnnotationComposer get recurringRuleId {
    final $$RecurringCashflowRulesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringRuleId,
          referencedTable: $db.recurringCashflowRules,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringCashflowRulesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringCashflowRules,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  Expression<T> cashflowEntryRevisionsRefs<T extends Object>(
    Expression<T> Function($$CashflowEntryRevisionsTableAnnotationComposer a) f,
  ) {
    final $$CashflowEntryRevisionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.cashflowEntryRevisions,
          getReferencedColumn: (t) => t.entryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CashflowEntryRevisionsTableAnnotationComposer(
                $db: $db,
                $table: $db.cashflowEntryRevisions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CashflowEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashflowEntriesTable,
          CashflowEntryRow,
          $$CashflowEntriesTableFilterComposer,
          $$CashflowEntriesTableOrderingComposer,
          $$CashflowEntriesTableAnnotationComposer,
          $$CashflowEntriesTableCreateCompanionBuilder,
          $$CashflowEntriesTableUpdateCompanionBuilder,
          (CashflowEntryRow, $$CashflowEntriesTableReferences),
          CashflowEntryRow,
          PrefetchHooks Function({
            bool categoryId,
            bool currencyCode,
            bool propertyId,
            bool accountId,
            bool assetTransactionId,
            bool recurringRuleId,
            bool cashflowEntryRevisionsRefs,
          })
        > {
  $$CashflowEntriesTableTableManager(
    _$AppDatabase db,
    $CashflowEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashflowEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashflowEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashflowEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<CashflowKind> kind = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<int> amountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<LocalDate> occurredOn = const Value.absent(),
                Value<Decimal> rateToRub = const Value.absent(),
                Value<int> amountRubMinor = const Value.absent(),
                Value<bool> affectsBalance = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int?> propertyId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<int?> assetTransactionId = const Value.absent(),
                Value<int?> recurringRuleId = const Value.absent(),
                Value<int> revisionNo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CashflowEntriesCompanion(
                id: id,
                kind: kind,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                occurredOn: occurredOn,
                rateToRub: rateToRub,
                amountRubMinor: amountRubMinor,
                affectsBalance: affectsBalance,
                comment: comment,
                propertyId: propertyId,
                accountId: accountId,
                assetTransactionId: assetTransactionId,
                recurringRuleId: recurringRuleId,
                revisionNo: revisionNo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required CashflowKind kind,
                required int categoryId,
                required int amountMinor,
                required String currencyCode,
                required LocalDate occurredOn,
                required Decimal rateToRub,
                required int amountRubMinor,
                required bool affectsBalance,
                Value<String?> comment = const Value.absent(),
                Value<int?> propertyId = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<int?> assetTransactionId = const Value.absent(),
                Value<int?> recurringRuleId = const Value.absent(),
                required int revisionNo,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => CashflowEntriesCompanion.insert(
                id: id,
                kind: kind,
                categoryId: categoryId,
                amountMinor: amountMinor,
                currencyCode: currencyCode,
                occurredOn: occurredOn,
                rateToRub: rateToRub,
                amountRubMinor: amountRubMinor,
                affectsBalance: affectsBalance,
                comment: comment,
                propertyId: propertyId,
                accountId: accountId,
                assetTransactionId: assetTransactionId,
                recurringRuleId: recurringRuleId,
                revisionNo: revisionNo,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CashflowEntriesTable, CashflowEntryRow>(table),
                  $$CashflowEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                categoryId = false,
                currencyCode = false,
                propertyId = false,
                accountId = false,
                assetTransactionId = false,
                recurringRuleId = false,
                cashflowEntryRevisionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cashflowEntryRevisionsRefs) db.cashflowEntryRevisions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (categoryId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.categoryId,
                            referencedTable: $$CashflowEntriesTableReferences
                                ._categoryIdTable(db),
                            referencedColumn: $$CashflowEntriesTableReferences
                                ._categoryIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (currencyCode) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.currencyCode,
                            referencedTable: $$CashflowEntriesTableReferences
                                ._currencyCodeTable(db),
                            referencedColumn: $$CashflowEntriesTableReferences
                                ._currencyCodeTable(db)
                                .code,
                          ) as T;
                        }
                        if (propertyId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.propertyId,
                            referencedTable: $$CashflowEntriesTableReferences
                                ._propertyIdTable(db),
                            referencedColumn: $$CashflowEntriesTableReferences
                                ._propertyIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (accountId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.accountId,
                            referencedTable: $$CashflowEntriesTableReferences
                                ._accountIdTable(db),
                            referencedColumn: $$CashflowEntriesTableReferences
                                ._accountIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (assetTransactionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.assetTransactionId,
                            referencedTable: $$CashflowEntriesTableReferences
                                ._assetTransactionIdTable(db),
                            referencedColumn: $$CashflowEntriesTableReferences
                                ._assetTransactionIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (recurringRuleId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.recurringRuleId,
                            referencedTable: $$CashflowEntriesTableReferences
                                ._recurringRuleIdTable(db),
                            referencedColumn: $$CashflowEntriesTableReferences
                                ._recurringRuleIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cashflowEntryRevisionsRefs)
                        await $_getPrefetchedDataByColumns<
                          CashflowEntryRow,
                          $CashflowEntriesTable,
                          CashflowEntryRevisionRow,
                          $CashflowEntryRevisionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$CashflowEntriesTableReferences
                              ._cashflowEntryRevisionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CashflowEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).cashflowEntryRevisionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'entry_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CashflowEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashflowEntriesTable,
      CashflowEntryRow,
      $$CashflowEntriesTableFilterComposer,
      $$CashflowEntriesTableOrderingComposer,
      $$CashflowEntriesTableAnnotationComposer,
      $$CashflowEntriesTableCreateCompanionBuilder,
      $$CashflowEntriesTableUpdateCompanionBuilder,
      (CashflowEntryRow, $$CashflowEntriesTableReferences),
      CashflowEntryRow,
      PrefetchHooks Function({
        bool categoryId,
        bool currencyCode,
        bool propertyId,
        bool accountId,
        bool assetTransactionId,
        bool recurringRuleId,
        bool cashflowEntryRevisionsRefs,
      })
    >;
typedef $$CashflowEntryRevisionsTableCreateCompanionBuilder =
    CashflowEntryRevisionsCompanion Function({
      Value<int> id,
      required int entryId,
      required int revisionNo,
      required RevisionAction action,
      required String snapshotJson,
      required DateTime changedAt,
    });
typedef $$CashflowEntryRevisionsTableUpdateCompanionBuilder =
    CashflowEntryRevisionsCompanion Function({
      Value<int> id,
      Value<int> entryId,
      Value<int> revisionNo,
      Value<RevisionAction> action,
      Value<String> snapshotJson,
      Value<DateTime> changedAt,
    });

final class $$CashflowEntryRevisionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CashflowEntryRevisionsTable,
          CashflowEntryRevisionRow
        > {
  $$CashflowEntryRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CashflowEntriesTable _entryIdTable(_$AppDatabase db) => db
      .cashflowEntries
      .createAlias('cashflow_entry_revisions__entry_id__cashflow_entries__id');

  $$CashflowEntriesTableProcessedTableManager get entryId {
    final $_column = $_itemColumn<int>('entry_id')!;

    final manager = $$CashflowEntriesTableTableManager(
      $_db,
      $_db.cashflowEntries,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_entryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CashflowEntryRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $CashflowEntryRevisionsTable> {
  $$CashflowEntryRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<RevisionAction, RevisionAction, String>
  get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get changedAt =>
      $composableBuilder(
        column: $table.changedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CashflowEntriesTableFilterComposer get entryId {
    final $$CashflowEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashflowEntryRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashflowEntryRevisionsTable> {
  $$CashflowEntryRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changedAt => $composableBuilder(
    column: $table.changedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CashflowEntriesTableOrderingComposer get entryId {
    final $$CashflowEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashflowEntryRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashflowEntryRevisionsTable> {
  $$CashflowEntryRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revisionNo => $composableBuilder(
    column: $table.revisionNo,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<RevisionAction, String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get snapshotJson => $composableBuilder(
    column: $table.snapshotJson,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get changedAt =>
      $composableBuilder(column: $table.changedAt, builder: (column) => column);

  $$CashflowEntriesTableAnnotationComposer get entryId {
    final $$CashflowEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.entryId,
      referencedTable: $db.cashflowEntries,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CashflowEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cashflowEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CashflowEntryRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CashflowEntryRevisionsTable,
          CashflowEntryRevisionRow,
          $$CashflowEntryRevisionsTableFilterComposer,
          $$CashflowEntryRevisionsTableOrderingComposer,
          $$CashflowEntryRevisionsTableAnnotationComposer,
          $$CashflowEntryRevisionsTableCreateCompanionBuilder,
          $$CashflowEntryRevisionsTableUpdateCompanionBuilder,
          (CashflowEntryRevisionRow, $$CashflowEntryRevisionsTableReferences),
          CashflowEntryRevisionRow,
          PrefetchHooks Function({bool entryId})
        > {
  $$CashflowEntryRevisionsTableTableManager(
    _$AppDatabase db,
    $CashflowEntryRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashflowEntryRevisionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CashflowEntryRevisionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CashflowEntryRevisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entryId = const Value.absent(),
                Value<int> revisionNo = const Value.absent(),
                Value<RevisionAction> action = const Value.absent(),
                Value<String> snapshotJson = const Value.absent(),
                Value<DateTime> changedAt = const Value.absent(),
              }) => CashflowEntryRevisionsCompanion(
                id: id,
                entryId: entryId,
                revisionNo: revisionNo,
                action: action,
                snapshotJson: snapshotJson,
                changedAt: changedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entryId,
                required int revisionNo,
                required RevisionAction action,
                required String snapshotJson,
                required DateTime changedAt,
              }) => CashflowEntryRevisionsCompanion.insert(
                id: id,
                entryId: entryId,
                revisionNo: revisionNo,
                action: action,
                snapshotJson: snapshotJson,
                changedAt: changedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $CashflowEntryRevisionsTable,
                    CashflowEntryRevisionRow
                  >(table),
                  $$CashflowEntryRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({entryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (entryId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.entryId,
                        referencedTable: $$CashflowEntryRevisionsTableReferences
                            ._entryIdTable(db),
                        referencedColumn:
                            $$CashflowEntryRevisionsTableReferences
                                ._entryIdTable(db)
                                .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CashflowEntryRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CashflowEntryRevisionsTable,
      CashflowEntryRevisionRow,
      $$CashflowEntryRevisionsTableFilterComposer,
      $$CashflowEntryRevisionsTableOrderingComposer,
      $$CashflowEntryRevisionsTableAnnotationComposer,
      $$CashflowEntryRevisionsTableCreateCompanionBuilder,
      $$CashflowEntryRevisionsTableUpdateCompanionBuilder,
      (CashflowEntryRevisionRow, $$CashflowEntryRevisionsTableReferences),
      CashflowEntryRevisionRow,
      PrefetchHooks Function({bool entryId})
    >;
typedef $$ExchangeRatesTableCreateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<int> id,
      required String currencyCode,
      required LocalDate date,
      required Decimal rateToRub,
      required ExchangeRateSource source,
      required DateTime fetchedAt,
    });
typedef $$ExchangeRatesTableUpdateCompanionBuilder =
    ExchangeRatesCompanion Function({
      Value<int> id,
      Value<String> currencyCode,
      Value<LocalDate> date,
      Value<Decimal> rateToRub,
      Value<ExchangeRateSource> source,
      Value<DateTime> fetchedAt,
    });

final class $$ExchangeRatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ExchangeRatesTable, ExchangeRateRow> {
  $$ExchangeRatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) => db.currencies
      .createAlias('exchange_rates__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExchangeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Decimal, Decimal, String> get rateToRub =>
      $composableBuilder(
        column: $table.rateToRub,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ExchangeRateSource, ExchangeRateSource, String>
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get fetchedAt =>
      $composableBuilder(
        column: $table.fetchedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExchangeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rateToRub => $composableBuilder(
    column: $table.rateToRub,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExchangeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExchangeRatesTable> {
  $$ExchangeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Decimal, String> get rateToRub =>
      $composableBuilder(column: $table.rateToRub, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ExchangeRateSource, String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExchangeRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExchangeRatesTable,
          ExchangeRateRow,
          $$ExchangeRatesTableFilterComposer,
          $$ExchangeRatesTableOrderingComposer,
          $$ExchangeRatesTableAnnotationComposer,
          $$ExchangeRatesTableCreateCompanionBuilder,
          $$ExchangeRatesTableUpdateCompanionBuilder,
          (ExchangeRateRow, $$ExchangeRatesTableReferences),
          ExchangeRateRow,
          PrefetchHooks Function({bool currencyCode})
        > {
  $$ExchangeRatesTableTableManager(_$AppDatabase db, $ExchangeRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExchangeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExchangeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExchangeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<LocalDate> date = const Value.absent(),
                Value<Decimal> rateToRub = const Value.absent(),
                Value<ExchangeRateSource> source = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
              }) => ExchangeRatesCompanion(
                id: id,
                currencyCode: currencyCode,
                date: date,
                rateToRub: rateToRub,
                source: source,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String currencyCode,
                required LocalDate date,
                required Decimal rateToRub,
                required ExchangeRateSource source,
                required DateTime fetchedAt,
              }) => ExchangeRatesCompanion.insert(
                id: id,
                currencyCode: currencyCode,
                date: date,
                rateToRub: rateToRub,
                source: source,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExchangeRatesTable, ExchangeRateRow>(table),
                  $$ExchangeRatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({currencyCode = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (currencyCode) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.currencyCode,
                        referencedTable: $$ExchangeRatesTableReferences
                            ._currencyCodeTable(db),
                        referencedColumn: $$ExchangeRatesTableReferences
                            ._currencyCodeTable(db)
                            .code,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExchangeRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExchangeRatesTable,
      ExchangeRateRow,
      $$ExchangeRatesTableFilterComposer,
      $$ExchangeRatesTableOrderingComposer,
      $$ExchangeRatesTableAnnotationComposer,
      $$ExchangeRatesTableCreateCompanionBuilder,
      $$ExchangeRatesTableUpdateCompanionBuilder,
      (ExchangeRateRow, $$ExchangeRatesTableReferences),
      ExchangeRateRow,
      PrefetchHooks Function({bool currencyCode})
    >;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  required String name,
  required GoalCategory category,
  required int targetAmountMinor,
  required String currencyCode,
  required GoalStatus status,
  Value<LocalDate?> targetDate,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<GoalCategory> category,
  Value<int> targetAmountMinor,
  Value<String> currencyCode,
  Value<GoalStatus> status,
  Value<LocalDate?> targetDate,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
});

final class $$GoalsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalsTable, GoalRow> {
  $$GoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CurrenciesTable _currencyCodeTable(_$AppDatabase db) =>
      db.currencies.createAlias('goals__currency_code__currencies__code');

  $$CurrenciesTableProcessedTableManager get currencyCode {
    final $_column = $_itemColumn<String>('currency_code')!;

    final manager = $$CurrenciesTableTableManager(
      $_db,
      $_db.currencies,
    ).filter((f) => f.code.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_currencyCodeTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$GoalAssetsTable, List<GoalAssetRow>>
  _goalAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.goalAssets,
    aliasName: 'goals__id__goal_assets__goal_id',
  );

  $$GoalAssetsTableProcessedTableManager get goalAssetsRefs {
    final manager = $$GoalAssetsTableTableManager(
      $_db,
      $_db.goalAssets,
    ).filter((f) => f.goalId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_goalAssetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalCategory, GoalCategory, String>
  get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get targetAmountMinor => $composableBuilder(
    column: $table.targetAmountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<GoalStatus, GoalStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String>
  get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CurrenciesTableFilterComposer get currencyCode {
    final $$CurrenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableFilterComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> goalAssetsRefs(
    Expression<bool> Function($$GoalAssetsTableFilterComposer f) f,
  ) {
    final $$GoalAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalAssets,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalAssetsTableFilterComposer(
            $db: $db,
            $table: $db.goalAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetAmountMinor => $composableBuilder(
    column: $table.targetAmountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CurrenciesTableOrderingComposer get currencyCode {
    final $$CurrenciesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableOrderingComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<GoalCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get targetAmountMinor => $composableBuilder(
    column: $table.targetAmountMinor,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<GoalStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate?, String> get targetDate =>
      $composableBuilder(
        column: $table.targetDate,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$CurrenciesTableAnnotationComposer get currencyCode {
    final $$CurrenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.currencyCode,
      referencedTable: $db.currencies,
      getReferencedColumn: (t) => t.code,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CurrenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.currencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> goalAssetsRefs<T extends Object>(
    Expression<T> Function($$GoalAssetsTableAnnotationComposer a) f,
  ) {
    final $$GoalAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.goalAssets,
      getReferencedColumn: (t) => t.goalId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.goalAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          GoalRow,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalRow, $$GoalsTableReferences),
          GoalRow,
          PrefetchHooks Function({bool currencyCode, bool goalAssetsRefs})
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<GoalCategory> category = const Value.absent(),
                Value<int> targetAmountMinor = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<GoalStatus> status = const Value.absent(),
                Value<LocalDate?> targetDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                name: name,
                category: category,
                targetAmountMinor: targetAmountMinor,
                currencyCode: currencyCode,
                status: status,
                targetDate: targetDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required GoalCategory category,
                required int targetAmountMinor,
                required String currencyCode,
                required GoalStatus status,
                Value<LocalDate?> targetDate = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                name: name,
                category: category,
                targetAmountMinor: targetAmountMinor,
                currencyCode: currencyCode,
                status: status,
                targetDate: targetDate,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, GoalRow>(table),
                  $$GoalsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({currencyCode = false, goalAssetsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (goalAssetsRefs) db.goalAssets],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (currencyCode) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.currencyCode,
                            referencedTable: $$GoalsTableReferences
                                ._currencyCodeTable(db),
                            referencedColumn: $$GoalsTableReferences
                                ._currencyCodeTable(db)
                                .code,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (goalAssetsRefs)
                        await $_getPrefetchedDataByColumns<
                          GoalRow,
                          $GoalsTable,
                          GoalAssetRow,
                          $GoalAssetsTable
                        >(
                          currentTable: table,
                          referencedTable: $$GoalsTableReferences
                              ._goalAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GoalsTableReferences(
                                db,
                                table,
                                p0,
                              ).goalAssetsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'goal_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      GoalRow,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalRow, $$GoalsTableReferences),
      GoalRow,
      PrefetchHooks Function({bool currencyCode, bool goalAssetsRefs})
    >;
typedef $$GoalAssetsTableCreateCompanionBuilder = GoalAssetsCompanion Function({
  required int goalId,
  required int assetId,
  Value<int> rowid,
});
typedef $$GoalAssetsTableUpdateCompanionBuilder = GoalAssetsCompanion Function({
  Value<int> goalId,
  Value<int> assetId,
  Value<int> rowid,
});

final class $$GoalAssetsTableReferences
    extends BaseReferences<_$AppDatabase, $GoalAssetsTable, GoalAssetRow> {
  $$GoalAssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GoalsTable _goalIdTable(_$AppDatabase db) =>
      db.goals.createAlias('goal_assets__goal_id__goals__id');

  $$GoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<int>('goal_id')!;

    final manager = $$GoalsTableTableManager(
      $_db,
      $_db.goals,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('goal_assets__asset_id__assets__id');

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<int>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$GoalAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $GoalAssetsTable> {
  $$GoalAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GoalsTableFilterComposer get goalId {
    final $$GoalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableFilterComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalAssetsTable> {
  $$GoalAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GoalsTableOrderingComposer get goalId {
    final $$GoalsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableOrderingComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalAssetsTable> {
  $$GoalAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$GoalsTableAnnotationComposer get goalId {
    final $$GoalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.goalId,
      referencedTable: $db.goals,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GoalsTableAnnotationComposer(
            $db: $db,
            $table: $db.goals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$GoalAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalAssetsTable,
          GoalAssetRow,
          $$GoalAssetsTableFilterComposer,
          $$GoalAssetsTableOrderingComposer,
          $$GoalAssetsTableAnnotationComposer,
          $$GoalAssetsTableCreateCompanionBuilder,
          $$GoalAssetsTableUpdateCompanionBuilder,
          (GoalAssetRow, $$GoalAssetsTableReferences),
          GoalAssetRow,
          PrefetchHooks Function({bool goalId, bool assetId})
        > {
  $$GoalAssetsTableTableManager(_$AppDatabase db, $GoalAssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> goalId = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalAssetsCompanion(
                goalId: goalId,
                assetId: assetId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int goalId,
                required int assetId,
                Value<int> rowid = const Value.absent(),
              }) => GoalAssetsCompanion.insert(
                goalId: goalId,
                assetId: assetId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalAssetsTable, GoalAssetRow>(table),
                  $$GoalAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({goalId = false, assetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (goalId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.goalId,
                        referencedTable: $$GoalAssetsTableReferences
                            ._goalIdTable(db),
                        referencedColumn: $$GoalAssetsTableReferences
                            ._goalIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (assetId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.assetId,
                        referencedTable: $$GoalAssetsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$GoalAssetsTableReferences
                            ._assetIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$GoalAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalAssetsTable,
      GoalAssetRow,
      $$GoalAssetsTableFilterComposer,
      $$GoalAssetsTableOrderingComposer,
      $$GoalAssetsTableAnnotationComposer,
      $$GoalAssetsTableCreateCompanionBuilder,
      $$GoalAssetsTableUpdateCompanionBuilder,
      (GoalAssetRow, $$GoalAssetsTableReferences),
      GoalAssetRow,
      PrefetchHooks Function({bool goalId, bool assetId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSettingRow,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSettingRow,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
          ),
          AppSettingRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSettingRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AppSettingsTable,
                    AppSettingRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSettingRow,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSettingRow,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingRow>,
      ),
      AppSettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db, _db.currencies);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$SubgroupsTableTableManager get subgroups =>
      $$SubgroupsTableTableManager(_db, _db.subgroups);
  $$AccountDetailsTableTableManager get accountDetails =>
      $$AccountDetailsTableTableManager(_db, _db.accountDetails);
  $$InvestmentDetailsTableTableManager get investmentDetails =>
      $$InvestmentDetailsTableTableManager(_db, _db.investmentDetails);
  $$PropertyDetailsTableTableManager get propertyDetails =>
      $$PropertyDetailsTableTableManager(_db, _db.propertyDetails);
  $$AssetValuationsTableTableManager get assetValuations =>
      $$AssetValuationsTableTableManager(_db, _db.assetValuations);
  $$AssetTransfersTableTableManager get assetTransfers =>
      $$AssetTransfersTableTableManager(_db, _db.assetTransfers);
  $$AssetTransactionsTableTableManager get assetTransactions =>
      $$AssetTransactionsTableTableManager(_db, _db.assetTransactions);
  $$AssetTransactionRevisionsTableTableManager get assetTransactionRevisions =>
      $$AssetTransactionRevisionsTableTableManager(
        _db,
        _db.assetTransactionRevisions,
      );
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$RecurringCashflowRulesTableTableManager get recurringCashflowRules =>
      $$RecurringCashflowRulesTableTableManager(
        _db,
        _db.recurringCashflowRules,
      );
  $$CashflowEntriesTableTableManager get cashflowEntries =>
      $$CashflowEntriesTableTableManager(_db, _db.cashflowEntries);
  $$CashflowEntryRevisionsTableTableManager get cashflowEntryRevisions =>
      $$CashflowEntryRevisionsTableTableManager(
        _db,
        _db.cashflowEntryRevisions,
      );
  $$ExchangeRatesTableTableManager get exchangeRates =>
      $$ExchangeRatesTableTableManager(_db, _db.exchangeRates);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$GoalAssetsTableTableManager get goalAssets =>
      $$GoalAssetsTableTableManager(_db, _db.goalAssets);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
