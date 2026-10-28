import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:flutter/widgets.dart';

/// A developer-only action a module offers in SET-01's Developer section,
/// in the dev flavor only (feature 012 contracts/dev-seed.md). Settings
/// never imports a module: it lists these through
/// `TrackerModule.devActions`, as SET-03 lists `exportDatasets`.
final class DevAction {
  const new({
    required this.id,
    required this.labelKey,
    required this.confirmKey,
    required this.icon,
    required this.run,
  });

  /// Stable id, e.g. `expense.seed10k`; the row's key is `dev_<id>`.
  final String id;

  /// ARB key of the row title.
  final String labelKey;

  /// ARB key of the confirm dialog body.
  final String confirmKey;

  final IconData icon;

  /// Runs the action, reporting progress from 0 to 1. Must not throw.
  final Future<DevActionResult> Function(
    ProviderReader read,
    void Function(double fraction) onProgress,
  )
  run;
}

/// How a [DevAction] ended.
sealed class DevActionResult {
  const new();
}

/// Finished, after adding [count] items.
final class DevActionDone extends DevActionResult {
  const new(this.count);

  final int count;
}

/// Refused because a backup or restore holds the lease; nothing changed.
final class DevActionBusy extends DevActionResult {
  const new();
}
