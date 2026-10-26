import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/account/domain/account_auth.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/config/google_config.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;

/// Google sign-in for the account and Drive backup: the default `openid
/// email profile` scopes plus `drive.appdata` only (FR-014, feature 010
/// research R1, R2). The app's only `google_sign_in` wrapper. Plugin calls,
/// so it is covered by the device check (quickstart §4 step 4); the Drive
/// store is tested with a fake client.
// coverage:ignore-start
final class GoogleAuth implements AccountAuth {
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

  static AccountProfile _profile(GoogleSignInAccount account) => AccountProfile(
    email: account.email,
    displayName: account.displayName,
    photoUrl: account.photoUrl,
  );

  /// Interactive: choose an account, then grant the scope.
  @override
  Future<AccountProfile> signIn() async {
    await _init();
    beforeLeaving?.call();
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: scopes,
      );
      await account.authorizationClient.authorizeScopes(scopes);
      return _profile(account);
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

  /// The account of an earlier session, without UI (SYS-01, FR-004).
  @override
  Future<AccountProfile?> signInSilently() async {
    await _init();
    try {
      final account = await GoogleSignIn.instance
          .attemptLightweightAuthentication();
      return account == null ? null : _profile(account);
    } on GoogleSignInException {
      return null;
    }
  }

  /// Ends the session and keeps consent (research R16).
  @override
  Future<void> signOut() async {
    await _init();
    await GoogleSignIn.instance.signOut();
  }

  /// Revokes access; the next sign-in asks for consent again.
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
