import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/settings_section.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/settings/presentation/controllers/security_controller.dart';
import 'package:dailytrack/features/settings/presentation/widgets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// SET-05 Security (spec §10, feature 007 contracts/screens.md): app lock,
/// change PIN, biometric unlock, lock after, and hide content in recents.
/// The rows that need a PIN are disabled, with a reason, while the lock is
/// off (FR-025). No ads (§11).
class SecurityScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(securityControllerProvider);
    return AppScaffold(
      title: l10n.security_title,
      padBody: false,
      body: switch (async) {
        AsyncValue(:final value?) => _SecurityList(state: value),
        AsyncError() => ErrorState(
          message: l10n.settings_loadError,
          onRetry: ref.read(securityControllerProvider.notifier).retry,
        ),
        _ => const DelayedSkeleton(child: SkeletonList(itemCount: 5)),
      },
    );
  }
}

class _SecurityList extends ConsumerWidget {
  const new({required this.state});

  final SecurityState state;

  static String lockAfterLabel(AppLocalizations l10n, int seconds) =>
      switch (LockAfter.fromSeconds(seconds)) {
        LockAfter.immediately => l10n.security_immediately,
        LockAfter.oneMinute => l10n.security_after1Min,
        LockAfter.fiveMinutes => l10n.security_after5Min,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(securityControllerProvider.notifier);
    final lockOn = state.lockOn;
    final biometricUsable =
        lockOn && state.biometric == BiometricAvailability.available;
    final biometricNote = !lockOn
        ? l10n.security_needsLock
        : switch (state.biometric) {
            BiometricAvailability.none => l10n.security_biometricNone,
            BiometricAvailability.notEnrolled =>
              l10n.security_biometricNotEnrolled,
            BiometricAvailability.available => null,
          };

    // SYS-04 owns the PIN; the switch follows the stored setting.
    Future<void> openPin(String mode) =>
        context.push<bool>(Routes.pinPath(mode, from: Routes.security));

    Future<void> pickLockAfter() async {
      final picked = await showChoiceSheet<int>(
        context,
        title: l10n.security_lockAfter,
        selected: state.lockAfterSeconds,
        choices: [
          for (final option in LockAfter.values)
            (
              value: option.seconds,
              label: lockAfterLabel(l10n, option.seconds),
              key: Key('lock_after_${option.seconds}'),
            ),
        ],
      );
      if (picked != null) await controller.setLockAfter(picked.value);
    }

    return ListView(
      key: const Key('security_list'),
      children: [
        SettingsSection(
          title: l10n.settings_security,
          children: [
            SwitchListTile(
              key: const Key('security_app_lock'),
              secondary: const Icon(Icons.lock_outline),
              title: Text(l10n.security_appLock),
              value: lockOn,
              onChanged: (on) => unawaited(
                openPin(on ? Routes.pinModeSet : Routes.pinModeDisable),
              ),
            ),
            ListTile(
              key: const Key('security_change_pin'),
              enabled: lockOn,
              leading: const Icon(Icons.pin_outlined),
              title: Text(l10n.security_changePin),
              subtitle: lockOn ? null : Text(l10n.security_needsLock),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(openPin(Routes.pinModeChange)),
            ),
            SwitchListTile(
              key: const Key('security_biometric'),
              secondary: const Icon(Icons.fingerprint),
              title: Text(l10n.security_biometric),
              subtitle: biometricNote == null ? null : Text(biometricNote),
              value: biometricUsable && state.biometricEnabled,
              onChanged: biometricUsable
                  ? (on) => unawaited(
                      controller.setBiometric(
                        enabled: on,
                        reason: l10n.lock_biometricReason,
                      ),
                    )
                  : null,
            ),
            ListTile(
              key: const Key('security_lock_after'),
              enabled: lockOn,
              leading: const Icon(Icons.timer_outlined),
              title: Text(l10n.security_lockAfter),
              subtitle: Text(
                lockOn
                    ? lockAfterLabel(l10n, state.lockAfterSeconds)
                    : l10n.security_needsLock,
              ),
              onTap: () => unawaited(pickLockAfter()),
            ),
            SwitchListTile(
              key: const Key('security_hide_in_recents'),
              secondary: const Icon(Icons.visibility_off_outlined),
              title: Text(l10n.security_hideInRecents),
              subtitle: Text(l10n.security_hideInRecentsHelp),
              value: state.hideInRecents,
              onChanged: (on) =>
                  unawaited(controller.setHideInRecents(enabled: on)),
            ),
            // Feature 008 (FR-047): only meaningful while the lock hides
            // the widget's data.
            SwitchListTile(
              key: const Key('security_show_widget_data'),
              secondary: const Icon(Icons.widgets_outlined),
              title: Text(l10n.security_showWidgetData),
              subtitle: Text(
                lockOn
                    ? l10n.security_showWidgetDataHelp
                    : l10n.security_needsLock,
              ),
              value: state.showDataOnWidget,
              onChanged: lockOn
                  ? (on) =>
                        unawaited(controller.setShowDataOnWidget(enabled: on))
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}
