import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medivault/core/logging/safe_logger.dart';
import 'package:medivault/core/security/cabinet_key.dart';

final safeLoggerProvider = Provider<SafeLogger>((ref) => SafeLogger());

final keyStoreProvider = Provider<KeyStore>((ref) => SecureKeyStore());

class MediVaultApp extends StatelessWidget {
  const MediVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediVault',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F5C78)),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Text('MediVault'),
          ),
        ),
      ),
    );
  }
}
