import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/app/router_ad_screen_probe.dart';
import 'package:flutter_test/flutter_test.dart';

/// FR-023 and contracts/routes.md (feature 009 T101): where a full-screen
/// ad may appear.
void main() {
  test('never over a form, lock, onboarding, PIN, or premium screen', () {
    for (final path in [
      Routes.splash,
      Routes.onboarding,
      Routes.lock,
      Routes.premium,
      Routes.pin,
      Routes.expenseAdd,
      Routes.expenseEditPath('t1'),
      Routes.habitAdd,
      Routes.habitEditPath('h1'),
      Routes.expenseRecurringAdd,
      Routes.expenseRuleEditPath('r1'),
    ]) {
      expect(isReadingLocation(path), isFalse, reason: path);
    }
  });

  test('reading screens, Home included (clarification Q1)', () {
    for (final path in [
      Routes.home,
      Routes.expenses,
      Routes.habits,
      Routes.more,
      Routes.backup,
      Routes.expenseReports,
    ]) {
      expect(isReadingLocation(path), isTrue, reason: path);
    }
  });

  test('a locked app never shows one', () {
    final probe = RouterAdScreenProbe(
      location: () => Routes.home,
      locked: () => true,
    );
    expect(probe.canShowFullScreenAd, isFalse);
  });
}
