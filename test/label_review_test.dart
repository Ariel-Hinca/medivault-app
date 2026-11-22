import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:medivault/features/inventory/domain/medicine.dart';
import 'package:medivault/features/scanning/domain/pack_label.dart';
import 'package:medivault/features/scanning/presentation/scan_page.dart';

void main() {
  testWidgets('shows the reading and asks for a check when unsure', (
    tester,
  ) async {
    final reading = readLabel([
      const RecognizedLine('Dafalgan 500mg', confidenceMilli: 900),
      const RecognizedLine('1 tablet', confidenceMilli: 800),
      const RecognizedLine('EXP 04/2028', confidenceMilli: 860),
      const RecognizedLine('Lot AB-12', confidenceMilli: 500),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LabelReview(reading: reading, onScanAgain: () {}),
        ),
      ),
    );

    expect(find.text('Dafalgan'), findsOneWidget);
    expect(find.text('500 mg'), findsOneWidget);
    expect(find.text('1 tablet'), findsOneWidget);
    expect(find.text('04/2028'), findsOneWidget);
    expect(find.text('AB-12'), findsOneWidget);
    expect(find.text('90% sure'), findsNWidgets(2));
    expect(find.text('Please check'), findsOneWidget);
    expect(find.text('Not found'), findsNothing);
    await tester.scrollUntilVisible(
      find.text(
        'This reading stays on this screen. It is not saved in the cabinet.',
      ),
      200,
    );
    expect(
      find.text(
        'This reading stays on this screen. It is not saved in the cabinet.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('says when a field was not found', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LabelReview(
            reading: LabelReading(
              name: LabelField('Dafalgan', confidenceMilli: null),
              strength: LabelField(
                Strength(500000, StrengthUnit.mg),
                confidenceMilli: 900,
              ),
            ),
            onScanAgain: () {},
          ),
        ),
      ),
    );

    expect(find.text('Not found'), findsNWidgets(3));
    expect(find.text('Please check'), findsWidgets);
  });
}
