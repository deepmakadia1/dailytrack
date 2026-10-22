/// Google Drive backup configuration (feature 008 research R10). The Web
/// OAuth client ID is passed per build with
/// `--dart-define=GOOGLE_SERVER_CLIENT_ID=<id>` and never committed
/// (Constitution III). Without it, Drive backup is shown as unavailable.
abstract final class GoogleConfig {
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );

  static bool get driveAvailable => serverClientId.isNotEmpty;
}
