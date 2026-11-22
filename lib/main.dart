import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:medivault/bootstrap.dart';
import 'package:medivault/features/scanning/infrastructure/mlkit_pack_text_reader.dart';
import 'package:medivault/features/scanning/presentation/scan_page.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: [
        packTextReaderProvider.overrideWith((ref) {
          final reader = MlKitPackTextReader();
          ref.onDispose(() {
            reader.close();
          });
          return reader;
        }),
      ],
      child: const MediVaultApp(),
    ),
  );
}
