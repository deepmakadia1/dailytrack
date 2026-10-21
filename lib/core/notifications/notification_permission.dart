/// Asks for permission to show notifications. Pure Dart, so presentation code
/// can depend on it without importing the platform plugin.
abstract interface class NotificationPermission {
  /// Requests POST_NOTIFICATIONS on Android 13+. Returns whether notifications
  /// are allowed; true on Android 12 and lower, where there is no runtime
  /// permission. Never throws: denial is a normal result.
  Future<bool> request();
}
