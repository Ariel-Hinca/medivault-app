import 'package:medivault/core/logging/safe_logger.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/inventory/domain/medicine_repository.dart';

/// One on-device reminder. [toString] omits the medicine name and the date.
final class Reminder {
  const Reminder({
    required this.id,
    required this.when,
    required this.title,
    required this.body,
  });

  final int id;
  final DateTime when;
  final String title;
  final String body;

  @override
  String toString() => 'Reminder($id)';
}

/// Replaces the device's pending MediVault reminders.
abstract interface class ReminderNotifier {
  Future<void> replace(List<Reminder> reminders);
}

/// Reminders for medicines that are expired or inside 90 days.
///
/// Each band fires at 09:00 local on the morning it starts. A band whose
/// morning has already passed is caught up at the next 09:00.
/// shortcut: that catch-up is scheduled once per app open; repeating it
/// while the app stays closed needs a background reschedule.
List<Reminder> planReminders(List<Medicine> medicines, DateTime now) {
  final reminders = <Reminder>[];
  for (final medicine in medicines) {
    final band = expirationBand(medicine.expiration, now);
    for (final entry in _bandMornings) {
      final when = _bandMorning(medicine.expiration, entry.band);
      if (when.isAfter(now)) {
        reminders.add(_reminder(medicine, entry.band, when));
      }
    }
    if (band != ExpirationBand.later) {
      final started = _bandMorning(medicine.expiration, band);
      if (!started.isAfter(now)) {
        reminders.add(_reminder(medicine, band, _nextNine(now)));
      }
    }
  }
  reminders.sort((a, b) {
    final byWhen = a.when.compareTo(b.when);
    if (byWhen != 0) {
      return byWhen;
    }
    final byTitle = a.title.compareTo(b.title);
    if (byTitle != 0) {
      return byTitle;
    }
    return a.body.compareTo(b.body);
  });
  return reminders;
}

int reminderId(String medicineId, ExpirationBand band) {
  var hash = 0x811c9dc5;
  for (final unit in '$medicineId:${band.name}'.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash == 0 ? 1 : hash;
}

Future<void> syncReminders({
  required MedicineRepository repository,
  required ReminderNotifier notifier,
  required SafeLogger logger,
  required DateTime now,
}) async {
  try {
    final medicines = await repository.findAll();
    await notifier.replace(planReminders(medicines, now));
  } catch (_) {
    logger.event('reminders_failed');
  }
}

Reminder _reminder(Medicine medicine, ExpirationBand band, DateTime when) {
  return Reminder(
    id: reminderId(medicine.id, band),
    when: when,
    title: _title(band),
    body: _body(medicine.name, band),
  );
}

const _bandMornings = <({ExpirationBand band, int daysFromEnd})>[
  (band: ExpirationBand.within90Days, daysFromEnd: -90),
  (band: ExpirationBand.within30Days, daysFromEnd: -30),
  (band: ExpirationBand.within7Days, daysFromEnd: -7),
  (band: ExpirationBand.expired, daysFromEnd: 1),
];

DateTime _bandMorning(ExpirationDate date, ExpirationBand band) {
  final days = _bandMornings
      .firstWhere((entry) => entry.band == band)
      .daysFromEnd;
  final end = date.effectiveEndDate();
  final day = DateTime(end.year, end.month, end.day).add(Duration(days: days));
  return DateTime(day.year, day.month, day.day, 9);
}

DateTime _nextNine(DateTime now) {
  final today = DateTime(now.year, now.month, now.day, 9);
  if (now.isBefore(today)) {
    return today;
  }
  return today.add(const Duration(days: 1));
}

String _title(ExpirationBand band) {
  return switch (band) {
    ExpirationBand.expired => 'Medicine expired',
    ExpirationBand.within7Days => 'Medicine expires within 7 days',
    ExpirationBand.within30Days => 'Medicine expires within 30 days',
    ExpirationBand.within90Days => 'Medicine expires within 90 days',
    ExpirationBand.later => '',
  };
}

String _body(String name, ExpirationBand band) {
  return switch (band) {
    ExpirationBand.expired => '$name is past its expiration date.',
    ExpirationBand.within7Days => '$name expires within 7 days.',
    ExpirationBand.within30Days => '$name expires within 30 days.',
    ExpirationBand.within90Days => '$name expires within 90 days.',
    ExpirationBand.later => '',
  };
}
