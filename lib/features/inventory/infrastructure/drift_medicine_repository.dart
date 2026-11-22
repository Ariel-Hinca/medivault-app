import 'package:drift/drift.dart';
import 'package:medivault/core/error/failure.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/inventory/domain/medicine_repository.dart';
import 'package:medivault/features/inventory/infrastructure/cabinet_database.dart';

final class DriftMedicineRepository implements MedicineRepository {
  DriftMedicineRepository(this._database);

  final CabinetDatabase _database;

  @override
  Future<void> save(Medicine medicine) {
    return _database
        .into(_database.medicineRecords)
        .insertOnConflictUpdate(_companion(medicine));
  }

  @override
  Future<Medicine?> findById(String id) async {
    final row = await (_database.select(
      _database.medicineRecords,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _medicineFromRow(row);
  }

  @override
  Future<List<Medicine>> findAll({String nameQuery = ''}) async {
    final rows = await _database.select(_database.medicineRecords).get();
    return filterMedicines(rows.map(_medicineFromRow).toList(), nameQuery);
  }

  @override
  Future<void> delete(String id) {
    return (_database.delete(
      _database.medicineRecords,
    )..where((table) => table.id.equals(id))).go();
  }

  @override
  Future<void> deleteAll() {
    return _database.delete(_database.medicineRecords).go();
  }
}

MedicineRecordsCompanion _companion(Medicine medicine) {
  final strength = medicine.strength;
  return MedicineRecordsCompanion.insert(
    id: medicine.id,
    name: medicine.name,
    strengthMilli: Value(strength?.milli),
    strengthUnit: Value(strength?.unit.name),
    dosageText: Value(medicine.dosageText),
    expirationYear: medicine.expiration.year,
    expirationMonth: medicine.expiration.month,
    expirationDay: Value(medicine.expiration.day),
    batchNumber: Value(medicine.batchNumber),
    quantityMilli: medicine.quantity.milli,
    quantityUnit: medicine.quantity.unit.name,
    keptFor: Value(medicine.keptFor),
    updatedAtMillis: medicine.updatedAt.millisecondsSinceEpoch,
  );
}

Medicine _medicineFromRow(MedicineRow row) {
  final strength = _strength(row.strengthMilli, row.strengthUnit);
  final quantityUnit = QuantityUnit.values.where(
    (unit) => unit.name == row.quantityUnit,
  );
  if (quantityUnit.isEmpty) {
    throw const Failure('invalid_medicine');
  }
  return Medicine.create(
    id: row.id,
    name: row.name,
    strength: strength,
    dosageText: row.dosageText,
    expiration: ExpirationDate.checked(
      year: row.expirationYear,
      month: row.expirationMonth,
      day: row.expirationDay,
    ),
    batchNumber: row.batchNumber,
    quantity: Quantity(row.quantityMilli, quantityUnit.first),
    keptFor: row.keptFor,
    updatedAt: DateTime.fromMillisecondsSinceEpoch(
      row.updatedAtMillis,
      isUtc: true,
    ),
  );
}

Strength? _strength(int? milli, String? unitName) {
  if (milli == null && unitName == null) {
    return null;
  }
  final unit = StrengthUnit.values.where((item) => item.name == unitName);
  if (milli == null || unit.isEmpty) {
    throw const Failure('invalid_medicine');
  }
  return Strength(milli, unit.first);
}
