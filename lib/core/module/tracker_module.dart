import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/backup/backup_section.dart';
import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/module/app_action.dart';
import 'package:dailytrack/core/module/dashboard_section.dart';
import 'package:dailytrack/core/module/dev_action.dart';
import 'package:dailytrack/core/module/insight_source.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

export 'package:dailytrack/core/background/background_scheduler.dart'
    show BackgroundTask;
export 'package:dailytrack/core/backup/backup_section.dart';
export 'package:dailytrack/core/export/export_dataset.dart';
export 'package:dailytrack/core/export/export_document.dart';
export 'package:dailytrack/core/module/app_action.dart'
    show AppAction, AppActionSource;
export 'package:dailytrack/core/module/dashboard_section.dart';
export 'package:dailytrack/core/module/insight.dart';
export 'package:dailytrack/core/module/insight_source.dart';
export 'package:dailytrack/core/module/provider_reader.dart';
export 'package:dailytrack/core/widget/domain/home_glance.dart';

/// Extended by every tracker (Expense, Habit; later Water, Period).
/// See specs/006-home-dashboard/contracts/tracker_module.md. Home, SET-06
/// and the router loop over the registry, so they never import a module
/// directly. An abstract class, not an interface, so the optional members
/// below have defaults and a new module need not implement them.
abstract class TrackerModule {
  const new();

  /// Stable id stored in settings (`enabledModules`, `moduleOrder`).
  /// Never change it.
  String get id;

  String displayName(BuildContext context);

  /// Localized bottom-navigation label, e.g. "Expenses" where [displayName]
  /// is "Expense".
  String tabLabel(BuildContext context);

  /// Outlined icon for the inactive tab.
  IconData get icon;

  /// Filled icon for the active tab.
  IconData get selectedIcon;

  /// Root path of the module's tab branch. Every route the module owns lives
  /// under this prefix, so the router can redirect it when disabled.
  String get rootPath;

  /// Routes of the module's tab branch, root route first.
  List<RouteBase> get routes;

  Widget dashboardCard(BuildContext context);

  /// This module's entries in the global "+" menu, in the order they appear
  /// within the module's part of the menu. Each `location` is a route the
  /// module owns or one that lives above the shell.
  List<QuickAddAction> quickAddActions() => const [];

  /// Extra Home sections, rendered after all module cards, grouped by module
  /// in the user's order. A section hides itself (`SizedBox.shrink()`) when
  /// it has nothing to show and adds no outer spacing.
  List<DashboardSection> dashboardSections() => const [];

  /// The module's rule-based insight source for the Home insight card, or
  /// null for none. Its `evaluate` reads only local data, never throws, and
  /// returns text localized with `l10nFor(settings.locale)`.
  InsightSource? insights() => null;

  /// A Home app bar badge, at most 48 dp tall, with its own semantic label
  /// and tap target, or null for none. Shown in module order.
  Widget? appBarBadge(BuildContext context) => null;

  /// Export/import of the module's own tables (SET-02, feature 008 research
  /// R5), or null for a module with no data.
  BackupSection? backupSection();

  /// What SET-03 can export from this module (feature 008 research R14),
  /// e.g. Expense's transactions. Settings never imports a module.
  List<ExportDataset> exportDatasets() => const [];

  /// Adds the module's part of the home screen widget and the daily
  /// summary for the local day of [nowLocal] (feature 008 research R19).
  /// Runs in background isolates too; reads only local data.
  Future<void> contributeGlance(
    GlanceBuilder b,
    ProviderReader read,
    DateTime nowLocal,
  ) async {}

  /// Handles a notification button, widget check, or system action the
  /// module owns (research R17, R20). Returns true when handled, even if
  /// nothing had to change.
  Future<bool> handleAction(AppAction action, ProviderReader read) async =>
      false;

  /// Run once each by SeedRunner, whether or not the module is enabled.
  List<Seeder> get seeders;

  /// Schedule or cancel the module's notifications and jobs. Must never
  /// delete data.
  Future<void> onEnable(ProviderReader read);

  Future<void> onDisable(ProviderReader read);

  /// Runs on cold start and on every resume, for enabled modules only, and
  /// never delays the first screen (e.g. budget rollover, FR-013).
  Future<void> onAppOpen(ProviderReader read);

  /// Called after the notifications master, budget alerts, or habit
  /// reminders setting changes (SET-01, feature 007 research R17).
  /// Reconcile scheduled notifications with the new settings. Must not throw.
  Future<void> onNotificationSettingsChanged(ProviderReader read) async {}

  /// Called after "Erase all data" has deleted every database row (SET-01,
  /// SYS-03 "Forgot PIN?"; feature 007 research R16). Remove module-owned
  /// files and scheduled alarms. Must not throw.
  Future<void> onEraseAll(ProviderReader read) async {}

  /// Background jobs by unique name, run by the background dispatcher for
  /// enabled modules only (research R10).
  Map<String, BackgroundTask> get backgroundTasks;

  /// Developer-only actions shown in SET-01 Developer in the dev flavor
  /// (feature 012 contracts/dev-seed.md). Return `const []` when
  /// `debugToolsAvailableProvider` is false; never shown in prod.
  List<DevAction> devActions(ProviderReader read) => const [];

  /// Dev flavor only: a small set of sample data, added after a Developer
  /// action with `DevAction.withSampleData` (e.g. a few habits with a
  /// year of check-ins next to "Seed 10,000 transactions"). Return
  /// `DevActionDone(0)` when `debugToolsAvailableProvider` is false. Must
  /// not throw.
  Future<DevActionResult> seedSampleData(ProviderReader read) async =>
      const DevActionDone(0);
}

final class QuickAddAction {
  const new({
    required this.labelKey,
    required this.icon,
    required this.location,
  });

  final String labelKey;
  final IconData icon;
  final String location;
}

/// A display-only "Coming soon" row (SYS-02 step 3, SET-06).
final class ComingSoonModule {
  const new({required this.id, required this.nameKey});

  final String id;

  /// ARB key of the display name.
  final String nameKey;
}
