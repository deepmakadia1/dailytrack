import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/presentation/controllers/recent_transactions_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/transaction_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// DSH-01 Recent transactions (`ExpenseModule.dashboardSections()`, feature
/// 006 contracts/screens.md): "See all" opens EXP-01, then up to five
/// EXP-01 rows (transfers as "From → To" with a neutral amount) that open
/// EXP-03. Hidden when there are no transactions, so Home leaves no gap.
class RecentTransactionsSection extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final async = ref.watch(recentTransactionsControllerProvider);
    final currency = currencyCodeOf(ref);

    final body = switch (async) {
      AsyncValue(:final value?) when value.isEmpty => null,
      AsyncValue(:final value?) => Column(
        children: [
          for (final view in value)
            TransactionRow(
              key: Key('recent_row_${view.transaction.id}'),
              view: view,
              currency: currency,
              onTap: () => unawaited(
                context.push(Routes.expenseDetailPath(view.transaction.id)),
              ),
              onLongPress: () => unawaited(
                context.push(Routes.expenseDetailPath(view.transaction.id)),
              ),
            ),
        ],
      ),
      AsyncError() => Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.s16),
        child: Row(
          key: const Key('recent_error'),
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            SizedBox(width: tokens.s8),
            Expanded(child: Text(l10n.expense_loadDataError)),
            TextButton(
              onPressed: ref
                  .read(recentTransactionsControllerProvider.notifier)
                  .retry,
              child: Text(l10n.common_tryAgain),
            ),
          ],
        ),
      ),
      _ => const DelayedSkeleton(child: SkeletonList(itemCount: 2)),
    };
    if (body == null) return const SizedBox.shrink();

    return Card(
      key: const Key('recent_transactions'),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: tokens.s16,
                end: tokens.s8,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        l10n.home_recentTitle,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ),
                  TextButton(
                    key: const Key('recent_see_all'),
                    onPressed: () => context.go(Routes.expenses),
                    child: Text(l10n.home_seeAll),
                  ),
                ],
              ),
            ),
            body,
          ],
        ),
      ),
    );
  }
}
