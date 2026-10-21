import 'package:dailytrack/core/security/domain/biometric_authenticator.dart';
import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:local_auth/local_auth.dart';

/// [BiometricAuthenticator] over `local_auth` 3.x (feature 007 research
/// R18). Biometrics only: the app PIN is the fallback, never the device PIN
/// or pattern. Platform calls only, so it is covered by the device check.
// coverage:ignore-start
final class LocalAuthBiometricAuthenticator implements BiometricAuthenticator {
  new([LocalAuthentication? auth]) : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<BiometricAvailability> availability() async {
    try {
      if (!await _auth.canCheckBiometrics) return BiometricAvailability.none;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isEmpty
          ? BiometricAvailability.notEnrolled
          : BiometricAvailability.available;
    } on Object {
      return BiometricAvailability.none;
    }
  }

  @override
  Future<bool> authenticate(String localizedReason) async {
    try {
      return await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );
    } on Object {
      // Cancel, lockout by the OS, or no hardware: the keypad stays ready.
      return false;
    }
  }
}
// coverage:ignore-end
