import 'dart:async';

import 'package:dailytrack/core/billing/pro_service.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/features/premium/presentation/controllers/premium_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// PRM-01 Premium / Remove Ads (spec §10, feature 009 contracts/screens.md):
/// the headline, the benefits, a price button from Google Play, "Restore
/// purchase", and a note that the purchase is tied to the Google account.
/// A fixed-control screen: its states are loading, unavailable, purchasing,
/// pending, error, and owned, with no empty state (plan Complexity
/// Tracking). Never shows ads (FR-009).
class PremiumScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(premiumControllerProvider);
    final controller = ref.read(premiumControllerProvider.notifier);
    final owned = state.phase == PremiumPhase.owned;

    Future<void> restore() async {
      final messenger = ScaffoldMessenger.of(context);
      final result = await controller.restore();
      final text = switch (result) {
        RestoreResult.restored => l10n.premium_restored,
        RestoreResult.pending => l10n.premium_pending,
        RestoreResult.notFound => l10n.premium_restoreNotFound,
        RestoreResult.unavailable => l10n.premium_storeUnavailable,
      };
      messenger.showSnackBar(
        SnackBar(
          key: Key('premium_restore_${result.name}'),
          content: Text(text),
        ),
      );
    }

    final benefits = <(IconData, String)>[
      (Icons.block, l10n.premium_benefitNoAds),
      (Icons.palette_outlined, l10n.premium_benefitThemes),
      (Icons.insights_outlined, l10n.premium_benefitReports),
      (Icons.ios_share, l10n.premium_benefitExports),
      (Icons.ac_unit, l10n.premium_benefitFreezes),
    ];

    Widget card(Key key, IconData icon, String text) => Card(
      key: key,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.s16),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            SizedBox(width: tokens.s12),
            Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
          ],
        ),
      ),
    );

    final status = switch (state.phase) {
      PremiumPhase.owned => card(
        const Key('premium_owned'),
        Icons.verified_outlined,
        l10n.premium_owned,
      ),
      PremiumPhase.pending => card(
        const Key('premium_pending'),
        Icons.hourglass_top,
        l10n.premium_pending,
      ),
      PremiumPhase.error => ErrorState(
        key: const Key('premium_error'),
        message: l10n.premium_purchaseError,
        onRetry: () => unawaited(controller.retry()),
      ),
      _ => null,
    };

    final busy =
        state.phase == PremiumPhase.loading ||
        state.phase == PremiumPhase.purchasing;
    final price = state.product?.price;
    final buy = switch (state.phase) {
      PremiumPhase.owned || PremiumPhase.pending || PremiumPhase.error => null,
      _ => FilledButton(
        key: const Key('premium_buy'),
        onPressed: state.phase == PremiumPhase.ready
            ? () => unawaited(controller.buy())
            : null,
        child: busy
            ? SizedBox.square(
                dimension: tokens.s16,
                child: CircularProgressIndicator(strokeWidth: tokens.s4 / 2),
              )
            : Text(
                price == null
                    ? l10n.premium_storeUnavailable
                    : l10n.premium_buyFor(price),
                textAlign: TextAlign.center,
              ),
      ),
    };

    return AppScaffold(
      title: l10n.premium_title,
      body: ListView(
        key: const Key('premium_benefits'),
        padding: EdgeInsets.symmetric(vertical: tokens.s16),
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.premium_title,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          SizedBox(height: tokens.s16),
          for (final (icon, text) in benefits)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: theme.colorScheme.primary),
              title: Text(text),
            ),
          SizedBox(height: tokens.s16),
          if (status != null) ...[status, SizedBox(height: tokens.s16)],
          ?buy,
          if (!owned) ...[
            SizedBox(height: tokens.s8),
            TextButton(
              key: const Key('premium_restore'),
              onPressed: () => unawaited(restore()),
              child: Text(l10n.premium_restore),
            ),
          ],
          SizedBox(height: tokens.s8),
          Text(
            l10n.premium_accountNote,
            key: const Key('premium_account_note'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
