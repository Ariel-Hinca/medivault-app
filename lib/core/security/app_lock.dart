/// Confirms the person holding the phone before the cabinet key is used.
abstract interface class AppLock {
  Future<bool> confirm();
}
