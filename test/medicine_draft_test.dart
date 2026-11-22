import 'package:flutter_test/flutter_test.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/inventory/domain/medicine_draft.dart';
import 'package:medivault/features/inventory/presentation/medicine_form_page.dart';
import 'package:medivault/features/scanning/domain/pack_label.dart';

void main() {
  test('saves a complete draft and rejects an unsafe batch', () {
    final saved = compileDraft(
      const MedicineDraft(
        name: ' Dafalgan ',
        strengthAmount: '500',
        strengthUnit: StrengthUnit.mg,
        dosage: '1 tablet',
        year: '2028',
        month: '4',
        batch: 'AB-12',
        quantityAmount: '20',
        keptFor: ' Mom ',
      ),
      updatedAt: DateTime.utc(2026, 11, 22),
    );

    expect(saved.invalid, isEmpty);
    expect(saved.medicine?.name, 'Dafalgan');
    expect(saved.medicine?.strength?.milli, 500000);
    expect(saved.medicine?.expiration.day, isNull);
    expect(saved.medicine?.keptFor, 'Mom');

    final rejected = compileDraft(
      const MedicineDraft(
        name: 'Dafalgan',
        year: '2028',
        month: '4',
        batch: 'has space',
        quantityAmount: '1',
      ),
      updatedAt: DateTime.utc(2026, 11, 22),
    );
    expect(rejected.medicine, isNull);
    expect(rejected.invalid, {DraftField.batch});
  });

  test('copies a pack reading and leaves the quantity blank', () {
    final draft = draftFromReading(
      readLabel(const [
        RecognizedLine('Paracetamol 1g', confidenceMilli: 900),
        RecognizedLine('EXP 04/2028', confidenceMilli: 900),
      ]),
    );

    expect(draft.name, 'Paracetamol');
    expect(draft.strengthAmount, '1');
    expect(draft.strengthUnit, StrengthUnit.g);
    expect(draft.year, '2028');
    expect(draft.month, '4');
    expect(draft.day, isEmpty);
    expect(draft.quantityAmount, isEmpty);
  });

  test('round-trips a stored medicine through the form', () {
    final medicine = Medicine.create(
      name: 'Dafalgan',
      strength: const Strength(500000, StrengthUnit.mg),
      expiration: ExpirationDate.checked(year: 2028, month: 4, day: 30),
      quantity: const Quantity(20000, QuantityUnit.tablet),
      updatedAt: DateTime.utc(2026, 11, 22),
    );
    final draft = draftFromMedicine(medicine);
    final again = compileDraft(
      draft,
      id: medicine.id,
      updatedAt: medicine.updatedAt,
    );

    expect(again.medicine?.id, medicine.id);
    expect(again.medicine?.strength?.milli, 500000);
    expect(again.medicine?.expiration.day, 30);
    expect(again.medicine?.quantity.milli, 20000);
  });
}
