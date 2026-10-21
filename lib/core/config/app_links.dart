/// Outbound links and the support address (SET-01 Privacy and About,
/// feature 007 research R14). Set per build with `--dart-define`, like the
/// ad unit IDs; the defaults are placeholders until the site is live.
abstract final class AppLinks {
  static const String privacyPolicyUrl = String.fromEnvironment(
    'PRIVACY_POLICY_URL',
    defaultValue: 'https://dailytrack.midexcode.com/privacy',
  );

  static const String termsUrl = String.fromEnvironment(
    'TERMS_URL',
    defaultValue: 'https://dailytrack.midexcode.com/terms',
  );

  static const String supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'support@midexcode.com',
  );

  /// The Play Store listing for [packageName].
  static String storeUrl(String packageName) =>
      'https://play.google.com/store/apps/details?id=$packageName';
}
