import 'dart:math' as math;

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/dashboard/domain/greeting.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

/// DSH-01 app bar title: the greeting (`titleMedium`) over today's date
/// `EEE, d MMM` (`bodySmall`).
class HomeAppBarTitle extends StatelessWidget {
  const new({required this.greeting, required this.today, super.key});

  final Greeting greeting;
  final DateTime today;

  static String greetingText(AppLocalizations l10n, Greeting g) => switch (g) {
    Greeting.morning => l10n.home_greetingMorning,
    Greeting.afternoon => l10n.home_greetingAfternoon,
    Greeting.evening => l10n.home_greetingEvening,
  };

  /// Toolbar height that fits both lines at the current text scale, never
  /// less than the standard toolbar.
  static double toolbarHeight(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scaler = MediaQuery.textScalerOf(context);
    final tokens = AppTokens.of(context);
    double lineOf(TextStyle? style) {
      final painter = TextPainter(
        text: TextSpan(text: 'Ag', style: style),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      final h = painter.height;
      painter.dispose();
      return h;
    }

    return math.max(
      kToolbarHeight,
      lineOf(textTheme.titleMedium) + lineOf(textTheme.bodySmall) + tokens.s16,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          greetingText(l10n, greeting),
          key: const Key('home_greeting'),
          style: textTheme.titleMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          DateFormat('EEE, d MMM', locale).format(today),
          key: const Key('home_date'),
          style: textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// The non-null `appBarBadge`s of [modules], in module order, each keyed
/// `home_badge_<moduleId>`.
List<Widget> homeBadges(BuildContext context, List<TrackerModule> modules) => [
  for (final m in modules)
    if (m.appBarBadge(context) case final badge?)
      KeyedSubtree(key: Key('home_badge_${m.id}'), child: badge),
];
