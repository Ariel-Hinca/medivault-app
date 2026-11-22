import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medivault/features/inventory/presentation/cabinet_page.dart';
import 'package:medivault/features/notifications/infrastructure/local_reminders.dart';

class MediVaultApp extends ConsumerWidget {
  const MediVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(reminderSyncProvider);
    return MaterialApp(
      title: 'MediVault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F5C78)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const CabinetPage(),
    );
  }
}
