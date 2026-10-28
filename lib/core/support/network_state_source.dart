import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'network_state_source.g.dart';

/// Whether the phone is online and on a metered network (feature 010
/// data-model §7, research R6). No connectivity plugin.
final class NetworkState {
  const new({required this.online, required this.metered});

  /// Used when the platform channel is unavailable: never blocks an action
  /// that would fail with its own error anyway.
  static const NetworkState unknown = NetworkState(
    online: true,
    metered: false,
  );

  final bool online;
  final bool metered;
}

abstract interface class NetworkStateSource {
  /// Never throws.
  Future<NetworkState> load();
}

/// Reads `getNetworkState` from `MainActivity`'s `dailytrack/window` channel
/// (`ConnectivityManager`). Never throws.
final class ChannelNetworkStateSource implements NetworkStateSource {
  const new();

  static const MethodChannel _channel = MethodChannel('dailytrack/window');

  @override
  Future<NetworkState> load() async {
    try {
      final map = await _channel.invokeMapMethod<String, Object?>(
        'getNetworkState',
      );
      if (map == null) return NetworkState.unknown;
      return NetworkState(
        online: map['online'] as bool? ?? true,
        metered: map['metered'] as bool? ?? false,
      );
    } on Object {
      return NetworkState.unknown;
    }
  }
}

@Riverpod(keepAlive: true)
NetworkStateSource networkStateSource(Ref ref) =>
    const ChannelNetworkStateSource();
