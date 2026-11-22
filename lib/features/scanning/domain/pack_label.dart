import 'package:medivault/core/error/failure.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';

/// One line from a pack photo. The photo and the raw lines are not stored.
final class RecognizedLine {
  const RecognizedLine(this.text, {required this.confidenceMilli});

  final String text;

  /// 0 to 1000. Null when the recognizer did not score the line.
  final int? confidenceMilli;
}

/// Reads text from a pack photo. ML Kit is one implementation.
abstract interface class PackTextReader {
  Future<List<RecognizedLine>> readFile(String path);
}

/// Used when scanning is not wired up. It never reads a file.
final class UnavailablePackTextReader implements PackTextReader {
  const UnavailablePackTextReader();

  @override
  Future<List<RecognizedLine>> readFile(String path) async {
    throw const Failure('scan_unavailable');
  }
}

/// One extracted value and the confidence of the line it came from.
final class LabelField<T> {
  const LabelField(this.value, {required this.confidenceMilli});

  final T value;
  final int? confidenceMilli;
}

/// Fields read from a pack. Missing fields stay null so the user can check them.
final class LabelReading {
  const LabelReading({
    this.name,
    this.strength,
    this.dosage,
    this.expiration,
    this.batchNumber,
  });

  final LabelField<String>? name;
  final LabelField<Strength>? strength;
  final LabelField<String>? dosage;
  final LabelField<ExpirationDate>? expiration;
  final LabelField<String>? batchNumber;

  bool get isEmpty =>
      name == null &&
      strength == null &&
      dosage == null &&
      expiration == null &&
      batchNumber == null;
}

/// Converts a recognizer score in the range 0 to 1 into thousandths.
int? confidenceMilliFromUnitInterval(double? confidence) {
  if (confidence == null || confidence.isNaN || confidence.isInfinite) {
    return null;
  }
  if (confidence < 0 || confidence > 1) {
    return null;
  }
  return (confidence * 1000).round();
}

/// Pulls medicine fields out of recognized lines. Untrusted text is dropped.
LabelReading readLabel(List<RecognizedLine> lines) {
  final cleaned = <RecognizedLine>[];
  for (final line in lines) {
    final text = _clean(line.text);
    if (text == null) {
      continue;
    }
    cleaned.add(RecognizedLine(text, confidenceMilli: _score(line)));
  }

  final expiration = _best(cleaned, _expirationAt);
  final batch = _best(cleaned, _batchAt);
  final blocked = <int>{...?expiration?.indexes, ...?batch?.indexes};
  final strength = _best(cleaned, _strengthAt);
  final dosage = _best(cleaned, (lines, index) {
    if (blocked.contains(index)) {
      return null;
    }
    return _dosageAt(lines, index);
  });
  final name = _name(cleaned, strength, blocked);

  return LabelReading(
    name: name?.field,
    strength: strength?.field,
    dosage: dosage?.field,
    expiration: expiration?.field,
    batchNumber: batch?.field,
  );
}

final class _Pick<T> {
  const _Pick(this.field, this.indexes);

  final LabelField<T> field;
  final List<int> indexes;
}

final _strength = RegExp(
  r'(\d+(?:[.,]\d{1,3})?)\s*(mcg|mg|ml|iu|g|µg|μg|ug)\b',
  caseSensitive: false,
);

final _expLabel = RegExp(
  r'\b(?:exp(?:iry|iration)?|verval(?:datum)?|tht|houdbaar|use\s+by|use\s+before)\b',
  caseSensitive: false,
);

final _batchLabel = RegExp(
  r'\b(?:lot(?:\s*nr|\.?nr)?|batch|bn|ch\.?\s*-?\s*b\.?)\b',
  caseSensitive: false,
);

final _batchSame = RegExp(
  r'\b(?:lot(?:\s*nr|\.?nr)?|batch|bn|ch\.?\s*-?\s*b\.?)[:\s.\-]+([A-Za-z0-9][A-Za-z0-9\-/]{0,63})',
  caseSensitive: false,
);

final _printedBatch = RegExp(
  r'^(?:lot|batch|bn)[A-Za-z0-9\-/]*\d[A-Za-z0-9\-/]*$',
  caseSensitive: false,
);

final _batchOnly = RegExp(
  r'^(?:lot(?:\s*nr|\.?nr)?|batch|bn|ch\.?\s*-?\s*b\.?)[:\s.\-]*$',
  caseSensitive: false,
);

final _batchValue = RegExp(r'^[A-Za-z0-9][A-Za-z0-9\-/]{0,63}$');

final _dosage = RegExp(
  r'\b(\d+(?:[.,]\d{1,3})?)\s*(tabletten|tablets|tablet|capsules|capsule|caps|ml|doses|dose|druppels|druppel)\b',
  caseSensitive: false,
);

