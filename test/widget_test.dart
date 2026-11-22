import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medivault/bootstrap.dart';

void main() {
  testWidgets('shows the app name', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MediVaultApp()));

    expect(find.text('MediVault'), findsOneWidget);
  });
}
