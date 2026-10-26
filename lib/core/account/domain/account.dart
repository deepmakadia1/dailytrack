/// The Google account shown in ACC-01 (feature 010 data-model §6). Pure
/// Dart (Constitution II).
final class AccountProfile {
  const new({required this.email, this.displayName, this.photoUrl});

  final String email;
  final String? displayName;
  final String? photoUrl;
}

/// Whether an account is signed in on this phone (data-model §6).
sealed class AccountState {
  const new();
}

final class SignedOut extends AccountState {
  const new({this.expired = false});

  /// Signed out because Drive said the sign-in expired or access was
  /// removed (research R2), not by the user.
  final bool expired;
}

/// [verified] is false when this run's silent sign-in failed: ACC-01 then
/// shows the signed-out content, and the stored email is kept until the
/// user signs out (research R2).
final class SignedIn extends AccountState {
  const new(this.profile, {required this.verified});

  final AccountProfile profile;
  final bool verified;
}
