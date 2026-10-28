import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_restore.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/presentation/backup_summaries.dart';
import 'package:dailytrack/core/backup/presentation/drive_restore_flow.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/security/secure_screen_service.dart';
import 'package:dailytrack/core/security/security_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/lock/presentation/controllers/unlock_controller.dart';
import 'package:dailytrack/features/lock/presentation/widgets/forgot_pin_sheet.dart';
import 'package:dailytrack/features/lock/presentation/widgets/lock_texts.dart';
import 'package:dailytrack/features/lock/presentation/widgets/pin_dots.dart';
import 'package:dailytrack/features/lock/presentation/widgets/pin_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// SYS-03 Unlock (spec §6, feature 007 contracts/screens.md): logo, "Enter
/// PIN", 4 dots, and the keypad with a biometric key. Shown as the `/lock`
/// route on a cold start, or covering the app after a resume
/// ([LockMode.overlay]) so the screens below keep their state. Screenshots
/// are blocked while it shows (SYS-03 AC3); back closes the app. No ads,
/// ever (§11). "Forgot PIN?" offers restoring from a Google Drive backup
/// (FR-024) or erasing all data (FR-035).
class UnlockScreen extends ConsumerStatefulWidget {
  const new({required this.mode, super.key, this.from});

  final LockMode mode;

  /// Route mode: where the user was going (the redirect sends them there
  /// once unlocked).
  final String? from;

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  late final SecureScreenController _secure;
  late final AppLifecycleListener _lifecycle;
  Orientation? _orientation;
  bool _promptShown = false;

  UnlockController get _controller =>
      ref.read(unlockControllerProvider.notifier);

  /// "Restore from Google Drive backup" (FR-024): on success the forgotten
  /// PIN, biometric unlock, and any lockout are cleared and app lock turns
  /// off, so the user can set a new PIN; then Home opens. A restore never
  /// carries lock settings (FR-009), so this is the only place they change.
  Future<DriveRestoreResult> _restoreFromDrive(AppLocalizations l10n) async {
    final settings = ref.read(settingsRepositoryProvider);
    final result = await showDriveRestoreFlow(
      context,
      drive: ref.read(driveBackupStoreProvider),
      restore: ref.read(restoreServiceProvider),
      moduleSummaries: backupSummaries(ref.read(moduleRegistryProvider), l10n),
      // Committed at once, as before feature 011 (its T050 moves the
      // commit after the restore).
      signIn: () async {
        final account = ref.read(accountServiceProvider);
        if (await account.signIn() == null) return false;
        await account.commitSignIn();
        return true;
      },
      // The account restore (feature 010 spec Edge Cases): the safety copy
      // first, then the last known backup, the pause, and FR-019b.
      applyFor: (entry) => (candidate, password) async {
        final restored = await ref
            .read(accountRestoreProvider)
            .apply(
              OpenedBackup(candidate, password: password),
              entry: entry,
              fromEmptyPhone: false,
            );
        return switch (restored) {
          Restored(:final outcome) => outcome,
          SafetyCopyFailed() => throw const BackupStorageFull(),
        };
      },
    );
    if (result != DriveRestoreResult.restored) return result;
    await ref.read(lockServiceProvider).reset();
    await settings.setBiometricEnabled(enabled: false);
    await settings.setLockEnabled(enabled: false);
    ref.read(lockSessionProvider.notifier).unlocked();
    if (mounted) GoRouter.of(context).go(Routes.home);
    return result;
  }

