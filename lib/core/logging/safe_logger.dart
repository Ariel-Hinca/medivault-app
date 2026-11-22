/// Logs event codes only. Medicine data, keys, and OCR text are never accepted.
final class SafeLogger {
  SafeLogger({this.sink});

  static const allowed = <String>{
    'database_open_failed',
    'database_erased',
  };

  final void Function(String code)? sink;

  void event(String code) {
    if (!allowed.contains(code)) {
      return;
    }
    sink?.call(code);
  }
}
