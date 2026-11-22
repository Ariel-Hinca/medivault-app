/// A failure the UI can show without revealing stored data or a stack trace.
final class Failure implements Exception {
  const Failure(this.code);

  final String code;

  @override
  String toString() => 'Failure($code)';
}
