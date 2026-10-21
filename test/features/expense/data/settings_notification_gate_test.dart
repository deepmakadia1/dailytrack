import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/data/notifications/settings_notification_gate.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

/// SettingsNotificationGate (T050, FR-018): allowed only when the master
/// switch, the Budget alerts setting and the OS permission are all on.
void main() {
  for (final master in [true, false]) {
    for (final alerts in [true, false]) {
      for (final os in [true, false]) {
        test('master=$master alerts=$alerts os=$os', () async {
          final gate = SettingsNotificationGate(
            FakeSettingsRepository(
              initial: AppSettings(
                notificationsEnabled: master,
                budgetAlertsEnabled: alerts,
              ),
            ),
            FakeNotificationService(allowed: os),
          );
          expect(await gate.budgetAlertsAllowed(), master && alerts && os);
        });
      }
    }
  }
}
