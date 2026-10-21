import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:flutter/material.dart';

/// EXP-01 sticky date header: "Today", "Yesterday" or `EEE, d MMM`, and that
/// day's net total (transfers excluded). Opaque, so rows scroll under it.
class DayHeader extends StatelessWidget {
  const new({
    required this.day,
    required this.total,
    required this.now,
    required this.currency,
    super.key,
  });

  /// Local midnight of the day.
  final DateTime day;
  final DayTotal total;
  final DateTime now;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final net = total.netMinor;
    return ColoredBox(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.s8),
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(
                  relativeDayLabel(
                    day,
                    now: now,
                    labels: RelativeDayLabels(
                      today: l10n.common_today,
                      yesterday: l10n.common_yesterday,
                    ),
                    locale: l10n.localeName,
                  ),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            AmountText(
              amountMinor: net.abs(),
              currencyCode: currency,
              kind: net < 0 ? AmountKind.expense : AmountKind.income,
              showSign: net != 0,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
