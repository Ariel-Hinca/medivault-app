import 'package:medivault/core/error/failure.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';

enum DraftField { name, strength, dosage, expiration, batch, quantity, keptFor }

/// The text a person typed or confirmed. It is not a stored medicine yet.
final class MedicineDraft {
  const MedicineDraft({
    this.name = '',
    this.strengthAmount = '',
    this.strengthUnit,
    this.dosage = '',
    this.year = '',
    this.month = '',
    this.day = '',
    this.batch = '',
    this.quantityAmount = '',
    this.quantityUnit = QuantityUnit.tablet,
    this.keptFor = '',
  });

  final String name;
  final String strengthAmount;
  final StrengthUnit? strengthUnit;
  final String dosage;
  final String year;
  final String month;
  final String day;
  final String batch;
  final String quantityAmount;
  final QuantityUnit quantityUnit;
  final String keptFor;
}

final class DraftResult {
  const DraftResult({this.medicine, this.invalid = const {}});

  final Medicine? medicine;
  final Set<DraftField> invalid;
}

MedicineDraft draftFromMedicine(Medicine medicine) {
  final strength = medicine.strength;
  final day = medicine.expiration.day;
  return MedicineDraft(
    name: medicine.name,
    strengthAmount: strength == null ? '' : formatMilliUnits(strength.milli),
    strengthUnit: strength?.unit,
    dosage: medicine.dosageText ?? '',
    year: '${medicine.expiration.year}',
    month: '${medicine.expiration.month}',
    day: day == null ? '' : '$day',
    batch: medicine.batchNumber ?? '',
    quantityAmount: formatMilliUnits(medicine.quantity.milli),
    quantityUnit: medicine.quantity.unit,
    keptFor: medicine.keptFor ?? '',
  );
}

/// Checks the draft and builds a medicine only when every field is safe to store.
DraftResult compileDraft(
  MedicineDraft draft, {
  String? id,
  required DateTime updatedAt,
}) {
  final invalid = <DraftField>{};

  if (_badText(draft.name, maxLength: 200, required: true)) {
    invalid.add(DraftField.name);
  }

  Strength? strength;
  final strengthText = draft.strengthAmount.trim();
  if (strengthText.isNotEmpty || draft.strengthUnit != null) {
    final milli = parseMilliUnits(strengthText);
    if (draft.strengthUnit == null || milli == null || milli <= 0) {
      invalid.add(DraftField.strength);
    } else {
      strength = Strength(milli, draft.strengthUnit!);
    }
  }

  if (_badText(draft.dosage, maxLength: 200, required: false)) {
    invalid.add(DraftField.dosage);
  }

  final expiration = _expiration(draft);
  if (expiration == null) {
    invalid.add(DraftField.expiration);
  }

  final batch = draft.batch.trim();
  if (_hasControl(draft.batch) ||
      (batch.isNotEmpty &&
          !RegExp(r'^[A-Za-z0-9][A-Za-z0-9\-/]{0,63}$').hasMatch(batch))) {
    invalid.add(DraftField.batch);
  }

  if (_badText(draft.keptFor, maxLength: 40, required: false)) {
    invalid.add(DraftField.keptFor);
  }

  final quantity = parseMilliUnits(draft.quantityAmount.trim());
  if (quantity == null) {
    invalid.add(DraftField.quantity);
  }

  if (invalid.isNotEmpty || expiration == null || quantity == null) {
    return DraftResult(invalid: invalid);
  }

  try {
    return DraftResult(
      medicine: Medicine.create(
        id: id,
        name: draft.name,
        strength: strength,
        dosageText: draft.dosage.trim().isEmpty ? null : draft.dosage,
        expiration: expiration,
        batchNumber: batch.isEmpty ? null : batch,
        quantity: Quantity(quantity, draft.quantityUnit),
        keptFor: draft.keptFor.trim().isEmpty ? null : draft.keptFor,
        updatedAt: updatedAt,
      ),
    );
  } on Failure {
    return DraftResult(invalid: {DraftField.name});
  }
}

ExpirationDate? _expiration(MedicineDraft draft) {
  final year = int.tryParse(draft.year.trim());
  final month = int.tryParse(draft.month.trim());
  final dayText = draft.day.trim();
  final day = dayText.isEmpty ? null : int.tryParse(dayText);
  if (year == null || month == null || (dayText.isNotEmpty && day == null)) {
    return null;
  }
  try {
    return ExpirationDate.checked(year: year, month: month, day: day);
  } on Failure {
    return null;
  }
}

bool _badText(String value, {required int maxLength, required bool required}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return required;
  }
  return trimmed.length > maxLength || _hasControl(value);
}

bool _hasControl(String value) {
  return value.runes.any((rune) => rune < 32 || rune == 127);
}
