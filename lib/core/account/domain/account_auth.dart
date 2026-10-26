import 'package:dailytrack/core/account/domain/account.dart';

/// Google sign-in, as `AccountService` needs it (research R1). Implemented
/// by `GoogleAuth`, the app's only `google_sign_in` wrapper. Pure Dart.
abstract interface class AccountAuth {
  /// Interactive: the account chooser, then the Drive scope. Throws
  /// `DriveAuthRequired` when cancelled, and `DriveUnavailable` or
  /// `DriveOffline` when it fails.
  Future<AccountProfile> signIn();

  /// Without UI; null when there is no session.
  Future<AccountProfile?> signInSilently();

  /// Ends the session and keeps consent, so the next sign-in doesn't ask
  /// for the scope again (research R16).
  Future<void> signOut();
}
