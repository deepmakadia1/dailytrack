import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/erase_all_data_flow.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/core/widgets/settings_section.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/settings/presentation/controllers/settings_controller.dart';
import 'package:dailytrack/features/settings/presentation/widgets/about_section.dart';
import 'package:dailytrack/features/settings/presentation/widgets/general_section.dart';
import 'package:dailytrack/features/settings/presentation/widgets/notifications_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// SET-01 More / Settings (spec §10, feature 007 contracts/screens.md):
/// General, Appearance, Modules, Notifications, Security, Data, Privacy, About,
/// and, in the dev flavor only, Developer. The Data section has Erase all
/// data. The premium card leads the list until Pro is owned; the bottom
/// banner is in the banner slot (spec §11).
class SettingsScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // Back from system settings: check the notification permission again.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref
        ..invalidate(notificationsAllowedProvider)
        ..invalidate(exactAlarmsAllowedProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(settingsControllerProvider);
    return AppScaffold(
      title: l10n.nav_more,
      // Spec §11: the bottom banner (no space until an ad loads).
      bannerSlot: const AppBannerAd(),
      largeTitle: true,
      showBack: false,
      padBody: false,
      body: switch (async) {
        // Keep the rows while a write reloads them.
        AsyncValue(:final value?) => _SettingsList(data: value),
        AsyncError() => ErrorState(
          message: l10n.settings_loadError,
          onRetry: ref.read(settingsControllerProvider.notifier).retry,
        ),
        _ => const DelayedSkeleton(child: SkeletonList(itemCount: 6)),
      },
    );
  }
}

/// SET-01 premium banner card: "Remove ads and unlock everything" → PRM-01
/// (spec §10 SET-01 item 1).
class _PremiumCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(tokens.s16, tokens.s8, tokens.s16, 0),
      child: Card(
        key: const Key('premium_card'),
        margin: EdgeInsets.zero,
        color: scheme.primaryContainer,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(
            Icons.workspace_premium,
            color: scheme.onPrimaryContainer,
          ),
          title: Text(
            l10n.premium_cardTitle,
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
          subtitle: Text(
            l10n.premium_cardSubtitle,
            style: TextStyle(color: scheme.onPrimaryContainer),
          ),
          trailing: Icon(Icons.chevron_right, color: scheme.onPrimaryContainer),
          onTap: () => unawaited(context.push(Routes.premium)),
        ),
      ),
    );
  }
}

class _SettingsList extends ConsumerWidget {
  const new({required this.data});

  final SettingsViewData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = data.settings;
    return ListView(
      key: const Key('settings_list'),
      children: [
        // PRM-01 entry, hidden once Pro is owned (FR-045).
        if (!ref.watch(proOwnedProvider)) const _PremiumCard(),
        GeneralSection(settings: settings),
        SettingsSection(
          title: l10n.settings_appearance,
          children: [
            ListTile(
              key: const Key('settings_theme'),
              leading: const Icon(Icons.palette_outlined),
              title: Text(l10n.settings_themeEntry),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push(Routes.themes)),
            ),
          ],
        ),
        SettingsSection(
          title: l10n.settings_modules,
          children: [
            ListTile(
              key: const Key('settings_modules'),
              leading: const Icon(Icons.dashboard_customize_outlined),
              title: Text(l10n.settings_modulesEntry),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push(Routes.modules)),
            ),
          ],
        ),
        NotificationsSection(
          settings: settings,
          habitEnabled: data.visibleModuleIds.contains('habit'),
        ),
        SettingsSection(
          title: l10n.settings_security,
          children: [
            ListTile(
              key: const Key('settings_app_lock'),
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.settings_appLockEntry),
              subtitle: Text(
                settings.lockEnabled ? l10n.settings_on : l10n.settings_off,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push(Routes.security)),
            ),
          ],
        ),
        SettingsSection(
          title: l10n.settings_data,
          children: [
            ListTile(
              key: const Key('settings_backup'),
              leading: const Icon(Icons.backup_outlined),
              title: Text(l10n.backup_title),
              subtitle: Text(switch (settings.lastBackupAt) {
                final at? => l10n.backup_lastBackupSubtitle(
                  formatFullDate(
                    Epoch.toLocal(at),
                    FullDateFormatScope.of(context),
                    Localizations.localeOf(context).toString(),
                  ),
                ),
                null => l10n.backup_notBackedUp,
              }),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push(Routes.backup)),
            ),
            ListTile(
              key: const Key('settings_export'),
              leading: const Icon(Icons.ios_share),
              title: Text(l10n.export_title),
              subtitle: Text(l10n.export_settingsHelp),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push(Routes.export)),
            ),
            ListTile(
              key: const Key('settings_erase_all'),
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
                semanticLabel: l10n.settings_eraseAll,
              ),
              title: Text(
                l10n.settings_eraseAll,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => unawaited(
                showEraseAllDataFlow(
                  context,
                  ref.read(appResetServiceProvider),
                ),
              ),
            ),
          ],
        ),
        const PrivacySection(),
        const AboutSection(),
        if (data.devTools)
          SettingsSection(
            key: const Key('developer_section'),
            title: l10n.more_developerSection,
            children: [
              SwitchListTile(
                key: const Key('debug_unlock_all'),
                secondary: const Icon(Icons.lock_open),
                title: Text(l10n.more_debugUnlockAll),
                value: settings.debugUnlockAll,
                onChanged: (on) => unawaited(
                  ref
                      .read(settingsControllerProvider.notifier)
                      .setDebugUnlockAll(enabled: on),
                ),
              ),
              // Lets the interstitial cap be tested in minutes (FR-048).
              ListTile(
                key: const Key('reset_ad_counters'),
                leading: const Icon(Icons.restart_alt),
                title: Text(l10n.ads_resetCounters),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref.read(resetAdCountersProvider)();
                  messenger.showSnackBar(
                    SnackBar(content: Text(l10n.ads_resetCountersDone)),
                  );
                },
              ),
            ],
          ),
      ],
    );
  }
}
