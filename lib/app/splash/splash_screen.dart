import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SYS-01 Splash. Shows the logo while startup runs and the error state with
/// "Retry" if storage fails to open. Never shows an ad.
class SplashScreen extends ConsumerWidget {
  const new({super.key});

  static const String logoAsset = 'assets/branding/logo.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final result = ref.watch(bootstrapProvider).value;

    if (result is BootstrapFailed) {
      return Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.screenPadding),
            child: ErrorState(
              message: l10n.splash_errorMessage,
              retryLabel: l10n.common_retry,
              onRetry: () => ref.read(bootstrapProvider.notifier).retry(),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              logoAsset,
              width: tokens.s48 * 2,
              height: tokens.s48 * 2,
              excludeFromSemantics: true,
            ),
            SizedBox(height: tokens.s16),
            Text(l10n.appName, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
