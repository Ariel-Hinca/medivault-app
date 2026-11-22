import 'dart:math';

import 'package:medivault/core/error/failure.dart';

enum StrengthUnit { mg, g, mcg, ml, iu }

enum QuantityUnit { tablet, capsule, ml, g, piece, dose, other }

enum ExpirationBand { expired, within7Days, within30Days, within90Days, later }

/// A printed strength such as 500 mg. Stored as thousandths of the unit.
final class Strength {
  const Strength(this.milli, this.unit);

  final int milli;
  final StrengthUnit unit;
}

/// How much of a medicine is currently in the cabinet.
final class Quantity {
  const Quantity(this.milli, this.unit);

  final int milli;
  final QuantityUnit unit;
}

/// A pack date. A missing day means the medicine lasts through that month.
final class ExpirationDate {
  const ExpirationDate._(this.year, this.month, this.day);

  final int year;
  final int month;
  final int? day;

  static ExpirationDate checked({
    required int year,
    required int month,
    int? day,
  }) {
    if (year < 1990 || year > 2100 || month < 1 || month > 12) {
      throw const Failure('invalid_medicine');
    }
    final lastDay = _daysInMonth(year, month);
    if (day != null && (day < 1 || day > lastDay)) {
      throw const Failure('invalid_medicine');
    }
    return ExpirationDate._(year, month, day);
  }

  DateTime effectiveEndDate() {
    return DateTime(year, month, day ?? _daysInMonth(year, month));
  }
}

/// One medicine in the household cabinet. Photos and raw OCR text are not stored.
final class Medicine {
  const Medicine._({
    required this.id,
    required this.name,
    required this.strength,
    required this.dosageText,
    required this.expiration,
    required this.batchNumber,
    required this.quantity,
    required this.keptFor,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final Strength? strength;
  final String? dosageText;
  final ExpirationDate expiration;
  final String? batchNumber;
  final Quantity quantity;
  final String? keptFor;
  final DateTime updatedAt;

  factory Medicine.create({
    String? id,
    required String name,
    Strength? strength,
    String? dosageText,
    required ExpirationDate expiration,
    String? batchNumber,
    required Quantity quantity,
    String? keptFor,
    required DateTime updatedAt,
    Random? random,
  }) {
    final resolvedId = id ?? newMedicineId(random ?? Random.secure());
    if (!_uuid.hasMatch(resolvedId)) {
      throw const Failure('invalid_medicine');
    }
    final resolvedName = _requiredText(name, 200);
    final resolvedDosage = _optionalText(dosageText, 200);
    final resolvedBatch = _batch(batchNumber);
    final resolvedKeptFor = _optionalText(keptFor, 40);
    if (strength != null &&
        (strength.milli <= 0 || strength.milli > _maxMilli)) {
      throw const Failure('invalid_medicine');
    }
    if (quantity.milli < 0 || quantity.milli > _maxMilli) {
      throw const Failure('invalid_medicine');
    }
    return Medicine._(
      id: resolvedId,
      name: resolvedName,
      strength: strength,
      dosageText: resolvedDosage,
      expiration: expiration,
      batchNumber: resolvedBatch,
      quantity: quantity,
      keptFor: resolvedKeptFor,
      updatedAt: updatedAt.toUtc(),
    );
  }
}

const _maxMilli = 1000000000;

final _uuid = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
);

final _batchPattern = RegExp(r'^[A-Za-z0-9][A-Za-z0-9\-/]{0,63}$');

String newMedicineId(Random random) {
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  const hex = '0123456789abcdef';
  final chars = bytes
      .map((byte) => '${hex[byte >> 4]}${hex[byte & 0xf]}')
      .join();
  return '${chars.substring(0, 8)}-'
      '${chars.substring(8, 12)}-'
      '${chars.substring(12, 16)}-'
      '${chars.substring(16, 20)}-'
      '${chars.substring(20)}';
}

/// Parses `500`, `1.5`, and `1,5` into thousandths. Returns null when invalid.
int? parseMilliUnits(String input) {
  final trimmed = input.trim().replaceAll(',', '.');
  if (!RegExp(r'^\d+(\.\d{1,3})?$').hasMatch(trimmed)) {
    return null;
  }
  final parts = trimmed.split('.');
  final whole = int.parse(parts[0]);
  final fraction = parts.length == 1
      ? 0
      : int.parse(parts[1].padRight(3, '0'));
  final milli = whole * 1000 + fraction;
  if (milli > _maxMilli) {
    return null;
  }
  return milli;
}

String formatMilliUnits(int milli) {
  final whole = milli ~/ 1000;
  final fraction = milli % 1000;
  if (fraction == 0) {
    return '$whole';
  }
  final digits = fraction
      .toString()
      .padLeft(3, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return '$whole.$digits';
}

ExpirationBand expirationBand(ExpirationDate date, DateTime today) {
  final end = date.effectiveEndDate();
  final todayDate = DateTime(today.year, today.month, today.day);
  if (end.isBefore(todayDate)) {
    return ExpirationBand.expired;
  }
  final days = end.difference(todayDate).inDays;
  if (days <= 7) {
    return ExpirationBand.within7Days;
  }
  if (days <= 30) {
    return ExpirationBand.within30Days;
  }
  if (days <= 90) {
    return ExpirationBand.within90Days;
  }
  return ExpirationBand.later;
}

List<Medicine> filterMedicines(List<Medicine> medicines, String query) {
  final needle = query.trim().toLowerCase();
  final sorted = [...medicines]..sort((a, b) {
    final byName = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    if (byName != 0) {
      return byName;
    }
    return a.id.compareTo(b.id);
  });
  if (needle.isEmpty) {
    return sorted;
  }
  return [
    for (final medicine in sorted)
      if (medicine.name.toLowerCase().contains(needle)) medicine,
  ];
}

String _requiredText(String value, int maxLength) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.length > maxLength || _hasControl(trimmed)) {
    throw const Failure('invalid_medicine');
  }
  return trimmed;
}

String? _optionalText(String? value, int maxLength) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (trimmed.length > maxLength || _hasControl(trimmed)) {
    throw const Failure('invalid_medicine');
  }
  return trimmed;
}

String? _batch(String? value) {
  if (value == null) {
    return null;
  }
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return null;
  }
  if (!_batchPattern.hasMatch(trimmed)) {
    throw const Failure('invalid_medicine');
  }
  return trimmed;
}

bool _hasControl(String value) {
  return value.runes.any((rune) => rune < 32 || rune == 127);
}

int _daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}
