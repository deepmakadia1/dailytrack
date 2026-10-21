import 'package:dailytrack/app/router/routes.dart';

/// What SYS-04 is for (feature 007 contracts/screens.md "SYS-04").
enum PinFlowMode {
  /// New PIN, confirm (SET-05 lock on, SYS-02 step 4).
  set,

  /// Current PIN, new PIN, confirm.
  change,

  /// Current PIN; turns the lock off.
  disable;

  /// The `mode` query of [uri]; anything unknown is [set].
  static PinFlowMode fromQuery(Uri uri) =>
      switch (uri.queryParameters['mode']) {
        Routes.pinModeChange => change,
        Routes.pinModeDisable => disable,
        _ => set,
      };
}
