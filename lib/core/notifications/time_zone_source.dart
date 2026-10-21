import 'package:flutter/services.dart';

/// The device's IANA time zone id, e.g. `Asia/Kolkata` (feature 005 research
/// R1). The `timezone` package cannot read it, so Android answers over a
/// small platform channel.
abstract interface class TimeZoneSource {
  /// The zone id, or null when it cannot be read. Never throws.
  Future<String?> deviceZoneId();
}

/// [TimeZoneSource] over `MethodChannel('dailytrack/timezone')`, answered by
/// `MainActivity.kt` with `java.util.TimeZone.getDefault().id`.
final class MethodChannelTimeZoneSource implements TimeZoneSource {
  const new([this._channel = const MethodChannel('dailytrack/timezone')]);

  final MethodChannel _channel;

  @override
  Future<String?> deviceZoneId() async {
    try {
      final id = await _channel.invokeMethod<String>('getTimeZone');
      return id == null || id.isEmpty ? null : id;
    } on Object {
      return null;
    }
  }
}
