// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AssetsTable extends Assets with TableInfo<$AssetsTable, Asset> {
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('EUR'),
  );
  static const VerificationMeta _institutionMeta = const VerificationMeta(
    'institution',
  );
  @override
  late final GeneratedColumn<String> institution = GeneratedColumn<String>(
    'institution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    value,
    currency,
    institution,
    note,
    sortOrder,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Asset> instance, {
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('institution')) {
      context.handle(
        _institutionMeta,
        institution.isAcceptableOrUnknown(
          data['institution']!,
          _institutionMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      institution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class Asset extends DataClass implements Insertable<Asset> {
  final int id;
  final String name;
  final String type;
  final double value;
  final String currency;
  final String? institution;
  final String? note;

  /// Position dans l'ordre manuel choisi par l'utilisateur (drag & drop).
  final int sortOrder;
  final DateTime createdAt;
  const Asset({
    required this.id,
    required this.name,
    required this.type,
    required this.value,
    required this.currency,
    this.institution,
    this.note,
    required this.sortOrder,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['value'] = Variable<double>(value);
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || institution != null) {
      map['institution'] = Variable<String>(institution);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      value: Value(value),
      currency: Value(currency),
      institution: institution == null && nullToAbsent
          ? const Value.absent()
          : Value(institution),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
    );
  }

  factory Asset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asset(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      value: serializer.fromJson<double>(json['value']),
      currency: serializer.fromJson<String>(json['currency']),
      institution: serializer.fromJson<String?>(json['institution']),
      note: serializer.fromJson<String?>(json['note']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'value': serializer.toJson<double>(value),
      'currency': serializer.toJson<String>(currency),
      'institution': serializer.toJson<String?>(institution),
      'note': serializer.toJson<String?>(note),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Asset copyWith({
    int? id,
    String? name,
    String? type,
    double? value,
    String? currency,
    Value<String?> institution = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
  }) => Asset(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    value: value ?? this.value,
    currency: currency ?? this.currency,
    institution: institution.present ? institution.value : this.institution,
    note: note.present ? note.value : this.note,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
  );
  Asset copyWithCompanion(AssetsCompanion data) {
    return Asset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      currency: data.currency.present ? data.currency.value : this.currency,
      institution: data.institution.present
          ? data.institution.value
          : this.institution,
      note: data.note.present ? data.note.value : this.note,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('currency: $currency, ')
          ..write('institution: $institution, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    value,
    currency,
    institution,
    note,
    sortOrder,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asset &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.value == this.value &&
          other.currency == this.currency &&
          other.institution == this.institution &&
          other.note == this.note &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<double> value;
  final Value<String> currency;
  final Value<String?> institution;
  final Value<String?> note;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.currency = const Value.absent(),
    this.institution = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AssetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.value = const Value.absent(),
    this.currency = const Value.absent(),
    this.institution = const Value.absent(),
    this.note = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       type = Value(type);
  static Insertable<Asset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? value,
    Expression<String>? currency,
    Expression<String>? institution,
    Expression<String>? note,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (currency != null) 'currency': currency,
      if (institution != null) 'institution': institution,
      if (note != null) 'note': note,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AssetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<double>? value,
    Value<String>? currency,
    Value<String?>? institution,
    Value<String?>? note,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      value: value ?? this.value,
      currency: currency ?? this.currency,
      institution: institution ?? this.institution,
      note: note ?? this.note,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
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
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (institution.present) {
      map['institution'] = Variable<String>(institution.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('currency: $currency, ')
          ..write('institution: $institution, ')
          ..write('note: $note, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PositionsTable extends Positions
    with TableInfo<$PositionsTable, Position> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PositionsTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES assets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
    'unit_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetClassMeta = const VerificationMeta(
    'assetClass',
  );
  @override
  late final GeneratedColumn<String> assetClass = GeneratedColumn<String>(
    'asset_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sectorMeta = const VerificationMeta('sector');
  @override
  late final GeneratedColumn<String> sector = GeneratedColumn<String>(
    'sector',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _feesMeta = const VerificationMeta('fees');
  @override
  late final GeneratedColumn<double> fees = GeneratedColumn<double>(
    'fees',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    symbol,
    name,
    quantity,
    unitCost,
    assetClass,
    sector,
    region,
    fees,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Position> instance, {
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
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('asset_class')) {
      context.handle(
        _assetClassMeta,
        assetClass.isAcceptableOrUnknown(data['asset_class']!, _assetClassMeta),
      );
    }
    if (data.containsKey('sector')) {
      context.handle(
        _sectorMeta,
        sector.isAcceptableOrUnknown(data['sector']!, _sectorMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('fees')) {
      context.handle(
        _feesMeta,
        fees.isAcceptableOrUnknown(data['fees']!, _feesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Position map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Position(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_cost'],
      )!,
      assetClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_class'],
      ),
      sector: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sector'],
      ),
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      fees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fees'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PositionsTable createAlias(String alias) {
    return $PositionsTable(attachedDatabase, alias);
  }
}

class Position extends DataClass implements Insertable<Position> {
  final int id;
  final int assetId;
  final String symbol;
  final String name;
  final double quantity;
  final double unitCost;
  final String? assetClass;
  final String? sector;
  final String? region;
  final double fees;
  final DateTime createdAt;
  const Position({
    required this.id,
    required this.assetId,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.unitCost,
    this.assetClass,
    this.sector,
    this.region,
    required this.fees,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    map['symbol'] = Variable<String>(symbol);
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<double>(quantity);
    map['unit_cost'] = Variable<double>(unitCost);
    if (!nullToAbsent || assetClass != null) {
      map['asset_class'] = Variable<String>(assetClass);
    }
    if (!nullToAbsent || sector != null) {
      map['sector'] = Variable<String>(sector);
    }
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    map['fees'] = Variable<double>(fees);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PositionsCompanion toCompanion(bool nullToAbsent) {
    return PositionsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      symbol: Value(symbol),
      name: Value(name),
      quantity: Value(quantity),
      unitCost: Value(unitCost),
      assetClass: assetClass == null && nullToAbsent
          ? const Value.absent()
          : Value(assetClass),
      sector: sector == null && nullToAbsent
          ? const Value.absent()
          : Value(sector),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      fees: Value(fees),
      createdAt: Value(createdAt),
    );
  }

  factory Position.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Position(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      assetClass: serializer.fromJson<String?>(json['assetClass']),
      sector: serializer.fromJson<String?>(json['sector']),
      region: serializer.fromJson<String?>(json['region']),
      fees: serializer.fromJson<double>(json['fees']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<double>(quantity),
      'unitCost': serializer.toJson<double>(unitCost),
      'assetClass': serializer.toJson<String?>(assetClass),
      'sector': serializer.toJson<String?>(sector),
      'region': serializer.toJson<String?>(region),
      'fees': serializer.toJson<double>(fees),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Position copyWith({
    int? id,
    int? assetId,
    String? symbol,
    String? name,
    double? quantity,
    double? unitCost,
    Value<String?> assetClass = const Value.absent(),
    Value<String?> sector = const Value.absent(),
    Value<String?> region = const Value.absent(),
    double? fees,
    DateTime? createdAt,
  }) => Position(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    symbol: symbol ?? this.symbol,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    unitCost: unitCost ?? this.unitCost,
    assetClass: assetClass.present ? assetClass.value : this.assetClass,
    sector: sector.present ? sector.value : this.sector,
    region: region.present ? region.value : this.region,
    fees: fees ?? this.fees,
    createdAt: createdAt ?? this.createdAt,
  );
  Position copyWithCompanion(PositionsCompanion data) {
    return Position(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      assetClass: data.assetClass.present
          ? data.assetClass.value
          : this.assetClass,
      sector: data.sector.present ? data.sector.value : this.sector,
      region: data.region.present ? data.region.value : this.region,
      fees: data.fees.present ? data.fees.value : this.fees,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Position(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('assetClass: $assetClass, ')
          ..write('sector: $sector, ')
          ..write('region: $region, ')
          ..write('fees: $fees, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetId,
    symbol,
    name,
    quantity,
    unitCost,
    assetClass,
    sector,
    region,
    fees,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Position &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.symbol == this.symbol &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.assetClass == this.assetClass &&
          other.sector == this.sector &&
          other.region == this.region &&
          other.fees == this.fees &&
          other.createdAt == this.createdAt);
}

class PositionsCompanion extends UpdateCompanion<Position> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<String> symbol;
  final Value<String> name;
  final Value<double> quantity;
  final Value<double> unitCost;
  final Value<String?> assetClass;
  final Value<String?> sector;
  final Value<String?> region;
  final Value<double> fees;
  final Value<DateTime> createdAt;
  const PositionsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.assetClass = const Value.absent(),
    this.sector = const Value.absent(),
    this.region = const Value.absent(),
    this.fees = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PositionsCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    required String symbol,
    required String name,
    required double quantity,
    required double unitCost,
    this.assetClass = const Value.absent(),
    this.sector = const Value.absent(),
    this.region = const Value.absent(),
    this.fees = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : assetId = Value(assetId),
       symbol = Value(symbol),
       name = Value(name),
       quantity = Value(quantity),
       unitCost = Value(unitCost);
  static Insertable<Position> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<double>? quantity,
    Expression<double>? unitCost,
    Expression<String>? assetClass,
    Expression<String>? sector,
    Expression<String>? region,
    Expression<double>? fees,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (assetClass != null) 'asset_class': assetClass,
      if (sector != null) 'sector': sector,
      if (region != null) 'region': region,
      if (fees != null) 'fees': fees,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PositionsCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<String>? symbol,
    Value<String>? name,
    Value<double>? quantity,
    Value<double>? unitCost,
    Value<String?>? assetClass,
    Value<String?>? sector,
    Value<String?>? region,
    Value<double>? fees,
    Value<DateTime>? createdAt,
  }) {
    return PositionsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      assetClass: assetClass ?? this.assetClass,
      sector: sector ?? this.sector,
      region: region ?? this.region,
      fees: fees ?? this.fees,
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
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (assetClass.present) {
      map['asset_class'] = Variable<String>(assetClass.value);
    }
    if (sector.present) {
      map['sector'] = Variable<String>(sector.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (fees.present) {
      map['fees'] = Variable<double>(fees.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PositionsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('assetClass: $assetClass, ')
          ..write('sector: $sector, ')
          ..write('region: $region, ')
          ..write('fees: $fees, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PriceCacheTable extends PriceCache
    with TableInfo<$PriceCacheTable, MarketPrice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
    'symbol',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [symbol, price, currency, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarketPrice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('symbol')) {
      context.handle(
        _symbolMeta,
        symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta),
      );
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    } else if (isInserting) {
      context.missing(_currencyMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {symbol};
  @override
  MarketPrice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarketPrice(
      symbol: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symbol'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PriceCacheTable createAlias(String alias) {
    return $PriceCacheTable(attachedDatabase, alias);
  }
}

class MarketPrice extends DataClass implements Insertable<MarketPrice> {
  final String symbol;
  final double price;
  final String currency;
  final DateTime updatedAt;
  const MarketPrice({
    required this.symbol,
    required this.price,
    required this.currency,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['symbol'] = Variable<String>(symbol);
    map['price'] = Variable<double>(price);
    map['currency'] = Variable<String>(currency);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PriceCacheCompanion toCompanion(bool nullToAbsent) {
    return PriceCacheCompanion(
      symbol: Value(symbol),
      price: Value(price),
      currency: Value(currency),
      updatedAt: Value(updatedAt),
    );
  }

  factory MarketPrice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarketPrice(
      symbol: serializer.fromJson<String>(json['symbol']),
      price: serializer.fromJson<double>(json['price']),
      currency: serializer.fromJson<String>(json['currency']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'symbol': serializer.toJson<String>(symbol),
      'price': serializer.toJson<double>(price),
      'currency': serializer.toJson<String>(currency),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MarketPrice copyWith({
    String? symbol,
    double? price,
    String? currency,
    DateTime? updatedAt,
  }) => MarketPrice(
    symbol: symbol ?? this.symbol,
    price: price ?? this.price,
    currency: currency ?? this.currency,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MarketPrice copyWithCompanion(PriceCacheCompanion data) {
    return MarketPrice(
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      price: data.price.present ? data.price.value : this.price,
      currency: data.currency.present ? data.currency.value : this.currency,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarketPrice(')
          ..write('symbol: $symbol, ')
          ..write('price: $price, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(symbol, price, currency, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarketPrice &&
          other.symbol == this.symbol &&
          other.price == this.price &&
          other.currency == this.currency &&
          other.updatedAt == this.updatedAt);
}

class PriceCacheCompanion extends UpdateCompanion<MarketPrice> {
  final Value<String> symbol;
  final Value<double> price;
  final Value<String> currency;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const PriceCacheCompanion({
    this.symbol = const Value.absent(),
    this.price = const Value.absent(),
    this.currency = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PriceCacheCompanion.insert({
    required String symbol,
    required double price,
    required String currency,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : symbol = Value(symbol),
       price = Value(price),
       currency = Value(currency),
       updatedAt = Value(updatedAt);
  static Insertable<MarketPrice> custom({
    Expression<String>? symbol,
    Expression<double>? price,
    Expression<String>? currency,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (symbol != null) 'symbol': symbol,
      if (price != null) 'price': price,
      if (currency != null) 'currency': currency,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PriceCacheCompanion copyWith({
    Value<String>? symbol,
    Value<double>? price,
    Value<String>? currency,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return PriceCacheCompanion(
      symbol: symbol ?? this.symbol,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceCacheCompanion(')
          ..write('symbol: $symbol, ')
          ..write('price: $price, ')
          ..write('currency: $currency, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SnapshotsTable extends Snapshots
    with TableInfo<$SnapshotsTable, NetWorthSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SnapshotsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _netWorthMeta = const VerificationMeta(
    'netWorth',
  );
  @override
  late final GeneratedColumn<double> netWorth = GeneratedColumn<double>(
    'net_worth',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, netWorth];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<NetWorthSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('net_worth')) {
      context.handle(
        _netWorthMeta,
        netWorth.isAcceptableOrUnknown(data['net_worth']!, _netWorthMeta),
      );
    } else if (isInserting) {
      context.missing(_netWorthMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetWorthSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetWorthSnapshot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      netWorth: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}net_worth'],
      )!,
    );
  }

  @override
  $SnapshotsTable createAlias(String alias) {
    return $SnapshotsTable(attachedDatabase, alias);
  }
}

class NetWorthSnapshot extends DataClass
    implements Insertable<NetWorthSnapshot> {
  final int id;
  final DateTime date;
  final double netWorth;
  const NetWorthSnapshot({
    required this.id,
    required this.date,
    required this.netWorth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['net_worth'] = Variable<double>(netWorth);
    return map;
  }

  SnapshotsCompanion toCompanion(bool nullToAbsent) {
    return SnapshotsCompanion(
      id: Value(id),
      date: Value(date),
      netWorth: Value(netWorth),
    );
  }

  factory NetWorthSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetWorthSnapshot(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      netWorth: serializer.fromJson<double>(json['netWorth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'netWorth': serializer.toJson<double>(netWorth),
    };
  }

  NetWorthSnapshot copyWith({int? id, DateTime? date, double? netWorth}) =>
      NetWorthSnapshot(
        id: id ?? this.id,
        date: date ?? this.date,
        netWorth: netWorth ?? this.netWorth,
      );
  NetWorthSnapshot copyWithCompanion(SnapshotsCompanion data) {
    return NetWorthSnapshot(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      netWorth: data.netWorth.present ? data.netWorth.value : this.netWorth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthSnapshot(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('netWorth: $netWorth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, netWorth);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetWorthSnapshot &&
          other.id == this.id &&
          other.date == this.date &&
          other.netWorth == this.netWorth);
}

class SnapshotsCompanion extends UpdateCompanion<NetWorthSnapshot> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<double> netWorth;
  const SnapshotsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.netWorth = const Value.absent(),
  });
  SnapshotsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime date,
    required double netWorth,
  }) : date = Value(date),
       netWorth = Value(netWorth);
  static Insertable<NetWorthSnapshot> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<double>? netWorth,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (netWorth != null) 'net_worth': netWorth,
    });
  }

  SnapshotsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? date,
    Value<double>? netWorth,
  }) {
    return SnapshotsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      netWorth: netWorth ?? this.netWorth,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (netWorth.present) {
      map['net_worth'] = Variable<double>(netWorth.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SnapshotsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('netWorth: $netWorth')
          ..write(')'))
        .toString();
  }
}

class $RentalsTable extends Rentals with TableInfo<$RentalsTable, Rental> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RentalsTable(this.attachedDatabase, [this._alias]);
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
      'UNIQUE REFERENCES assets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
    'statut',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('vacant'),
  );
  static const VerificationMeta _typeBailMeta = const VerificationMeta(
    'typeBail',
  );
  @override
  late final GeneratedColumn<String> typeBail = GeneratedColumn<String>(
    'type_bail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locataireMeta = const VerificationMeta(
    'locataire',
  );
  @override
  late final GeneratedColumn<String> locataire = GeneratedColumn<String>(
    'locataire',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _loyerHcMeta = const VerificationMeta(
    'loyerHc',
  );
  @override
  late final GeneratedColumn<double> loyerHc = GeneratedColumn<double>(
    'loyer_hc',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chargesLocativesMeta = const VerificationMeta(
    'chargesLocatives',
  );
  @override
  late final GeneratedColumn<double> chargesLocatives = GeneratedColumn<double>(
    'charges_locatives',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _depotGarantieMeta = const VerificationMeta(
    'depotGarantie',
  );
  @override
  late final GeneratedColumn<double> depotGarantie = GeneratedColumn<double>(
    'depot_garantie',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateDebutBailMeta = const VerificationMeta(
    'dateDebutBail',
  );
  @override
  late final GeneratedColumn<DateTime> dateDebutBail =
      GeneratedColumn<DateTime>(
        'date_debut_bail',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _dateFinBailMeta = const VerificationMeta(
    'dateFinBail',
  );
  @override
  late final GeneratedColumn<DateTime> dateFinBail = GeneratedColumn<DateTime>(
    'date_fin_bail',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modeGestionMeta = const VerificationMeta(
    'modeGestion',
  );
  @override
  late final GeneratedColumn<String> modeGestion = GeneratedColumn<String>(
    'mode_gestion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fraisGestionMeta = const VerificationMeta(
    'fraisGestion',
  );
  @override
  late final GeneratedColumn<double> fraisGestion = GeneratedColumn<double>(
    'frais_gestion',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _taxeFonciereMeta = const VerificationMeta(
    'taxeFonciere',
  );
  @override
  late final GeneratedColumn<double> taxeFonciere = GeneratedColumn<double>(
    'taxe_fonciere',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _assurancePnoMeta = const VerificationMeta(
    'assurancePno',
  );
  @override
  late final GeneratedColumn<double> assurancePno = GeneratedColumn<double>(
    'assurance_pno',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _chargesCoproprieteMeta =
      const VerificationMeta('chargesCopropriete');
  @override
  late final GeneratedColumn<double> chargesCopropriete =
      GeneratedColumn<double>(
        'charges_copropriete',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _travauxEntretienMeta = const VerificationMeta(
    'travauxEntretien',
  );
  @override
  late final GeneratedColumn<double> travauxEntretien = GeneratedColumn<double>(
    'travaux_entretien',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _vacanceLocativeMeta = const VerificationMeta(
    'vacanceLocative',
  );
  @override
  late final GeneratedColumn<double> vacanceLocative = GeneratedColumn<double>(
    'vacance_locative',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aUnCreditMeta = const VerificationMeta(
    'aUnCredit',
  );
  @override
  late final GeneratedColumn<bool> aUnCredit = GeneratedColumn<bool>(
    'a_un_credit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("a_un_credit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _montantCreditMeta = const VerificationMeta(
    'montantCredit',
  );
  @override
  late final GeneratedColumn<double> montantCredit = GeneratedColumn<double>(
    'montant_credit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tauxCreditPctMeta = const VerificationMeta(
    'tauxCreditPct',
  );
  @override
  late final GeneratedColumn<double> tauxCreditPct = GeneratedColumn<double>(
    'taux_credit_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _mensualiteCreditMeta = const VerificationMeta(
    'mensualiteCredit',
  );
  @override
  late final GeneratedColumn<double> mensualiteCredit = GeneratedColumn<double>(
    'mensualite_credit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dureeCreditMoisMeta = const VerificationMeta(
    'dureeCreditMois',
  );
  @override
  late final GeneratedColumn<int> dureeCreditMois = GeneratedColumn<int>(
    'duree_credit_mois',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _capitalRestantDuMeta = const VerificationMeta(
    'capitalRestantDu',
  );
  @override
  late final GeneratedColumn<double> capitalRestantDu = GeneratedColumn<double>(
    'capital_restant_du',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _assuranceEmprunteurMeta =
      const VerificationMeta('assuranceEmprunteur');
  @override
  late final GeneratedColumn<double> assuranceEmprunteur =
      GeneratedColumn<double>(
        'assurance_emprunteur',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    statut,
    typeBail,
    locataire,
    loyerHc,
    chargesLocatives,
    depotGarantie,
    dateDebutBail,
    dateFinBail,
    modeGestion,
    fraisGestion,
    taxeFonciere,
    assurancePno,
    chargesCopropriete,
    travauxEntretien,
    vacanceLocative,
    note,
    aUnCredit,
    montantCredit,
    tauxCreditPct,
    mensualiteCredit,
    dureeCreditMois,
    capitalRestantDu,
    assuranceEmprunteur,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rentals';
  @override
  VerificationContext validateIntegrity(
    Insertable<Rental> instance, {
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
    if (data.containsKey('statut')) {
      context.handle(
        _statutMeta,
        statut.isAcceptableOrUnknown(data['statut']!, _statutMeta),
      );
    }
    if (data.containsKey('type_bail')) {
      context.handle(
        _typeBailMeta,
        typeBail.isAcceptableOrUnknown(data['type_bail']!, _typeBailMeta),
      );
    }
    if (data.containsKey('locataire')) {
      context.handle(
        _locataireMeta,
        locataire.isAcceptableOrUnknown(data['locataire']!, _locataireMeta),
      );
    }
    if (data.containsKey('loyer_hc')) {
      context.handle(
        _loyerHcMeta,
        loyerHc.isAcceptableOrUnknown(data['loyer_hc']!, _loyerHcMeta),
      );
    }
    if (data.containsKey('charges_locatives')) {
      context.handle(
        _chargesLocativesMeta,
        chargesLocatives.isAcceptableOrUnknown(
          data['charges_locatives']!,
          _chargesLocativesMeta,
        ),
      );
    }
    if (data.containsKey('depot_garantie')) {
      context.handle(
        _depotGarantieMeta,
        depotGarantie.isAcceptableOrUnknown(
          data['depot_garantie']!,
          _depotGarantieMeta,
        ),
      );
    }
    if (data.containsKey('date_debut_bail')) {
      context.handle(
        _dateDebutBailMeta,
        dateDebutBail.isAcceptableOrUnknown(
          data['date_debut_bail']!,
          _dateDebutBailMeta,
        ),
      );
    }
    if (data.containsKey('date_fin_bail')) {
      context.handle(
        _dateFinBailMeta,
        dateFinBail.isAcceptableOrUnknown(
          data['date_fin_bail']!,
          _dateFinBailMeta,
        ),
      );
    }
    if (data.containsKey('mode_gestion')) {
      context.handle(
        _modeGestionMeta,
        modeGestion.isAcceptableOrUnknown(
          data['mode_gestion']!,
          _modeGestionMeta,
        ),
      );
    }
    if (data.containsKey('frais_gestion')) {
      context.handle(
        _fraisGestionMeta,
        fraisGestion.isAcceptableOrUnknown(
          data['frais_gestion']!,
          _fraisGestionMeta,
        ),
      );
    }
    if (data.containsKey('taxe_fonciere')) {
      context.handle(
        _taxeFonciereMeta,
        taxeFonciere.isAcceptableOrUnknown(
          data['taxe_fonciere']!,
          _taxeFonciereMeta,
        ),
      );
    }
    if (data.containsKey('assurance_pno')) {
      context.handle(
        _assurancePnoMeta,
        assurancePno.isAcceptableOrUnknown(
          data['assurance_pno']!,
          _assurancePnoMeta,
        ),
      );
    }
    if (data.containsKey('charges_copropriete')) {
      context.handle(
        _chargesCoproprieteMeta,
        chargesCopropriete.isAcceptableOrUnknown(
          data['charges_copropriete']!,
          _chargesCoproprieteMeta,
        ),
      );
    }
    if (data.containsKey('travaux_entretien')) {
      context.handle(
        _travauxEntretienMeta,
        travauxEntretien.isAcceptableOrUnknown(
          data['travaux_entretien']!,
          _travauxEntretienMeta,
        ),
      );
    }
    if (data.containsKey('vacance_locative')) {
      context.handle(
        _vacanceLocativeMeta,
        vacanceLocative.isAcceptableOrUnknown(
          data['vacance_locative']!,
          _vacanceLocativeMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('a_un_credit')) {
      context.handle(
        _aUnCreditMeta,
        aUnCredit.isAcceptableOrUnknown(data['a_un_credit']!, _aUnCreditMeta),
      );
    }
    if (data.containsKey('montant_credit')) {
      context.handle(
        _montantCreditMeta,
        montantCredit.isAcceptableOrUnknown(
          data['montant_credit']!,
          _montantCreditMeta,
        ),
      );
    }
    if (data.containsKey('taux_credit_pct')) {
      context.handle(
        _tauxCreditPctMeta,
        tauxCreditPct.isAcceptableOrUnknown(
          data['taux_credit_pct']!,
          _tauxCreditPctMeta,
        ),
      );
    }
    if (data.containsKey('mensualite_credit')) {
      context.handle(
        _mensualiteCreditMeta,
        mensualiteCredit.isAcceptableOrUnknown(
          data['mensualite_credit']!,
          _mensualiteCreditMeta,
        ),
      );
    }
    if (data.containsKey('duree_credit_mois')) {
      context.handle(
        _dureeCreditMoisMeta,
        dureeCreditMois.isAcceptableOrUnknown(
          data['duree_credit_mois']!,
          _dureeCreditMoisMeta,
        ),
      );
    }
    if (data.containsKey('capital_restant_du')) {
      context.handle(
        _capitalRestantDuMeta,
        capitalRestantDu.isAcceptableOrUnknown(
          data['capital_restant_du']!,
          _capitalRestantDuMeta,
        ),
      );
    }
    if (data.containsKey('assurance_emprunteur')) {
      context.handle(
        _assuranceEmprunteurMeta,
        assuranceEmprunteur.isAcceptableOrUnknown(
          data['assurance_emprunteur']!,
          _assuranceEmprunteurMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Rental map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Rental(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      statut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut'],
      )!,
      typeBail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_bail'],
      ),
      locataire: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locataire'],
      ),
      loyerHc: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}loyer_hc'],
      )!,
      chargesLocatives: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}charges_locatives'],
      )!,
      depotGarantie: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}depot_garantie'],
      )!,
      dateDebutBail: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_debut_bail'],
      ),
      dateFinBail: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_fin_bail'],
      ),
      modeGestion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode_gestion'],
      ),
      fraisGestion: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}frais_gestion'],
      )!,
      taxeFonciere: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taxe_fonciere'],
      )!,
      assurancePno: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}assurance_pno'],
      )!,
      chargesCopropriete: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}charges_copropriete'],
      )!,
      travauxEntretien: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}travaux_entretien'],
      )!,
      vacanceLocative: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vacance_locative'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      aUnCredit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}a_un_credit'],
      )!,
      montantCredit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_credit'],
      )!,
      tauxCreditPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taux_credit_pct'],
      )!,
      mensualiteCredit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mensualite_credit'],
      )!,
      dureeCreditMois: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duree_credit_mois'],
      )!,
      capitalRestantDu: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}capital_restant_du'],
      )!,
      assuranceEmprunteur: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}assurance_emprunteur'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RentalsTable createAlias(String alias) {
    return $RentalsTable(attachedDatabase, alias);
  }
}

class Rental extends DataClass implements Insertable<Rental> {
  final int id;
  final int assetId;

  /// loue | vacant | autre
  final String statut;

  /// vide | meuble | commercial | saisonnier | colocation | autre
  final String? typeBail;
  final String? locataire;
  final double loyerHc;
  final double chargesLocatives;
  final double depotGarantie;
  final DateTime? dateDebutBail;
  final DateTime? dateFinBail;

  /// direct | agence | autre
  final String? modeGestion;
  final double fraisGestion;
  final double taxeFonciere;
  final double assurancePno;
  final double chargesCopropriete;
  final double travauxEntretien;
  final double vacanceLocative;
  final String? note;
  final bool aUnCredit;
  final double montantCredit;
  final double tauxCreditPct;
  final double mensualiteCredit;
  final int dureeCreditMois;
  final double capitalRestantDu;
  final double assuranceEmprunteur;
  final DateTime createdAt;
  const Rental({
    required this.id,
    required this.assetId,
    required this.statut,
    this.typeBail,
    this.locataire,
    required this.loyerHc,
    required this.chargesLocatives,
    required this.depotGarantie,
    this.dateDebutBail,
    this.dateFinBail,
    this.modeGestion,
    required this.fraisGestion,
    required this.taxeFonciere,
    required this.assurancePno,
    required this.chargesCopropriete,
    required this.travauxEntretien,
    required this.vacanceLocative,
    this.note,
    required this.aUnCredit,
    required this.montantCredit,
    required this.tauxCreditPct,
    required this.mensualiteCredit,
    required this.dureeCreditMois,
    required this.capitalRestantDu,
    required this.assuranceEmprunteur,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || typeBail != null) {
      map['type_bail'] = Variable<String>(typeBail);
    }
    if (!nullToAbsent || locataire != null) {
      map['locataire'] = Variable<String>(locataire);
    }
    map['loyer_hc'] = Variable<double>(loyerHc);
    map['charges_locatives'] = Variable<double>(chargesLocatives);
    map['depot_garantie'] = Variable<double>(depotGarantie);
    if (!nullToAbsent || dateDebutBail != null) {
      map['date_debut_bail'] = Variable<DateTime>(dateDebutBail);
    }
    if (!nullToAbsent || dateFinBail != null) {
      map['date_fin_bail'] = Variable<DateTime>(dateFinBail);
    }
    if (!nullToAbsent || modeGestion != null) {
      map['mode_gestion'] = Variable<String>(modeGestion);
    }
    map['frais_gestion'] = Variable<double>(fraisGestion);
    map['taxe_fonciere'] = Variable<double>(taxeFonciere);
    map['assurance_pno'] = Variable<double>(assurancePno);
    map['charges_copropriete'] = Variable<double>(chargesCopropriete);
    map['travaux_entretien'] = Variable<double>(travauxEntretien);
    map['vacance_locative'] = Variable<double>(vacanceLocative);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['a_un_credit'] = Variable<bool>(aUnCredit);
    map['montant_credit'] = Variable<double>(montantCredit);
    map['taux_credit_pct'] = Variable<double>(tauxCreditPct);
    map['mensualite_credit'] = Variable<double>(mensualiteCredit);
    map['duree_credit_mois'] = Variable<int>(dureeCreditMois);
    map['capital_restant_du'] = Variable<double>(capitalRestantDu);
    map['assurance_emprunteur'] = Variable<double>(assuranceEmprunteur);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RentalsCompanion toCompanion(bool nullToAbsent) {
    return RentalsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      statut: Value(statut),
      typeBail: typeBail == null && nullToAbsent
          ? const Value.absent()
          : Value(typeBail),
      locataire: locataire == null && nullToAbsent
          ? const Value.absent()
          : Value(locataire),
      loyerHc: Value(loyerHc),
      chargesLocatives: Value(chargesLocatives),
      depotGarantie: Value(depotGarantie),
      dateDebutBail: dateDebutBail == null && nullToAbsent
          ? const Value.absent()
          : Value(dateDebutBail),
      dateFinBail: dateFinBail == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFinBail),
      modeGestion: modeGestion == null && nullToAbsent
          ? const Value.absent()
          : Value(modeGestion),
      fraisGestion: Value(fraisGestion),
      taxeFonciere: Value(taxeFonciere),
      assurancePno: Value(assurancePno),
      chargesCopropriete: Value(chargesCopropriete),
      travauxEntretien: Value(travauxEntretien),
      vacanceLocative: Value(vacanceLocative),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      aUnCredit: Value(aUnCredit),
      montantCredit: Value(montantCredit),
      tauxCreditPct: Value(tauxCreditPct),
      mensualiteCredit: Value(mensualiteCredit),
      dureeCreditMois: Value(dureeCreditMois),
      capitalRestantDu: Value(capitalRestantDu),
      assuranceEmprunteur: Value(assuranceEmprunteur),
      createdAt: Value(createdAt),
    );
  }

  factory Rental.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Rental(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      statut: serializer.fromJson<String>(json['statut']),
      typeBail: serializer.fromJson<String?>(json['typeBail']),
      locataire: serializer.fromJson<String?>(json['locataire']),
      loyerHc: serializer.fromJson<double>(json['loyerHc']),
      chargesLocatives: serializer.fromJson<double>(json['chargesLocatives']),
      depotGarantie: serializer.fromJson<double>(json['depotGarantie']),
      dateDebutBail: serializer.fromJson<DateTime?>(json['dateDebutBail']),
      dateFinBail: serializer.fromJson<DateTime?>(json['dateFinBail']),
      modeGestion: serializer.fromJson<String?>(json['modeGestion']),
      fraisGestion: serializer.fromJson<double>(json['fraisGestion']),
      taxeFonciere: serializer.fromJson<double>(json['taxeFonciere']),
      assurancePno: serializer.fromJson<double>(json['assurancePno']),
      chargesCopropriete: serializer.fromJson<double>(
        json['chargesCopropriete'],
      ),
      travauxEntretien: serializer.fromJson<double>(json['travauxEntretien']),
      vacanceLocative: serializer.fromJson<double>(json['vacanceLocative']),
      note: serializer.fromJson<String?>(json['note']),
      aUnCredit: serializer.fromJson<bool>(json['aUnCredit']),
      montantCredit: serializer.fromJson<double>(json['montantCredit']),
      tauxCreditPct: serializer.fromJson<double>(json['tauxCreditPct']),
      mensualiteCredit: serializer.fromJson<double>(json['mensualiteCredit']),
      dureeCreditMois: serializer.fromJson<int>(json['dureeCreditMois']),
      capitalRestantDu: serializer.fromJson<double>(json['capitalRestantDu']),
      assuranceEmprunteur: serializer.fromJson<double>(
        json['assuranceEmprunteur'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'statut': serializer.toJson<String>(statut),
      'typeBail': serializer.toJson<String?>(typeBail),
      'locataire': serializer.toJson<String?>(locataire),
      'loyerHc': serializer.toJson<double>(loyerHc),
      'chargesLocatives': serializer.toJson<double>(chargesLocatives),
      'depotGarantie': serializer.toJson<double>(depotGarantie),
      'dateDebutBail': serializer.toJson<DateTime?>(dateDebutBail),
      'dateFinBail': serializer.toJson<DateTime?>(dateFinBail),
      'modeGestion': serializer.toJson<String?>(modeGestion),
      'fraisGestion': serializer.toJson<double>(fraisGestion),
      'taxeFonciere': serializer.toJson<double>(taxeFonciere),
      'assurancePno': serializer.toJson<double>(assurancePno),
      'chargesCopropriete': serializer.toJson<double>(chargesCopropriete),
      'travauxEntretien': serializer.toJson<double>(travauxEntretien),
      'vacanceLocative': serializer.toJson<double>(vacanceLocative),
      'note': serializer.toJson<String?>(note),
      'aUnCredit': serializer.toJson<bool>(aUnCredit),
      'montantCredit': serializer.toJson<double>(montantCredit),
      'tauxCreditPct': serializer.toJson<double>(tauxCreditPct),
      'mensualiteCredit': serializer.toJson<double>(mensualiteCredit),
      'dureeCreditMois': serializer.toJson<int>(dureeCreditMois),
      'capitalRestantDu': serializer.toJson<double>(capitalRestantDu),
      'assuranceEmprunteur': serializer.toJson<double>(assuranceEmprunteur),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Rental copyWith({
    int? id,
    int? assetId,
    String? statut,
    Value<String?> typeBail = const Value.absent(),
    Value<String?> locataire = const Value.absent(),
    double? loyerHc,
    double? chargesLocatives,
    double? depotGarantie,
    Value<DateTime?> dateDebutBail = const Value.absent(),
    Value<DateTime?> dateFinBail = const Value.absent(),
    Value<String?> modeGestion = const Value.absent(),
    double? fraisGestion,
    double? taxeFonciere,
    double? assurancePno,
    double? chargesCopropriete,
    double? travauxEntretien,
    double? vacanceLocative,
    Value<String?> note = const Value.absent(),
    bool? aUnCredit,
    double? montantCredit,
    double? tauxCreditPct,
    double? mensualiteCredit,
    int? dureeCreditMois,
    double? capitalRestantDu,
    double? assuranceEmprunteur,
    DateTime? createdAt,
  }) => Rental(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    statut: statut ?? this.statut,
    typeBail: typeBail.present ? typeBail.value : this.typeBail,
    locataire: locataire.present ? locataire.value : this.locataire,
    loyerHc: loyerHc ?? this.loyerHc,
    chargesLocatives: chargesLocatives ?? this.chargesLocatives,
    depotGarantie: depotGarantie ?? this.depotGarantie,
    dateDebutBail: dateDebutBail.present
        ? dateDebutBail.value
        : this.dateDebutBail,
    dateFinBail: dateFinBail.present ? dateFinBail.value : this.dateFinBail,
    modeGestion: modeGestion.present ? modeGestion.value : this.modeGestion,
    fraisGestion: fraisGestion ?? this.fraisGestion,
    taxeFonciere: taxeFonciere ?? this.taxeFonciere,
    assurancePno: assurancePno ?? this.assurancePno,
    chargesCopropriete: chargesCopropriete ?? this.chargesCopropriete,
    travauxEntretien: travauxEntretien ?? this.travauxEntretien,
    vacanceLocative: vacanceLocative ?? this.vacanceLocative,
    note: note.present ? note.value : this.note,
    aUnCredit: aUnCredit ?? this.aUnCredit,
    montantCredit: montantCredit ?? this.montantCredit,
    tauxCreditPct: tauxCreditPct ?? this.tauxCreditPct,
    mensualiteCredit: mensualiteCredit ?? this.mensualiteCredit,
    dureeCreditMois: dureeCreditMois ?? this.dureeCreditMois,
    capitalRestantDu: capitalRestantDu ?? this.capitalRestantDu,
    assuranceEmprunteur: assuranceEmprunteur ?? this.assuranceEmprunteur,
    createdAt: createdAt ?? this.createdAt,
  );
  Rental copyWithCompanion(RentalsCompanion data) {
    return Rental(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      statut: data.statut.present ? data.statut.value : this.statut,
      typeBail: data.typeBail.present ? data.typeBail.value : this.typeBail,
      locataire: data.locataire.present ? data.locataire.value : this.locataire,
      loyerHc: data.loyerHc.present ? data.loyerHc.value : this.loyerHc,
      chargesLocatives: data.chargesLocatives.present
          ? data.chargesLocatives.value
          : this.chargesLocatives,
      depotGarantie: data.depotGarantie.present
          ? data.depotGarantie.value
          : this.depotGarantie,
      dateDebutBail: data.dateDebutBail.present
          ? data.dateDebutBail.value
          : this.dateDebutBail,
      dateFinBail: data.dateFinBail.present
          ? data.dateFinBail.value
          : this.dateFinBail,
      modeGestion: data.modeGestion.present
          ? data.modeGestion.value
          : this.modeGestion,
      fraisGestion: data.fraisGestion.present
          ? data.fraisGestion.value
          : this.fraisGestion,
      taxeFonciere: data.taxeFonciere.present
          ? data.taxeFonciere.value
          : this.taxeFonciere,
      assurancePno: data.assurancePno.present
          ? data.assurancePno.value
          : this.assurancePno,
      chargesCopropriete: data.chargesCopropriete.present
          ? data.chargesCopropriete.value
          : this.chargesCopropriete,
      travauxEntretien: data.travauxEntretien.present
          ? data.travauxEntretien.value
          : this.travauxEntretien,
      vacanceLocative: data.vacanceLocative.present
          ? data.vacanceLocative.value
          : this.vacanceLocative,
      note: data.note.present ? data.note.value : this.note,
      aUnCredit: data.aUnCredit.present ? data.aUnCredit.value : this.aUnCredit,
      montantCredit: data.montantCredit.present
          ? data.montantCredit.value
          : this.montantCredit,
      tauxCreditPct: data.tauxCreditPct.present
          ? data.tauxCreditPct.value
          : this.tauxCreditPct,
      mensualiteCredit: data.mensualiteCredit.present
          ? data.mensualiteCredit.value
          : this.mensualiteCredit,
      dureeCreditMois: data.dureeCreditMois.present
          ? data.dureeCreditMois.value
          : this.dureeCreditMois,
      capitalRestantDu: data.capitalRestantDu.present
          ? data.capitalRestantDu.value
          : this.capitalRestantDu,
      assuranceEmprunteur: data.assuranceEmprunteur.present
          ? data.assuranceEmprunteur.value
          : this.assuranceEmprunteur,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Rental(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('statut: $statut, ')
          ..write('typeBail: $typeBail, ')
          ..write('locataire: $locataire, ')
          ..write('loyerHc: $loyerHc, ')
          ..write('chargesLocatives: $chargesLocatives, ')
          ..write('depotGarantie: $depotGarantie, ')
          ..write('dateDebutBail: $dateDebutBail, ')
          ..write('dateFinBail: $dateFinBail, ')
          ..write('modeGestion: $modeGestion, ')
          ..write('fraisGestion: $fraisGestion, ')
          ..write('taxeFonciere: $taxeFonciere, ')
          ..write('assurancePno: $assurancePno, ')
          ..write('chargesCopropriete: $chargesCopropriete, ')
          ..write('travauxEntretien: $travauxEntretien, ')
          ..write('vacanceLocative: $vacanceLocative, ')
          ..write('note: $note, ')
          ..write('aUnCredit: $aUnCredit, ')
          ..write('montantCredit: $montantCredit, ')
          ..write('tauxCreditPct: $tauxCreditPct, ')
          ..write('mensualiteCredit: $mensualiteCredit, ')
          ..write('dureeCreditMois: $dureeCreditMois, ')
          ..write('capitalRestantDu: $capitalRestantDu, ')
          ..write('assuranceEmprunteur: $assuranceEmprunteur, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    assetId,
    statut,
    typeBail,
    locataire,
    loyerHc,
    chargesLocatives,
    depotGarantie,
    dateDebutBail,
    dateFinBail,
    modeGestion,
    fraisGestion,
    taxeFonciere,
    assurancePno,
    chargesCopropriete,
    travauxEntretien,
    vacanceLocative,
    note,
    aUnCredit,
    montantCredit,
    tauxCreditPct,
    mensualiteCredit,
    dureeCreditMois,
    capitalRestantDu,
    assuranceEmprunteur,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Rental &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.statut == this.statut &&
          other.typeBail == this.typeBail &&
          other.locataire == this.locataire &&
          other.loyerHc == this.loyerHc &&
          other.chargesLocatives == this.chargesLocatives &&
          other.depotGarantie == this.depotGarantie &&
          other.dateDebutBail == this.dateDebutBail &&
          other.dateFinBail == this.dateFinBail &&
          other.modeGestion == this.modeGestion &&
          other.fraisGestion == this.fraisGestion &&
          other.taxeFonciere == this.taxeFonciere &&
          other.assurancePno == this.assurancePno &&
          other.chargesCopropriete == this.chargesCopropriete &&
          other.travauxEntretien == this.travauxEntretien &&
          other.vacanceLocative == this.vacanceLocative &&
          other.note == this.note &&
          other.aUnCredit == this.aUnCredit &&
          other.montantCredit == this.montantCredit &&
          other.tauxCreditPct == this.tauxCreditPct &&
          other.mensualiteCredit == this.mensualiteCredit &&
          other.dureeCreditMois == this.dureeCreditMois &&
          other.capitalRestantDu == this.capitalRestantDu &&
          other.assuranceEmprunteur == this.assuranceEmprunteur &&
          other.createdAt == this.createdAt);
}

class RentalsCompanion extends UpdateCompanion<Rental> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<String> statut;
  final Value<String?> typeBail;
  final Value<String?> locataire;
  final Value<double> loyerHc;
  final Value<double> chargesLocatives;
  final Value<double> depotGarantie;
  final Value<DateTime?> dateDebutBail;
  final Value<DateTime?> dateFinBail;
  final Value<String?> modeGestion;
  final Value<double> fraisGestion;
  final Value<double> taxeFonciere;
  final Value<double> assurancePno;
  final Value<double> chargesCopropriete;
  final Value<double> travauxEntretien;
  final Value<double> vacanceLocative;
  final Value<String?> note;
  final Value<bool> aUnCredit;
  final Value<double> montantCredit;
  final Value<double> tauxCreditPct;
  final Value<double> mensualiteCredit;
  final Value<int> dureeCreditMois;
  final Value<double> capitalRestantDu;
  final Value<double> assuranceEmprunteur;
  final Value<DateTime> createdAt;
  const RentalsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.statut = const Value.absent(),
    this.typeBail = const Value.absent(),
    this.locataire = const Value.absent(),
    this.loyerHc = const Value.absent(),
    this.chargesLocatives = const Value.absent(),
    this.depotGarantie = const Value.absent(),
    this.dateDebutBail = const Value.absent(),
    this.dateFinBail = const Value.absent(),
    this.modeGestion = const Value.absent(),
    this.fraisGestion = const Value.absent(),
    this.taxeFonciere = const Value.absent(),
    this.assurancePno = const Value.absent(),
    this.chargesCopropriete = const Value.absent(),
    this.travauxEntretien = const Value.absent(),
    this.vacanceLocative = const Value.absent(),
    this.note = const Value.absent(),
    this.aUnCredit = const Value.absent(),
    this.montantCredit = const Value.absent(),
    this.tauxCreditPct = const Value.absent(),
    this.mensualiteCredit = const Value.absent(),
    this.dureeCreditMois = const Value.absent(),
    this.capitalRestantDu = const Value.absent(),
    this.assuranceEmprunteur = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RentalsCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    this.statut = const Value.absent(),
    this.typeBail = const Value.absent(),
    this.locataire = const Value.absent(),
    this.loyerHc = const Value.absent(),
    this.chargesLocatives = const Value.absent(),
    this.depotGarantie = const Value.absent(),
    this.dateDebutBail = const Value.absent(),
    this.dateFinBail = const Value.absent(),
    this.modeGestion = const Value.absent(),
    this.fraisGestion = const Value.absent(),
    this.taxeFonciere = const Value.absent(),
    this.assurancePno = const Value.absent(),
    this.chargesCopropriete = const Value.absent(),
    this.travauxEntretien = const Value.absent(),
    this.vacanceLocative = const Value.absent(),
    this.note = const Value.absent(),
    this.aUnCredit = const Value.absent(),
    this.montantCredit = const Value.absent(),
    this.tauxCreditPct = const Value.absent(),
    this.mensualiteCredit = const Value.absent(),
    this.dureeCreditMois = const Value.absent(),
    this.capitalRestantDu = const Value.absent(),
    this.assuranceEmprunteur = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : assetId = Value(assetId);
  static Insertable<Rental> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<String>? statut,
    Expression<String>? typeBail,
    Expression<String>? locataire,
    Expression<double>? loyerHc,
    Expression<double>? chargesLocatives,
    Expression<double>? depotGarantie,
    Expression<DateTime>? dateDebutBail,
    Expression<DateTime>? dateFinBail,
    Expression<String>? modeGestion,
    Expression<double>? fraisGestion,
    Expression<double>? taxeFonciere,
    Expression<double>? assurancePno,
    Expression<double>? chargesCopropriete,
    Expression<double>? travauxEntretien,
    Expression<double>? vacanceLocative,
    Expression<String>? note,
    Expression<bool>? aUnCredit,
    Expression<double>? montantCredit,
    Expression<double>? tauxCreditPct,
    Expression<double>? mensualiteCredit,
    Expression<int>? dureeCreditMois,
    Expression<double>? capitalRestantDu,
    Expression<double>? assuranceEmprunteur,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (statut != null) 'statut': statut,
      if (typeBail != null) 'type_bail': typeBail,
      if (locataire != null) 'locataire': locataire,
      if (loyerHc != null) 'loyer_hc': loyerHc,
      if (chargesLocatives != null) 'charges_locatives': chargesLocatives,
      if (depotGarantie != null) 'depot_garantie': depotGarantie,
      if (dateDebutBail != null) 'date_debut_bail': dateDebutBail,
      if (dateFinBail != null) 'date_fin_bail': dateFinBail,
      if (modeGestion != null) 'mode_gestion': modeGestion,
      if (fraisGestion != null) 'frais_gestion': fraisGestion,
      if (taxeFonciere != null) 'taxe_fonciere': taxeFonciere,
      if (assurancePno != null) 'assurance_pno': assurancePno,
      if (chargesCopropriete != null) 'charges_copropriete': chargesCopropriete,
      if (travauxEntretien != null) 'travaux_entretien': travauxEntretien,
      if (vacanceLocative != null) 'vacance_locative': vacanceLocative,
      if (note != null) 'note': note,
      if (aUnCredit != null) 'a_un_credit': aUnCredit,
      if (montantCredit != null) 'montant_credit': montantCredit,
      if (tauxCreditPct != null) 'taux_credit_pct': tauxCreditPct,
      if (mensualiteCredit != null) 'mensualite_credit': mensualiteCredit,
      if (dureeCreditMois != null) 'duree_credit_mois': dureeCreditMois,
      if (capitalRestantDu != null) 'capital_restant_du': capitalRestantDu,
      if (assuranceEmprunteur != null)
        'assurance_emprunteur': assuranceEmprunteur,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RentalsCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<String>? statut,
    Value<String?>? typeBail,
    Value<String?>? locataire,
    Value<double>? loyerHc,
    Value<double>? chargesLocatives,
    Value<double>? depotGarantie,
    Value<DateTime?>? dateDebutBail,
    Value<DateTime?>? dateFinBail,
    Value<String?>? modeGestion,
    Value<double>? fraisGestion,
    Value<double>? taxeFonciere,
    Value<double>? assurancePno,
    Value<double>? chargesCopropriete,
    Value<double>? travauxEntretien,
    Value<double>? vacanceLocative,
    Value<String?>? note,
    Value<bool>? aUnCredit,
    Value<double>? montantCredit,
    Value<double>? tauxCreditPct,
    Value<double>? mensualiteCredit,
    Value<int>? dureeCreditMois,
    Value<double>? capitalRestantDu,
    Value<double>? assuranceEmprunteur,
    Value<DateTime>? createdAt,
  }) {
    return RentalsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      statut: statut ?? this.statut,
      typeBail: typeBail ?? this.typeBail,
      locataire: locataire ?? this.locataire,
      loyerHc: loyerHc ?? this.loyerHc,
      chargesLocatives: chargesLocatives ?? this.chargesLocatives,
      depotGarantie: depotGarantie ?? this.depotGarantie,
      dateDebutBail: dateDebutBail ?? this.dateDebutBail,
      dateFinBail: dateFinBail ?? this.dateFinBail,
      modeGestion: modeGestion ?? this.modeGestion,
      fraisGestion: fraisGestion ?? this.fraisGestion,
      taxeFonciere: taxeFonciere ?? this.taxeFonciere,
      assurancePno: assurancePno ?? this.assurancePno,
      chargesCopropriete: chargesCopropriete ?? this.chargesCopropriete,
      travauxEntretien: travauxEntretien ?? this.travauxEntretien,
      vacanceLocative: vacanceLocative ?? this.vacanceLocative,
      note: note ?? this.note,
      aUnCredit: aUnCredit ?? this.aUnCredit,
      montantCredit: montantCredit ?? this.montantCredit,
      tauxCreditPct: tauxCreditPct ?? this.tauxCreditPct,
      mensualiteCredit: mensualiteCredit ?? this.mensualiteCredit,
      dureeCreditMois: dureeCreditMois ?? this.dureeCreditMois,
      capitalRestantDu: capitalRestantDu ?? this.capitalRestantDu,
      assuranceEmprunteur: assuranceEmprunteur ?? this.assuranceEmprunteur,
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
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (typeBail.present) {
      map['type_bail'] = Variable<String>(typeBail.value);
    }
    if (locataire.present) {
      map['locataire'] = Variable<String>(locataire.value);
    }
    if (loyerHc.present) {
      map['loyer_hc'] = Variable<double>(loyerHc.value);
    }
    if (chargesLocatives.present) {
      map['charges_locatives'] = Variable<double>(chargesLocatives.value);
    }
    if (depotGarantie.present) {
      map['depot_garantie'] = Variable<double>(depotGarantie.value);
    }
    if (dateDebutBail.present) {
      map['date_debut_bail'] = Variable<DateTime>(dateDebutBail.value);
    }
    if (dateFinBail.present) {
      map['date_fin_bail'] = Variable<DateTime>(dateFinBail.value);
    }
    if (modeGestion.present) {
      map['mode_gestion'] = Variable<String>(modeGestion.value);
    }
    if (fraisGestion.present) {
      map['frais_gestion'] = Variable<double>(fraisGestion.value);
    }
    if (taxeFonciere.present) {
      map['taxe_fonciere'] = Variable<double>(taxeFonciere.value);
    }
    if (assurancePno.present) {
      map['assurance_pno'] = Variable<double>(assurancePno.value);
    }
    if (chargesCopropriete.present) {
      map['charges_copropriete'] = Variable<double>(chargesCopropriete.value);
    }
    if (travauxEntretien.present) {
      map['travaux_entretien'] = Variable<double>(travauxEntretien.value);
    }
    if (vacanceLocative.present) {
      map['vacance_locative'] = Variable<double>(vacanceLocative.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (aUnCredit.present) {
      map['a_un_credit'] = Variable<bool>(aUnCredit.value);
    }
    if (montantCredit.present) {
      map['montant_credit'] = Variable<double>(montantCredit.value);
    }
    if (tauxCreditPct.present) {
      map['taux_credit_pct'] = Variable<double>(tauxCreditPct.value);
    }
    if (mensualiteCredit.present) {
      map['mensualite_credit'] = Variable<double>(mensualiteCredit.value);
    }
    if (dureeCreditMois.present) {
      map['duree_credit_mois'] = Variable<int>(dureeCreditMois.value);
    }
    if (capitalRestantDu.present) {
      map['capital_restant_du'] = Variable<double>(capitalRestantDu.value);
    }
    if (assuranceEmprunteur.present) {
      map['assurance_emprunteur'] = Variable<double>(assuranceEmprunteur.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RentalsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('statut: $statut, ')
          ..write('typeBail: $typeBail, ')
          ..write('locataire: $locataire, ')
          ..write('loyerHc: $loyerHc, ')
          ..write('chargesLocatives: $chargesLocatives, ')
          ..write('depotGarantie: $depotGarantie, ')
          ..write('dateDebutBail: $dateDebutBail, ')
          ..write('dateFinBail: $dateFinBail, ')
          ..write('modeGestion: $modeGestion, ')
          ..write('fraisGestion: $fraisGestion, ')
          ..write('taxeFonciere: $taxeFonciere, ')
          ..write('assurancePno: $assurancePno, ')
          ..write('chargesCopropriete: $chargesCopropriete, ')
          ..write('travauxEntretien: $travauxEntretien, ')
          ..write('vacanceLocative: $vacanceLocative, ')
          ..write('note: $note, ')
          ..write('aUnCredit: $aUnCredit, ')
          ..write('montantCredit: $montantCredit, ')
          ..write('tauxCreditPct: $tauxCreditPct, ')
          ..write('mensualiteCredit: $mensualiteCredit, ')
          ..write('dureeCreditMois: $dureeCreditMois, ')
          ..write('capitalRestantDu: $capitalRestantDu, ')
          ..write('assuranceEmprunteur: $assuranceEmprunteur, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DocumentsTable extends Documents
    with TableInfo<$DocumentsTable, AssetDocument> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentsTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES assets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    label,
    fileName,
    filePath,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'documents';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetDocument> instance, {
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
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetDocument map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetDocument(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DocumentsTable createAlias(String alias) {
    return $DocumentsTable(attachedDatabase, alias);
  }
}

class AssetDocument extends DataClass implements Insertable<AssetDocument> {
  final int id;
  final int assetId;
  final String label;
  final String fileName;
  final String filePath;
  final String? note;
  final DateTime createdAt;
  const AssetDocument({
    required this.id,
    required this.assetId,
    required this.label,
    required this.fileName,
    required this.filePath,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    map['label'] = Variable<String>(label);
    map['file_name'] = Variable<String>(fileName);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DocumentsCompanion toCompanion(bool nullToAbsent) {
    return DocumentsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      label: Value(label),
      fileName: Value(fileName),
      filePath: Value(filePath),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory AssetDocument.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetDocument(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      label: serializer.fromJson<String>(json['label']),
      fileName: serializer.fromJson<String>(json['fileName']),
      filePath: serializer.fromJson<String>(json['filePath']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'label': serializer.toJson<String>(label),
      'fileName': serializer.toJson<String>(fileName),
      'filePath': serializer.toJson<String>(filePath),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AssetDocument copyWith({
    int? id,
    int? assetId,
    String? label,
    String? fileName,
    String? filePath,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => AssetDocument(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    label: label ?? this.label,
    fileName: fileName ?? this.fileName,
    filePath: filePath ?? this.filePath,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  AssetDocument copyWithCompanion(DocumentsCompanion data) {
    return AssetDocument(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      label: data.label.present ? data.label.value : this.label,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetDocument(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('label: $label, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, assetId, label, fileName, filePath, note, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetDocument &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.label == this.label &&
          other.fileName == this.fileName &&
          other.filePath == this.filePath &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class DocumentsCompanion extends UpdateCompanion<AssetDocument> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<String> label;
  final Value<String> fileName;
  final Value<String> filePath;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const DocumentsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.label = const Value.absent(),
    this.fileName = const Value.absent(),
    this.filePath = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  DocumentsCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    required String label,
    required String fileName,
    required String filePath,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : assetId = Value(assetId),
       label = Value(label),
       fileName = Value(fileName),
       filePath = Value(filePath);
  static Insertable<AssetDocument> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<String>? label,
    Expression<String>? fileName,
    Expression<String>? filePath,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (label != null) 'label': label,
      if (fileName != null) 'file_name': fileName,
      if (filePath != null) 'file_path': filePath,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  DocumentsCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<String>? label,
    Value<String>? fileName,
    Value<String>? filePath,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return DocumentsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      label: label ?? this.label,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      note: note ?? this.note,
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
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('label: $label, ')
          ..write('fileName: $fileName, ')
          ..write('filePath: $filePath, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StartupDetailsTable extends StartupDetails
    with TableInfo<$StartupDetailsTable, StartupDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StartupDetailsTable(this.attachedDatabase, [this._alias]);
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
      'UNIQUE REFERENCES assets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeTitreMeta = const VerificationMeta(
    'typeTitre',
  );
  @override
  late final GeneratedColumn<String> typeTitre = GeneratedColumn<String>(
    'type_titre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categorieMeta = const VerificationMeta(
    'categorie',
  );
  @override
  late final GeneratedColumn<String> categorie = GeneratedColumn<String>(
    'categorie',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantiteMeta = const VerificationMeta(
    'quantite',
  );
  @override
  late final GeneratedColumn<double> quantite = GeneratedColumn<double>(
    'quantite',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _prixEntreeMeta = const VerificationMeta(
    'prixEntree',
  );
  @override
  late final GeneratedColumn<double> prixEntree = GeneratedColumn<double>(
    'prix_entree',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _fraisMeta = const VerificationMeta('frais');
  @override
  late final GeneratedColumn<double> frais = GeneratedColumn<double>(
    'frais',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateInvestissementMeta =
      const VerificationMeta('dateInvestissement');
  @override
  late final GeneratedColumn<DateTime> dateInvestissement =
      GeneratedColumn<DateTime>(
        'date_investissement',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _stadeMeta = const VerificationMeta('stade');
  @override
  late final GeneratedColumn<String> stade = GeneratedColumn<String>(
    'stade',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _prixActuelMeta = const VerificationMeta(
    'prixActuel',
  );
  @override
  late final GeneratedColumn<double> prixActuel = GeneratedColumn<double>(
    'prix_actuel',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dateValorisationMeta = const VerificationMeta(
    'dateValorisation',
  );
  @override
  late final GeneratedColumn<DateTime> dateValorisation =
      GeneratedColumn<DateTime>(
        'date_valorisation',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _valorisationEntrepriseMeta =
      const VerificationMeta('valorisationEntreprise');
  @override
  late final GeneratedColumn<double> valorisationEntreprise =
      GeneratedColumn<double>(
        'valorisation_entreprise',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _statutMeta = const VerificationMeta('statut');
  @override
  late final GeneratedColumn<String> statut = GeneratedColumn<String>(
    'statut',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en_portefeuille'),
  );
  static const VerificationMeta _exitDateMeta = const VerificationMeta(
    'exitDate',
  );
  @override
  late final GeneratedColumn<DateTime> exitDate = GeneratedColumn<DateTime>(
    'exit_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exitProduitMeta = const VerificationMeta(
    'exitProduit',
  );
  @override
  late final GeneratedColumn<double> exitProduit = GeneratedColumn<double>(
    'exit_produit',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _exitModeMeta = const VerificationMeta(
    'exitMode',
  );
  @override
  late final GeneratedColumn<String> exitMode = GeneratedColumn<String>(
    'exit_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    typeTitre,
    categorie,
    quantite,
    prixEntree,
    frais,
    dateInvestissement,
    stade,
    prixActuel,
    dateValorisation,
    valorisationEntreprise,
    statut,
    exitDate,
    exitProduit,
    exitMode,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'startup_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<StartupDetail> instance, {
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
    if (data.containsKey('type_titre')) {
      context.handle(
        _typeTitreMeta,
        typeTitre.isAcceptableOrUnknown(data['type_titre']!, _typeTitreMeta),
      );
    }
    if (data.containsKey('categorie')) {
      context.handle(
        _categorieMeta,
        categorie.isAcceptableOrUnknown(data['categorie']!, _categorieMeta),
      );
    }
    if (data.containsKey('quantite')) {
      context.handle(
        _quantiteMeta,
        quantite.isAcceptableOrUnknown(data['quantite']!, _quantiteMeta),
      );
    }
    if (data.containsKey('prix_entree')) {
      context.handle(
        _prixEntreeMeta,
        prixEntree.isAcceptableOrUnknown(data['prix_entree']!, _prixEntreeMeta),
      );
    }
    if (data.containsKey('frais')) {
      context.handle(
        _fraisMeta,
        frais.isAcceptableOrUnknown(data['frais']!, _fraisMeta),
      );
    }
    if (data.containsKey('date_investissement')) {
      context.handle(
        _dateInvestissementMeta,
        dateInvestissement.isAcceptableOrUnknown(
          data['date_investissement']!,
          _dateInvestissementMeta,
        ),
      );
    }
    if (data.containsKey('stade')) {
      context.handle(
        _stadeMeta,
        stade.isAcceptableOrUnknown(data['stade']!, _stadeMeta),
      );
    }
    if (data.containsKey('prix_actuel')) {
      context.handle(
        _prixActuelMeta,
        prixActuel.isAcceptableOrUnknown(data['prix_actuel']!, _prixActuelMeta),
      );
    }
    if (data.containsKey('date_valorisation')) {
      context.handle(
        _dateValorisationMeta,
        dateValorisation.isAcceptableOrUnknown(
          data['date_valorisation']!,
          _dateValorisationMeta,
        ),
      );
    }
    if (data.containsKey('valorisation_entreprise')) {
      context.handle(
        _valorisationEntrepriseMeta,
        valorisationEntreprise.isAcceptableOrUnknown(
          data['valorisation_entreprise']!,
          _valorisationEntrepriseMeta,
        ),
      );
    }
    if (data.containsKey('statut')) {
      context.handle(
        _statutMeta,
        statut.isAcceptableOrUnknown(data['statut']!, _statutMeta),
      );
    }
    if (data.containsKey('exit_date')) {
      context.handle(
        _exitDateMeta,
        exitDate.isAcceptableOrUnknown(data['exit_date']!, _exitDateMeta),
      );
    }
    if (data.containsKey('exit_produit')) {
      context.handle(
        _exitProduitMeta,
        exitProduit.isAcceptableOrUnknown(
          data['exit_produit']!,
          _exitProduitMeta,
        ),
      );
    }
    if (data.containsKey('exit_mode')) {
      context.handle(
        _exitModeMeta,
        exitMode.isAcceptableOrUnknown(data['exit_mode']!, _exitModeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StartupDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StartupDetail(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      typeTitre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_titre'],
      ),
      categorie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categorie'],
      ),
      quantite: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantite'],
      )!,
      prixEntree: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prix_entree'],
      )!,
      frais: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}frais'],
      )!,
      dateInvestissement: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_investissement'],
      ),
      stade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stade'],
      ),
      prixActuel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prix_actuel'],
      )!,
      dateValorisation: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_valorisation'],
      ),
      valorisationEntreprise: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valorisation_entreprise'],
      )!,
      statut: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statut'],
      )!,
      exitDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exit_date'],
      ),
      exitProduit: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}exit_produit'],
      )!,
      exitMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exit_mode'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StartupDetailsTable createAlias(String alias) {
    return $StartupDetailsTable(attachedDatabase, alias);
  }
}

class StartupDetail extends DataClass implements Insertable<StartupDetail> {
  final int id;
  final int assetId;

  /// actions | actions_preference | bsa | bsa_air | bspce |
  /// obligations_convertibles | safe | autre
  final String? typeTitre;

  /// Catégorie libre (ex. « Europe Multi-Stage », « Y Combinator Seed »).
  final String? categorie;
  final double quantite;
  final double prixEntree;
  final double frais;
  final DateTime? dateInvestissement;

  /// seed | serie_a | serie_b | serie_c | late_stage | autre
  final String? stade;

  /// Mise à jour MANUELLE (pas de cotation pour une startup).
  final double prixActuel;
  final DateTime? dateValorisation;
  final double valorisationEntreprise;

  /// en_portefeuille | sorti | radie
  final String statut;
  final DateTime? exitDate;
  final double exitProduit;

  /// acquisition | ipo | secondaire | liquidation | autre
  final String? exitMode;
  final String? note;
  final DateTime createdAt;
  const StartupDetail({
    required this.id,
    required this.assetId,
    this.typeTitre,
    this.categorie,
    required this.quantite,
    required this.prixEntree,
    required this.frais,
    this.dateInvestissement,
    this.stade,
    required this.prixActuel,
    this.dateValorisation,
    required this.valorisationEntreprise,
    required this.statut,
    this.exitDate,
    required this.exitProduit,
    this.exitMode,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    if (!nullToAbsent || typeTitre != null) {
      map['type_titre'] = Variable<String>(typeTitre);
    }
    if (!nullToAbsent || categorie != null) {
      map['categorie'] = Variable<String>(categorie);
    }
    map['quantite'] = Variable<double>(quantite);
    map['prix_entree'] = Variable<double>(prixEntree);
    map['frais'] = Variable<double>(frais);
    if (!nullToAbsent || dateInvestissement != null) {
      map['date_investissement'] = Variable<DateTime>(dateInvestissement);
    }
    if (!nullToAbsent || stade != null) {
      map['stade'] = Variable<String>(stade);
    }
    map['prix_actuel'] = Variable<double>(prixActuel);
    if (!nullToAbsent || dateValorisation != null) {
      map['date_valorisation'] = Variable<DateTime>(dateValorisation);
    }
    map['valorisation_entreprise'] = Variable<double>(valorisationEntreprise);
    map['statut'] = Variable<String>(statut);
    if (!nullToAbsent || exitDate != null) {
      map['exit_date'] = Variable<DateTime>(exitDate);
    }
    map['exit_produit'] = Variable<double>(exitProduit);
    if (!nullToAbsent || exitMode != null) {
      map['exit_mode'] = Variable<String>(exitMode);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StartupDetailsCompanion toCompanion(bool nullToAbsent) {
    return StartupDetailsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      typeTitre: typeTitre == null && nullToAbsent
          ? const Value.absent()
          : Value(typeTitre),
      categorie: categorie == null && nullToAbsent
          ? const Value.absent()
          : Value(categorie),
      quantite: Value(quantite),
      prixEntree: Value(prixEntree),
      frais: Value(frais),
      dateInvestissement: dateInvestissement == null && nullToAbsent
          ? const Value.absent()
          : Value(dateInvestissement),
      stade: stade == null && nullToAbsent
          ? const Value.absent()
          : Value(stade),
      prixActuel: Value(prixActuel),
      dateValorisation: dateValorisation == null && nullToAbsent
          ? const Value.absent()
          : Value(dateValorisation),
      valorisationEntreprise: Value(valorisationEntreprise),
      statut: Value(statut),
      exitDate: exitDate == null && nullToAbsent
          ? const Value.absent()
          : Value(exitDate),
      exitProduit: Value(exitProduit),
      exitMode: exitMode == null && nullToAbsent
          ? const Value.absent()
          : Value(exitMode),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory StartupDetail.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StartupDetail(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      typeTitre: serializer.fromJson<String?>(json['typeTitre']),
      categorie: serializer.fromJson<String?>(json['categorie']),
      quantite: serializer.fromJson<double>(json['quantite']),
      prixEntree: serializer.fromJson<double>(json['prixEntree']),
      frais: serializer.fromJson<double>(json['frais']),
      dateInvestissement: serializer.fromJson<DateTime?>(
        json['dateInvestissement'],
      ),
      stade: serializer.fromJson<String?>(json['stade']),
      prixActuel: serializer.fromJson<double>(json['prixActuel']),
      dateValorisation: serializer.fromJson<DateTime?>(
        json['dateValorisation'],
      ),
      valorisationEntreprise: serializer.fromJson<double>(
        json['valorisationEntreprise'],
      ),
      statut: serializer.fromJson<String>(json['statut']),
      exitDate: serializer.fromJson<DateTime?>(json['exitDate']),
      exitProduit: serializer.fromJson<double>(json['exitProduit']),
      exitMode: serializer.fromJson<String?>(json['exitMode']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'typeTitre': serializer.toJson<String?>(typeTitre),
      'categorie': serializer.toJson<String?>(categorie),
      'quantite': serializer.toJson<double>(quantite),
      'prixEntree': serializer.toJson<double>(prixEntree),
      'frais': serializer.toJson<double>(frais),
      'dateInvestissement': serializer.toJson<DateTime?>(dateInvestissement),
      'stade': serializer.toJson<String?>(stade),
      'prixActuel': serializer.toJson<double>(prixActuel),
      'dateValorisation': serializer.toJson<DateTime?>(dateValorisation),
      'valorisationEntreprise': serializer.toJson<double>(
        valorisationEntreprise,
      ),
      'statut': serializer.toJson<String>(statut),
      'exitDate': serializer.toJson<DateTime?>(exitDate),
      'exitProduit': serializer.toJson<double>(exitProduit),
      'exitMode': serializer.toJson<String?>(exitMode),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StartupDetail copyWith({
    int? id,
    int? assetId,
    Value<String?> typeTitre = const Value.absent(),
    Value<String?> categorie = const Value.absent(),
    double? quantite,
    double? prixEntree,
    double? frais,
    Value<DateTime?> dateInvestissement = const Value.absent(),
    Value<String?> stade = const Value.absent(),
    double? prixActuel,
    Value<DateTime?> dateValorisation = const Value.absent(),
    double? valorisationEntreprise,
    String? statut,
    Value<DateTime?> exitDate = const Value.absent(),
    double? exitProduit,
    Value<String?> exitMode = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => StartupDetail(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    typeTitre: typeTitre.present ? typeTitre.value : this.typeTitre,
    categorie: categorie.present ? categorie.value : this.categorie,
    quantite: quantite ?? this.quantite,
    prixEntree: prixEntree ?? this.prixEntree,
    frais: frais ?? this.frais,
    dateInvestissement: dateInvestissement.present
        ? dateInvestissement.value
        : this.dateInvestissement,
    stade: stade.present ? stade.value : this.stade,
    prixActuel: prixActuel ?? this.prixActuel,
    dateValorisation: dateValorisation.present
        ? dateValorisation.value
        : this.dateValorisation,
    valorisationEntreprise:
        valorisationEntreprise ?? this.valorisationEntreprise,
    statut: statut ?? this.statut,
    exitDate: exitDate.present ? exitDate.value : this.exitDate,
    exitProduit: exitProduit ?? this.exitProduit,
    exitMode: exitMode.present ? exitMode.value : this.exitMode,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  StartupDetail copyWithCompanion(StartupDetailsCompanion data) {
    return StartupDetail(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      typeTitre: data.typeTitre.present ? data.typeTitre.value : this.typeTitre,
      categorie: data.categorie.present ? data.categorie.value : this.categorie,
      quantite: data.quantite.present ? data.quantite.value : this.quantite,
      prixEntree: data.prixEntree.present
          ? data.prixEntree.value
          : this.prixEntree,
      frais: data.frais.present ? data.frais.value : this.frais,
      dateInvestissement: data.dateInvestissement.present
          ? data.dateInvestissement.value
          : this.dateInvestissement,
      stade: data.stade.present ? data.stade.value : this.stade,
      prixActuel: data.prixActuel.present
          ? data.prixActuel.value
          : this.prixActuel,
      dateValorisation: data.dateValorisation.present
          ? data.dateValorisation.value
          : this.dateValorisation,
      valorisationEntreprise: data.valorisationEntreprise.present
          ? data.valorisationEntreprise.value
          : this.valorisationEntreprise,
      statut: data.statut.present ? data.statut.value : this.statut,
      exitDate: data.exitDate.present ? data.exitDate.value : this.exitDate,
      exitProduit: data.exitProduit.present
          ? data.exitProduit.value
          : this.exitProduit,
      exitMode: data.exitMode.present ? data.exitMode.value : this.exitMode,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StartupDetail(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('typeTitre: $typeTitre, ')
          ..write('categorie: $categorie, ')
          ..write('quantite: $quantite, ')
          ..write('prixEntree: $prixEntree, ')
          ..write('frais: $frais, ')
          ..write('dateInvestissement: $dateInvestissement, ')
          ..write('stade: $stade, ')
          ..write('prixActuel: $prixActuel, ')
          ..write('dateValorisation: $dateValorisation, ')
          ..write('valorisationEntreprise: $valorisationEntreprise, ')
          ..write('statut: $statut, ')
          ..write('exitDate: $exitDate, ')
          ..write('exitProduit: $exitProduit, ')
          ..write('exitMode: $exitMode, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetId,
    typeTitre,
    categorie,
    quantite,
    prixEntree,
    frais,
    dateInvestissement,
    stade,
    prixActuel,
    dateValorisation,
    valorisationEntreprise,
    statut,
    exitDate,
    exitProduit,
    exitMode,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StartupDetail &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.typeTitre == this.typeTitre &&
          other.categorie == this.categorie &&
          other.quantite == this.quantite &&
          other.prixEntree == this.prixEntree &&
          other.frais == this.frais &&
          other.dateInvestissement == this.dateInvestissement &&
          other.stade == this.stade &&
          other.prixActuel == this.prixActuel &&
          other.dateValorisation == this.dateValorisation &&
          other.valorisationEntreprise == this.valorisationEntreprise &&
          other.statut == this.statut &&
          other.exitDate == this.exitDate &&
          other.exitProduit == this.exitProduit &&
          other.exitMode == this.exitMode &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class StartupDetailsCompanion extends UpdateCompanion<StartupDetail> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<String?> typeTitre;
  final Value<String?> categorie;
  final Value<double> quantite;
  final Value<double> prixEntree;
  final Value<double> frais;
  final Value<DateTime?> dateInvestissement;
  final Value<String?> stade;
  final Value<double> prixActuel;
  final Value<DateTime?> dateValorisation;
  final Value<double> valorisationEntreprise;
  final Value<String> statut;
  final Value<DateTime?> exitDate;
  final Value<double> exitProduit;
  final Value<String?> exitMode;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const StartupDetailsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.typeTitre = const Value.absent(),
    this.categorie = const Value.absent(),
    this.quantite = const Value.absent(),
    this.prixEntree = const Value.absent(),
    this.frais = const Value.absent(),
    this.dateInvestissement = const Value.absent(),
    this.stade = const Value.absent(),
    this.prixActuel = const Value.absent(),
    this.dateValorisation = const Value.absent(),
    this.valorisationEntreprise = const Value.absent(),
    this.statut = const Value.absent(),
    this.exitDate = const Value.absent(),
    this.exitProduit = const Value.absent(),
    this.exitMode = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StartupDetailsCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    this.typeTitre = const Value.absent(),
    this.categorie = const Value.absent(),
    this.quantite = const Value.absent(),
    this.prixEntree = const Value.absent(),
    this.frais = const Value.absent(),
    this.dateInvestissement = const Value.absent(),
    this.stade = const Value.absent(),
    this.prixActuel = const Value.absent(),
    this.dateValorisation = const Value.absent(),
    this.valorisationEntreprise = const Value.absent(),
    this.statut = const Value.absent(),
    this.exitDate = const Value.absent(),
    this.exitProduit = const Value.absent(),
    this.exitMode = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : assetId = Value(assetId);
  static Insertable<StartupDetail> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<String>? typeTitre,
    Expression<String>? categorie,
    Expression<double>? quantite,
    Expression<double>? prixEntree,
    Expression<double>? frais,
    Expression<DateTime>? dateInvestissement,
    Expression<String>? stade,
    Expression<double>? prixActuel,
    Expression<DateTime>? dateValorisation,
    Expression<double>? valorisationEntreprise,
    Expression<String>? statut,
    Expression<DateTime>? exitDate,
    Expression<double>? exitProduit,
    Expression<String>? exitMode,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (typeTitre != null) 'type_titre': typeTitre,
      if (categorie != null) 'categorie': categorie,
      if (quantite != null) 'quantite': quantite,
      if (prixEntree != null) 'prix_entree': prixEntree,
      if (frais != null) 'frais': frais,
      if (dateInvestissement != null) 'date_investissement': dateInvestissement,
      if (stade != null) 'stade': stade,
      if (prixActuel != null) 'prix_actuel': prixActuel,
      if (dateValorisation != null) 'date_valorisation': dateValorisation,
      if (valorisationEntreprise != null)
        'valorisation_entreprise': valorisationEntreprise,
      if (statut != null) 'statut': statut,
      if (exitDate != null) 'exit_date': exitDate,
      if (exitProduit != null) 'exit_produit': exitProduit,
      if (exitMode != null) 'exit_mode': exitMode,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StartupDetailsCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<String?>? typeTitre,
    Value<String?>? categorie,
    Value<double>? quantite,
    Value<double>? prixEntree,
    Value<double>? frais,
    Value<DateTime?>? dateInvestissement,
    Value<String?>? stade,
    Value<double>? prixActuel,
    Value<DateTime?>? dateValorisation,
    Value<double>? valorisationEntreprise,
    Value<String>? statut,
    Value<DateTime?>? exitDate,
    Value<double>? exitProduit,
    Value<String?>? exitMode,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return StartupDetailsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      typeTitre: typeTitre ?? this.typeTitre,
      categorie: categorie ?? this.categorie,
      quantite: quantite ?? this.quantite,
      prixEntree: prixEntree ?? this.prixEntree,
      frais: frais ?? this.frais,
      dateInvestissement: dateInvestissement ?? this.dateInvestissement,
      stade: stade ?? this.stade,
      prixActuel: prixActuel ?? this.prixActuel,
      dateValorisation: dateValorisation ?? this.dateValorisation,
      valorisationEntreprise:
          valorisationEntreprise ?? this.valorisationEntreprise,
      statut: statut ?? this.statut,
      exitDate: exitDate ?? this.exitDate,
      exitProduit: exitProduit ?? this.exitProduit,
      exitMode: exitMode ?? this.exitMode,
      note: note ?? this.note,
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
    if (typeTitre.present) {
      map['type_titre'] = Variable<String>(typeTitre.value);
    }
    if (categorie.present) {
      map['categorie'] = Variable<String>(categorie.value);
    }
    if (quantite.present) {
      map['quantite'] = Variable<double>(quantite.value);
    }
    if (prixEntree.present) {
      map['prix_entree'] = Variable<double>(prixEntree.value);
    }
    if (frais.present) {
      map['frais'] = Variable<double>(frais.value);
    }
    if (dateInvestissement.present) {
      map['date_investissement'] = Variable<DateTime>(dateInvestissement.value);
    }
    if (stade.present) {
      map['stade'] = Variable<String>(stade.value);
    }
    if (prixActuel.present) {
      map['prix_actuel'] = Variable<double>(prixActuel.value);
    }
    if (dateValorisation.present) {
      map['date_valorisation'] = Variable<DateTime>(dateValorisation.value);
    }
    if (valorisationEntreprise.present) {
      map['valorisation_entreprise'] = Variable<double>(
        valorisationEntreprise.value,
      );
    }
    if (statut.present) {
      map['statut'] = Variable<String>(statut.value);
    }
    if (exitDate.present) {
      map['exit_date'] = Variable<DateTime>(exitDate.value);
    }
    if (exitProduit.present) {
      map['exit_produit'] = Variable<double>(exitProduit.value);
    }
    if (exitMode.present) {
      map['exit_mode'] = Variable<String>(exitMode.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StartupDetailsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('typeTitre: $typeTitre, ')
          ..write('categorie: $categorie, ')
          ..write('quantite: $quantite, ')
          ..write('prixEntree: $prixEntree, ')
          ..write('frais: $frais, ')
          ..write('dateInvestissement: $dateInvestissement, ')
          ..write('stade: $stade, ')
          ..write('prixActuel: $prixActuel, ')
          ..write('dateValorisation: $dateValorisation, ')
          ..write('valorisationEntreprise: $valorisationEntreprise, ')
          ..write('statut: $statut, ')
          ..write('exitDate: $exitDate, ')
          ..write('exitProduit: $exitProduit, ')
          ..write('exitMode: $exitMode, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FundingRoundsTable extends FundingRounds
    with TableInfo<$FundingRoundsTable, FundingRound> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FundingRoundsTable(this.attachedDatabase, [this._alias]);
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
      'REFERENCES assets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _montantLeveMeta = const VerificationMeta(
    'montantLeve',
  );
  @override
  late final GeneratedColumn<double> montantLeve = GeneratedColumn<double>(
    'montant_leve',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _valorisationPostMoneyMeta =
      const VerificationMeta('valorisationPostMoney');
  @override
  late final GeneratedColumn<double> valorisationPostMoney =
      GeneratedColumn<double>(
        'valorisation_post_money',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _prixParActionMeta = const VerificationMeta(
    'prixParAction',
  );
  @override
  late final GeneratedColumn<double> prixParAction = GeneratedColumn<double>(
    'prix_par_action',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    assetId,
    date,
    montantLeve,
    valorisationPostMoney,
    prixParAction,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'funding_rounds';
  @override
  VerificationContext validateIntegrity(
    Insertable<FundingRound> instance, {
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
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('montant_leve')) {
      context.handle(
        _montantLeveMeta,
        montantLeve.isAcceptableOrUnknown(
          data['montant_leve']!,
          _montantLeveMeta,
        ),
      );
    }
    if (data.containsKey('valorisation_post_money')) {
      context.handle(
        _valorisationPostMoneyMeta,
        valorisationPostMoney.isAcceptableOrUnknown(
          data['valorisation_post_money']!,
          _valorisationPostMoneyMeta,
        ),
      );
    }
    if (data.containsKey('prix_par_action')) {
      context.handle(
        _prixParActionMeta,
        prixParAction.isAcceptableOrUnknown(
          data['prix_par_action']!,
          _prixParActionMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FundingRound map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FundingRound(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}asset_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      ),
      montantLeve: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}montant_leve'],
      )!,
      valorisationPostMoney: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}valorisation_post_money'],
      )!,
      prixParAction: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}prix_par_action'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $FundingRoundsTable createAlias(String alias) {
    return $FundingRoundsTable(attachedDatabase, alias);
  }
}

class FundingRound extends DataClass implements Insertable<FundingRound> {
  final int id;
  final int assetId;
  final DateTime? date;
  final double montantLeve;
  final double valorisationPostMoney;
  final double prixParAction;
  final String? note;
  const FundingRound({
    required this.id,
    required this.assetId,
    this.date,
    required this.montantLeve,
    required this.valorisationPostMoney,
    required this.prixParAction,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['asset_id'] = Variable<int>(assetId);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date);
    }
    map['montant_leve'] = Variable<double>(montantLeve);
    map['valorisation_post_money'] = Variable<double>(valorisationPostMoney);
    map['prix_par_action'] = Variable<double>(prixParAction);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  FundingRoundsCompanion toCompanion(bool nullToAbsent) {
    return FundingRoundsCompanion(
      id: Value(id),
      assetId: Value(assetId),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      montantLeve: Value(montantLeve),
      valorisationPostMoney: Value(valorisationPostMoney),
      prixParAction: Value(prixParAction),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory FundingRound.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FundingRound(
      id: serializer.fromJson<int>(json['id']),
      assetId: serializer.fromJson<int>(json['assetId']),
      date: serializer.fromJson<DateTime?>(json['date']),
      montantLeve: serializer.fromJson<double>(json['montantLeve']),
      valorisationPostMoney: serializer.fromJson<double>(
        json['valorisationPostMoney'],
      ),
      prixParAction: serializer.fromJson<double>(json['prixParAction']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'assetId': serializer.toJson<int>(assetId),
      'date': serializer.toJson<DateTime?>(date),
      'montantLeve': serializer.toJson<double>(montantLeve),
      'valorisationPostMoney': serializer.toJson<double>(valorisationPostMoney),
      'prixParAction': serializer.toJson<double>(prixParAction),
      'note': serializer.toJson<String?>(note),
    };
  }

  FundingRound copyWith({
    int? id,
    int? assetId,
    Value<DateTime?> date = const Value.absent(),
    double? montantLeve,
    double? valorisationPostMoney,
    double? prixParAction,
    Value<String?> note = const Value.absent(),
  }) => FundingRound(
    id: id ?? this.id,
    assetId: assetId ?? this.assetId,
    date: date.present ? date.value : this.date,
    montantLeve: montantLeve ?? this.montantLeve,
    valorisationPostMoney: valorisationPostMoney ?? this.valorisationPostMoney,
    prixParAction: prixParAction ?? this.prixParAction,
    note: note.present ? note.value : this.note,
  );
  FundingRound copyWithCompanion(FundingRoundsCompanion data) {
    return FundingRound(
      id: data.id.present ? data.id.value : this.id,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      date: data.date.present ? data.date.value : this.date,
      montantLeve: data.montantLeve.present
          ? data.montantLeve.value
          : this.montantLeve,
      valorisationPostMoney: data.valorisationPostMoney.present
          ? data.valorisationPostMoney.value
          : this.valorisationPostMoney,
      prixParAction: data.prixParAction.present
          ? data.prixParAction.value
          : this.prixParAction,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FundingRound(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('date: $date, ')
          ..write('montantLeve: $montantLeve, ')
          ..write('valorisationPostMoney: $valorisationPostMoney, ')
          ..write('prixParAction: $prixParAction, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    assetId,
    date,
    montantLeve,
    valorisationPostMoney,
    prixParAction,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FundingRound &&
          other.id == this.id &&
          other.assetId == this.assetId &&
          other.date == this.date &&
          other.montantLeve == this.montantLeve &&
          other.valorisationPostMoney == this.valorisationPostMoney &&
          other.prixParAction == this.prixParAction &&
          other.note == this.note);
}

class FundingRoundsCompanion extends UpdateCompanion<FundingRound> {
  final Value<int> id;
  final Value<int> assetId;
  final Value<DateTime?> date;
  final Value<double> montantLeve;
  final Value<double> valorisationPostMoney;
  final Value<double> prixParAction;
  final Value<String?> note;
  const FundingRoundsCompanion({
    this.id = const Value.absent(),
    this.assetId = const Value.absent(),
    this.date = const Value.absent(),
    this.montantLeve = const Value.absent(),
    this.valorisationPostMoney = const Value.absent(),
    this.prixParAction = const Value.absent(),
    this.note = const Value.absent(),
  });
  FundingRoundsCompanion.insert({
    this.id = const Value.absent(),
    required int assetId,
    this.date = const Value.absent(),
    this.montantLeve = const Value.absent(),
    this.valorisationPostMoney = const Value.absent(),
    this.prixParAction = const Value.absent(),
    this.note = const Value.absent(),
  }) : assetId = Value(assetId);
  static Insertable<FundingRound> custom({
    Expression<int>? id,
    Expression<int>? assetId,
    Expression<DateTime>? date,
    Expression<double>? montantLeve,
    Expression<double>? valorisationPostMoney,
    Expression<double>? prixParAction,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (assetId != null) 'asset_id': assetId,
      if (date != null) 'date': date,
      if (montantLeve != null) 'montant_leve': montantLeve,
      if (valorisationPostMoney != null)
        'valorisation_post_money': valorisationPostMoney,
      if (prixParAction != null) 'prix_par_action': prixParAction,
      if (note != null) 'note': note,
    });
  }

  FundingRoundsCompanion copyWith({
    Value<int>? id,
    Value<int>? assetId,
    Value<DateTime?>? date,
    Value<double>? montantLeve,
    Value<double>? valorisationPostMoney,
    Value<double>? prixParAction,
    Value<String?>? note,
  }) {
    return FundingRoundsCompanion(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      date: date ?? this.date,
      montantLeve: montantLeve ?? this.montantLeve,
      valorisationPostMoney:
          valorisationPostMoney ?? this.valorisationPostMoney,
      prixParAction: prixParAction ?? this.prixParAction,
      note: note ?? this.note,
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
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (montantLeve.present) {
      map['montant_leve'] = Variable<double>(montantLeve.value);
    }
    if (valorisationPostMoney.present) {
      map['valorisation_post_money'] = Variable<double>(
        valorisationPostMoney.value,
      );
    }
    if (prixParAction.present) {
      map['prix_par_action'] = Variable<double>(prixParAction.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FundingRoundsCompanion(')
          ..write('id: $id, ')
          ..write('assetId: $assetId, ')
          ..write('date: $date, ')
          ..write('montantLeve: $montantLeve, ')
          ..write('valorisationPostMoney: $valorisationPostMoney, ')
          ..write('prixParAction: $prixParAction, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, Preference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preference> instance, {
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
  Preference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preference(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class Preference extends DataClass implements Insertable<Preference> {
  final String key;
  final String value;
  const Preference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory Preference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Preference copyWith({String? key, String? value}) =>
      Preference(key: key ?? this.key, value: value ?? this.value);
  Preference copyWithCompanion(PreferencesCompanion data) {
    return Preference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preference(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Preference &&
          other.key == this.key &&
          other.value == this.value);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Preference> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return PreferencesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
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
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $PositionsTable positions = $PositionsTable(this);
  late final $PriceCacheTable priceCache = $PriceCacheTable(this);
  late final $SnapshotsTable snapshots = $SnapshotsTable(this);
  late final $RentalsTable rentals = $RentalsTable(this);
  late final $DocumentsTable documents = $DocumentsTable(this);
  late final $StartupDetailsTable startupDetails = $StartupDetailsTable(this);
  late final $FundingRoundsTable fundingRounds = $FundingRoundsTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    assets,
    positions,
    priceCache,
    snapshots,
    rentals,
    documents,
    startupDetails,
    fundingRounds,
    preferences,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('positions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rentals', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('documents', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('startup_details', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('funding_rounds', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AssetsTableCreateCompanionBuilder = AssetsCompanion Function({
  Value<int> id,
  required String name,
  required String type,
  Value<double> value,
  Value<String> currency,
  Value<String?> institution,
  Value<String?> note,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});
typedef $$AssetsTableUpdateCompanionBuilder = AssetsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<double> value,
  Value<String> currency,
  Value<String?> institution,
  Value<String?> note,
  Value<int> sortOrder,
  Value<DateTime> createdAt,
});

final class $$AssetsTableReferences
    extends BaseReferences<_$AppDatabase, $AssetsTable, Asset> {
  $$AssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PositionsTable, List<Position>>
  _positionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.positions,
    aliasName: 'assets__id__positions__asset_id',
  );

  $$PositionsTableProcessedTableManager get positionsRefs {
    final manager = $$PositionsTableTableManager(
      $_db,
      $_db.positions,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_positionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RentalsTable, List<Rental>> _rentalsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rentals,
    aliasName: 'assets__id__rentals__asset_id',
  );

  $$RentalsTableProcessedTableManager get rentalsRefs {
    final manager = $$RentalsTableTableManager(
      $_db,
      $_db.rentals,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_rentalsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentsTable, List<AssetDocument>>
  _documentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.documents,
    aliasName: 'assets__id__documents__asset_id',
  );

  $$DocumentsTableProcessedTableManager get documentsRefs {
    final manager = $$DocumentsTableTableManager(
      $_db,
      $_db.documents,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_documentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StartupDetailsTable, List<StartupDetail>>
  _startupDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.startupDetails,
    aliasName: 'assets__id__startup_details__asset_id',
  );

  $$StartupDetailsTableProcessedTableManager get startupDetailsRefs {
    final manager = $$StartupDetailsTableTableManager(
      $_db,
      $_db.startupDetails,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_startupDetailsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$FundingRoundsTable, List<FundingRound>>
  _fundingRoundsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.fundingRounds,
    aliasName: 'assets__id__funding_rounds__asset_id',
  );

  $$FundingRoundsTableProcessedTableManager get fundingRoundsRefs {
    final manager = $$FundingRoundsTableTableManager(
      $_db,
      $_db.fundingRounds,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_fundingRoundsRefsTable($_db));
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> positionsRefs(
    Expression<bool> Function($$PositionsTableFilterComposer f) f,
  ) {
    final $$PositionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.positions,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PositionsTableFilterComposer(
            $db: $db,
            $table: $db.positions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> rentalsRefs(
    Expression<bool> Function($$RentalsTableFilterComposer f) f,
  ) {
    final $$RentalsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rentals,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentalsTableFilterComposer(
            $db: $db,
            $table: $db.rentals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentsRefs(
    Expression<bool> Function($$DocumentsTableFilterComposer f) f,
  ) {
    final $$DocumentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableFilterComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> startupDetailsRefs(
    Expression<bool> Function($$StartupDetailsTableFilterComposer f) f,
  ) {
    final $$StartupDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.startupDetails,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StartupDetailsTableFilterComposer(
            $db: $db,
            $table: $db.startupDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> fundingRoundsRefs(
    Expression<bool> Function($$FundingRoundsTableFilterComposer f) f,
  ) {
    final $$FundingRoundsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fundingRounds,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundingRoundsTableFilterComposer(
            $db: $db,
            $table: $db.fundingRounds,
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get institution => $composableBuilder(
    column: $table.institution,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> positionsRefs<T extends Object>(
    Expression<T> Function($$PositionsTableAnnotationComposer a) f,
  ) {
    final $$PositionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.positions,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PositionsTableAnnotationComposer(
            $db: $db,
            $table: $db.positions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> rentalsRefs<T extends Object>(
    Expression<T> Function($$RentalsTableAnnotationComposer a) f,
  ) {
    final $$RentalsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rentals,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RentalsTableAnnotationComposer(
            $db: $db,
            $table: $db.rentals,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentsRefs<T extends Object>(
    Expression<T> Function($$DocumentsTableAnnotationComposer a) f,
  ) {
    final $$DocumentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documents,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentsTableAnnotationComposer(
            $db: $db,
            $table: $db.documents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> startupDetailsRefs<T extends Object>(
    Expression<T> Function($$StartupDetailsTableAnnotationComposer a) f,
  ) {
    final $$StartupDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.startupDetails,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StartupDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.startupDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> fundingRoundsRefs<T extends Object>(
    Expression<T> Function($$FundingRoundsTableAnnotationComposer a) f,
  ) {
    final $$FundingRoundsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.fundingRounds,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FundingRoundsTableAnnotationComposer(
            $db: $db,
            $table: $db.fundingRounds,
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
          Asset,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (Asset, $$AssetsTableReferences),
          Asset,
          PrefetchHooks Function({
            bool positionsRefs,
            bool rentalsRefs,
            bool documentsRefs,
            bool startupDetailsRefs,
            bool fundingRoundsRefs,
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
                Value<String> type = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> institution = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                name: name,
                type: type,
                value: value,
                currency: currency,
                institution: institution,
                note: note,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                Value<double> value = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> institution = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                name: name,
                type: type,
                value: value,
                currency: currency,
                institution: institution,
                note: note,
                sortOrder: sortOrder,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AssetsTable, Asset>(table),
                  $$AssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                positionsRefs = false,
                rentalsRefs = false,
                documentsRefs = false,
                startupDetailsRefs = false,
                fundingRoundsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (positionsRefs) db.positions,
                    if (rentalsRefs) db.rentals,
                    if (documentsRefs) db.documents,
                    if (startupDetailsRefs) db.startupDetails,
                    if (fundingRoundsRefs) db.fundingRounds,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (positionsRefs)
                        await $_getPrefetchedDataByColumns<
                          Asset,
                          $AssetsTable,
                          Position,
                          $PositionsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._positionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).positionsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                      if (rentalsRefs)
                        await $_getPrefetchedDataByColumns<
                          Asset,
                          $AssetsTable,
                          Rental,
                          $RentalsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._rentalsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).rentalsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                      if (documentsRefs)
                        await $_getPrefetchedDataByColumns<
                          Asset,
                          $AssetsTable,
                          AssetDocument,
                          $DocumentsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._documentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).documentsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                      if (startupDetailsRefs)
                        await $_getPrefetchedDataByColumns<
                          Asset,
                          $AssetsTable,
                          StartupDetail,
                          $StartupDetailsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._startupDetailsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).startupDetailsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'asset_id',
                          typedResults: items,
                        ),
                      if (fundingRoundsRefs)
                        await $_getPrefetchedDataByColumns<
                          Asset,
                          $AssetsTable,
                          FundingRound,
                          $FundingRoundsTable
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._fundingRoundsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).fundingRoundsRefs,
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
      Asset,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (Asset, $$AssetsTableReferences),
      Asset,
      PrefetchHooks Function({
        bool positionsRefs,
        bool rentalsRefs,
        bool documentsRefs,
        bool startupDetailsRefs,
        bool fundingRoundsRefs,
      })
    >;
typedef $$PositionsTableCreateCompanionBuilder = PositionsCompanion Function({
  Value<int> id,
  required int assetId,
  required String symbol,
  required String name,
  required double quantity,
  required double unitCost,
  Value<String?> assetClass,
  Value<String?> sector,
  Value<String?> region,
  Value<double> fees,
  Value<DateTime> createdAt,
});
typedef $$PositionsTableUpdateCompanionBuilder = PositionsCompanion Function({
  Value<int> id,
  Value<int> assetId,
  Value<String> symbol,
  Value<String> name,
  Value<double> quantity,
  Value<double> unitCost,
  Value<String?> assetClass,
  Value<String?> sector,
  Value<String?> region,
  Value<double> fees,
  Value<DateTime> createdAt,
});

final class $$PositionsTableReferences
    extends BaseReferences<_$AppDatabase, $PositionsTable, Position> {
  $$PositionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('positions__asset_id__assets__id');

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

class $$PositionsTableFilterComposer
    extends Composer<_$AppDatabase, $PositionsTable> {
  $$PositionsTableFilterComposer({
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

  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetClass => $composableBuilder(
    column: $table.assetClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$PositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PositionsTable> {
  $$PositionsTableOrderingComposer({
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

  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetClass => $composableBuilder(
    column: $table.assetClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sector => $composableBuilder(
    column: $table.sector,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
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
}

class $$PositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PositionsTable> {
  $$PositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<String> get assetClass => $composableBuilder(
    column: $table.assetClass,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sector =>
      $composableBuilder(column: $table.sector, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<double> get fees =>
      $composableBuilder(column: $table.fees, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
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
}

class $$PositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PositionsTable,
          Position,
          $$PositionsTableFilterComposer,
          $$PositionsTableOrderingComposer,
          $$PositionsTableAnnotationComposer,
          $$PositionsTableCreateCompanionBuilder,
          $$PositionsTableUpdateCompanionBuilder,
          (Position, $$PositionsTableReferences),
          Position,
          PrefetchHooks Function({bool assetId})
        > {
  $$PositionsTableTableManager(_$AppDatabase db, $PositionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<String> symbol = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> unitCost = const Value.absent(),
                Value<String?> assetClass = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<double> fees = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PositionsCompanion(
                id: id,
                assetId: assetId,
                symbol: symbol,
                name: name,
                quantity: quantity,
                unitCost: unitCost,
                assetClass: assetClass,
                sector: sector,
                region: region,
                fees: fees,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                required String symbol,
                required String name,
                required double quantity,
                required double unitCost,
                Value<String?> assetClass = const Value.absent(),
                Value<String?> sector = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<double> fees = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PositionsCompanion.insert(
                id: id,
                assetId: assetId,
                symbol: symbol,
                name: name,
                quantity: quantity,
                unitCost: unitCost,
                assetClass: assetClass,
                sector: sector,
                region: region,
                fees: fees,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PositionsTable, Position>(table),
                  $$PositionsTableReferences(db, table, e),
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
                        referencedTable: $$PositionsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$PositionsTableReferences
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

typedef $$PositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PositionsTable,
      Position,
      $$PositionsTableFilterComposer,
      $$PositionsTableOrderingComposer,
      $$PositionsTableAnnotationComposer,
      $$PositionsTableCreateCompanionBuilder,
      $$PositionsTableUpdateCompanionBuilder,
      (Position, $$PositionsTableReferences),
      Position,
      PrefetchHooks Function({bool assetId})
    >;
typedef $$PriceCacheTableCreateCompanionBuilder = PriceCacheCompanion Function({
  required String symbol,
  required double price,
  required String currency,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$PriceCacheTableUpdateCompanionBuilder = PriceCacheCompanion Function({
  Value<String> symbol,
  Value<double> price,
  Value<String> currency,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$PriceCacheTableFilterComposer
    extends Composer<_$AppDatabase, $PriceCacheTable> {
  $$PriceCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceCacheTable> {
  $$PriceCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get symbol => $composableBuilder(
    column: $table.symbol,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceCacheTable> {
  $$PriceCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PriceCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceCacheTable,
          MarketPrice,
          $$PriceCacheTableFilterComposer,
          $$PriceCacheTableOrderingComposer,
          $$PriceCacheTableAnnotationComposer,
          $$PriceCacheTableCreateCompanionBuilder,
          $$PriceCacheTableUpdateCompanionBuilder,
          (
            MarketPrice,
            BaseReferences<_$AppDatabase, $PriceCacheTable, MarketPrice>,
          ),
          MarketPrice,
          PrefetchHooks Function()
        > {
  $$PriceCacheTableTableManager(_$AppDatabase db, $PriceCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> symbol = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PriceCacheCompanion(
                symbol: symbol,
                price: price,
                currency: currency,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String symbol,
                required double price,
                required String currency,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => PriceCacheCompanion.insert(
                symbol: symbol,
                price: price,
                currency: currency,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PriceCacheTable, MarketPrice>(table),
                  BaseReferences<_$AppDatabase, $PriceCacheTable, MarketPrice>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceCacheTable,
      MarketPrice,
      $$PriceCacheTableFilterComposer,
      $$PriceCacheTableOrderingComposer,
      $$PriceCacheTableAnnotationComposer,
      $$PriceCacheTableCreateCompanionBuilder,
      $$PriceCacheTableUpdateCompanionBuilder,
      (
        MarketPrice,
        BaseReferences<_$AppDatabase, $PriceCacheTable, MarketPrice>,
      ),
      MarketPrice,
      PrefetchHooks Function()
    >;
typedef $$SnapshotsTableCreateCompanionBuilder = SnapshotsCompanion Function({
  Value<int> id,
  required DateTime date,
  required double netWorth,
});
typedef $$SnapshotsTableUpdateCompanionBuilder = SnapshotsCompanion Function({
  Value<int> id,
  Value<DateTime> date,
  Value<double> netWorth,
});

class $$SnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get netWorth => $composableBuilder(
    column: $table.netWorth,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get netWorth => $composableBuilder(
    column: $table.netWorth,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SnapshotsTable> {
  $$SnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get netWorth =>
      $composableBuilder(column: $table.netWorth, builder: (column) => column);
}

class $$SnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SnapshotsTable,
          NetWorthSnapshot,
          $$SnapshotsTableFilterComposer,
          $$SnapshotsTableOrderingComposer,
          $$SnapshotsTableAnnotationComposer,
          $$SnapshotsTableCreateCompanionBuilder,
          $$SnapshotsTableUpdateCompanionBuilder,
          (
            NetWorthSnapshot,
            BaseReferences<_$AppDatabase, $SnapshotsTable, NetWorthSnapshot>,
          ),
          NetWorthSnapshot,
          PrefetchHooks Function()
        > {
  $$SnapshotsTableTableManager(_$AppDatabase db, $SnapshotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> netWorth = const Value.absent(),
          }) => SnapshotsCompanion(id: id, date: date, netWorth: netWorth),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime date,
                required double netWorth,
              }) => SnapshotsCompanion.insert(
                id: id,
                date: date,
                netWorth: netWorth,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SnapshotsTable, NetWorthSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SnapshotsTable,
                    NetWorthSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SnapshotsTable,
      NetWorthSnapshot,
      $$SnapshotsTableFilterComposer,
      $$SnapshotsTableOrderingComposer,
      $$SnapshotsTableAnnotationComposer,
      $$SnapshotsTableCreateCompanionBuilder,
      $$SnapshotsTableUpdateCompanionBuilder,
      (
        NetWorthSnapshot,
        BaseReferences<_$AppDatabase, $SnapshotsTable, NetWorthSnapshot>,
      ),
      NetWorthSnapshot,
      PrefetchHooks Function()
    >;
typedef $$RentalsTableCreateCompanionBuilder = RentalsCompanion Function({
  Value<int> id,
  required int assetId,
  Value<String> statut,
  Value<String?> typeBail,
  Value<String?> locataire,
  Value<double> loyerHc,
  Value<double> chargesLocatives,
  Value<double> depotGarantie,
  Value<DateTime?> dateDebutBail,
  Value<DateTime?> dateFinBail,
  Value<String?> modeGestion,
  Value<double> fraisGestion,
  Value<double> taxeFonciere,
  Value<double> assurancePno,
  Value<double> chargesCopropriete,
  Value<double> travauxEntretien,
  Value<double> vacanceLocative,
  Value<String?> note,
  Value<bool> aUnCredit,
  Value<double> montantCredit,
  Value<double> tauxCreditPct,
  Value<double> mensualiteCredit,
  Value<int> dureeCreditMois,
  Value<double> capitalRestantDu,
  Value<double> assuranceEmprunteur,
  Value<DateTime> createdAt,
});
typedef $$RentalsTableUpdateCompanionBuilder = RentalsCompanion Function({
  Value<int> id,
  Value<int> assetId,
  Value<String> statut,
  Value<String?> typeBail,
  Value<String?> locataire,
  Value<double> loyerHc,
  Value<double> chargesLocatives,
  Value<double> depotGarantie,
  Value<DateTime?> dateDebutBail,
  Value<DateTime?> dateFinBail,
  Value<String?> modeGestion,
  Value<double> fraisGestion,
  Value<double> taxeFonciere,
  Value<double> assurancePno,
  Value<double> chargesCopropriete,
  Value<double> travauxEntretien,
  Value<double> vacanceLocative,
  Value<String?> note,
  Value<bool> aUnCredit,
  Value<double> montantCredit,
  Value<double> tauxCreditPct,
  Value<double> mensualiteCredit,
  Value<int> dureeCreditMois,
  Value<double> capitalRestantDu,
  Value<double> assuranceEmprunteur,
  Value<DateTime> createdAt,
});

final class $$RentalsTableReferences
    extends BaseReferences<_$AppDatabase, $RentalsTable, Rental> {
  $$RentalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('rentals__asset_id__assets__id');

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

class $$RentalsTableFilterComposer
    extends Composer<_$AppDatabase, $RentalsTable> {
  $$RentalsTableFilterComposer({
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

  ColumnFilters<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get typeBail => $composableBuilder(
    column: $table.typeBail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locataire => $composableBuilder(
    column: $table.locataire,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get loyerHc => $composableBuilder(
    column: $table.loyerHc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chargesLocatives => $composableBuilder(
    column: $table.chargesLocatives,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get depotGarantie => $composableBuilder(
    column: $table.depotGarantie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateDebutBail => $composableBuilder(
    column: $table.dateDebutBail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateFinBail => $composableBuilder(
    column: $table.dateFinBail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get modeGestion => $composableBuilder(
    column: $table.modeGestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fraisGestion => $composableBuilder(
    column: $table.fraisGestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxeFonciere => $composableBuilder(
    column: $table.taxeFonciere,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get assurancePno => $composableBuilder(
    column: $table.assurancePno,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chargesCopropriete => $composableBuilder(
    column: $table.chargesCopropriete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get travauxEntretien => $composableBuilder(
    column: $table.travauxEntretien,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vacanceLocative => $composableBuilder(
    column: $table.vacanceLocative,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get aUnCredit => $composableBuilder(
    column: $table.aUnCredit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantCredit => $composableBuilder(
    column: $table.montantCredit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tauxCreditPct => $composableBuilder(
    column: $table.tauxCreditPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get mensualiteCredit => $composableBuilder(
    column: $table.mensualiteCredit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dureeCreditMois => $composableBuilder(
    column: $table.dureeCreditMois,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get capitalRestantDu => $composableBuilder(
    column: $table.capitalRestantDu,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get assuranceEmprunteur => $composableBuilder(
    column: $table.assuranceEmprunteur,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$RentalsTableOrderingComposer
    extends Composer<_$AppDatabase, $RentalsTable> {
  $$RentalsTableOrderingComposer({
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

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get typeBail => $composableBuilder(
    column: $table.typeBail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locataire => $composableBuilder(
    column: $table.locataire,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get loyerHc => $composableBuilder(
    column: $table.loyerHc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chargesLocatives => $composableBuilder(
    column: $table.chargesLocatives,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get depotGarantie => $composableBuilder(
    column: $table.depotGarantie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateDebutBail => $composableBuilder(
    column: $table.dateDebutBail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateFinBail => $composableBuilder(
    column: $table.dateFinBail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get modeGestion => $composableBuilder(
    column: $table.modeGestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fraisGestion => $composableBuilder(
    column: $table.fraisGestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxeFonciere => $composableBuilder(
    column: $table.taxeFonciere,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get assurancePno => $composableBuilder(
    column: $table.assurancePno,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chargesCopropriete => $composableBuilder(
    column: $table.chargesCopropriete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get travauxEntretien => $composableBuilder(
    column: $table.travauxEntretien,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vacanceLocative => $composableBuilder(
    column: $table.vacanceLocative,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get aUnCredit => $composableBuilder(
    column: $table.aUnCredit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantCredit => $composableBuilder(
    column: $table.montantCredit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tauxCreditPct => $composableBuilder(
    column: $table.tauxCreditPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get mensualiteCredit => $composableBuilder(
    column: $table.mensualiteCredit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dureeCreditMois => $composableBuilder(
    column: $table.dureeCreditMois,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get capitalRestantDu => $composableBuilder(
    column: $table.capitalRestantDu,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get assuranceEmprunteur => $composableBuilder(
    column: $table.assuranceEmprunteur,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
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
}

class $$RentalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RentalsTable> {
  $$RentalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<String> get typeBail =>
      $composableBuilder(column: $table.typeBail, builder: (column) => column);

  GeneratedColumn<String> get locataire =>
      $composableBuilder(column: $table.locataire, builder: (column) => column);

  GeneratedColumn<double> get loyerHc =>
      $composableBuilder(column: $table.loyerHc, builder: (column) => column);

  GeneratedColumn<double> get chargesLocatives => $composableBuilder(
    column: $table.chargesLocatives,
    builder: (column) => column,
  );

  GeneratedColumn<double> get depotGarantie => $composableBuilder(
    column: $table.depotGarantie,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateDebutBail => $composableBuilder(
    column: $table.dateDebutBail,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateFinBail => $composableBuilder(
    column: $table.dateFinBail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get modeGestion => $composableBuilder(
    column: $table.modeGestion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fraisGestion => $composableBuilder(
    column: $table.fraisGestion,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxeFonciere => $composableBuilder(
    column: $table.taxeFonciere,
    builder: (column) => column,
  );

  GeneratedColumn<double> get assurancePno => $composableBuilder(
    column: $table.assurancePno,
    builder: (column) => column,
  );

  GeneratedColumn<double> get chargesCopropriete => $composableBuilder(
    column: $table.chargesCopropriete,
    builder: (column) => column,
  );

  GeneratedColumn<double> get travauxEntretien => $composableBuilder(
    column: $table.travauxEntretien,
    builder: (column) => column,
  );

  GeneratedColumn<double> get vacanceLocative => $composableBuilder(
    column: $table.vacanceLocative,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get aUnCredit =>
      $composableBuilder(column: $table.aUnCredit, builder: (column) => column);

  GeneratedColumn<double> get montantCredit => $composableBuilder(
    column: $table.montantCredit,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tauxCreditPct => $composableBuilder(
    column: $table.tauxCreditPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get mensualiteCredit => $composableBuilder(
    column: $table.mensualiteCredit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dureeCreditMois => $composableBuilder(
    column: $table.dureeCreditMois,
    builder: (column) => column,
  );

  GeneratedColumn<double> get capitalRestantDu => $composableBuilder(
    column: $table.capitalRestantDu,
    builder: (column) => column,
  );

  GeneratedColumn<double> get assuranceEmprunteur => $composableBuilder(
    column: $table.assuranceEmprunteur,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
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
}

class $$RentalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RentalsTable,
          Rental,
          $$RentalsTableFilterComposer,
          $$RentalsTableOrderingComposer,
          $$RentalsTableAnnotationComposer,
          $$RentalsTableCreateCompanionBuilder,
          $$RentalsTableUpdateCompanionBuilder,
          (Rental, $$RentalsTableReferences),
          Rental,
          PrefetchHooks Function({bool assetId})
        > {
  $$RentalsTableTableManager(_$AppDatabase db, $RentalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RentalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RentalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RentalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<String> statut = const Value.absent(),
                Value<String?> typeBail = const Value.absent(),
                Value<String?> locataire = const Value.absent(),
                Value<double> loyerHc = const Value.absent(),
                Value<double> chargesLocatives = const Value.absent(),
                Value<double> depotGarantie = const Value.absent(),
                Value<DateTime?> dateDebutBail = const Value.absent(),
                Value<DateTime?> dateFinBail = const Value.absent(),
                Value<String?> modeGestion = const Value.absent(),
                Value<double> fraisGestion = const Value.absent(),
                Value<double> taxeFonciere = const Value.absent(),
                Value<double> assurancePno = const Value.absent(),
                Value<double> chargesCopropriete = const Value.absent(),
                Value<double> travauxEntretien = const Value.absent(),
                Value<double> vacanceLocative = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> aUnCredit = const Value.absent(),
                Value<double> montantCredit = const Value.absent(),
                Value<double> tauxCreditPct = const Value.absent(),
                Value<double> mensualiteCredit = const Value.absent(),
                Value<int> dureeCreditMois = const Value.absent(),
                Value<double> capitalRestantDu = const Value.absent(),
                Value<double> assuranceEmprunteur = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RentalsCompanion(
                id: id,
                assetId: assetId,
                statut: statut,
                typeBail: typeBail,
                locataire: locataire,
                loyerHc: loyerHc,
                chargesLocatives: chargesLocatives,
                depotGarantie: depotGarantie,
                dateDebutBail: dateDebutBail,
                dateFinBail: dateFinBail,
                modeGestion: modeGestion,
                fraisGestion: fraisGestion,
                taxeFonciere: taxeFonciere,
                assurancePno: assurancePno,
                chargesCopropriete: chargesCopropriete,
                travauxEntretien: travauxEntretien,
                vacanceLocative: vacanceLocative,
                note: note,
                aUnCredit: aUnCredit,
                montantCredit: montantCredit,
                tauxCreditPct: tauxCreditPct,
                mensualiteCredit: mensualiteCredit,
                dureeCreditMois: dureeCreditMois,
                capitalRestantDu: capitalRestantDu,
                assuranceEmprunteur: assuranceEmprunteur,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                Value<String> statut = const Value.absent(),
                Value<String?> typeBail = const Value.absent(),
                Value<String?> locataire = const Value.absent(),
                Value<double> loyerHc = const Value.absent(),
                Value<double> chargesLocatives = const Value.absent(),
                Value<double> depotGarantie = const Value.absent(),
                Value<DateTime?> dateDebutBail = const Value.absent(),
                Value<DateTime?> dateFinBail = const Value.absent(),
                Value<String?> modeGestion = const Value.absent(),
                Value<double> fraisGestion = const Value.absent(),
                Value<double> taxeFonciere = const Value.absent(),
                Value<double> assurancePno = const Value.absent(),
                Value<double> chargesCopropriete = const Value.absent(),
                Value<double> travauxEntretien = const Value.absent(),
                Value<double> vacanceLocative = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> aUnCredit = const Value.absent(),
                Value<double> montantCredit = const Value.absent(),
                Value<double> tauxCreditPct = const Value.absent(),
                Value<double> mensualiteCredit = const Value.absent(),
                Value<int> dureeCreditMois = const Value.absent(),
                Value<double> capitalRestantDu = const Value.absent(),
                Value<double> assuranceEmprunteur = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RentalsCompanion.insert(
                id: id,
                assetId: assetId,
                statut: statut,
                typeBail: typeBail,
                locataire: locataire,
                loyerHc: loyerHc,
                chargesLocatives: chargesLocatives,
                depotGarantie: depotGarantie,
                dateDebutBail: dateDebutBail,
                dateFinBail: dateFinBail,
                modeGestion: modeGestion,
                fraisGestion: fraisGestion,
                taxeFonciere: taxeFonciere,
                assurancePno: assurancePno,
                chargesCopropriete: chargesCopropriete,
                travauxEntretien: travauxEntretien,
                vacanceLocative: vacanceLocative,
                note: note,
                aUnCredit: aUnCredit,
                montantCredit: montantCredit,
                tauxCreditPct: tauxCreditPct,
                mensualiteCredit: mensualiteCredit,
                dureeCreditMois: dureeCreditMois,
                capitalRestantDu: capitalRestantDu,
                assuranceEmprunteur: assuranceEmprunteur,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RentalsTable, Rental>(table),
                  $$RentalsTableReferences(db, table, e),
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
                        referencedTable: $$RentalsTableReferences._assetIdTable(
                          db,
                        ),
                        referencedColumn: $$RentalsTableReferences
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

typedef $$RentalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RentalsTable,
      Rental,
      $$RentalsTableFilterComposer,
      $$RentalsTableOrderingComposer,
      $$RentalsTableAnnotationComposer,
      $$RentalsTableCreateCompanionBuilder,
      $$RentalsTableUpdateCompanionBuilder,
      (Rental, $$RentalsTableReferences),
      Rental,
      PrefetchHooks Function({bool assetId})
    >;
typedef $$DocumentsTableCreateCompanionBuilder = DocumentsCompanion Function({
  Value<int> id,
  required int assetId,
  required String label,
  required String fileName,
  required String filePath,
  Value<String?> note,
  Value<DateTime> createdAt,
});
typedef $$DocumentsTableUpdateCompanionBuilder = DocumentsCompanion Function({
  Value<int> id,
  Value<int> assetId,
  Value<String> label,
  Value<String> fileName,
  Value<String> filePath,
  Value<String?> note,
  Value<DateTime> createdAt,
});

final class $$DocumentsTableReferences
    extends BaseReferences<_$AppDatabase, $DocumentsTable, AssetDocument> {
  $$DocumentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('documents__asset_id__assets__id');

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

class $$DocumentsTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$DocumentsTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
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
}

class $$DocumentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentsTable> {
  $$DocumentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
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
}

class $$DocumentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentsTable,
          AssetDocument,
          $$DocumentsTableFilterComposer,
          $$DocumentsTableOrderingComposer,
          $$DocumentsTableAnnotationComposer,
          $$DocumentsTableCreateCompanionBuilder,
          $$DocumentsTableUpdateCompanionBuilder,
          (AssetDocument, $$DocumentsTableReferences),
          AssetDocument,
          PrefetchHooks Function({bool assetId})
        > {
  $$DocumentsTableTableManager(_$AppDatabase db, $DocumentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DocumentsCompanion(
                id: id,
                assetId: assetId,
                label: label,
                fileName: fileName,
                filePath: filePath,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                required String label,
                required String fileName,
                required String filePath,
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => DocumentsCompanion.insert(
                id: id,
                assetId: assetId,
                label: label,
                fileName: fileName,
                filePath: filePath,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DocumentsTable, AssetDocument>(table),
                  $$DocumentsTableReferences(db, table, e),
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
                        referencedTable: $$DocumentsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$DocumentsTableReferences
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

typedef $$DocumentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentsTable,
      AssetDocument,
      $$DocumentsTableFilterComposer,
      $$DocumentsTableOrderingComposer,
      $$DocumentsTableAnnotationComposer,
      $$DocumentsTableCreateCompanionBuilder,
      $$DocumentsTableUpdateCompanionBuilder,
      (AssetDocument, $$DocumentsTableReferences),
      AssetDocument,
      PrefetchHooks Function({bool assetId})
    >;
typedef $$StartupDetailsTableCreateCompanionBuilder =
    StartupDetailsCompanion Function({
      Value<int> id,
      required int assetId,
      Value<String?> typeTitre,
      Value<String?> categorie,
      Value<double> quantite,
      Value<double> prixEntree,
      Value<double> frais,
      Value<DateTime?> dateInvestissement,
      Value<String?> stade,
      Value<double> prixActuel,
      Value<DateTime?> dateValorisation,
      Value<double> valorisationEntreprise,
      Value<String> statut,
      Value<DateTime?> exitDate,
      Value<double> exitProduit,
      Value<String?> exitMode,
      Value<String?> note,
      Value<DateTime> createdAt,
    });
typedef $$StartupDetailsTableUpdateCompanionBuilder =
    StartupDetailsCompanion Function({
      Value<int> id,
      Value<int> assetId,
      Value<String?> typeTitre,
      Value<String?> categorie,
      Value<double> quantite,
      Value<double> prixEntree,
      Value<double> frais,
      Value<DateTime?> dateInvestissement,
      Value<String?> stade,
      Value<double> prixActuel,
      Value<DateTime?> dateValorisation,
      Value<double> valorisationEntreprise,
      Value<String> statut,
      Value<DateTime?> exitDate,
      Value<double> exitProduit,
      Value<String?> exitMode,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$StartupDetailsTableReferences
    extends BaseReferences<_$AppDatabase, $StartupDetailsTable, StartupDetail> {
  $$StartupDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('startup_details__asset_id__assets__id');

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

class $$StartupDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $StartupDetailsTable> {
  $$StartupDetailsTableFilterComposer({
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

  ColumnFilters<String> get typeTitre => $composableBuilder(
    column: $table.typeTitre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categorie => $composableBuilder(
    column: $table.categorie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prixEntree => $composableBuilder(
    column: $table.prixEntree,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get frais => $composableBuilder(
    column: $table.frais,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateInvestissement => $composableBuilder(
    column: $table.dateInvestissement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stade => $composableBuilder(
    column: $table.stade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prixActuel => $composableBuilder(
    column: $table.prixActuel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateValorisation => $composableBuilder(
    column: $table.dateValorisation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorisationEntreprise => $composableBuilder(
    column: $table.valorisationEntreprise,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exitDate => $composableBuilder(
    column: $table.exitDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get exitProduit => $composableBuilder(
    column: $table.exitProduit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exitMode => $composableBuilder(
    column: $table.exitMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

class $$StartupDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $StartupDetailsTable> {
  $$StartupDetailsTableOrderingComposer({
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

  ColumnOrderings<String> get typeTitre => $composableBuilder(
    column: $table.typeTitre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categorie => $composableBuilder(
    column: $table.categorie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantite => $composableBuilder(
    column: $table.quantite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prixEntree => $composableBuilder(
    column: $table.prixEntree,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get frais => $composableBuilder(
    column: $table.frais,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateInvestissement => $composableBuilder(
    column: $table.dateInvestissement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stade => $composableBuilder(
    column: $table.stade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prixActuel => $composableBuilder(
    column: $table.prixActuel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateValorisation => $composableBuilder(
    column: $table.dateValorisation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorisationEntreprise => $composableBuilder(
    column: $table.valorisationEntreprise,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statut => $composableBuilder(
    column: $table.statut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exitDate => $composableBuilder(
    column: $table.exitDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get exitProduit => $composableBuilder(
    column: $table.exitProduit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exitMode => $composableBuilder(
    column: $table.exitMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
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
}

class $$StartupDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StartupDetailsTable> {
  $$StartupDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get typeTitre =>
      $composableBuilder(column: $table.typeTitre, builder: (column) => column);

  GeneratedColumn<String> get categorie =>
      $composableBuilder(column: $table.categorie, builder: (column) => column);

  GeneratedColumn<double> get quantite =>
      $composableBuilder(column: $table.quantite, builder: (column) => column);

  GeneratedColumn<double> get prixEntree => $composableBuilder(
    column: $table.prixEntree,
    builder: (column) => column,
  );

  GeneratedColumn<double> get frais =>
      $composableBuilder(column: $table.frais, builder: (column) => column);

  GeneratedColumn<DateTime> get dateInvestissement => $composableBuilder(
    column: $table.dateInvestissement,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stade =>
      $composableBuilder(column: $table.stade, builder: (column) => column);

  GeneratedColumn<double> get prixActuel => $composableBuilder(
    column: $table.prixActuel,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateValorisation => $composableBuilder(
    column: $table.dateValorisation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorisationEntreprise => $composableBuilder(
    column: $table.valorisationEntreprise,
    builder: (column) => column,
  );

  GeneratedColumn<String> get statut =>
      $composableBuilder(column: $table.statut, builder: (column) => column);

  GeneratedColumn<DateTime> get exitDate =>
      $composableBuilder(column: $table.exitDate, builder: (column) => column);

  GeneratedColumn<double> get exitProduit => $composableBuilder(
    column: $table.exitProduit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exitMode =>
      $composableBuilder(column: $table.exitMode, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
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
}

class $$StartupDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StartupDetailsTable,
          StartupDetail,
          $$StartupDetailsTableFilterComposer,
          $$StartupDetailsTableOrderingComposer,
          $$StartupDetailsTableAnnotationComposer,
          $$StartupDetailsTableCreateCompanionBuilder,
          $$StartupDetailsTableUpdateCompanionBuilder,
          (StartupDetail, $$StartupDetailsTableReferences),
          StartupDetail,
          PrefetchHooks Function({bool assetId})
        > {
  $$StartupDetailsTableTableManager(
    _$AppDatabase db,
    $StartupDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StartupDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StartupDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StartupDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<String?> typeTitre = const Value.absent(),
                Value<String?> categorie = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<double> prixEntree = const Value.absent(),
                Value<double> frais = const Value.absent(),
                Value<DateTime?> dateInvestissement = const Value.absent(),
                Value<String?> stade = const Value.absent(),
                Value<double> prixActuel = const Value.absent(),
                Value<DateTime?> dateValorisation = const Value.absent(),
                Value<double> valorisationEntreprise = const Value.absent(),
                Value<String> statut = const Value.absent(),
                Value<DateTime?> exitDate = const Value.absent(),
                Value<double> exitProduit = const Value.absent(),
                Value<String?> exitMode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StartupDetailsCompanion(
                id: id,
                assetId: assetId,
                typeTitre: typeTitre,
                categorie: categorie,
                quantite: quantite,
                prixEntree: prixEntree,
                frais: frais,
                dateInvestissement: dateInvestissement,
                stade: stade,
                prixActuel: prixActuel,
                dateValorisation: dateValorisation,
                valorisationEntreprise: valorisationEntreprise,
                statut: statut,
                exitDate: exitDate,
                exitProduit: exitProduit,
                exitMode: exitMode,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                Value<String?> typeTitre = const Value.absent(),
                Value<String?> categorie = const Value.absent(),
                Value<double> quantite = const Value.absent(),
                Value<double> prixEntree = const Value.absent(),
                Value<double> frais = const Value.absent(),
                Value<DateTime?> dateInvestissement = const Value.absent(),
                Value<String?> stade = const Value.absent(),
                Value<double> prixActuel = const Value.absent(),
                Value<DateTime?> dateValorisation = const Value.absent(),
                Value<double> valorisationEntreprise = const Value.absent(),
                Value<String> statut = const Value.absent(),
                Value<DateTime?> exitDate = const Value.absent(),
                Value<double> exitProduit = const Value.absent(),
                Value<String?> exitMode = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StartupDetailsCompanion.insert(
                id: id,
                assetId: assetId,
                typeTitre: typeTitre,
                categorie: categorie,
                quantite: quantite,
                prixEntree: prixEntree,
                frais: frais,
                dateInvestissement: dateInvestissement,
                stade: stade,
                prixActuel: prixActuel,
                dateValorisation: dateValorisation,
                valorisationEntreprise: valorisationEntreprise,
                statut: statut,
                exitDate: exitDate,
                exitProduit: exitProduit,
                exitMode: exitMode,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StartupDetailsTable, StartupDetail>(table),
                  $$StartupDetailsTableReferences(db, table, e),
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
                        referencedTable: $$StartupDetailsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$StartupDetailsTableReferences
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

typedef $$StartupDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StartupDetailsTable,
      StartupDetail,
      $$StartupDetailsTableFilterComposer,
      $$StartupDetailsTableOrderingComposer,
      $$StartupDetailsTableAnnotationComposer,
      $$StartupDetailsTableCreateCompanionBuilder,
      $$StartupDetailsTableUpdateCompanionBuilder,
      (StartupDetail, $$StartupDetailsTableReferences),
      StartupDetail,
      PrefetchHooks Function({bool assetId})
    >;
typedef $$FundingRoundsTableCreateCompanionBuilder =
    FundingRoundsCompanion Function({
      Value<int> id,
      required int assetId,
      Value<DateTime?> date,
      Value<double> montantLeve,
      Value<double> valorisationPostMoney,
      Value<double> prixParAction,
      Value<String?> note,
    });
typedef $$FundingRoundsTableUpdateCompanionBuilder =
    FundingRoundsCompanion Function({
      Value<int> id,
      Value<int> assetId,
      Value<DateTime?> date,
      Value<double> montantLeve,
      Value<double> valorisationPostMoney,
      Value<double> prixParAction,
      Value<String?> note,
    });

final class $$FundingRoundsTableReferences
    extends BaseReferences<_$AppDatabase, $FundingRoundsTable, FundingRound> {
  $$FundingRoundsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) =>
      db.assets.createAlias('funding_rounds__asset_id__assets__id');

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

class $$FundingRoundsTableFilterComposer
    extends Composer<_$AppDatabase, $FundingRoundsTable> {
  $$FundingRoundsTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montantLeve => $composableBuilder(
    column: $table.montantLeve,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get valorisationPostMoney => $composableBuilder(
    column: $table.valorisationPostMoney,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get prixParAction => $composableBuilder(
    column: $table.prixParAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
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

class $$FundingRoundsTableOrderingComposer
    extends Composer<_$AppDatabase, $FundingRoundsTable> {
  $$FundingRoundsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montantLeve => $composableBuilder(
    column: $table.montantLeve,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get valorisationPostMoney => $composableBuilder(
    column: $table.valorisationPostMoney,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get prixParAction => $composableBuilder(
    column: $table.prixParAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
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

class $$FundingRoundsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FundingRoundsTable> {
  $$FundingRoundsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get montantLeve => $composableBuilder(
    column: $table.montantLeve,
    builder: (column) => column,
  );

  GeneratedColumn<double> get valorisationPostMoney => $composableBuilder(
    column: $table.valorisationPostMoney,
    builder: (column) => column,
  );

  GeneratedColumn<double> get prixParAction => $composableBuilder(
    column: $table.prixParAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

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

class $$FundingRoundsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FundingRoundsTable,
          FundingRound,
          $$FundingRoundsTableFilterComposer,
          $$FundingRoundsTableOrderingComposer,
          $$FundingRoundsTableAnnotationComposer,
          $$FundingRoundsTableCreateCompanionBuilder,
          $$FundingRoundsTableUpdateCompanionBuilder,
          (FundingRound, $$FundingRoundsTableReferences),
          FundingRound,
          PrefetchHooks Function({bool assetId})
        > {
  $$FundingRoundsTableTableManager(_$AppDatabase db, $FundingRoundsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FundingRoundsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FundingRoundsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FundingRoundsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> assetId = const Value.absent(),
                Value<DateTime?> date = const Value.absent(),
                Value<double> montantLeve = const Value.absent(),
                Value<double> valorisationPostMoney = const Value.absent(),
                Value<double> prixParAction = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => FundingRoundsCompanion(
                id: id,
                assetId: assetId,
                date: date,
                montantLeve: montantLeve,
                valorisationPostMoney: valorisationPostMoney,
                prixParAction: prixParAction,
                note: note,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int assetId,
                Value<DateTime?> date = const Value.absent(),
                Value<double> montantLeve = const Value.absent(),
                Value<double> valorisationPostMoney = const Value.absent(),
                Value<double> prixParAction = const Value.absent(),
                Value<String?> note = const Value.absent(),
              }) => FundingRoundsCompanion.insert(
                id: id,
                assetId: assetId,
                date: date,
                montantLeve: montantLeve,
                valorisationPostMoney: valorisationPostMoney,
                prixParAction: prixParAction,
                note: note,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FundingRoundsTable, FundingRound>(table),
                  $$FundingRoundsTableReferences(db, table, e),
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
                        referencedTable: $$FundingRoundsTableReferences
                            ._assetIdTable(db),
                        referencedColumn: $$FundingRoundsTableReferences
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

typedef $$FundingRoundsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FundingRoundsTable,
      FundingRound,
      $$FundingRoundsTableFilterComposer,
      $$FundingRoundsTableOrderingComposer,
      $$FundingRoundsTableAnnotationComposer,
      $$FundingRoundsTableCreateCompanionBuilder,
      $$FundingRoundsTableUpdateCompanionBuilder,
      (FundingRound, $$FundingRoundsTableReferences),
      FundingRound,
      PrefetchHooks Function({bool assetId})
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$PreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
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
}

class $$PreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
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
}

class $$PreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
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
}

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreferencesTable,
          Preference,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (
            Preference,
            BaseReferences<_$AppDatabase, $PreferencesTable, Preference>,
          ),
          Preference,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$AppDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => PreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferencesTable, Preference>(table),
                  BaseReferences<_$AppDatabase, $PreferencesTable, Preference>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreferencesTable,
      Preference,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (
        Preference,
        BaseReferences<_$AppDatabase, $PreferencesTable, Preference>,
      ),
      Preference,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$PositionsTableTableManager get positions =>
      $$PositionsTableTableManager(_db, _db.positions);
  $$PriceCacheTableTableManager get priceCache =>
      $$PriceCacheTableTableManager(_db, _db.priceCache);
  $$SnapshotsTableTableManager get snapshots =>
      $$SnapshotsTableTableManager(_db, _db.snapshots);
  $$RentalsTableTableManager get rentals =>
      $$RentalsTableTableManager(_db, _db.rentals);
  $$DocumentsTableTableManager get documents =>
      $$DocumentsTableTableManager(_db, _db.documents);
  $$StartupDetailsTableTableManager get startupDetails =>
      $$StartupDetailsTableTableManager(_db, _db.startupDetails);
  $$FundingRoundsTableTableManager get fundingRounds =>
      $$FundingRoundsTableTableManager(_db, _db.fundingRounds);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
}
