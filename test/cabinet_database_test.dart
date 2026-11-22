import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivault/core/error/failure.dart';
import 'package:medivault/core/logging/safe_logger.dart';
import 'package:medivault/core/security/app_lock.dart';
import 'package:medivault/core/security/cabinet_key.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/inventory/infrastructure/drift_medicine_repository.dart';
import 'package:medivault/features/inventory/infrastructure/open_cabinet.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('medivault-cabinet');
  });

  tearDown(() async {
    if (directory.existsSync()) {
      await directory.delete(recursive: true);
    }
  });

  test('refuses to create a cabinet when the lock is denied', () async {
    final file = File('${directory.path}/cabinet.sqlite');
    final store = _MemoryKeyStore();
    final seen = <String>[];

    await expectLater(
      openCabinet(
        file: file,
        keys: store,
        lock: _TestLock(false),
        logger: SafeLogger(sink: seen.add),
      ),
      throwsA(
        isA<Failure>().having(
          (failure) => failure.code,
          'code',
          'device_credential_required',
        ),
      ),
    );
    expect(file.existsSync(), isFalse);
    expect(store.value, isNull);
    expect(seen, isEmpty);
  });

  test('round-trips medicines and hides them in the file', () async {
    final file = File('${directory.path}/cabinet.sqlite');
    final store = _MemoryKeyStore();
    final logger = SafeLogger();
    final opened = await openCabinet(
      file: file,
      keys: store,
      lock: _TestLock(true),
      logger: logger,
    );
    final repository = DriftMedicineRepository(opened);
    final dafalgan = _medicine('Dafalgan');
    final ibuprofen = _medicine('Ibuprofen');
    await repository.save(dafalgan);
    await repository.save(ibuprofen);
    await repository.save(
      Medicine.create(
        id: dafalgan.id,
        name: 'Dafalgan Forte',
        expiration: dafalgan.expiration,
        quantity: dafalgan.quantity,
        updatedAt: DateTime.utc(2026, 11, 22, 12),
      ),
    );

    expect((await repository.findById(dafalgan.id))?.name, 'Dafalgan Forte');
    expect(
      (await repository.findAll(nameQuery: 'ibu')).map((item) => item.name),
      ['Ibuprofen'],
    );
    expect((await repository.findById(dafalgan.id))?.expiration.day, isNull);
    await repository.delete(ibuprofen.id);
    expect(await repository.findAll(), hasLength(1));
    await opened.close();

    final stored = String.fromCharCodes(await file.readAsBytes());
    final key = store.value!;
    expect(stored.contains('Dafalgan'), isFalse);
    expect(stored.contains('Ibuprofen'), isFalse);
    expect(stored.contains(key), isFalse);

    final reopened = await openCabinet(
      file: file,
      keys: store,
      lock: _TestLock(true),
      logger: logger,
    );
    final columns = await reopened
        .customSelect('PRAGMA table_info(medicines)')
        .get();
    final names = columns.map((row) => row.read<String>('name')).toSet();
    expect(names, isNot(contains('raw_text')));
    expect(
      (await DriftMedicineRepository(reopened).findById(dafalgan.id))?.name,
      'Dafalgan Forte',
    );
    await reopened.close();
  });

  test('a wrong key leaves the file in place and is not echoed', () async {
    final file = File('${directory.path}/cabinet.sqlite');
    final store = _MemoryKeyStore();
    final seen = <String>[];
    final opened = await openCabinet(
      file: file,
      keys: store,
      lock: _TestLock(true),
      logger: SafeLogger(sink: seen.add),
    );
    await opened.close();
    final key = store.value!;
    final wrong = key.startsWith('a')
        ? 'b${key.substring(1)}'
        : 'a${key.substring(1)}';
    final other = _MemoryKeyStore()..value = wrong;

    await expectLater(
      openCabinet(
        file: file,
        keys: other,
        lock: _TestLock(true),
        logger: SafeLogger(sink: seen.add),
      ),
      throwsA(
        predicate<Failure>(
          (failure) =>
              failure.code == 'database_key_rejected' &&
              !failure.toString().contains(wrong) &&
              !failure.toString().contains(key),
        ),
      ),
    );
    expect(file.existsSync(), isTrue);
    expect(seen, ['database_open_failed']);
  });

  test('erase removes the file and the key', () async {
    final file = File('${directory.path}/cabinet.sqlite');
    final store = _MemoryKeyStore();
    final seen = <String>[];
    final opened = await openCabinet(
      file: file,
      keys: store,
      lock: _TestLock(true),
      logger: SafeLogger(sink: seen.add),
    );
    await DriftMedicineRepository(opened).save(_medicine('Dafalgan'));

    await eraseCabinet(
      database: opened,
      file: file,
      keys: store,
      logger: SafeLogger(sink: seen.add),
    );

    expect(file.existsSync(), isFalse);
    expect(store.value, isNull);
    expect(seen, ['database_erased']);
  });

  test('secure key store round-trips through the platform interface', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
    final store = SecureKeyStore();
    final key = 'ab' * 32;

    await store.writeDatabaseKey(key);

    expect(await store.readDatabaseKey(), key);
    await store.deleteDatabaseKey();
    expect(await store.readDatabaseKey(), isNull);
  });
}

Medicine _medicine(String name) {
  return Medicine.create(
    name: name,
    strength: Strength(500000, StrengthUnit.mg),
    dosageText: 'As printed',
    expiration: ExpirationDate.checked(year: 2028, month: 4),
    batchNumber: 'B1',
    quantity: const Quantity(20000, QuantityUnit.tablet),
    keptFor: 'Mom',
    updatedAt: DateTime.utc(2026, 11, 22),
  );
}

final class _TestLock implements AppLock {
  _TestLock(this.allowed);

  final bool allowed;

  @override
  Future<bool> confirm() async => allowed;
}

final class _MemoryKeyStore implements KeyStore {
  String? value;

  @override
  Future<void> deleteDatabaseKey() async {
    value = null;
  }

  @override
  Future<String?> readDatabaseKey() async => value;

  @override
  Future<void> writeDatabaseKey(String key) async {
    value = key;
  }
}
