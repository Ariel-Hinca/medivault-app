import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:medivault/core/error/failure.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';

void main() {
  test('stores a confirmed medicine and drops nothing extra', () {
    final medicine = Medicine.create(
      name: '  Dafalgan  ',
      strength: Strength(parseMilliUnits('1,5')!, StrengthUnit.g),
      dosageText: ' 1 tablet ',
      expiration: ExpirationDate.checked(year: 2028, month: 4),
      batchNumber: ' LOT-4 ',
      quantity: Quantity(parseMilliUnits('20')!, QuantityUnit.tablet),
      keptFor: ' Mom ',
      updatedAt: DateTime.utc(2026, 11, 22, 10),
    );

    expect(medicine.name, 'Dafalgan');
    expect(medicine.strength?.milli, 1500);
    expect(formatMilliUnits(1500), '1.5');
    expect(medicine.dosageText, '1 tablet');
    expect(medicine.batchNumber, 'LOT-4');
    expect(medicine.keptFor, 'Mom');
    expect(medicine.expiration.day, isNull);
    expect(medicine.expiration.effectiveEndDate(), DateTime(2028, 4, 30));
  });

  test('rejects empty names, bad dates, and unsafe batch text', () {
    expect(
      () => Medicine.create(
        name: ' ',
        expiration: ExpirationDate.checked(year: 2028, month: 4),
        quantity: const Quantity(0, QuantityUnit.piece),
        updatedAt: DateTime.utc(2026, 11, 22),
      ),
      throwsA(
        isA<Failure>().having(
          (failure) => failure.code,
          'code',
          'invalid_medicine',
        ),
      ),
    );
    expect(
      () => ExpirationDate.checked(year: 2026, month: 2, day: 29),
      throwsA(isA<Failure>()),
    );
    expect(
      () => Medicine.create(
        name: 'Dafalgan',
        expiration: ExpirationDate.checked(year: 2028, month: 4),
        batchNumber: 'has space',
        quantity: const Quantity(0, QuantityUnit.piece),
        updatedAt: DateTime.utc(2026, 11, 22),
      ),
      throwsA(isA<Failure>()),
    );
  });

  test('month-only dates expire at month end and bands use whole days', () {
    final february = ExpirationDate.checked(year: 2026, month: 2);
    expect(february.effectiveEndDate(), DateTime(2026, 2, 28));

    final today = DateTime(2026, 11, 22);
    expect(
      expirationBand(
        ExpirationDate.checked(year: 2026, month: 11, day: 21),
        today,
      ),
      ExpirationBand.expired,
    );
    expect(
      expirationBand(
        ExpirationDate.checked(year: 2026, month: 11, day: 22),
        today,
      ),
      ExpirationBand.within7Days,
    );
    expect(
      expirationBand(
        ExpirationDate.checked(year: 2026, month: 11, day: 29),
        today,
      ),
      ExpirationBand.within7Days,
    );
    expect(
      expirationBand(
        ExpirationDate.checked(year: 2026, month: 11, day: 30),
        today,
      ),
      ExpirationBand.within30Days,
    );
    expect(
      expirationBand(
        ExpirationDate.checked(year: 2026, month: 12, day: 22),
        today,
      ),
      ExpirationBand.within30Days,
    );
    expect(
      expirationBand(
        ExpirationDate.checked(year: 2026, month: 12, day: 23),
        today,
      ),
      ExpirationBand.within90Days,
    );
    expect(
      expirationBand(
        ExpirationDate.checked(year: 2027, month: 2, day: 20),
        today,
      ),
      ExpirationBand.within90Days,
    );
    expect(
      expirationBand(
        ExpirationDate.checked(year: 2027, month: 2, day: 21),
        today,
      ),
      ExpirationBand.later,
    );
  });

  test('search is case-insensitive and lists names alphabetically', () {
    final later = _medicine('Ibuprofen');
    final earlier = _medicine('Dafalgan');
    final found = filterMedicines([later, earlier], ' daf ');

    expect(found.map((medicine) => medicine.name), ['Dafalgan']);
    expect(
      filterMedicines([later, earlier], '').map((medicine) => medicine.name),
      ['Dafalgan', 'Ibuprofen'],
    );
  });

  test('ids are random version-4 uuids', () {
    final random = Random(4);
    final first = newMedicineId(random);
    final second = newMedicineId(random);

    expect(first, isNot(second));
    expect(first, matches(RegExp(r'^[0-9a-f-]{36}$')));
  });

  test('search and expiry filters narrow the cabinet', () {
    final today = DateTime(2026, 11, 22);
    final medicines = [
      _dated('Old', ExpirationDate.checked(year: 2026, month: 11, day: 21)),
      _dated('Soon', ExpirationDate.checked(year: 2026, month: 11, day: 29)),
      _dated('Month', ExpirationDate.checked(year: 2026, month: 12, day: 22)),
      _dated('Season', ExpirationDate.checked(year: 2027, month: 2, day: 20)),
      _dated('Later', ExpirationDate.checked(year: 2027, month: 2, day: 21)),
    ];

    expect(
      filterCabinet(
        medicines,
        query: 'soon',
        filter: CabinetFilter.all,
        today: today,
      ).map((medicine) => medicine.name),
      ['Soon'],
    );
    expect(
      filterCabinet(
        medicines,
        query: '',
        filter: CabinetFilter.expired,
        today: today,
      ).map((medicine) => medicine.name),
      ['Old'],
    );
    expect(
      filterCabinet(
        medicines,
        query: '',
        filter: CabinetFilter.next30Days,
        today: today,
      ).map((medicine) => medicine.name),
      ['Month', 'Soon'],
    );
    expect(
      filterCabinet(
        medicines,
        query: 'later',
        filter: CabinetFilter.next90Days,
        today: today,
      ),
      isEmpty,
    );
  });
}

Medicine _medicine(String name) {
  return _dated(name, ExpirationDate.checked(year: 2028, month: 4));
}

Medicine _dated(String name, ExpirationDate expiration) {
  return Medicine.create(
    name: name,
    expiration: expiration,
    quantity: const Quantity(1000, QuantityUnit.tablet),
    updatedAt: DateTime.utc(2026, 11, 22),
  );
}
