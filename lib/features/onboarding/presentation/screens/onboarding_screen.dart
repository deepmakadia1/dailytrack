import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/presentation/backup_password_sheet.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:dailytrack/features/onboarding/presentation/controllers/onboarding_state.dart';
import 'package:dailytrack/features/onboarding/presentation/widgets/currency_step.dart';
import 'package:dailytrack/features/onboarding/presentation/widgets/language_step.dart';
import 'package:dailytrack/features/onboarding/presentation/widgets/modules_step.dart';
import 'package:dailytrack/features/onboarding/presentation/widgets/privacy_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// SYS-02 Onboarding (T071): 4 steps, Skip on steps 1–2, one primary button.
/// No ads. The router leaves this screen once settings report onboarding
/// done.
class OnboardingScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pages = PageController();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _showStep(int step) {
    if (!_pages.hasClients) return;
    final page = step - 1;
    if (MediaQuery.disableAnimationsOf(context)) {
      _pages.jumpToPage(page);
    } else {
      _pages.animateToPage(
        page,
        duration: AppTokens.of(context).motionMedium,
        curve: Easing.standard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final registry = ref.watch(moduleRegistryProvider);

    ref.listen(
      onboardingControllerProvider.select((s) => s.step),
      (_, step) => _showStep(step),
    );

    // Full screen while restoring; back can't interrupt it (FR-017).
    if (state.googleRestore == GoogleRestoreStatus.restoring) {
      return PopScope(
        canPop: false,
        child: Scaffold(
          body: Center(
            key: const Key('sys02_restoring'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: tokens.s16),
                Text(l10n.account_restoring),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          l10n.onboarding_stepLabel(state.step, OnboardingState.stepCount),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        actions: [
          if (state.canSkip)
            TextButton(
              key: const Key('onboarding_skip'),
              onPressed: state.saving ? null : controller.skip,
              child: Text(l10n.common_skip),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(tokens.s4),
          child: LinearProgressIndicator(
            value: state.step / OnboardingState.stepCount,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pad = tokens.sidePadding(constraints.maxWidth);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          controller: _pages,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            LanguageStep(
                              languageCode: state.languageCode,
                              onLanguageSelected: controller.selectLanguage,
                              restore: ref.watch(driveAvailableProvider)
                                  ? _RestoreWithGoogle(state: state)
                                  : null,
                            ),
                            CurrencyStep(
                              selectedCode: state.currencyCode,
                              query: state.query,
                              onQueryChanged: controller.setQuery,
                              onSelected: controller.selectCurrency,
                            ),
                            ModulesStep(
                              registry: registry,
                              enabledModules: state.enabledModules,
                              messageKey: state.moduleMessageKey,
                              onToggle: controller.toggleModule,
                            ),
                            PrivacyStep(
                              notificationsGranted: state.notificationsGranted,
                              onAllowNotifications:
                                  controller.requestNotifications,
                              // SYS-04 is a route above onboarding (feature
                              // 007 research R10); its result arrives through
                              // the settings stream.
                              appLockOn: ref.watch(
                                appSettingsProvider.select(
                                  (s) => s.value?.lockEnabled ?? false,
                                ),
                              ),
                              onSetAppLock: (lockOn) => unawaited(
                                context.push<bool>(
                                  Routes.pinPath(
                                    lockOn
                                        ? Routes.pinModeChange
                                        : Routes.pinModeSet,
                                    from: Routes.onboarding,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (state.saveErrorKey != null)
                        _SaveError(
                          message:
                              l10nByKey(l10n, state.saveErrorKey!) ??
                              l10n.onboarding_saveError,
                          retryLabel: l10n.common_retry,
                          onRetry: state.saving ? null : controller.retrySave,
                        ),
                      _BottomBar(state: state, controller: controller),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// SYS-02 step 1 "Restore with Google" (spec §2): a secondary button, and
/// what happened last time it was tapped.
class _RestoreWithGoogle extends ConsumerWidget {
  const new({required this.state});

  final OnboardingState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final busy =
        state.saving || state.googleRestore == GoogleRestoreStatus.signingIn;

    Future<void> restore() {
      // Shown over Home after the router leaves onboarding.
      final proRestored = l10n.premium_restored;
      return ref
          .read(onboardingControllerProvider.notifier)
          .restoreWithGoogle(
            askPassword: ({required wrong}) => showBackupPasswordPrompt(
              context,
              error: wrong ? l10n.account_wrongPassword : null,
            ),
            onProRestored: () => rootMessengerKey.currentState?.showSnackBar(
              SnackBar(
                key: const Key('sys02_proRestored'),
                content: Text(proRestored),
              ),
            ),
          );
    }

    final error = state.googleRestoreError;
    final message = switch (state.googleRestore) {
      GoogleRestoreStatus.noBackup => l10n.onboarding_noBackupFound,
      GoogleRestoreStatus.failed when error is DriveAuthRequired =>
        l10n.account_sessionExpired,
      GoogleRestoreStatus.failed => l10n.account_restoreFailed,
      _ => null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          key: const Key('sys02.restoreWithGoogle'),
          onPressed: busy ? null : () => unawaited(restore()),
          icon: busy
              ? SizedBox.square(
                  dimension: tokens.chipIconSize,
                  child: const CircularProgressIndicator(),
                )
              : const Icon(Icons.cloud_download_outlined),
          label: Text(
            state.googleRestore == GoogleRestoreStatus.failed
                ? l10n.common_tryAgain
                : l10n.onboarding_restoreWithGoogle,
          ),
        ),
        if (message != null) ...[
          SizedBox(height: tokens.s8),
          Text(
            message,
            key: const Key('sys02_restoreMessage'),
            textAlign: TextAlign.center,
            style: state.googleRestore == GoogleRestoreStatus.failed
                ? theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  )
                : theme.textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const new({required this.state, required this.controller});

  final OnboardingState state;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.s16),
      child: Row(
        children: [
          if (state.step > 1)
            TextButton(
              key: const Key('onboarding_back'),
              onPressed: state.saving ? null : controller.back,
              child: Text(l10n.common_back),
            ),
          const Spacer(),
          FilledButton(
            key: const Key('onboarding_primary'),
            onPressed: state.saving
                ? null
                : state.isLastStep
                ? controller.complete
                : controller.next,
            child: state.saving
                ? SizedBox.square(
                    dimension: tokens.s16,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    state.isLastStep
                        ? l10n.onboarding_getStarted
                        : l10n.common_next,
                  ),
          ),
        ],
      ),
    );
  }
}

/// Inline save error with a retry action (FR-024).
class _SaveError extends StatelessWidget {
  const new({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = AppTokens.of(context);
    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: theme.colorScheme.error),
          SizedBox(width: tokens.s8),
          Expanded(child: Text(message, style: theme.textTheme.bodyMedium)),
          TextButton(
            key: const Key('onboarding_retry'),
            onPressed: onRetry,
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}
