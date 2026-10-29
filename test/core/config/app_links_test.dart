import 'package:dailytrack/core/config/app_links.dart';
import 'package:flutter_test/flutter_test.dart';

/// The privacy policy and terms links point to the final website (feature
/// 012 T051, spec FR-028, clarification Q2). Tests run without
/// `--dart-define`, so these are the defaults a prod build ships with.
void main() {
  test('the privacy policy and terms URLs are the final pages', () {
    expect(
      AppLinks.privacyPolicyUrl,
      'https://dailytrack.midexcode.com/privacy',
    );
    expect(AppLinks.termsUrl, 'https://dailytrack.midexcode.com/terms');
  });

  test('both use HTTPS on the site the store listing uses', () {
    for (final url in [AppLinks.privacyPolicyUrl, AppLinks.termsUrl]) {
      final uri = Uri.parse(url);
      expect(uri.scheme, 'https', reason: url);
      expect(uri.host, 'dailytrack.midexcode.com', reason: url);
    }
  });
}
