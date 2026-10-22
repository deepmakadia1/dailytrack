import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/config/google_config.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

/// Google sign-in for Drive backup, `drive.appdata` scope only (FR-014,
/// feature 008 research R10). Plugin calls, so it is covered by the device
/// check (quickstart §4 step 4); the Drive store is tested with a fake
/// client.
// coverage:ignore-start
final class GoogleAuth {
  new({this.beforeLeaving});

  /// Called before the account picker opens, so the trip out does not lock
  /// the app (feature 007 research R15).
  final void Function()? beforeLeaving;

  static const List<String> scopes = [drive.DriveApi.driveAppdataScope];

  Future<void>? _initialized;

  Future<void> _init() {
    if (!GoogleConfig.driveAvailable) {
      throw const DriveUnavailable('not-configured');
    }
    return _initialized ??= GoogleSignIn.instance
        .initialize(serverClientId: GoogleConfig.serverClientId)
        .catchError((Object e, StackTrace stack) {
          _initialized = null;
          Error.throwWithStackTrace(e, stack);
        });
  }

  /// Interactive: choose an account, then grant the scope. Returns the email.
  Future<String> connect() async {
    await _init();
    beforeLeaving?.call();
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: scopes,
      );
      await account.authorizationClient.authorizeScopes(scopes);
      return account.email;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const DriveAuthRequired();
      }
      throw DriveUnavailable(e.code.name);
    }
  }

  /// Without any UI, for "Back up now" after connecting and for auto backup
  /// in the background. Throws [DriveAuthRequired] when the user must
  /// reconnect.
  Future<drive.DriveApi> driveApi() async {
    await _init();
    try {
      final account = await GoogleSignIn.instance
          .attemptLightweightAuthentication();
      final authorization =
          await (account?.authorizationClient ??
                  GoogleSignIn.instance.authorizationClient)
              .authorizationForScopes(scopes);
      if (authorization == null) throw const DriveAuthRequired();
      return drive.DriveApi(authorization.authClient(scopes: scopes));
    } on GoogleSignInException {
      throw const DriveAuthRequired();
    }
  }

  /// Revokes access; the next connect asks again.
  Future<void> disconnect() async {
    await _init();
    try {
      await GoogleSignIn.instance.disconnect();
    } on GoogleSignInException {
      await GoogleSignIn.instance.signOut();
    }
  }
}
// coverage:ignore-end
