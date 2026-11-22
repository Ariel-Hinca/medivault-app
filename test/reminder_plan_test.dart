import 'package:flutter_test/flutter_test.dart';
import 'package:medivault/core/logging/safe_logger.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/inventory/domain/medicine_repository.dart';
import 'package:medivault/features/notifications/domain/reminder_plan.dart';

void main() {
  test('plans catch-up and later band mornings without dates in the text', () {
    final now = DateTime(2026, 11, 22, 15);
    final expired = _medicine(
      '11111111-1111-4111-8111-111111111111',
      'Old Pack',
      ExpirationDate.checked(year: 2026, month: 11, day: 21),
    );
    final week = _medicine(
      '22222222-2222-4222-8222-222222222222',
      'Week Pack',
      ExpirationDate.checked(year: 2026, month: 11, day: 29),
    );
    final later = _medicine(
      '33333333-3333-4333-8333-333333333333',
      'Later Pack',
      ExpirationDate.checked(year: 2027, month: 2, day: 21),
    );

    final reminders = planReminders([later, expired, week], now);

    expect(reminders.map((reminder) => reminder.toString()).toList(), [
      'Reminder(${reminderId(expired.id, ExpirationBand.expired)})',
      'Reminder(${reminderId(week.id, ExpirationBand.within7Days)})',
      'Reminder(${reminderId(later.id, ExpirationBand.within90Days)})',
      'Reminder(${reminderId(week.id, ExpirationBand.expired)})',
      'Reminder(${reminderId(later.id, ExpirationBand.within30Days)})',
      'Reminder(${reminderId(later.id, ExpirationBand.within7Days)})',
      'Reminder(${reminderId(later.id, ExpirationBand.expired)})',
    ]);
    expect(reminders.map((reminder) => reminder.when).toList(), [
      DateTime(2026, 11, 23, 9),
      DateTime(2026, 11, 23, 9),
      DateTime(2026, 11, 23, 9),
      DateTime(2026, 11, 30, 9),
      DateTime(2027, 1, 22, 9),
      DateTime(2027, 2, 14, 9),
      DateTime(2027, 2, 22, 9),
    ]);
    expect(reminders[0].title, 'Medicine expired');
    expect(reminders[0].body, 'Old Pack is past its expiration date.');
    expect(reminders[1].body, 'Week Pack expires within 7 days.');
    expect(reminders[2].body, 'Later Pack expires within 90 days.');
    expect(
      reminders.every((reminder) => !reminder.body.contains('2026')),
      isTrue,
    );
    expect(reminders.first.id, inInclusiveRange(1, 0x7fffffff));
  });

  test('a failed schedule records only the failure code', () async {
    final seen = <String>[];
    final notifier = _ThrowingNotifier();

    await syncReminders(
      repository: _Cabinet([
        _medicine(
          '11111111-1111-4111-8111-111111111111',
          'Old Pack',
          ExpirationDate.checked(year: 2026, month: 11, day: 21),
        ),
      ]),
      notifier: notifier,
      logger: SafeLogger(sink: seen.add),
      now: DateTime(2026, 11, 22, 15),
    );

    expect(seen, ['reminders_failed']);
  });
}

Medicine _medicine(String id, String name, ExpirationDate expiration) {
  return Medicine.create(
    id: id,
    name: name,
    expiration: expiration,
    quantity: const Quantity(1000, QuantityUnit.tablet),
    updatedAt: DateTime.utc(2026, 11, 22),
  );
}

final class _Cabinet implements MedicineRepository {
  _Cabinet(this._medicines);

  final List<Medicine> _medicines;

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> deleteAll() async {}

  @override
  Future<List<Medicine>> findAll({String nameQuery = ''}) async => _medicines;

  @override
  Future<Medicine?> findById(String id) async => null;

  @override
  Future<void> save(Medicine medicine) async {}
}

final class _ThrowingNotifier implements ReminderNotifier {
  @override
  Future<void> replace(List<Reminder> reminders) async {
    throw StateError(reminders.first.body);
  }
}
