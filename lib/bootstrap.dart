import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medivault/core/security/cabinet_key.dart';
import 'package:medivault/features/scanning/presentation/scan_page.dart';

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
      home: const CabinetHome(),
    );
  }
}

class CabinetHome extends StatelessWidget {
  const CabinetHome({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MediVault',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Point the camera at a medicine pack. MediVault reads it on this phone, then deletes the photo.',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const ScanPage(),
                    ),
                  );
                },
                child: const Text('Scan a pack'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
