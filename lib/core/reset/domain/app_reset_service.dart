/// "Erase all data" (SET-01 Data, SYS-03 "Forgot PIN?"; feature 007
/// FR-047, FR-048, research R16).
abstract interface class AppResetService {
  /// Deletes every row in one transaction, then (best effort) module files
  /// and alarms, notifications, and the app lock, and restarts the app at
  /// onboarding. Throws only when the database step fails, in which case
  /// nothing was deleted.
  Future<void> eraseAll();
}
