// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cabinet_database.dart';

// ignore_for_file: type=lint
class $MedicineRecordsTable extends MedicineRecords
    with TableInfo<$MedicineRecordsTable, MedicineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicineRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _strengthMilliMeta = const VerificationMeta(
    'strengthMilli',
  );
  @override
  late final GeneratedColumn<int> strengthMilli = GeneratedColumn<int>(
    'strength_milli',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _strengthUnitMeta = const VerificationMeta(
    'strengthUnit',
  );
  @override
  late final GeneratedColumn<String> strengthUnit = GeneratedColumn<String>(
    'strength_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dosageTextMeta = const VerificationMeta(
    'dosageText',
  );
  @override
  late final GeneratedColumn<String> dosageText = GeneratedColumn<String>(
    'dosage_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expirationYearMeta = const VerificationMeta(
    'expirationYear',
  );
  @override
  late final GeneratedColumn<int> expirationYear = GeneratedColumn<int>(
    'expiration_year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expirationMonthMeta = const VerificationMeta(
    'expirationMonth',
  );
  @override
  late final GeneratedColumn<int> expirationMonth = GeneratedColumn<int>(
    'expiration_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expirationDayMeta = const VerificationMeta(
    'expirationDay',
  );
  @override
  late final GeneratedColumn<int> expirationDay = GeneratedColumn<int>(
    'expiration_day',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batchNumberMeta = const VerificationMeta(
    'batchNumber',
  );
  @override
  late final GeneratedColumn<String> batchNumber = GeneratedColumn<String>(
    'batch_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMilliMeta = const VerificationMeta(
    'quantityMilli',
  );
  @override
  late final GeneratedColumn<int> quantityMilli = GeneratedColumn<int>(
    'quantity_milli',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityUnitMeta = const VerificationMeta(
    'quantityUnit',
  );
  @override
  late final GeneratedColumn<String> quantityUnit = GeneratedColumn<String>(
    'quantity_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keptForMeta = const VerificationMeta(
    'keptFor',
  );
  @override
  late final GeneratedColumn<String> keptFor = GeneratedColumn<String>(
    'kept_for',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMillisMeta = const VerificationMeta(
    'updatedAtMillis',
  );
  @override
  late final GeneratedColumn<int> updatedAtMillis = GeneratedColumn<int>(
    'updated_at_millis',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    strengthMilli,
    strengthUnit,
    dosageText,
    expirationYear,
    expirationMonth,
    expirationDay,
    batchNumber,
    quantityMilli,
    quantityUnit,
    keptFor,
    updatedAtMillis,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medicines';
  @override
  VerificationContext validateIntegrity(
    Insertable<MedicineRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('strength_milli')) {
      context.handle(
        _strengthMilliMeta,
        strengthMilli.isAcceptableOrUnknown(
          data['strength_milli']!,
          _strengthMilliMeta,
        ),
      );
    }
    if (data.containsKey('strength_unit')) {
      context.handle(
        _strengthUnitMeta,
        strengthUnit.isAcceptableOrUnknown(
          data['strength_unit']!,
          _strengthUnitMeta,
        ),
      );
    }
    if (data.containsKey('dosage_text')) {
      context.handle(
        _dosageTextMeta,
        dosageText.isAcceptableOrUnknown(data['dosage_text']!, _dosageTextMeta),
      );
    }
    if (data.containsKey('expiration_year')) {
      context.handle(
        _expirationYearMeta,
        expirationYear.isAcceptableOrUnknown(
          data['expiration_year']!,
          _expirationYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expirationYearMeta);
    }
    if (data.containsKey('expiration_month')) {
      context.handle(
        _expirationMonthMeta,
        expirationMonth.isAcceptableOrUnknown(
          data['expiration_month']!,
          _expirationMonthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expirationMonthMeta);
    }
    if (data.containsKey('expiration_day')) {
      context.handle(
        _expirationDayMeta,
        expirationDay.isAcceptableOrUnknown(
          data['expiration_day']!,
          _expirationDayMeta,
        ),
      );
    }
    if (data.containsKey('batch_number')) {
      context.handle(
        _batchNumberMeta,
        batchNumber.isAcceptableOrUnknown(
          data['batch_number']!,
          _batchNumberMeta,
        ),
      );
    }
    if (data.containsKey('quantity_milli')) {
      context.handle(
        _quantityMilliMeta,
        quantityMilli.isAcceptableOrUnknown(
          data['quantity_milli']!,
          _quantityMilliMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityMilliMeta);
    }
    if (data.containsKey('quantity_unit')) {
      context.handle(
        _quantityUnitMeta,
        quantityUnit.isAcceptableOrUnknown(
          data['quantity_unit']!,
          _quantityUnitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityUnitMeta);
    }
    if (data.containsKey('kept_for')) {
      context.handle(
        _keptForMeta,
        keptFor.isAcceptableOrUnknown(data['kept_for']!, _keptForMeta),
      );
    }
    if (data.containsKey('updated_at_millis')) {
      context.handle(
        _updatedAtMillisMeta,
        updatedAtMillis.isAcceptableOrUnknown(
          data['updated_at_millis']!,
          _updatedAtMillisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMillisMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicineRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      strengthMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}strength_milli'],
      ),
      strengthUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}strength_unit'],
      ),
      dosageText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage_text'],
      ),
      expirationYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expiration_year'],
      )!,
      expirationMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expiration_month'],
      )!,
      expirationDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expiration_day'],
      ),
      batchNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_number'],
      ),
      quantityMilli: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity_milli'],
      )!,
      quantityUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quantity_unit'],
      )!,
      keptFor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kept_for'],
      ),
      updatedAtMillis: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_millis'],
      )!,
    );
  }

  @override
  $MedicineRecordsTable createAlias(String alias) {
    return $MedicineRecordsTable(attachedDatabase, alias);
  }
}

