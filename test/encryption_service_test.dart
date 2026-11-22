import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:medivault/core/error/failure.dart';
import 'package:medivault/core/security/cabinet_key.dart';

void main() {
  test('creates a 256-bit key once and keeps it', () async {
    final store = _MemoryKeyStore();
    final service = EncryptionService(store, random: Random(7));

    final first = await service.loadOrCreateKey();
    final second = await service.loadOrCreateKey();

    expect(first, hasLength(64));
    expect(EncryptionService.isDatabaseKey(first), isTrue);
    expect(second, first);
  });

  test('rejects a stored key that is not 256-bit hex', () async {
    final store = _MemoryKeyStore();
    await store.writeDatabaseKey('short');

    expect(
      () => EncryptionService(store).loadOrCreateKey(),
      throwsA(
        isA<Failure>().having(
          (failure) => failure.code,
          'code',
          'database_key_invalid',
        ),
      ),
    );
  });
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
