import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/recurrence.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/schedule_text.dart';
import 'package:flutter/material.dart';

/// EXP-10 rule row (US3 s8–s9): icon, note or category, signed amount,
/// the schedule in words, and the next date (or "Ended …"). Swipe right
/// pauses or resumes, swipe left deletes; both are also in the long-press
/// menu ([onMenu]).
class RecurringRow extends StatelessWidget {
  const new({
    required this.view,
    required this.currencyCode,
    required this.onTap,
    required this.onTogglePause,
    required this.onDelete,
    required this.onMenu,
    super.key,
  });

  final RecurringRuleView view;
  final String currencyCode;
  final VoidCallback onTap;
  final VoidCallback onTogglePause;
  final VoidCallback onDelete;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final rule = view.rule;
    final category = view.category;
    final isTransfer = rule.type == TxnType.transfer;
    final locale = l10n.localeName;
    final title = switch (rule.note) {
      final n? when n.isNotEmpty => n,
      _ when category != null => l10n.categoryName(category),
      _ => l10n.txnType(rule.type),
    };
    final schedule = scheduleText(
      l10n,
      RecurrenceSchedule(
        anchorLocal: rule.anchorAt.toLocal(),
        frequency: rule.frequency,
        interval: rule.interval,
      ).describe(),
    );
    final dateFormat = FullDateFormatScope.of(context);
    final when = rule.isEnded
        ? l10n.expense_recurringEnded(
            formatFullDate(rule.endAt!.toLocal(), dateFormat, locale),
          )
        : l10n.expense_recurringNext(
            formatFullDate(rule.nextRunAt.toLocal(), dateFormat, locale),
          );
    final staleText =
        view.account.isArchived || (view.toAccount?.isArchived ?? false)
        ? l10n.expense_recurringStaleAccount
        : l10n.expense_recurringStaleCategory;
    final scheme = theme.colorScheme;
    final paused = !rule.isActive;

    Widget swipeBackground(
      IconData icon,
      String label,
      Color color,
      Alignment alignment,
    ) => Container(
      color: color,
      alignment: alignment,
      padding: EdgeInsets.symmetric(horizontal: tokens.s16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: scheme.onPrimary),
          SizedBox(width: tokens.s8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: scheme.onPrimary,
            ),
          ),
        ],
      ),
    );

    return Dismissible(
      key: ValueKey('rule_${rule.id}'),
      background: swipeBackground(
        paused ? Icons.play_arrow : Icons.pause,
        paused ? l10n.expense_recurringResume : l10n.expense_recurringPause,
        scheme.primary,
        AlignmentDirectional.centerStart.resolve(Directionality.of(context)),
      ),
      secondaryBackground: swipeBackground(
        Icons.delete_outline,
        l10n.expense_recurringDelete,
        scheme.error,
        AlignmentDirectional.centerEnd.resolve(Directionality.of(context)),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // An ended rule can only be resumed by changing its end date.
          if (!rule.isEnded) onTogglePause();
          return false;
        }
        return true;
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        key: ValueKey('rule_row_${rule.id}'),
        contentPadding: EdgeInsets.zero,
        minTileHeight: tokens.s48 + tokens.s16,
        onTap: onTap,
        onLongPress: onMenu,
        leading: CategoryAvatar(
          icon: isTransfer
              ? Icons.swap_horiz
              : AppIcons.byKey(category?.iconKey ?? 'category'),
          color: category == null
              ? scheme.primary
              : colorFromHex(category.colorHex),
          semanticLabel: category == null
              ? l10n.txnType(rule.type)
              : l10n.categoryName(category),
        ),
        title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(schedule),
            Text(key: ValueKey('rule_when_${rule.id}'), when),
            if (view.staleReference)
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    size: tokens.chipIconSize,
                    color: scheme.error,
                  ),
                  SizedBox(width: tokens.s4),
                  Flexible(
                    child: Text(
                      key: ValueKey('rule_stale_${rule.id}'),
                      staleText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.error,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: AmountText(
          amountMinor: rule.amountMinor,
          currencyCode: currencyCode,
          kind: amountKindFor(rule.type),
          showSign: true,
          style: theme.textTheme.titleMedium,
        ),
      ),
    );
  }
}
