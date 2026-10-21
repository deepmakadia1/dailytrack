import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/features/expense/domain/ports/notification_gate.dart';

/// [NotificationGate] from settings and the OS permission (FR-018): the
/// notifications master switch, the Budget alerts setting, and
/// `canNotify()` must all be on.
final class SettingsNotificationGate implements NotificationGate {
  new(this._settings, this._service);

  final SettingsRepository _settings;
  final NotificationService _service;

  @override
  Future<bool> budgetAlertsAllowed() async {
    final s = await _settings.load();
    if (!s.notificationsEnabled || !s.budgetAlertsEnabled) return false;
    return await _service.canNotify();
  }
}
