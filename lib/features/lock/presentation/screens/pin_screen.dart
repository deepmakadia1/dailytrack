import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/features/lock/presentation/controllers/pin_controller.dart';
import 'package:dailytrack/features/lock/presentation/pin_flow_mode.dart';
import 'package:dailytrack/features/lock/presentation/widgets/lock_texts.dart';
import 'package:dailytrack/features/lock/presentation/widgets/pin_dots.dart';
import 'package:dailytrack/features/lock/presentation/widgets/pin_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// SYS-04 Set / change PIN (spec §6, feature 007 contracts/screens.md):
/// the SYS-03 keypad with the steps current → new → confirm, and the
/// biometric offer after a first-time set. Done or back returns to the
/// screen that opened it; back saves nothing (FR-041). No ads (§11).
class PinScreen extends ConsumerStatefulWidget {
  const new({required this.mode, super.key, this.from});

  final PinFlowMode mode;

  /// Where to go when done or on back (the screen that opened SYS-04).
  final String? from;

  @override
  ConsumerState<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends ConsumerState<PinScreen> {
  late final AppLifecycleListener _lifecycle;
  Orientation? _orientation;

  PinController get _controller =>
      ref.read(pinControllerProvider(widget.mode).notifier);

  @override
  void initState() {
    super.initState();
    // Switching apps clears a half-typed PIN (spec edge case).
    _lifecycle = AppLifecycleListener(onHide: () => _controller.clearEntry());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // So does rotating: the manifest handles rotation, so nothing rebuilds
    // the screen from scratch.
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
    super.dispose();
  }

  void _close(PinOutcome outcome) {
    final l10n = AppLocalizations.of(context);
    final message = switch (outcome) {
      PinOutcome.lockOn => l10n.security_lockOn,
      PinOutcome.pinChanged => l10n.security_pinChanged,
      PinOutcome.lockOff => l10n.security_lockOff,
    };
    rootMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message)),
    );
    _leave();
  }

  /// Goes back to [PinScreen.from]. Leaving with `go` rather than `pop`
  /// updates the router at once, so the refresh that follows the lock
  /// setting change cannot re-open SYS-04 (go_router reports a pop only on
  /// the next frame). Callers follow the settings stream, not a result.
  void _leave() => context.go(widget.from ?? Routes.more);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(pinControllerProvider(widget.mode));
    final controller = _controller;

    ref.listen(pinControllerProvider(widget.mode).select((s) => s.outcome), (
      _,
      outcome,
    ) {
      if (outcome != null) _close(outcome);
    });

    final title = switch (state.step) {
      PinFlowStep.current => l10n.pin_enterCurrent,
      PinFlowStep.confirmNew => l10n.pin_confirmNew,
      PinFlowStep.offerBiometric => l10n.security_lockOn,
      _ => l10n.pin_enterNew,
    };
    final lockedOut = state.lockoutRemaining > Duration.zero;
    final message = lockedOut
        ? l10n.lock_tryAgainIn(formatCountdown(state.lockoutRemaining))
        : switch (state.error) {
            PinError.wrong when state.attemptsLeft != null =>
              l10n.lock_attemptsLeft(state.attemptsLeft!),
            PinError.wrong => l10n.lock_wrongPin,
            PinError.mismatch => l10n.pin_mismatch,
            PinError.saveFailed => l10n.pin_saveError,
            PinError.none => null,
          };

    return PopScope(
      // Back discards everything and reports "not done" (FR-041).
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leave();
      },
      child: AppScaffold(
        title: title,
        body: state.step == PinFlowStep.offerBiometric
            ? _BiometricOffer(
                on: state.biometricOn,
                onChanged: (on) => unawaited(
                  controller.setBiometric(
                    enabled: on,
                    reason: l10n.lock_biometricReason,
                  ),
                ),
                onDone: controller.finish,
              )
            : SingleChildScrollView(
                padding: EdgeInsets.symmetric(vertical: tokens.s24),
                child: Column(
                  children: [
                    Text(
                      title,
                      key: const Key('pin_title'),
                      style: textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: tokens.s24),
                    PinDots(
                      filled: state.entered,
                      shakeCount: state.shakeCount,
                    ),
                    SizedBox(height: tokens.s16),
                    SizedBox(
                      height: tokens.s48,
                      child: message == null
                          ? null
                          : Semantics(
                              liveRegion: true,
                              child: Text(
                                message,
                                key: const Key('pin_message'),
                                textAlign: TextAlign.center,
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                    ),
                    PinKeypad(
                      enabled: !state.busy && !lockedOut,
                      onDigit: controller.digit,
                      onBackspace: controller.backspace,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// After a first-time set: "Use fingerprint / face unlock" and Done.
class _BiometricOffer extends StatelessWidget {
  const new({required this.on, required this.onChanged, required this.onDone});

  final bool on;
  final ValueChanged<bool> onChanged;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return ListView(
      padding: EdgeInsets.symmetric(vertical: tokens.s24),
      children: [
        SwitchListTile(
          key: const Key('pin_offer_biometric'),
          secondary: const Icon(Icons.fingerprint),
          title: Text(l10n.pin_offerBiometric),
          value: on,
          onChanged: onChanged,
        ),
        SizedBox(height: tokens.s24),
        FilledButton(
          key: const Key('pin_done'),
          onPressed: onDone,
          child: Text(l10n.pin_done),
        ),
      ],
    );
  }
}
