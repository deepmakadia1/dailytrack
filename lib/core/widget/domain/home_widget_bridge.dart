/// The home screen widget host (feature 008 research R20, R21). Pure Dart;
/// `HomeWidgetPluginBridge` implements it with `home_widget`, and tests use
/// a fake.
abstract interface class HomeWidgetBridge {
  /// Stores the `glance.v1` payload and redraws the widget.
  Future<void> save(String payloadJson);

  /// Arms the native alarm that wakes Dart just after local midnight.
  Future<void> armMidnight();

  /// `/home` when a widget tap cold-started the app, else null.
  Future<String?> launchLocation();

  /// Widget taps while the app runs, as router locations (`/home`).
  Stream<String> get launches;

  /// Registers the background entry point for widget checks and system
  /// triggers. A top-level `@pragma('vm:entry-point')` function, passed in
  /// by `bootstrap.dart`, so core never imports `lib/app/`.
  Future<void> registerBackgroundCallback(
    Future<void> Function(Uri? uri) callback,
  );
}

/// Widget URIs (data-model §6).
abstract final class WidgetUris {
  static const String scheme = 'dailytrack';

  /// `dailytrack://widget/check?habit=<id>&day=<yyyy-MM-dd>`.
  static bool isCheck(Uri uri) =>
      uri.scheme == scheme && uri.host == 'widget' && uri.path == '/check';

  /// `dailytrack://widget/open`.
  static bool isOpen(Uri uri) =>
      uri.scheme == scheme && uri.host == 'widget' && uri.path == '/open';

  /// `dailytrack://system/{midnight,boot,timezone}`: the trigger name, or
  /// null for any other URI.
  static String? systemTrigger(Uri uri) {
    if (uri.scheme != scheme || uri.host != 'system') return null;
    final name = uri.path.replaceFirst('/', '');
    return const {'midnight', 'boot', 'timezone'}.contains(name) ? name : null;
  }
}