class MedicineRow extends DataClass implements Insertable<MedicineRow> {
  final String id;
  final String name;
  final int? strengthMilli;
  final String? strengthUnit;
  final String? dosageText;
  final int expirationYear;
  final int expirationMonth;
  final int? expirationDay;
  final String? batchNumber;
  final int quantityMilli;
  final String quantityUnit;
  final String? keptFor;
  final int updatedAtMillis;
  const MedicineRow({
    required this.id,
    required this.name,
    this.strengthMilli,
    this.strengthUnit,
    this.dosageText,
    required this.expirationYear,
    required this.expirationMonth,
    this.expirationDay,
    this.batchNumber,
    required this.quantityMilli,
    required this.quantityUnit,
    this.keptFor,
    required this.updatedAtMillis,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || strengthMilli != null) {
      map['strength_milli'] = Variable<int>(strengthMilli);
    }
    if (!nullToAbsent || strengthUnit != null) {
      map['strength_unit'] = Variable<String>(strengthUnit);
    }
    if (!nullToAbsent || dosageText != null) {
      map['dosage_text'] = Variable<String>(dosageText);
    }
    map['expiration_year'] = Variable<int>(expirationYear);
    map['expiration_month'] = Variable<int>(expirationMonth);
    if (!nullToAbsent || expirationDay != null) {
      map['expiration_day'] = Variable<int>(expirationDay);
    }
    if (!nullToAbsent || batchNumber != null) {
      map['batch_number'] = Variable<String>(batchNumber);
    }
    map['quantity_milli'] = Variable<int>(quantityMilli);
    map['quantity_unit'] = Variable<String>(quantityUnit);
    if (!nullToAbsent || keptFor != null) {
      map['kept_for'] = Variable<String>(keptFor);
    }
    map['updated_at_millis'] = Variable<int>(updatedAtMillis);
    return map;
  }

