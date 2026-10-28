import 'dart:async';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/auth/presentation/controllers/login_controller.dart';
import 'package:dailytrack/features/auth/presentation/controllers/login_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AUTH-01 Login (spec §6, feature 011 contracts/screens.md): Google or
/// guest. Full screen with no app bar; Android back closes the app. No ads.
/// It reads no data, so it has no loading or empty state (a fixed set of
/// controls; the feature plan says so). Leaving it is the router's job,
/// once `authMode` is set.
class LoginScreen extends ConsumerStatefulWidget {
  const new({super.key});

  /// The app logo, as on SYS-01.
  static const String logoAsset = 'assets/branding/logo.png';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  LoginController get _controller => ref.read(loginControllerProvider.notifier);

  /// Runs a Google action; when it asks for the restore check, opens ACC-02
  /// (or the no-data restore) and hands back the result.
  Future<void> _run(Future<LoginNext> Function() action) async {
    final next = await action();
    if (next is! LoginChooseRestore || !mounted) return;
    // Shown over Home, after the router leaves AUTH-01.
    final proRestored = AppLocalizations.of(context).premium_restored;
    final result = await ref
        .read(accountUiProvider)
        .showRestoreChoice(context, newest: next.newest, afterSignIn: true);
    if (!mounted) return;
    await _controller.onRestoreChoice(
      result,
      onProRestored: () => rootMessengerKey.currentState?.showSnackBar(
        SnackBar(
          key: const Key('auth01_proRestored'),
          content: Text(proRestored),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginControllerProvider);
    final Widget body;
    if (state.busy == LoginBusy.restoring) {
      body = const _Restoring();
    } else if (state.restoreFailed) {
      body = _RestoreFailed(
        onTryAgain: () => unawaited(_run(_controller.retryRestore)),
        onContinue: () => unawaited(_controller.continueWithoutRestoring()),
      );
    } else {
      body = _Choices(
        state: state,
        onGoogle: () => unawaited(_run(_controller.continueWithGoogle)),
        onTryAgain: () => unawaited(_run(_controller.tryAgain)),
        onGuest: () => unawaited(_controller.continueAsGuest()),
      );
    }
    return PopScope(
      canPop: false,
      // Back never returns to Intro or the screens before a sign-out.
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(SystemNavigator.pop());
      },
      child: Scaffold(body: SafeArea(child: body)),
    );
  }
}

/// Centered, at most [AppTokens.maxContentWidth] wide, scrolling when the
/// text is large.
class _Centered extends StatelessWidget {
  const new({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.sidePadding(constraints.maxWidth),
            vertical: tokens.s24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: tokens.maxContentWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class _Choices extends StatelessWidget {
  const new({
    required this.state,
    required this.onGoogle,
    required this.onTryAgain,
    required this.onGuest,
  });

  final LoginState state;
  final VoidCallback onGoogle;
  final VoidCallback onTryAgain;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final busy = state.isBusy;
    final error = switch (state.error) {
      LoginError.cancelled => l10n.auth_signInCancelled,
      LoginError.failed => l10n.account_signInFailed,
      LoginError.offline => l10n.auth_offline,
      null => null,
    };
    return _Centered(
      children: [
        Semantics(
          key: const Key('auth01_logo'),
          label: l10n.appName,
          image: true,
          child: Image.asset(
            LoginScreen.logoAsset,
            width: tokens.s48 * 2,
            height: tokens.s48 * 2,
            excludeFromSemantics: true,
          ),
        ),
        SizedBox(height: tokens.s16),
        ExcludeSemantics(
          child: Text(
            l10n.appName,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: tokens.s32),
        Text(
          l10n.auth_title,
          key: const Key('auth01_title'),
          style: theme.textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.s12),
        Text(
          l10n.auth_body,
          key: const Key('auth01_body'),
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.s32),
        FilledButton(
          key: const Key('auth01_google'),
          onPressed: busy ? null : onGoogle,
          child: state.busy == LoginBusy.signingIn
              ? SizedBox.square(
                  dimension: tokens.s16,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.auth_continueWithGoogle),
        ),
        SizedBox(height: tokens.s12),
        OutlinedButton(
          key: const Key('auth01_guest'),
          onPressed: busy ? null : onGuest,
          child: Text(l10n.auth_continueAsGuest),
        ),
        SizedBox(height: tokens.s12),
        Text(
          l10n.auth_guestNote,
          key: const Key('auth01_guestNote'),
          style: theme.textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        if (error != null) ...[
          SizedBox(height: tokens.s16),
          Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                ),
                SizedBox(width: tokens.s8),
                Expanded(
                  child: Text(
                    error,
                    key: const Key('auth01_error'),
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.s8),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              key: const Key('auth01_tryAgain'),
              onPressed: busy ? null : onTryAgain,
              child: Text(l10n.common_tryAgain),
            ),
          ),
        ],
      ],
    );
  }
}

/// The full-screen "Restoring your data…" view; back can't interrupt it.
/// ACC-02's own progress dialogs spin over it while the backup downloads
/// and is applied; it stays still under the password prompt.
class _Restoring extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return _Centered(
      children: [
        ExcludeSemantics(
          child: Icon(
            Icons.cloud_download_outlined,
            size: tokens.s48,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: tokens.s16),
        Text(
          l10n.account_restoring,
          key: const Key('auth01_restoring'),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// The restore failed after sign-in; this phone's data is unchanged.
class _RestoreFailed extends StatelessWidget {
  const new({required this.onTryAgain, required this.onContinue});

  final VoidCallback onTryAgain;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return _Centered(
      children: [
        Icon(
          Icons.cloud_off_outlined,
          size: tokens.s48,
          color: theme.colorScheme.error,
          semanticLabel: l10n.account_restoreFailed,
        ),
        SizedBox(height: tokens.s16),
        Text(
          l10n.account_restoreFailed,
          key: const Key('auth01_restoreFailed'),
          style: theme.textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: tokens.s24),
        FilledButton(
          key: const Key('auth01_restoreTryAgain'),
          onPressed: onTryAgain,
          child: Text(l10n.common_tryAgain),
        ),
        SizedBox(height: tokens.s12),
        OutlinedButton(
          key: const Key('auth01_continueWithoutRestoring'),
          onPressed: onContinue,
          child: Text(l10n.auth_continueWithoutRestoring),
        ),
      ],
    );
  }
}
