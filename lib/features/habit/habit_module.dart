import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/dev_action.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/data/backup/habit_backup_section.dart';
import 'package:dailytrack/features/habit/data/dev/habit_sample_seeder.dart';
import 'package:dailytrack/features/habit/habit_actions.dart';
import 'package:dailytrack/features/habit/presentation/export/habits_export_dataset.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:dailytrack/features/habit/presentation/insights/habit_insight_source.dart';
import 'package:dailytrack/features/habit/presentation/screens/archived_habits_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_detail_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habits_today_screen.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_dashboard_card.dart';
import 'package:dailytrack/features/habit/presentation/widgets/streak_flame_badge.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Habit tracker module (feature 005, contracts/routes_and_module.md): the
/// Habits tab (HAB-01 to HAB-04), the Home card, the "Check in habit"
/// quick add, the reminder hooks, backup, export, and the widget and
/// notification actions (feature 008).
final class HabitModule extends TrackerModule {
  const new();

  @override
  String get id => 'habit';

  @override
  String displayName(BuildContext context) =>
      AppLocalizations.of(context).modules_habit;

  @override
  String tabLabel(BuildContext context) =>
      AppLocalizations.of(context).nav_habits;

  @override
  IconData get icon => Icons.check_circle_outline;

  @override
  IconData get selectedIcon => Icons.check_circle;

  @override
  String get rootPath => Routes.habits;

  @override
  List<RouteBase> get routes => [
    GoRoute(
      path: Routes.habits,
      name: RouteNames.habits,
      builder: (context, state) => const HabitsTodayScreen(),
      // Static segments before `:id` (research R15).
      routes: [
        GoRoute(
          path: Routes.habitAddSegment,
          name: RouteNames.habitAdd,
          parentNavigatorKey: rootNavigatorKey,
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            fullscreenDialog: true,
            child: HabitFormScreen(
              templateId: state.uri.queryParameters['template'],
            ),
          ),
        ),
        GoRoute(
          path: Routes.habitArchivedSegment,
          name: RouteNames.habitArchived,
          builder: (context, state) => const ArchivedHabitsScreen(),
        ),
        GoRoute(
          path: Routes.habitDetailSegment,
          name: RouteNames.habitDetail,
          builder: (context, state) =>
              HabitDetailScreen(id: state.pathParameters['id']!),
          routes: [
            GoRoute(
              path: Routes.habitEditSegment,
              name: RouteNames.habitEdit,
              parentNavigatorKey: rootNavigatorKey,
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                fullscreenDialog: true,
                child: HabitFormScreen(id: state.pathParameters['id']),
              ),
            ),
          ],
        ),
      ],
    ),
  ];

  /// Ring and today's check buttons (US7).
  @override
  Widget dashboardCard(BuildContext context) => const HabitDashboardCard();

  /// "Check in habit" opens HAB-01 for today (US7-5).
  @override
  List<QuickAddAction> quickAddActions() => const [
    QuickAddAction(
      labelKey: 'habit_quickAddCheckIn',
      icon: Icons.check_circle,
      location: Routes.habits,
    ),
  ];

  /// DSH-01 streak flame: the best active streak, live.
  @override
  Widget? appBarBadge(BuildContext context) => const StreakFlameBadge();

  /// DSH-01 rule-based insights, evaluated on the device.
  @override
  InsightSource? insights() => const HabitInsightSource();

  /// SET-03 export (feature 008 research R14).
  @override
  List<ExportDataset> exportDatasets() => const [HabitsExportDataset()];

  @override
  BackupSection? backupSection() => const HabitBackupSection();

  /// Today's habits for the home screen widget and the daily summary
  /// (feature 008 research R19).
  @override
  Future<void> contributeGlance(
    GlanceBuilder b,
    ProviderReader read,
    DateTime nowLocal,
  ) => contributeHabitGlance(b, read, nowLocal);

  /// Reminder "Mark done" and "Snooze 1 h", and widget checks (feature 008
  /// research R17, R20).
  @override
  Future<bool> handleAction(AppAction action, ProviderReader read) =>
      handleHabitAction(action, read);

  @override
  List<Seeder> get seeders => const [];

  /// Dev flavor only: a few sample habits with a year of check-ins, added
  /// with "Seed 10,000 transactions" (feature 012 contracts/dev-seed.md).
  @override
  Future<DevActionResult> seedSampleData(ProviderReader read) async {
    if (!read(debugToolsAvailableProvider)) return const DevActionDone(0);
    try {
      return await HabitSampleSeeder(
        read(appDatabaseProvider),
        read(clockProvider),
        read(backupCoordinatorProvider),
      ).seed();
    } on Object {
      return const DevActionDone(0);
    }
  }

  /// FR-040: reschedules every active habit's reminders.
  @override
  Future<void> onEnable(ProviderReader read) => _reconcileAll(read);

  /// FR-040: cancels all habit reminders. Habit data is kept.
  @override
  Future<void> onDisable(ProviderReader read) async {
    try {
      await read(habitReminderSchedulerProvider).cancelAll();
    } on Object {
      // Best effort.
    }
  }

  /// Cold start and every resume (FR-040, US4-6): picks up a time-zone
  /// change, a day rollover, and anything a reboot lost.
  @override
  Future<void> onAppOpen(ProviderReader read) => _reconcileAll(read);

  /// SET-01 notification switches (feature 007 R17): the scheduler cancels
  /// every reminder when notifications or habit reminders are off, and
  /// schedules them again when both are on.
  @override
  Future<void> onNotificationSettingsChanged(ProviderReader read) async {
    try {
      await read(habitReminderSchedulerProvider).reconcileAll();
    } on Object {
      // Best effort; the next app open reconciles again.
    }
  }

  /// Erase all data (feature 007 R16): no habit is left to remind about.
  @override
  Future<void> onEraseAll(ProviderReader read) async {
    try {
      await read(habitReminderSchedulerProvider).cancelAll();
    } on Object {
      // Best effort; the data is already gone.
    }
  }

  @override
  Map<String, BackgroundTask> get backgroundTasks => const {};

  static Future<void> _reconcileAll(ProviderReader read) async {
    try {
      await read(notificationServiceProvider).refreshTimeZone();
      await read(habitReminderSchedulerProvider).reconcileAll();
    } on Object {
      // Best effort (research R10); the next open retries.
    }
  }
}