final _twoLetters = RegExp('[A-Za-zÀ-ÖØ-öø-ÿ]{2}');

const _maxSolidMilli = 10000;
const _maxLiquidMilli = 30000;

_Pick<T>? _best<T>(
  List<RecognizedLine> lines,
  _Pick<T>? Function(List<RecognizedLine> lines, int index) read,
) {
  _Pick<T>? best;
  for (var index = 0; index < lines.length; index++) {
    best = _keepBest(best, read(lines, index));
  }
  return best;
}

_Pick<T>? _keepBest<T>(_Pick<T>? current, _Pick<T>? next) {
  if (next == null) {
    return current;
  }
  if (current == null) {
    return next;
  }
  final nextScore = next.field.confidenceMilli;
  final currentScore = current.field.confidenceMilli;
  if (currentScore == null) {
    return nextScore == null ? current : next;
  }
  if (nextScore != null && nextScore > currentScore) {
    return next;
  }
  return current;
}

_Pick<ExpirationDate>? _expirationAt(List<RecognizedLine> lines, int index) {
  final text = lines[index].text;
  if (!_expLabel.hasMatch(text)) {
    return null;
  }
  final onSameLine = _dateIn(text);
  if (onSameLine != null) {
    return _Pick(
      LabelField(onSameLine, confidenceMilli: _score(lines[index])),
      [index],
    );
  }
  if (index + 1 >= lines.length) {
    return null;
  }
  final onNextLine = _dateIn(lines[index + 1].text);
  if (onNextLine == null) {
    return null;
  }
  return _Pick(
    LabelField(
      onNextLine,
      confidenceMilli: _combine(_score(lines[index]), _score(lines[index + 1])),
    ),
    [index, index + 1],
  );
}

_Pick<String>? _batchAt(List<RecognizedLine> lines, int index) {
  final text = lines[index].text;
  final same = _batchSame.firstMatch(text);
  final inline = same?.group(1);
  if (inline != null && _acceptBatch(inline)) {
    return _Pick(LabelField(inline, confidenceMilli: _score(lines[index])), [
      index,
    ]);
  }
  if (_printedBatch.hasMatch(text)) {
    return _Pick(LabelField(text, confidenceMilli: _score(lines[index])), [
      index,
    ]);
  }
  if (!_batchOnly.hasMatch(text) || index + 1 >= lines.length) {
    return null;
  }
  final next = lines[index + 1].text.trim();
  if (!_acceptBatch(next)) {
    return null;
  }
  return _Pick(
    LabelField(
      next,
      confidenceMilli: _combine(_score(lines[index]), _score(lines[index + 1])),
    ),
    [index, index + 1],
  );
}

bool _acceptBatch(String value) {
  return _batchValue.hasMatch(value) &&
      _dateIn(value) == null &&
      RegExp(r'\d').hasMatch(value);
}

_Pick<Strength>? _strengthAt(List<RecognizedLine> lines, int index) {
  final match = _strength.firstMatch(lines[index].text);
  if (match == null) {
    return null;
  }
  final milli = parseMilliUnits(match.group(1)!);
  final unit = _unit(match.group(2)!);
  if (milli == null || milli <= 0 || unit == null) {
    return null;
  }
  return _Pick(
    LabelField(Strength(milli, unit), confidenceMilli: _score(lines[index])),
    [index],
  );
}

_Pick<String>? _dosageAt(List<RecognizedLine> lines, int index) {
  final match = _dosage.firstMatch(lines[index].text);
  if (match == null) {
    return null;
  }
  final milli = parseMilliUnits(match.group(1)!);
  if (milli == null || milli <= 0) {
    return null;
  }
  final unit = match.group(2)!.toLowerCase();
  final liquid = unit == 'ml';
  if (milli > (liquid ? _maxLiquidMilli : _maxSolidMilli)) {
    return null;
  }
  return _Pick(
    LabelField(_dosageText(milli, unit), confidenceMilli: _score(lines[index])),
    [index],
  );
}

_Pick<String>? _name(
  List<RecognizedLine> lines,
  _Pick<Strength>? strength,
  Set<int> blocked,
) {
  if (strength != null) {
    final index = strength.indexes.first;
    final beside = _withoutStrengths(lines[index].text);
    if (_looksLikeName(beside)) {
      return _Pick(LabelField(beside, confidenceMilli: _score(lines[index])), [
        index,
      ]);
    }
    for (var previous = index - 1; previous >= 0; previous--) {
      if (blocked.contains(previous) ||
          _dosage.hasMatch(lines[previous].text)) {
        continue;
      }
      if (!_looksLikeName(lines[previous].text)) {
        continue;
      }
      return _Pick(
        LabelField(
          lines[previous].text,
          confidenceMilli: _combine(
            _score(lines[index]),
            _score(lines[previous]),
          ),
        ),
        [previous],
      );
    }
  }

  _Pick<String>? best;
  for (var index = 0; index < lines.length; index++) {
    if (blocked.contains(index) || _dosage.hasMatch(lines[index].text)) {
      continue;
    }
    final candidate = _withoutStrengths(lines[index].text);
    if (!_looksLikeName(candidate)) {
      continue;
    }
    best = _keepBest(
      best,
      _Pick(LabelField(candidate, confidenceMilli: _score(lines[index])), [
        index,
      ]),
    );
  }
  return best;
}

