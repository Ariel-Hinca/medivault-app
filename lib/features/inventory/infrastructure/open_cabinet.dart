import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:medivault/core/error/failure.dart';
import 'package:medivault/core/logging/safe_logger.dart';
import 'package:medivault/core/security/app_lock.dart';
import 'package:medivault/core/security/cabinet_key.dart';
import 'package:medivault/features/inventory/infrastructure/cabinet_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

const _backupChannel = MethodChannel('be.medivault/backup');

/// Support-directory file for the cabinet. It is not the public documents folder.
Future<File> defaultCabinetFile() async {
  final directory = await getApplicationSupportDirectory();
  return File('${directory.path}/cabinet.sqlite');
}

/// Opens the encrypted cabinet. A denied lock does not create a key or a file.
Future<CabinetDatabase> openCabinet({
  required File file,
  required KeyStore keys,
  required AppLock lock,
  required SafeLogger logger,
  EncryptionService? encryption,
}) async {
  if (!await lock.confirm()) {
    throw const Failure('device_credential_required');
  }

  final key = await (encryption ?? EncryptionService(keys)).loadOrCreateKey();
  final existed = file.existsSync();
  sqlite3.tempDirectory = file.parent.path;
  final database = CabinetDatabase(
    NativeDatabase(file, setup: (db) => applyCabinetKey(db, key)),
  );

  try {
    await database.customSelect('SELECT 1').get();
    await _excludeFromBackup(file);
    return database;
  } on Failure {
    await database.close();
    await _deleteIfNew(file, existed);
    logger.event('database_open_failed');
    rethrow;
  } catch (_) {
    await database.close();
    await _deleteIfNew(file, existed);
    logger.event('database_open_failed');
    throw Failure(existed ? 'database_key_rejected' : 'database_open_failed');
  }
}

/// Removes the cabinet file and its key. The database must be closed by this call.
Future<void> eraseCabinet({
  required CabinetDatabase database,
  required File file,
  required KeyStore keys,
  required SafeLogger logger,
}) async {
  await database.close();
  if (file.existsSync()) {
    await file.delete();
  }
  await keys.deleteDatabaseKey();
  logger.event('database_erased');
}

/// Selects SQLCipher (AES-256) and applies a raw 256-bit key.
///
/// sqlite3mc's default cipher is not AES-256. Legacy SQLCipher mode is left
/// off because upstream recommends it only for old files.
void applyCabinetKey(Database db, String keyHex) {
  if (!EncryptionService.isDatabaseKey(keyHex)) {
    throw const Failure('database_key_invalid');
  }
  try {
    final marker = db.select('PRAGMA cipher');
    if (marker.isEmpty) {
      throw const Failure('database_cipher_unavailable');
    }
    db.execute("PRAGMA cipher = 'sqlcipher'");
    final selected = db.select('PRAGMA cipher').first.columnAt(0).toString();
    if (selected != 'sqlcipher') {
      throw const Failure('database_cipher_unavailable');
    }
    db.execute('PRAGMA key = "x\'$keyHex\'"');
    db.execute('SELECT count(*) FROM sqlite_master');
    db.execute('PRAGMA secure_delete = ON');
    db.execute('PRAGMA journal_mode = DELETE');
    db.execute('PRAGMA temp_store = MEMORY');
  } on Failure {
    rethrow;
  } catch (_) {
    throw const Failure('database_key_rejected');
  }
}

Future<void> _excludeFromBackup(File file) async {
  if (!Platform.isIOS) {
    return;
  }
  try {
    await _backupChannel.invokeMethod<void>('excludeFromBackup', {
      'path': file.path,
    });
  } on PlatformException {
    throw const Failure('backup_exclusion_failed');
  }
}

Future<void> _deleteIfNew(File file, bool existed) async {
  if (!existed && file.existsSync()) {
    await file.delete();
  }
}
