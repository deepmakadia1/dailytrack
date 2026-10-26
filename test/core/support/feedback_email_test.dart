import 'package:dailytrack/core/l10n/gen/app_localizations_en.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/support/app_info_source.dart';
import 'package:dailytrack/core/support/device_info_source.dart';
import 'package:dailytrack/core/support/feedback_email.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// SET-01 Send feedback draft (T066, FR-012, US8-4, Constitution III).
void main() {
  final l10n = AppLocalizationsEn();
  const app = AppInfo(
    version: '1.0.0',
    buildNumber: '7',
    packageName: 'com.midexcode.dailytrack',
  );
  const device = DeviceInfo(
    manufacturer: 'Samsung',
    model: 'SM-A146B',
    release: '14',
    sdkInt: 34,
  );

  test('subject has the app version; body has app, device, Android, and '
      'device language', () {
    final mail = buildFeedbackEmail(
      l10n,
      app: app,
      device: device,
      deviceLocale: const Locale('en', 'IN'),
    );
    expect(mail.subject, contains('1.0.0'));
    expect(mail.body, contains('1.0.0 (7)'));
    expect(mail.body, contains('Samsung SM-A146B'));
    expect(mail.body, contains('14 (API 34)'));
    expect(mail.body, contains('en-IN'));
  });

  test('the device language is used, never the app language setting', () {
    // The app is set to Gujarati, the phone to English (India).
    const settings = AppSettings(locale: 'gu', currencyCode: 'USD');
    final mail = buildFeedbackEmail(
      l10n,
      app: app,
      device: device,
      deviceLocale: const Locale('en', 'IN'),
    );
    expect(mail.body, contains('Device language: en-IN'));
    expect(mail.body, isNot(contains('language: ${settings.locale}')));
  });

  test('no app data or settings appear in the draft', () {
    // Values a seeded user might have; none may leak into the email.
    const seeded = [
      'Groceries',
      'Morning walk',
      'Paid rent',
      '₹1,250.00',
      'USD',
      'saffron',
    ];
    final mail = buildFeedbackEmail(
      l10n,
      app: app,
      device: device,
      deviceLocale: const Locale('en', 'IN'),
    );
    for (final value in seeded) {
      expect(mail.subject, isNot(contains(value)));
      expect(mail.body, isNot(contains(value)));
    }
  });

  test('missing device facts still produce a draft', () {
    final mail = buildFeedbackEmail(
      l10n,
      app: app,
      device: DeviceInfo.unknown,
      deviceLocale: const Locale('hi'),
    );
    expect(mail.body, contains('Device language: hi'));
  });
}
