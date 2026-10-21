import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'device_info_source.g.dart';

/// Device facts for the feedback email (feature 007 research R14). No user
/// data and no identifiers.
final class DeviceInfo {
  const new({
    required this.manufacturer,
    required this.model,
    required this.release,
    required this.sdkInt,
  });

  /// Used when the platform channel is unavailable.
  static const DeviceInfo unknown = DeviceInfo(
    manufacturer: '',
    model: '',
    release: '',
    sdkInt: 0,
  );

  final String manufacturer;
  final String model;

  /// Android version name, e.g. "14".
  final String release;
  final int sdkInt;
}

abstract interface class DeviceInfoSource {
  Future<DeviceInfo> load();
}

/// Reads `getDeviceInfo` from `MainActivity`'s `dailytrack/window` channel,
/// so the app needs no device-info plugin. Never throws.
final class ChannelDeviceInfoSource implements DeviceInfoSource {
  const new();

  static const MethodChannel _channel = MethodChannel('dailytrack/window');

  @override
  Future<DeviceInfo> load() async {
    try {
      final map = await _channel.invokeMapMethod<String, Object?>(
        'getDeviceInfo',
      );
      if (map == null) return DeviceInfo.unknown;
      return DeviceInfo(
        manufacturer: map['manufacturer'] as String? ?? '',
        model: map['model'] as String? ?? '',
        release: map['release'] as String? ?? '',
        sdkInt: map['sdkInt'] as int? ?? 0,
      );
    } on Object {
      return DeviceInfo.unknown;
    }
  }
}

@Riverpod(keepAlive: true)
DeviceInfoSource deviceInfoSource(Ref ref) => const ChannelDeviceInfoSource();
