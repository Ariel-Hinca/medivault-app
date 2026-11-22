import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:medivault/core/logging/safe_logger.dart';
import 'package:medivault/features/inventory/infrastructure/cabinet_providers.dart';
import 'package:medivault/features/notifications/domain/reminder_plan.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final reminderNotifierProvider = Provider<ReminderNotifier>(
  (ref) => LocalReminderNotifier(),
);

/// Rebuilds on-device reminders from the whole cabinet, ignoring search.
final reminderSyncProvider = FutureProvider<void>((ref) async {
  final repository = await ref.watch(medicineRepositoryProvider.future);
  await syncReminders(
    repository: repository,
    notifier: ref.watch(reminderNotifierProvider),
    logger: ref.watch(safeLoggerProvider),
    now: DateTime.now(),
  );
});

final class LocalReminderNotifier implements ReminderNotifier {
  final _plugin = FlutterLocalNotificationsPlugin();
  var _ready = false;

  @override
  Future<void> replace(List<Reminder> reminders) async {
    await _ensureReady();
    if (await _allowed() != true) {
      throw StateError('notifications_not_allowed');
    }
    await _useLocalZone();
    await _plugin.cancelAll();
    // shortcut: iOS keeps 64 pending notifications; a larger cabinet schedules the soonest 64 until the app opens again.
    for (final reminder in reminders.take(64)) {
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: reminder.title,
        body: reminder.body,
        scheduledDate: tz.TZDateTime(
          tz.local,
          reminder.when.year,
          reminder.when.month,
          reminder.when.day,
          reminder.when.hour,
        ),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> _ensureReady() async {
    if (_ready) {
      return;
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  Future<bool?> _allowed() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android =>
        _plugin
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >()
                ?.requestNotificationsPermission() ??
            Future<bool?>.value(false),
      TargetPlatform.iOS =>
        _plugin
                .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin
                >()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            Future<bool?>.value(false),
      _ => Future<bool?>.value(false),
    };
  }

  Future<void> _useLocalZone() async {
    tz_data.initializeTimeZones();
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  }
}

const _details = NotificationDetails(
  android: AndroidNotificationDetails(
    'expiration',
    'Expiration reminders',
    channelDescription: 'Alerts when a medicine is expired or expiring.',
    visibility: NotificationVisibility.private,
  ),
  iOS: DarwinNotificationDetails(),
);