  @override
  void initState() {
    super.initState();
    _secure = ref.read(secureScreenControllerProvider.notifier);
    final session = ref.read(lockSessionProvider.notifier);
    _lifecycle = AppLifecycleListener(onHide: () => _controller.clearEntry());
    // Providers can't change while the tree builds; do it right after.
    scheduleMicrotask(() {
      _secure.setUnlockVisible(visible: true);
      // A new navigation while locked shows SYS-03 as the route; the
      // covering overlay is no longer needed.
      if (widget.mode == LockMode.route) session.showAsRoute();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.orientationOf(context);
    if (_orientation != null && orientation != _orientation) {
      // Not during build: providers may not change while the tree builds.
      scheduleMicrotask(_controller.clearEntry);
    }
    _orientation = orientation;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    final secure = _secure;
    scheduleMicrotask(() => secure.setUnlockVisible(visible: false));
    super.dispose();
  }

  void _autoPrompt(String reason) {
    if (_promptShown) return;
    _promptShown = true;
    unawaited(_controller.biometric(reason));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(unlockControllerProvider);
    final controller = _controller;

    ref
      // Biometric unlock opens on its own once per lock (FR-029).
      ..listen(unlockControllerProvider.select((s) => s.biometricReady), (
        _,
        ready,
      ) {
        if (ready) _autoPrompt(l10n.lock_biometricReason);
      })
      // Unlocked: the redirect (route) or the overlay's removal shows what
      // was there; a deferred notification target opens next (app.dart).
      ..listen(unlockControllerProvider.select((s) => s.unlocked), (_, done) {
        if (done) {
          unawaited(HapticFeedback.lightImpact());
          ref.read(lockSessionProvider.notifier).unlocked();
        }
      });

    final lockedOut = state.lockoutRemaining > Duration.zero;
    final unavailable = state.status == LockStatus.credentialUnavailable;
    final message = unavailable
        ? l10n.lock_credentialUnavailable
        : lockedOut
        ? l10n.lock_tryAgainIn(formatCountdown(state.lockoutRemaining))
        : state.error == UnlockError.wrong && state.attemptsLeft != null
        ? l10n.lock_attemptsLeft(state.attemptsLeft!)
        : state.nextLockout != null
        ? l10n.lock_nextLockoutWarning(formatCountdown(state.nextLockout!))
        : state.error == UnlockError.wrong
        ? l10n.lock_wrongPin
        : null;

    final body = Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(tokens.screenPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/branding/logo.png',
                    width: tokens.s48 * 1.5,
                    height: tokens.s48 * 1.5,
                    excludeFromSemantics: true,
                  ),
                  SizedBox(height: tokens.s16),
                  Semantics(
                    header: true,
                    child: Text(
                      l10n.lock_enterPin,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                  SizedBox(height: tokens.s24),
                  PinDots(filled: state.entered, shakeCount: state.shakeCount),
                  SizedBox(height: tokens.s16),
                  SizedBox(
                    height: tokens.s48,
                    child: message == null
                        ? null
                        : Semantics(
                            liveRegion: true,
                            child: Text(
                              message,
                              key: const Key('unlock_message'),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color:
                                    lockedOut || state.error != UnlockError.none
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                  if (!unavailable)
                    PinKeypad(
                      enabled:
                          state.status == LockStatus.enabled &&
                          !state.busy &&
                          !lockedOut,
                      onDigit: controller.digit,
                      onBackspace: controller.backspace,
                      onBiometric: state.biometricReady
                          ? () => unawaited(
                              controller.biometric(l10n.lock_biometricReason),
                            )
                          : null,
                    ),
                  SizedBox(height: tokens.s8),
                  // FR-035; also the only way out when the PIN can't be read.
                  TextButton(
                    key: const Key('unlock_forgot_pin'),
                    onPressed: () => unawaited(
                      showForgotPinSheet(
                        context,
                        ref.read(appResetServiceProvider),
                        restoreFromDrive: ref.read(driveAvailableProvider)
                            ? () => _restoreFromDrive(l10n)
                            : null,
                      ),
                    ),
                    child: Text(l10n.lock_forgotPin),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Route mode: back closes the app and never reveals anything (FR-034).
    // Overlay mode is handled by the app's back button dispatcher.
    return widget.mode == LockMode.route
        ? PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) unawaited(SystemNavigator.pop());
            },
            child: body,
          )
        : body;
  }
}
