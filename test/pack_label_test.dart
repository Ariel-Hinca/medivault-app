import 'package:flutter_test/flutter_test.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/scanning/domain/pack_label.dart';

void main() {
  test('reads a Belgian pack and keeps each line confidence', () {
    final reading = readLabel([
      const RecognizedLine('Dafalgan 500mg', confidenceMilli: 900),
      const RecognizedLine('1 tablet', confidenceMilli: 800),
      const RecognizedLine('EXP 04/2028', confidenceMilli: 860),
      const RecognizedLine('Lot AB-12', confidenceMilli: 500),
    ]);

    expect(reading.name?.value, 'Dafalgan');
    expect(reading.name?.confidenceMilli, 900);
    expect(reading.strength?.value.milli, 500000);
    expect(reading.strength?.value.unit, StrengthUnit.mg);
    expect(reading.dosage?.value, '1 tablet');
    expect(reading.expiration?.value.year, 2028);
    expect(reading.expiration?.value.month, 4);
    expect(reading.expiration?.value.day, isNull);
    expect(reading.batchNumber?.value, 'AB-12');
    expect(reading.batchNumber?.confidenceMilli, 500);
  });

  test('reads strength beside the name and a full expiry date', () {
    final reading = readLabel([
      const RecognizedLine('Paracetamol 1g', confidenceMilli: 700),
      const RecognizedLine('EXP 30/04/2028', confidenceMilli: 700),
      const RecognizedLine('BATCH: X9', confidenceMilli: 700),
    ]);

    expect(reading.name?.value, 'Paracetamol');
    expect(reading.strength?.value.milli, 1000);
    expect(reading.strength?.value.unit, StrengthUnit.g);
    expect(reading.expiration?.value.day, 30);
    expect(reading.batchNumber?.value, 'X9');
  });

  test('reads a date or batch printed on the following line', () {
    final reading = readLabel([
      const RecognizedLine('Ibuprofen', confidenceMilli: 810),
      const RecognizedLine('400 mg', confidenceMilli: 820),
      const RecognizedLine('EXP', confidenceMilli: 830),
      const RecognizedLine('2028-04-30', confidenceMilli: 840),
      const RecognizedLine('Lot', confidenceMilli: 850),
      const RecognizedLine('LOT12', confidenceMilli: 860),
    ]);

    expect(reading.name?.value, 'Ibuprofen');
    expect(reading.name?.confidenceMilli, 810);
    expect(reading.strength?.value.milli, 400000);
    expect(reading.expiration?.value.day, 30);
    expect(reading.expiration?.confidenceMilli, 830);
    expect(reading.batchNumber?.value, 'LOT12');
    expect(reading.batchNumber?.confidenceMilli, 860);
  });

  test('accepts a spaced expiry date and a decimal strength', () {
    final reading = readLabel([
      const RecognizedLine('Fébrilex 1,5 g', confidenceMilli: 900),
      const RecognizedLine('Use by 04 / 2028', confidenceMilli: 900),
    ]);

    expect(reading.name?.value, 'Fébrilex');
    expect(reading.strength?.value.milli, 1500);
    expect(reading.strength?.value.unit, StrengthUnit.g);
    expect(reading.expiration?.value.month, 4);
    expect(reading.expiration?.value.year, 2028);
    expect(reading.expiration?.value.day, isNull);
  });

  test('reads micrograms', () {
    final reading = readLabel(const [
      RecognizedLine('Levothyroxine 25µg', confidenceMilli: 910),
    ]);

    expect(reading.name?.value, 'Levothyroxine');
    expect(reading.strength?.value.milli, 25000);
    expect(reading.strength?.value.unit, StrengthUnit.mcg);
  });

  test(
    'drops pack counts, invalid dates, unsafe text, and unscored values',
    () {
      final reading = readLabel([
        const RecognizedLine('Dafalgan', confidenceMilli: 900),
        const RecognizedLine('30 tabletten', confidenceMilli: 900),
        const RecognizedLine('EXP 31/02/2028', confidenceMilli: 900),
        const RecognizedLine('Lot has space', confidenceMilli: 900),
        RecognizedLine('Hidden\nname', confidenceMilli: 900),
        const RecognizedLine('Aspirin', confidenceMilli: 1200),
      ]);

      expect(reading.name?.value, 'Dafalgan');
      expect(reading.dosage, isNull);
      expect(reading.expiration, isNull);
      expect(reading.batchNumber, isNull);
      expect(reading.isEmpty, isFalse);
    },
  );

  test('keeps the stronger reading when two names are seen', () {
    final reading = readLabel([
      const RecognizedLine('Old Name', confidenceMilli: 400),
      const RecognizedLine('Clear Name', confidenceMilli: 950),
    ]);

    expect(reading.name?.value, 'Clear Name');
    expect(reading.name?.confidenceMilli, 950);
  });

  test('scores only confidences from 0 to 1', () {
    expect(confidenceMilliFromUnitInterval(0.9), 900);
    expect(confidenceMilliFromUnitInterval(1), 1000);
    expect(confidenceMilliFromUnitInterval(null), isNull);
    expect(confidenceMilliFromUnitInterval(1.2), isNull);
    expect(confidenceMilliFromUnitInterval(double.nan), isNull);
  });
}
