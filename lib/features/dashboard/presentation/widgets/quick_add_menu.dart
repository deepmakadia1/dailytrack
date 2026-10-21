import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// DSH-01 + button: one FAB whose small menu lists every visible module's
/// quick adds in module order (FR-020, research R12).
class QuickAddMenu extends StatelessWidget {
  const new({required this.actions, super.key});

  final List<QuickAddAction> actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return MenuAnchor(
      alignmentOffset: Offset(0, -tokens.s8),
      menuChildren: [
        for (final action in actions)
          MenuItemButton(
            key: Key('home_quick_add_${action.labelKey}'),
            leadingIcon: Icon(action.icon),
            style: MenuItemButton.styleFrom(
              minimumSize: Size(0, tokens.minTouchTarget),
            ),
            onPressed: () => unawaited(context.push(action.location)),
            child: Text(l10nByKey(l10n, action.labelKey) ?? action.labelKey),
          ),
      ],
      builder: (context, controller, _) => FloatingActionButton(
        key: const Key('home_fab'),
        heroTag: null,
        tooltip: l10n.home_quickAddTooltip,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