  MedicineRecordsCompanion toCompanion(bool nullToAbsent) {
    return MedicineRecordsCompanion(
      id: Value(id),
      name: Value(name),
      strengthMilli: strengthMilli == null && nullToAbsent
          ? const Value.absent()
          : Value(strengthMilli),
      strengthUnit: strengthUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(strengthUnit),
      dosageText: dosageText == null && nullToAbsent
          ? const Value.absent()
          : Value(dosageText),
      expirationYear: Value(expirationYear),
      expirationMonth: Value(expirationMonth),
      expirationDay: expirationDay == null && nullToAbsent
          ? const Value.absent()
          : Value(expirationDay),
      batchNumber: batchNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(batchNumber),
      quantityMilli: Value(quantityMilli),
      quantityUnit: Value(quantityUnit),
      keptFor: keptFor == null && nullToAbsent
          ? const Value.absent()
          : Value(keptFor),
      updatedAtMillis: Value(updatedAtMillis),
    );
  }

  factory MedicineRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicineRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      strengthMilli: serializer.fromJson<int?>(json['strengthMilli']),
      strengthUnit: serializer.fromJson<String?>(json['strengthUnit']),
      dosageText: serializer.fromJson<String?>(json['dosageText']),
      expirationYear: serializer.fromJson<int>(json['expirationYear']),
      expirationMonth: serializer.fromJson<int>(json['expirationMonth']),
      expirationDay: serializer.fromJson<int?>(json['expirationDay']),
      batchNumber: serializer.fromJson<String?>(json['batchNumber']),
      quantityMilli: serializer.fromJson<int>(json['quantityMilli']),
      quantityUnit: serializer.fromJson<String>(json['quantityUnit']),
      keptFor: serializer.fromJson<String?>(json['keptFor']),
      updatedAtMillis: serializer.fromJson<int>(json['updatedAtMillis']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'strengthMilli': serializer.toJson<int?>(strengthMilli),
      'strengthUnit': serializer.toJson<String?>(strengthUnit),
      'dosageText': serializer.toJson<String?>(dosageText),
      'expirationYear': serializer.toJson<int>(expirationYear),
      'expirationMonth': serializer.toJson<int>(expirationMonth),
      'expirationDay': serializer.toJson<int?>(expirationDay),
      'batchNumber': serializer.toJson<String?>(batchNumber),
      'quantityMilli': serializer.toJson<int>(quantityMilli),
      'quantityUnit': serializer.toJson<String>(quantityUnit),
      'keptFor': serializer.toJson<String?>(keptFor),
      'updatedAtMillis': serializer.toJson<int>(updatedAtMillis),
    };
  }

  MedicineRow copyWith({
    String? id,
    String? name,
    Value<int?> strengthMilli = const Value.absent(),
    Value<String?> strengthUnit = const Value.absent(),
    Value<String?> dosageText = const Value.absent(),
    int? expirationYear,
    int? expirationMonth,
    Value<int?> expirationDay = const Value.absent(),
    Value<String?> batchNumber = const Value.absent(),
    int? quantityMilli,
    String? quantityUnit,
    Value<String?> keptFor = const Value.absent(),
    int? updatedAtMillis,
  }) => MedicineRow(
    id: id ?? this.id,
    name: name ?? this.name,
    strengthMilli: strengthMilli.present
        ? strengthMilli.value
        : this.strengthMilli,
    strengthUnit: strengthUnit.present ? strengthUnit.value : this.strengthUnit,
    dosageText: dosageText.present ? dosageText.value : this.dosageText,
    expirationYear: expirationYear ?? this.expirationYear,
    expirationMonth: expirationMonth ?? this.expirationMonth,
    expirationDay: expirationDay.present
        ? expirationDay.value
        : this.expirationDay,
    batchNumber: batchNumber.present ? batchNumber.value : this.batchNumber,
    quantityMilli: quantityMilli ?? this.quantityMilli,
    quantityUnit: quantityUnit ?? this.quantityUnit,
    keptFor: keptFor.present ? keptFor.value : this.keptFor,
    updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
  );
  MedicineRow copyWithCompanion(MedicineRecordsCompanion data) {
    return MedicineRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      strengthMilli: data.strengthMilli.present
          ? data.strengthMilli.value
          : this.strengthMilli,
      strengthUnit: data.strengthUnit.present
          ? data.strengthUnit.value
          : this.strengthUnit,
      dosageText: data.dosageText.present
          ? data.dosageText.value
          : this.dosageText,
      expirationYear: data.expirationYear.present
          ? data.expirationYear.value
          : this.expirationYear,
      expirationMonth: data.expirationMonth.present
          ? data.expirationMonth.value
          : this.expirationMonth,
      expirationDay: data.expirationDay.present
          ? data.expirationDay.value
          : this.expirationDay,
      batchNumber: data.batchNumber.present
          ? data.batchNumber.value
          : this.batchNumber,
      quantityMilli: data.quantityMilli.present
          ? data.quantityMilli.value
          : this.quantityMilli,
      quantityUnit: data.quantityUnit.present
          ? data.quantityUnit.value
          : this.quantityUnit,
      keptFor: data.keptFor.present ? data.keptFor.value : this.keptFor,
      updatedAtMillis: data.updatedAtMillis.present
          ? data.updatedAtMillis.value
          : this.updatedAtMillis,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicineRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('strengthMilli: $strengthMilli, ')
          ..write('strengthUnit: $strengthUnit, ')
          ..write('dosageText: $dosageText, ')
          ..write('expirationYear: $expirationYear, ')
          ..write('expirationMonth: $expirationMonth, ')
          ..write('expirationDay: $expirationDay, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('quantityMilli: $quantityMilli, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('keptFor: $keptFor, ')
          ..write('updatedAtMillis: $updatedAtMillis')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    strengthMilli,
    strengthUnit,
    dosageText,
    expirationYear,
    expirationMonth,
    expirationDay,
    batchNumber,
    quantityMilli,
    quantityUnit,
    keptFor,
    updatedAtMillis,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicineRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.strengthMilli == this.strengthMilli &&
          other.strengthUnit == this.strengthUnit &&
          other.dosageText == this.dosageText &&
          other.expirationYear == this.expirationYear &&
          other.expirationMonth == this.expirationMonth &&
          other.expirationDay == this.expirationDay &&
          other.batchNumber == this.batchNumber &&
          other.quantityMilli == this.quantityMilli &&
          other.quantityUnit == this.quantityUnit &&
          other.keptFor == this.keptFor &&
          other.updatedAtMillis == this.updatedAtMillis);
}

