import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:medivault/core/error/failure.dart';

/// Stores the cabinet database key outside the database file.
abstract interface class KeyStore {
  Future<String?> readDatabaseKey();

  Future<void> writeDatabaseKey(String key);

  Future<void> deleteDatabaseKey();
}

/// Creates and loads the 256-bit key used to encrypt the cabinet file.
final class EncryptionService {
  EncryptionService(this._keys, {Random? random})
    : _random = random ?? Random.secure();

  static final _keyPattern = RegExp(r'^[0-9a-f]{64}$');

  final KeyStore _keys;
  final Random _random;

  static bool isDatabaseKey(String value) => _keyPattern.hasMatch(value);

  Future<String> loadOrCreateKey() async {
    final existing = await _keys.readDatabaseKey();
    if (existing != null) {
      if (!isDatabaseKey(existing)) {
        throw const Failure('database_key_invalid');
      }
      return existing;
    }
    final created = generateDatabaseKey(_random);
    await _keys.writeDatabaseKey(created);
    return created;
  }
}

String generateDatabaseKey(Random random) {
  final bytes = List<int>.generate(32, (_) => random.nextInt(256));
  return bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
}

/// Keystore on Android and Keychain on iOS. The key never enters the database.
final class SecureKeyStore implements KeyStore {
  SecureKeyStore({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(
              resetOnError: true,
              migrateWithBackup: false,
            ),
            iOptions: IOSOptions(
              accountName: _accountName,
              accessibility: KeychainAccessibility.first_unlock_this_device,
              synchronizable: false,
            ),
            mOptions: MacOsOptions(
              accountName: _accountName,
              accessibility: KeychainAccessibility.first_unlock_this_device,
              synchronizable: false,
            ),
          );

  static const _accountName = 'be.medivault.cabinet';
  static const _keyName = 'cabinet_db_key';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readDatabaseKey() {
    return _guard(() => _storage.read(key: _keyName));
  }

  @override
  Future<void> writeDatabaseKey(String key) {
    return _guard(() => _storage.write(key: _keyName, value: key));
  }

  @override
  Future<void> deleteDatabaseKey() {
    return _guard(() => _storage.delete(key: _keyName));
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException {
      throw const Failure('key_store_failed');
    }
  }
}
