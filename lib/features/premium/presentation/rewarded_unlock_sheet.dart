import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/rewarded_unlock.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/features/premium/presentation/controllers/rewarded_unlock_controller.dart';
import 'package:dailytrack/features/premium/presentation/rewarded_offers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Shows PRM-02 as a bottom sheet (spec §5): bound to
/// `rewardedUnlockPresenterProvider` in the composition root.
final class PremiumRewardedUnlockPresenter implements RewardedUnlockPresenter {
  const new();

  @override
  Future<bool> present(
    BuildContext context,
    RewardedUnlockRequest request,
  ) async {
    final offer = rewardedOfferFor(
      AppLocalizations.of(context),
      request.key,
      subjectName: request.subjectName,
    );
    final result = await AppBottomSheet.show<bool>(
      context,
      title: offer.title,
      child: RewardedUnlockSheet(request: request),
    );
    // A swipe down is "Not now".
    return result ?? false;
  }
}

/// PRM-02 Rewarded unlock prompt (spec §10, feature 009 contracts/screens
/// .md): what the user gets, then "Watch a short ad", "Get Pro instead",
/// and "Not now". No banner or native ads (FR-009).
class RewardedUnlockSheet extends ConsumerStatefulWidget {
  const new({required this.request, super.key});

  final RewardedUnlockRequest request;

  @override
  ConsumerState<RewardedUnlockSheet> createState() =>
      _RewardedUnlockSheetState();
}

class _RewardedUnlockSheetState extends ConsumerState<RewardedUnlockSheet> {
  RewardedUnlockControllerProvider get _provider =>
      rewardedUnlockControllerProvider(widget.request.key);

  @override
  void initState() {
    super.initState();
    unawaited(ref.read(_provider.notifier).start(widget.request));
  }

  void _getPro() {
    final router = GoRouter.of(context);
    Navigator.of(context).pop(false);
    unawaited(router.push<void>(Routes.premium));
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(_provider, (_, next) {
      if (next.phase == RewardedPhase.done) {
        Navigator.of(context).pop(next.result ?? false);
      }
    });
    final state = ref.watch(_provider);
    final controller = ref.read(_provider.notifier);
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final offer = rewardedOfferFor(
      l10n,
      widget.request.key,
      subjectName: widget.request.subjectName,
    );

    final note = switch (state.phase) {
      RewardedPhase.limitReached => l10n.rewarded_limitReached,
      RewardedPhase.unavailable => l10n.rewarded_unavailable,
      _ when state.closedEarly => l10n.rewarded_closedEarly,
      _ => null,
    };
    final noteKey = switch (state.phase) {
      RewardedPhase.limitReached => 'rewarded_limit',
      RewardedPhase.unavailable => 'rewarded_unavailable',
      _ => 'rewarded_closed_early',
    };

    final primary = switch (state.phase) {
      RewardedPhase.limitReached || RewardedPhase.done => const SizedBox(),
      RewardedPhase.unavailable => FilledButton(
        key: const Key('rewarded_try_again'),
        onPressed: () => unawaited(controller.retry()),
        child: Text(l10n.rewarded_tryAgain),
      ),
      RewardedPhase.ready => FilledButton.icon(
        key: const Key('rewarded_watch'),
        onPressed: () => unawaited(controller.watch()),
        icon: const Icon(Icons.play_circle_outline),
        label: Text(l10n.rewarded_watch),
      ),
      RewardedPhase.loading || RewardedPhase.showing => FilledButton.icon(
        key: const Key('rewarded_watch'),
        onPressed: null,
        icon: SizedBox.square(
          dimension: tokens.s16,
          child: CircularProgressIndicator(
            strokeWidth: tokens.s4 / 2,
            semanticsLabel: l10n.rewarded_loadingAd,
          ),
        ),
        label: Text(l10n.rewarded_watch),
      ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: tokens.avatarSize / 2,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                offer.icon,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(width: tokens.s12),
            Expanded(
              child: Text(
                offer.explanation,
                key: const Key('rewarded_explanation'),
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        if (note != null) ...[
          SizedBox(height: tokens.s12),
          Text(
            note,
            key: Key(noteKey),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        SizedBox(height: tokens.s16),
        primary,
        SizedBox(height: tokens.s8),
        OutlinedButton(
          key: const Key('rewarded_get_pro'),
          onPressed: _getPro,
          child: Text(l10n.rewarded_getPro),
        ),
        TextButton(
          key: const Key('rewarded_not_now'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.rewarded_notNow),
        ),
      ],
    );
  }
}
