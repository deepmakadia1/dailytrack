import 'package:dailytrack/core/config/app_links.dart';
import 'package:flutter_test/flutter_test.dart';

/// The privacy policy and terms links point to the final website (feature
/// 012 T051, spec FR-028, clarification Q2). Tests run without
/// `--dart-define`, so these are the defaults a prod build ships with.
void main() {
  test('the privacy policy and terms URLs are the final pages', () {
    expect(
      AppLinks.privacyPolicyUrl,
      'https://daily-track-c5736.web.app/privacy',
    );
    expect(AppLinks.termsUrl, 'https://daily-track-c5736.web.app/terms');
  });

  test('both use HTTPS on the Firebase Hosting site', () {
    for (final url in [AppLinks.privacyPolicyUrl, AppLinks.termsUrl]) {
      final uri = Uri.parse(url);
      expect(uri.scheme, 'https', reason: url);
      expect(uri.host, 'daily-track-c5736.web.app', reason: url);
    }
  });
}
