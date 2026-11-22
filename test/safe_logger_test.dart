import 'package:flutter_test/flutter_test.dart';
import 'package:medivault/core/logging/safe_logger.dart';

void main() {
  test('records allow-listed codes and drops everything else', () {
    final seen = <String>[];
    final logger = SafeLogger(sink: seen.add);

    logger.event('database_erased');
    logger.event('Dafalgan');
    logger.event('scan_failed');
    logger.event('database_open_failed EXP 04/2028');

    expect(seen, ['database_erased', 'scan_failed']);
  });
}
