import 'package:drift/drift.dart';

part 'cabinet_database.g.dart';

@DataClassName('MedicineRow')
class MedicineRecords extends Table {
  @override
  String get tableName => 'medicines';

  TextColumn get id => text()();

  TextColumn get name => text()();

  IntColumn get strengthMilli => integer().nullable()();

  TextColumn get strengthUnit => text().nullable()();

  TextColumn get dosageText => text().nullable()();

  IntColumn get expirationYear => integer()();

  IntColumn get expirationMonth => integer()();

  IntColumn get expirationDay => integer().nullable()();

  TextColumn get batchNumber => text().nullable()();

  IntColumn get quantityMilli => integer()();

  TextColumn get quantityUnit => text()();

  TextColumn get keptFor => text().nullable()();

  IntColumn get updatedAtMillis => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [MedicineRecords])
class CabinetDatabase extends _$CabinetDatabase {
  CabinetDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
