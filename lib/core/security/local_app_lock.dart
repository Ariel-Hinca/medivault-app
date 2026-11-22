import 'package:local_auth/local_auth.dart';
import 'package:medivault/core/security/app_lock.dart';

/// Asks for the fingerprint, face, or device PIN before the cabinet opens.
final class LocalAppLock implements AppLock {
  const LocalAppLock({this._authentication});

  final LocalAuthentication? _authentication;

  @override
  Future<bool> confirm() async {
    final authentication = _authentication ?? LocalAuthentication();
    try {
      if (!await authentication.isDeviceSupported()) {
        return false;
      }
      return await authentication.authenticate(
        localizedReason: 'Open your medicine cabinet',
        biometricOnly: false,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}
