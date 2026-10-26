/// What a crash report says about an error: its type only (Constitution
/// III: no financial or habit data in crash SDKs). An exception's message
/// can carry user text (a note, a category name, an amount), so it never
/// leaves the device; the stack trace holds only code locations. Pure Dart.
final class RedactedError implements Exception {
  const new(this.type);

  /// E.g. `BackupInvalid`, `StateError`.
  final String type;

  @override
  String toString() => type;
}

/// [error] without its message.
RedactedError redactError(Object error) =>
    RedactedError(error.runtimeType.toString());
