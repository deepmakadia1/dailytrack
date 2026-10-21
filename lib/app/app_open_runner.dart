import 'dart:async';

import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_open_runner.g.dart';

/// Runs every enabled module's `onAppOpen` hook on cold start and on each
/// resume (feature 003 research R10), and raises `latestSeenAt` for the
/// feature gate (FR-038). Failures are swallowed so they never affect the
/// UI, and a run is skipped while the previous one is still in flight.
final class AppOpenRunner {
  new(this._ref);

  final Ref _ref;
  Future<void>? _inFlight;

  bool get isRunning => _inFlight != null;

  /// Completes when this run (or the one already in flight) is done.
  Future<void> run() =>
      _inFlight ??= _run().whenComplete(() => _inFlight = null);

  Future<void> _run() async {
    try {
      final settingsRepo = _ref.read(settingsRepositoryProvider);
      final now = _ref.read(clockProvider).now().toUtc();
      unawaited(
        settingsRepo
            .raiseLatestSeenAt(now.millisecondsSinceEpoch)
            .catchError((Object _) {}),
      );
      final settings = await settingsRepo.load();
      final modules = _ref.read(moduleRegistryProvider).visible(settings);
      for (final module in modules) {
        try {
          await module.onAppOpen(_ref.read);
        } on Object {
          // One module's failure never stops the others.
        }
      }
    } on Object {
      // App-open work is best effort; the next open retries.
    }
  }
}

@Riverpod(keepAlive: true)
AppOpenRunner appOpenRunner(Ref ref) => AppOpenRunner(ref);