class MedicineRecordsCompanion extends UpdateCompanion<MedicineRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> strengthMilli;
  final Value<String?> strengthUnit;
  final Value<String?> dosageText;
  final Value<int> expirationYear;
  final Value<int> expirationMonth;
  final Value<int?> expirationDay;
  final Value<String?> batchNumber;
  final Value<int> quantityMilli;
  final Value<String> quantityUnit;
  final Value<String?> keptFor;
  final Value<int> updatedAtMillis;
  final Value<int> rowid;
  const MedicineRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.strengthMilli = const Value.absent(),
    this.strengthUnit = const Value.absent(),
    this.dosageText = const Value.absent(),
    this.expirationYear = const Value.absent(),
    this.expirationMonth = const Value.absent(),
    this.expirationDay = const Value.absent(),
    this.batchNumber = const Value.absent(),
    this.quantityMilli = const Value.absent(),
    this.quantityUnit = const Value.absent(),
    this.keptFor = const Value.absent(),
    this.updatedAtMillis = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicineRecordsCompanion.insert({
    required String id,
    required String name,
    this.strengthMilli = const Value.absent(),
    this.strengthUnit = const Value.absent(),
    this.dosageText = const Value.absent(),
    required int expirationYear,
    required int expirationMonth,
    this.expirationDay = const Value.absent(),
    this.batchNumber = const Value.absent(),
    required int quantityMilli,
    required String quantityUnit,
    this.keptFor = const Value.absent(),
    required int updatedAtMillis,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       expirationYear = Value(expirationYear),
       expirationMonth = Value(expirationMonth),
       quantityMilli = Value(quantityMilli),
       quantityUnit = Value(quantityUnit),
       updatedAtMillis = Value(updatedAtMillis);
  static Insertable<MedicineRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? strengthMilli,
    Expression<String>? strengthUnit,
    Expression<String>? dosageText,
    Expression<int>? expirationYear,
    Expression<int>? expirationMonth,
    Expression<int>? expirationDay,
    Expression<String>? batchNumber,
    Expression<int>? quantityMilli,
    Expression<String>? quantityUnit,
    Expression<String>? keptFor,
    Expression<int>? updatedAtMillis,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (strengthMilli != null) 'strength_milli': strengthMilli,
      if (strengthUnit != null) 'strength_unit': strengthUnit,
      if (dosageText != null) 'dosage_text': dosageText,
      if (expirationYear != null) 'expiration_year': expirationYear,
      if (expirationMonth != null) 'expiration_month': expirationMonth,
      if (expirationDay != null) 'expiration_day': expirationDay,
      if (batchNumber != null) 'batch_number': batchNumber,
      if (quantityMilli != null) 'quantity_milli': quantityMilli,
      if (quantityUnit != null) 'quantity_unit': quantityUnit,
      if (keptFor != null) 'kept_for': keptFor,
      if (updatedAtMillis != null) 'updated_at_millis': updatedAtMillis,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicineRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int?>? strengthMilli,
    Value<String?>? strengthUnit,
    Value<String?>? dosageText,
    Value<int>? expirationYear,
    Value<int>? expirationMonth,
    Value<int?>? expirationDay,
    Value<String?>? batchNumber,
    Value<int>? quantityMilli,
    Value<String>? quantityUnit,
    Value<String?>? keptFor,
    Value<int>? updatedAtMillis,
    Value<int>? rowid,
  }) {
    return MedicineRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      strengthMilli: strengthMilli ?? this.strengthMilli,
      strengthUnit: strengthUnit ?? this.strengthUnit,
      dosageText: dosageText ?? this.dosageText,
      expirationYear: expirationYear ?? this.expirationYear,
      expirationMonth: expirationMonth ?? this.expirationMonth,
      expirationDay: expirationDay ?? this.expirationDay,
      batchNumber: batchNumber ?? this.batchNumber,
      quantityMilli: quantityMilli ?? this.quantityMilli,
      quantityUnit: quantityUnit ?? this.quantityUnit,
      keptFor: keptFor ?? this.keptFor,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (strengthMilli.present) {
      map['strength_milli'] = Variable<int>(strengthMilli.value);
    }
    if (strengthUnit.present) {
      map['strength_unit'] = Variable<String>(strengthUnit.value);
    }
    if (dosageText.present) {
      map['dosage_text'] = Variable<String>(dosageText.value);
    }
    if (expirationYear.present) {
      map['expiration_year'] = Variable<int>(expirationYear.value);
    }
    if (expirationMonth.present) {
      map['expiration_month'] = Variable<int>(expirationMonth.value);
    }
    if (expirationDay.present) {
      map['expiration_day'] = Variable<int>(expirationDay.value);
    }
    if (batchNumber.present) {
      map['batch_number'] = Variable<String>(batchNumber.value);
    }
    if (quantityMilli.present) {
      map['quantity_milli'] = Variable<int>(quantityMilli.value);
    }
    if (quantityUnit.present) {
      map['quantity_unit'] = Variable<String>(quantityUnit.value);
    }
    if (keptFor.present) {
      map['kept_for'] = Variable<String>(keptFor.value);
    }
    if (updatedAtMillis.present) {
      map['updated_at_millis'] = Variable<int>(updatedAtMillis.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicineRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('strengthMilli: $strengthMilli, ')
          ..write('strengthUnit: $strengthUnit, ')
          ..write('dosageText: $dosageText, ')
          ..write('expirationYear: $expirationYear, ')
          ..write('expirationMonth: $expirationMonth, ')
          ..write('expirationDay: $expirationDay, ')
          ..write('batchNumber: $batchNumber, ')
          ..write('quantityMilli: $quantityMilli, ')
          ..write('quantityUnit: $quantityUnit, ')
          ..write('keptFor: $keptFor, ')
          ..write('updatedAtMillis: $updatedAtMillis, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$CabinetDatabase extends GeneratedDatabase {
  _$CabinetDatabase(QueryExecutor e) : super(e);
  $CabinetDatabaseManager get managers => $CabinetDatabaseManager(this);
  late final $MedicineRecordsTable medicineRecords = $MedicineRecordsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [medicineRecords];
}

typedef $$MedicineRecordsTableCreateCompanionBuilder =
    MedicineRecordsCompanion Function({
      required String id,
      required String name,
      Value<int?> strengthMilli,
      Value<String?> strengthUnit,
      Value<String?> dosageText,
      required int expirationYear,
      required int expirationMonth,
      Value<int?> expirationDay,
      Value<String?> batchNumber,
      required int quantityMilli,
      required String quantityUnit,
      Value<String?> keptFor,
      required int updatedAtMillis,
      Value<int> rowid,
    });
typedef $$MedicineRecordsTableUpdateCompanionBuilder =
    MedicineRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int?> strengthMilli,
      Value<String?> strengthUnit,
      Value<String?> dosageText,
      Value<int> expirationYear,
      Value<int> expirationMonth,
      Value<int?> expirationDay,
      Value<String?> batchNumber,
      Value<int> quantityMilli,
      Value<String> quantityUnit,
      Value<String?> keptFor,
      Value<int> updatedAtMillis,
      Value<int> rowid,
    });

class $$MedicineRecordsTableFilterComposer
    extends Composer<_$CabinetDatabase, $MedicineRecordsTable> {
  $$MedicineRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get strengthMilli => $composableBuilder(
    column: $table.strengthMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosageText => $composableBuilder(
    column: $table.dosageText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expirationYear => $composableBuilder(
    column: $table.expirationYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expirationMonth => $composableBuilder(
    column: $table.expirationMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expirationDay => $composableBuilder(
    column: $table.expirationDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantityMilli => $composableBuilder(
    column: $table.quantityMilli,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keptFor => $composableBuilder(
    column: $table.keptFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MedicineRecordsTableOrderingComposer
    extends Composer<_$CabinetDatabase, $MedicineRecordsTable> {
  $$MedicineRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get strengthMilli => $composableBuilder(
    column: $table.strengthMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosageText => $composableBuilder(
    column: $table.dosageText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expirationYear => $composableBuilder(
    column: $table.expirationYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expirationMonth => $composableBuilder(
    column: $table.expirationMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expirationDay => $composableBuilder(
    column: $table.expirationDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantityMilli => $composableBuilder(
    column: $table.quantityMilli,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keptFor => $composableBuilder(
    column: $table.keptFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MedicineRecordsTableAnnotationComposer
    extends Composer<_$CabinetDatabase, $MedicineRecordsTable> {
  $$MedicineRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get strengthMilli => $composableBuilder(
    column: $table.strengthMilli,
    builder: (column) => column,
  );

  GeneratedColumn<String> get strengthUnit => $composableBuilder(
    column: $table.strengthUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dosageText => $composableBuilder(
    column: $table.dosageText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expirationYear => $composableBuilder(
    column: $table.expirationYear,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expirationMonth => $composableBuilder(
    column: $table.expirationMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expirationDay => $composableBuilder(
    column: $table.expirationDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get batchNumber => $composableBuilder(
    column: $table.batchNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantityMilli => $composableBuilder(
    column: $table.quantityMilli,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quantityUnit => $composableBuilder(
    column: $table.quantityUnit,
    builder: (column) => column,
  );

  GeneratedColumn<String> get keptFor =>
      $composableBuilder(column: $table.keptFor, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMillis => $composableBuilder(
    column: $table.updatedAtMillis,
    builder: (column) => column,
  );
}

class $$MedicineRecordsTableTableManager
    extends
        RootTableManager<
          _$CabinetDatabase,
          $MedicineRecordsTable,
          MedicineRow,
          $$MedicineRecordsTableFilterComposer,
          $$MedicineRecordsTableOrderingComposer,
          $$MedicineRecordsTableAnnotationComposer,
          $$MedicineRecordsTableCreateCompanionBuilder,
          $$MedicineRecordsTableUpdateCompanionBuilder,
          (
            MedicineRow,
            BaseReferences<
              _$CabinetDatabase,
              $MedicineRecordsTable,
              MedicineRow
            >,
          ),
          MedicineRow,
          PrefetchHooks Function()
        > {
  $$MedicineRecordsTableTableManager(
    _$CabinetDatabase db,
    $MedicineRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicineRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicineRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicineRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> strengthMilli = const Value.absent(),
                Value<String?> strengthUnit = const Value.absent(),
                Value<String?> dosageText = const Value.absent(),
                Value<int> expirationYear = const Value.absent(),
                Value<int> expirationMonth = const Value.absent(),
                Value<int?> expirationDay = const Value.absent(),
                Value<String?> batchNumber = const Value.absent(),
                Value<int> quantityMilli = const Value.absent(),
                Value<String> quantityUnit = const Value.absent(),
                Value<String?> keptFor = const Value.absent(),
                Value<int> updatedAtMillis = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MedicineRecordsCompanion(
                id: id,
                name: name,
                strengthMilli: strengthMilli,
                strengthUnit: strengthUnit,
                dosageText: dosageText,
                expirationYear: expirationYear,
                expirationMonth: expirationMonth,
                expirationDay: expirationDay,
                batchNumber: batchNumber,
                quantityMilli: quantityMilli,
                quantityUnit: quantityUnit,
                keptFor: keptFor,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<int?> strengthMilli = const Value.absent(),
                Value<String?> strengthUnit = const Value.absent(),
                Value<String?> dosageText = const Value.absent(),
                required int expirationYear,
                required int expirationMonth,
                Value<int?> expirationDay = const Value.absent(),
                Value<String?> batchNumber = const Value.absent(),
                required int quantityMilli,
                required String quantityUnit,
                Value<String?> keptFor = const Value.absent(),
                required int updatedAtMillis,
                Value<int> rowid = const Value.absent(),
              }) => MedicineRecordsCompanion.insert(
                id: id,
                name: name,
                strengthMilli: strengthMilli,
                strengthUnit: strengthUnit,
                dosageText: dosageText,
                expirationYear: expirationYear,
                expirationMonth: expirationMonth,
                expirationDay: expirationDay,
                batchNumber: batchNumber,
                quantityMilli: quantityMilli,
                quantityUnit: quantityUnit,
                keptFor: keptFor,
                updatedAtMillis: updatedAtMillis,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MedicineRecordsTable, MedicineRow>(table),
                  BaseReferences<
                    _$CabinetDatabase,
                    $MedicineRecordsTable,
                    MedicineRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MedicineRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$CabinetDatabase,
      $MedicineRecordsTable,
      MedicineRow,
      $$MedicineRecordsTableFilterComposer,
      $$MedicineRecordsTableOrderingComposer,
      $$MedicineRecordsTableAnnotationComposer,
      $$MedicineRecordsTableCreateCompanionBuilder,
      $$MedicineRecordsTableUpdateCompanionBuilder,
      (
        MedicineRow,
        BaseReferences<_$CabinetDatabase, $MedicineRecordsTable, MedicineRow>,
      ),
      MedicineRow,
      PrefetchHooks Function()
    >;

class $CabinetDatabaseManager {
  final _$CabinetDatabase _db;
  $CabinetDatabaseManager(this._db);
  $$MedicineRecordsTableTableManager get medicineRecords =>
      $$MedicineRecordsTableTableManager(_db, _db.medicineRecords);
}
