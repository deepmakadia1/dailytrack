import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../account/account_test_app.dart';

/// Onboarding done and no login chosen yet: the app opens on AUTH-01.
const AppSettings onLogin = AppSettings(onboardingDone: true, locale: 'en');

/// Pumps the app on AUTH-01 with every account fake (feature 011 tests).
Future<AccountWorld> pumpLogin(
  WidgetTester tester, {
  AppSettings initial = onLogin,
  bool hasData = false,
  FakeNetworkStateSource? network,
  FakeAdService? ads,
  FakeProStore? pro,
  FakeNotificationPermission? notif,
  int androidSdk = 34,
  String? pin,
  void Function(AccountWorld world)? arrange,
}) async {
  final world = await pumpAccountApp(
    tester,
    initial: initial,
    authModeStored: true,
    location: null,
    hasData: hasData,
    network: network,
    ads: ads,
    pro: pro,
    notif: notif,
    androidSdk: androidSdk,
    pin: pin,
    arrange: arrange,
  );
  expect(find.byType(LoginScreen), findsOneWidget);
  return world;
}

/// What the backup holds: its language, currency, and modules.
void restoreWritesBackup(AccountWorld w) => w.restore.onApply = () =>
    w.settings.completeOnboarding(
      const OnboardingChoices(
        locale: 'hi',
        currencyCode: 'USD',
        moduleOrder: ['habit', 'expense'],
        enabledModules: ['habit'],
      ),
    );

/// Records the platform channel's method calls (`SystemNavigator.pop` is
/// Android back closing the app).
List<String> recordSystemCalls(WidgetTester tester) {
  final calls = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      calls.add(call.method);
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  return calls;
}
