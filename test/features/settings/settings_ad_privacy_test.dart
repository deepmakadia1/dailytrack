import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/domain/consent_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/settings/presentation/widgets/about_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/widget_wrapper.dart';

void main() {
  const row = Key('ad_privacy_choices');

  Future<void> pump(
    WidgetTester tester, {
    required ConsentService consent,
    bool pro = false,
  }) async {
    final settings = FakeSettingsRepository(
      initial: AppSettings(removeAdsPurchased: pro),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          consentServiceProvider.overrideWithValue(consent),
        ],
        child: themed(const SingleChildScrollView(child: PrivacySection())),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SET-01 "Ad privacy choices" is visible whenever the UMP SDK '
      'reports a privacy options requirement', () {
    testWidgets('required → shown, and a tap reopens the consent form', (
      tester,
    ) async {
      final consent = FakeConsentService(privacyRequired: true);
      await pump(tester, consent: consent);
      expect(find.byKey(row), findsOneWidget);
      expect(find.text('Ad privacy choices'), findsOneWidget);
      await tester.tap(find.byKey(row));
      await tester.pump();
      expect(consent.privacyFormCalls, 1);
    });

    testWidgets('not required → hidden', (tester) async {
      await pump(tester, consent: FakeConsentService());
      expect(find.byKey(row), findsNothing);
    });

    testWidgets('becomes required later → appears without leaving the '
        'screen', (tester) async {
      final consent = FakeConsentService();
      await pump(tester, consent: consent);
      expect(find.byKey(row), findsNothing);
      consent.setPrivacyRequired(required: true);
      await tester.pumpAndSettle();
      expect(find.byKey(row), findsOneWidget);
    });

    testWidgets('Pro owned → hidden even when the SDK requires it', (
      tester,
    ) async {
      await pump(
        tester,
        consent: FakeConsentService(privacyRequired: true),
        pro: true,
      );
      expect(find.byKey(row), findsNothing);
    });

    testWidgets('no consent SDK (default) → hidden', (tester) async {
      await pump(tester, consent: const NoConsentService());
      expect(find.byKey(row), findsNothing);
    });
  });
}
