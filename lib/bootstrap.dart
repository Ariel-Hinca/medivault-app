import 'package:material_ui/material_ui.dart';
import 'package:medivault/features/inventory/presentation/cabinet_page.dart';

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
      home: const CabinetPage(),
    );
  }
}
