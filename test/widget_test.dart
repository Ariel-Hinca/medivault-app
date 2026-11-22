import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivault/bootstrap.dart';
import 'package:medivault/features/inventory/domain/medicine_repository.dart';
import 'package:medivault/features/inventory/infrastructure/cabinet_providers.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';

void main() {
  testWidgets('shows the app name', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medicineRepositoryProvider.overrideWith(
            (ref) async => _EmptyCabinet(),
          ),
        ],
        child: const MediVaultApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MediVault'), findsOneWidget);
    expect(find.text('Scan a pack'), findsOneWidget);
  });
}

final class _EmptyCabinet implements MedicineRepository {
  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> deleteAll() async {}

  @override
  Future<List<Medicine>> findAll({String nameQuery = ''}) async => const [];

  @override
  Future<Medicine?> findById(String id) async => null;

  @override
  Future<void> save(Medicine medicine) async {}
}
