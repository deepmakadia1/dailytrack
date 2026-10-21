import 'package:dailytrack/core/security/domain/lock_types.dart';

/// A port over fingerprint or face unlock (research R18). Never throws.
abstract interface class BiometricAuthenticator {
  Future<BiometricAvailability> availability();

  /// Shows the system prompt with [localizedReason]; biometrics only (the
  /// app PIN is the fallback, never the device PIN). False on cancel or
  /// any error.
  Future<bool> authenticate(String localizedReason);
}
