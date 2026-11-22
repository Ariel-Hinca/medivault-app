import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medivault/bootstrap.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/inventory/domain/medicine_repository.dart';
import 'package:medivault/features/inventory/infrastructure/cabinet_providers.dart';

void main() {
  testWidgets('shows an empty cabinet', (tester) async {
    await _pump(tester, _MemoryCabinet());

    expect(find.text('MediVault'), findsOneWidget);
    expect(find.text('Scan a pack'), findsOneWidget);
    expect(
      find.text('Your cabinet is empty. Scan a pack or add a medicine.'),
      findsOneWidget,
    );
  });

  testWidgets('searches, filters, adds, and removes a medicine', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final today = DateTime.now();
    final cabinet = _MemoryCabinet();
    await cabinet.save(_medicine('Ibuprofen', DateTime(today.year + 2, 1, 1)));
    await cabinet.save(_medicine('Old Pack', DateTime(today.year - 1, 1, 1)));
    await _pump(tester, cabinet);

    expect(find.text('Ibuprofen'), findsOneWidget);
    expect(find.text('Old Pack'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search medicines'),
      'ibu',
    );
    await tester.pumpAndSettle();
    expect(find.text('Ibuprofen'), findsOneWidget);
    expect(find.text('Old Pack'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextField, 'Search medicines'),
      '',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Expired'));
    await tester.pumpAndSettle();
    expect(find.text('Old Pack'), findsOneWidget);
    expect(find.text('Ibuprofen'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add a medicine'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Medicine name'),
      'Dafalgan',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Expiry year'),
      '2028',
    );
    await tester.tap(find.byKey(const Key('expiry-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('04 April').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('quantity')), '20');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Dafalgan'), findsOneWidget);
    expect(
      cabinet.items.values.map((medicine) => medicine.name),
      contains('Dafalgan'),
    );

    await tester.tap(find.text('Dafalgan'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from cabinet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    expect(find.text('Dafalgan'), findsNothing);
    expect(cabinet.items.containsKey('missing'), isFalse);
    expect(
      cabinet.items.values.map((medicine) => medicine.name),
      isNot(contains('Dafalgan')),
    );
  });
}

Future<void> _pump(WidgetTester tester, _MemoryCabinet cabinet) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        medicineRepositoryProvider.overrideWith((ref) async => cabinet),
      ],
      child: const MediVaultApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Medicine _medicine(String name, DateTime expiration) {
  return Medicine.create(
    name: name,
    expiration: ExpirationDate.checked(
      year: expiration.year,
      month: expiration.month,
      day: expiration.day,
    ),
    quantity: const Quantity(1000, QuantityUnit.tablet),
    updatedAt: DateTime.utc(2026, 11, 22),
  );
}

final class _MemoryCabinet implements MedicineRepository {
  final items = <String, Medicine>{};

  @override
  Future<void> delete(String id) async {
    items.remove(id);
  }

  @override
  Future<void> deleteAll() async {
    items.clear();
  }

  @override
  Future<List<Medicine>> findAll({String nameQuery = ''}) async {
    return filterMedicines(items.values.toList(), nameQuery);
  }

  @override
  Future<Medicine?> findById(String id) async => items[id];

  @override
  Future<void> save(Medicine medicine) async {
    items[medicine.id] = medicine;
  }
}
