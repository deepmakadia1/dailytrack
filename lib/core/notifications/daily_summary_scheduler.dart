import 'package:clock/clock.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/notifications/notification_ids.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:dailytrack/core/widget/glance_source.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'daily_summary_scheduler.g.dart';

/// Notification id of the daily summary (data-model §7).
final int dailySummaryNotificationId = stableNotificationId('daily-summary');

/// Where tapping the summary goes: Home (FR-036). A literal, since core
/// cannot import the app's route table.
const String dailySummaryPayload = '/home';

/// The daily summary (FR-036, feature 008 research R18): one one-shot
/// notification at the next `dailySummaryTime`, with text from the current
/// glance. Rescheduled after every glance refresh, so the text is current
/// when it fires without waking the app.
class DailySummaryScheduler {
  new({
    required this.notifications,
    required this.settings,
    required this.clock,
    required this.glanceFor,
  });

  final NotificationService notifications;
  final SettingsRepository settings;
  final Clock clock;

  /// Builds the glance of a local day; used when [reschedule] gets none.
  final Future<HomeGlance> Function(DateTime dayLocal) glanceFor;

  /// Replaces the scheduled summary. [today] and [next] are the glances of
  /// today and tomorrow when the caller already has them. Cancels it when
  /// notifications are off or blocked, or no module has anything to say.
  /// Never throws.
  Future<void> reschedule({HomeGlance? today, HomeGlance? next}) async {
    try {
      final s = await settings.load();
      if (!s.notificationsEnabled || !await notifications.canNotify()) {
        await notifications.cancel(dailySummaryNotificationId);
        return;
      }
      if (!await notifications.refreshTimeZone()) return;
      final now = clock.now();
      final fireAt = nextFire(s.dailySummaryTime, now);
      final isToday = fireAt.day == now.day;
      final glance = isToday
          ? today ?? await glanceFor(now)
          : next ?? await glanceFor(DateTime(now.year, now.month, now.day + 1));
      final l10n = l10nFor(s.locale);
      final body = textFor(l10n, glance);
      if (body == null) {
        await notifications.cancel(dailySummaryNotificationId);
        return;
      }
      await notifications.schedule(
        ScheduledNotification(
          notification: AppNotification(
            id: dailySummaryNotificationId,
            channel: NotificationChannelId.dailySummary,
            title: l10n.notif_dailySummaryTitle,
            body: body,
            payload: dailySummaryPayload,
          ),
          firstAt: fireAt,
          repeat: null,
          exact: await _canExact(),
        ),
      );
    } on Object {
      // Best effort; the next refresh tries again.
    }
  }

  Future<bool> _canExact() async {
    try {
      return await notifications.canScheduleExact();
    } on Object {
      return false;
    }
  }

  /// The next local time at [time] (`HH:mm`) after [now]: today, or
  /// tomorrow once it has passed.
  static DateTime nextFire(String time, DateTime now) {
    final parts = time.split(':');
    final hour = int.tryParse(parts.first) ?? 21;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    final today = DateTime(now.year, now.month, now.day, hour, minute);
    return today.isAfter(now)
        ? today
        : DateTime(now.year, now.month, now.day + 1, hour, minute);
  }

  /// "Spent ₹1,250 today · 3/5 habits done", with each part only for an
  /// enabled module (R18), or null when there is nothing to report.
  static String? textFor(AppLocalizations l10n, HomeGlance glance) {
    final spend = glance.spend;
    final habits = glance.habits;
    final amount = spend == null
        ? null
        : MoneyFormatter.format(
            spend.todayMinor,
            currencyCode: spend.currencyCode,
          );
    return switch ((amount, habits)) {
      (final a?, final h?) => l10n.notif_dailySummaryBoth(
        a,
        h.done,
        h.scheduled,
      ),
      (final a?, null) => l10n.notif_dailySummarySpend(a),
      (null, final h?) => l10n.notif_dailySummaryHabits(h.done, h.scheduled),
      (null, null) => null,
    };
  }
}

@Riverpod(keepAlive: true)
DailySummaryScheduler dailySummaryScheduler(Ref ref) => DailySummaryScheduler(
  notifications: ref.watch(notificationServiceProvider),
  settings: ref.watch(settingsRepositoryProvider),
  clock: ref.watch(clockProvider),
  glanceFor: (day) => buildHomeGlance(ref.read, day),
);
