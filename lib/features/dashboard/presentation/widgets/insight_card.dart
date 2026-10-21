import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/summary_card.dart';
import 'package:dailytrack/features/dashboard/domain/insight_rotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// DSH-01 "Tip for today" (FR-024–FR-028). A tap opens the insight's screen;
/// the starter tip is not tappable. A failed evaluation shows the starter.
class InsightCard extends StatelessWidget {
  const new({required this.insight, super.key});

  final AsyncValue<InsightPick> insight;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final pick = switch (insight) {
      AsyncValue(:final value?) => value,
      AsyncError() => const Starter(),
      _ => null,
    };
    if (pick == null) {
      return const DelayedSkeleton(child: SkeletonCard());
    }

    final (text, location, semanticLabel) = switch (pick) {
      Picked(:final insight) => (
        insight.text,
        insight.location,
        insight.semanticLabel ?? insight.text,
      ),
      Starter() => (l10n.home_insightStarter, null, l10n.home_insightStarter),
    };
    final card = SummaryCard(
      leading: CategoryAvatar(
        icon: Icons.lightbulb_outline,
        color: theme.colorScheme.primary,
        semanticLabel: l10n.home_insightTitle,
      ),
      title: l10n.home_insightTitle,
      value: Text(text),
    );
    final key = Key(pick is Starter ? 'home_insight_starter' : 'home_insight');
    if (location == null) {
      return Semantics(
        key: key,
        container: true,
        label: semanticLabel,
        excludeSemantics: true,
        child: card,
      );
    }
    return Semantics(
      key: key,
      container: true,
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      onTap: () => unawaited(context.push(location)),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusCard),
        onTap: () => unawaited(context.push(location)),
        child: card,
      ),
    );
  }
}