bool _looksLikeName(String text) {
  if (text.length < 2 || text.length > 80 || _hasControl(text)) {
    return false;
  }
  if (!_twoLetters.hasMatch(text)) {
    return false;
  }
  if (_expLabel.hasMatch(text) || _batchLabel.hasMatch(text)) {
    return false;
  }
  if (_dosage.hasMatch(text)) {
    return false;
  }
  return true;
}

String _withoutStrengths(String text) {
  final stripped = text
      .replaceAll(_strength, ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  return stripped.replaceAll(RegExp(r'^[\s,.:;/\-]+|[\s,.:;/\-]+$'), '');
}

String _dosageText(int milli, String unit) {
  final number = formatMilliUnits(milli);
  final one = milli == 1000;
  final label = switch (unit) {
    'tablet' || 'tablets' || 'tabletten' => one ? 'tablet' : 'tablets',
    'capsule' || 'capsules' || 'caps' => one ? 'capsule' : 'capsules',
    'dose' || 'doses' => one ? 'dose' : 'doses',
    'druppel' || 'druppels' => one ? 'drop' : 'drops',
    _ => 'ml',
  };
  return '$number $label';
}

StrengthUnit? _unit(String raw) {
  return switch (raw.toLowerCase()) {
    'mg' => StrengthUnit.mg,
    'g' => StrengthUnit.g,
    'mcg' || 'ug' || 'µg' || 'μg' => StrengthUnit.mcg,
    'ml' => StrengthUnit.ml,
    'iu' => StrengthUnit.iu,
    _ => null,
  };
}

ExpirationDate? _dateIn(String text) {
  final tightened = _tighten(text);
  final yearFirst = RegExp(r'\b(\d{4})[./-](\d{1,2})(?:[./-](\d{1,2}))?\b')
      .firstMatch(tightened);
  if (yearFirst != null) {
    final parsed = _tryDate(
      year: int.parse(yearFirst.group(1)!),
      month: int.parse(yearFirst.group(2)!),
      day: yearFirst.group(3) == null ? null : int.parse(yearFirst.group(3)!),
    );
    if (parsed != null) {
      return parsed;
    }
  }
  final dayFirst = RegExp(r'\b(\d{1,2})[./-](\d{1,2})[./-](\d{4})\b')
      .firstMatch(tightened);
  if (dayFirst != null) {
    return _tryDate(
      year: int.parse(dayFirst.group(3)!),
      month: int.parse(dayFirst.group(2)!),
      day: int.parse(dayFirst.group(1)!),
    );
  }
  final monthFirst = RegExp(r'\b(\d{1,2})[./-](\d{4})\b').firstMatch(tightened);
  if (monthFirst == null) {
    return null;
  }
  return _tryDate(
    year: int.parse(monthFirst.group(2)!),
    month: int.parse(monthFirst.group(1)!),
  );
}

ExpirationDate? _tryDate({required int year, required int month, int? day}) {
  try {
    return ExpirationDate.checked(year: year, month: month, day: day);
  } on Failure {
    return null;
  }
}

String _tighten(String text) {
  final separator = RegExp(r'(\d)\s*[./-]\s*(\d)');
  var current = text;
  for (var pass = 0; pass < 3; pass++) {
    final next = current.replaceAllMapped(
      separator,
      (match) => '${match[1]}/${match[2]}',
    );
    if (next == current) {
      return current;
    }
    current = next;
  }
  return current;
}

String? _clean(String raw) {
  final trimmed = raw
      .replaceAll('®', '')
      .replaceAll('™', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  if (trimmed.isEmpty || trimmed.length > 300 || _hasControl(trimmed)) {
    return null;
  }
  return trimmed;
}

int? _score(RecognizedLine line) {
  final value = line.confidenceMilli;
  if (value == null || value < 0 || value > 1000) {
    return null;
  }
  return value;
}

int? _combine(int? first, int? second) {
  if (first == null || second == null) {
    return null;
  }
  return first < second ? first : second;
}

bool _hasControl(String value) {
  return value.runes.any((rune) => rune < 32 || rune == 127);
}
