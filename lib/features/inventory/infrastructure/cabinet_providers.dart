import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivault/core/logging/safe_logger.dart';
import 'package:medivault/core/security/app_lock.dart';
import 'package:medivault/core/security/cabinet_key.dart';
import 'package:medivault/core/security/local_app_lock.dart';
import 'package:medivault/features/inventory/domain/medicine_repository.dart';
import 'package:medivault/features/inventory/infrastructure/drift_medicine_repository.dart';
import 'package:medivault/features/inventory/infrastructure/open_cabinet.dart';

final appLockProvider = Provider<AppLock>((ref) => const LocalAppLock());

/// Opens the encrypted cabinet after the phone lock succeeds.
final medicineRepositoryProvider = FutureProvider<MedicineRepository>((
  ref,
) async {
  final database = await openCabinet(
    file: await defaultCabinetFile(),
    keys: ref.watch(keyStoreProvider),
    lock: ref.watch(appLockProvider),
    logger: ref.watch(safeLoggerProvider),
  );
  ref.onDispose(database.close);
  return DriftMedicineRepository(database);
});
