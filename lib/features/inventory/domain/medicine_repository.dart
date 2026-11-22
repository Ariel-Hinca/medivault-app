import 'package:medivault/features/inventory/domain/medicine.dart';

/// Persistence port for the cabinet. Widgets do not implement this.
abstract interface class MedicineRepository {
  Future<void> save(Medicine medicine);

  Future<Medicine?> findById(String id);

  Future<List<Medicine>> findAll({String nameQuery = ''});

  Future<void> delete(String id);

  Future<void> deleteAll();
}
