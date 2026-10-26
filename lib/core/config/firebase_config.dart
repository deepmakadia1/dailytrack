import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase for crash reporting and analytics (spec §2). The values come
/// from the build, like `GOOGLE_SERVER_CLIENT_ID`
/// (`--dart-define-from-file=config/dart_defines.json`, see
/// `config/dart_defines.example.json`), and are never committed
/// (Constitution III). Without them Firebase stays off: tests, fresh
/// clones, and CI without secrets build and run as before. Android only;
/// iOS is untested.
abstract final class FirebaseConfig {
  static const String apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const String projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  static bool get available =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      senderId.isNotEmpty &&
      projectId.isNotEmpty;

  /// Null when this build has no Firebase values.
  static FirebaseOptions? get options => available
      ? const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: senderId,
          projectId: projectId,
        )
      : null;
}
