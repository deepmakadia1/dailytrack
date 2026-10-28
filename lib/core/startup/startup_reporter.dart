/// Tells the platform when the app is fully drawn on cold start, so the
/// §13 "cold start to Home" time can be measured (feature 012 research R10).
/// On Android this is `Activity.reportFullyDrawn()`, which `am start -W`
/// and Android vitals read. Pure Dart; bound in `lib/app/`.
abstract interface class StartupReporter {
  /// DSH-01 showed its content for the first time in this app run.
  void homeShown();
}

/// Reports nothing (tests and platforms without the channel).
final class NoStartupReporter implements StartupReporter {
  const new();

  @override
  void homeShown() {}
}
