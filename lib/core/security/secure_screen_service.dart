import 'dart:async';

import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_screen_service.g.dart';

/// `FLAG_SECURE`: blocks screenshots and blanks the recents preview
/// (feature 007 research R9).
abstract interface class SecureScreenService {
  Future<void> setSecure({required bool on});
}

/// Calls `setSecure` on `MainActivity`'s `dailytrack/window` channel.
/// Platform call only, so it is covered by the device check.
// coverage:ignore-start
final class ChannelSecureScreenService implements SecureScreenService {
  const new();

  static const MethodChannel _channel = MethodChannel('dailytrack/window');

  @override
  Future<void> setSecure({required bool on}) async {
    try {
      await _channel.invokeMethod<void>('setSecure', on);
    } on Object {
      // No channel (e.g. iOS for now): nothing to secure.
    }
  }
}
// coverage:ignore-end

/// `production_overrides.dart` binds [ChannelSecureScreenService]; widget
/// tests bind a recording fake.
@Riverpod(keepAlive: true)
SecureScreenService secureScreenService(Ref ref) =>
    throw UnimplementedError('secureScreenServiceProvider must be overridden');

/// Keeps `FLAG_SECURE` on while SYS-03 is visible (FR-033) or app-wide
/// with "Hide app content in recents" (FR-027). The state is whether the
/// flag is on; the service is called only when that changes.
@Riverpod(keepAlive: true)
class SecureScreenController extends _$SecureScreenController {
  bool _unlockVisible = false;

  /// What the platform was last told; the window starts unsecured.
  bool _applied = false;

  @override
  bool build() {
    final hide = ref.watch(
      appSettingsProvider.select((s) => s.value?.hideInRecents ?? false),
    );
    return _apply(hide || _unlockVisible);
  }

  /// SYS-03 calls this when it appears and disappears.
  void setUnlockVisible({required bool visible}) {
    // SYS-03 can go away together with the whole app.
    if (!ref.mounted) return;
    _unlockVisible = visible;
    final hide = ref.read(appSettingsProvider).value?.hideInRecents ?? false;
    state = _apply(hide || _unlockVisible);
  }

  bool _apply(bool secure) {
    if (secure != _applied) {
      _applied = secure;
      unawaited(ref.read(secureScreenServiceProvider).setSecure(on: secure));
    }
    return secure;
  }
}
