import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/recurrence.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_state.dart';
import 'package:dailytrack/features/expense/presentation/widgets/field_error.dart';
import 'package:dailytrack/features/expense/presentation/widgets/schedule_text.dart';
import 'package:flutter/material.dart';

/// EXP-02 Repeat section (item 9, FR-021, US3 s1–s3): a switch; when on,
/// the frequency chips, an optional end date, and the schedule in words.
class RepeatSection extends StatelessWidget {
  const new({
    required this.repeat,
    required this.firstLocal,
    required this.onToggle,
    required this.onFrequency,
    required this.onEndDate,
    required this.onClearEndDate,
    super.key,
    this.error,
  });

  final RepeatState repeat;

  /// The entry's (or the rule's next) local date and time: the anchor the
  /// schedule is described from.
  final DateTime firstLocal;
  final VoidCallback onToggle;
  final ValueChanged<Frequency> onFrequency;
  final ValueChanged<DateTime> onEndDate;
  final VoidCallback onClearEndDate;

  /// Inline error under the section ("End date can't be before…").
  final String? error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final end = repeat.endDate;
    final schedule = RecurrenceSchedule(
      anchorLocal: firstLocal,
      frequency: repeat.frequency,
    ).describe();

    Future<void> pickEnd() async {
      final day = await showDatePicker(
        context: context,
        initialDate: end ?? firstLocal,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (day != null) onEndDate(day);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SwitchListTile(
          key: const Key('repeat_switch'),
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.repeat),
          title: Text(l10n.expense_repeat),
          value: repeat.enabled,
          onChanged: (_) => onToggle(),
        ),
        if (repeat.enabled) ...[
          ChipSelector<Frequency>(
            key: const Key('repeat_frequency'),
            options: Frequency.values,
            selected: {repeat.frequency},
            labelBuilder: (f) => frequencyLabel(l10n, f),
            onChanged: (s) => onFrequency(s.single),
          ),
          SizedBox(height: tokens.s8),
          Wrap(
            spacing: tokens.s8,
            runSpacing: tokens.s8,
            children: [
              if (end == null)
                ActionChip(
                  key: const Key('repeat_end'),
                  avatar: Icon(Icons.event, size: tokens.chipIconSize),
                  label: Text(l10n.expense_repeatEndDate),
                  onPressed: () => unawaited(pickEnd()),
                )
              else
                InputChip(
                  key: const Key('repeat_end'),
                  avatar: Icon(Icons.event, size: tokens.chipIconSize),
                  label: Text(
                    l10n.expense_repeatEndsOn(
                      formatFullDate(
                        end,
                        FullDateFormatScope.of(context),
                        l10n.localeName,
                      ),
                    ),
                  ),
                  onPressed: () => unawaited(pickEnd()),
                  onDeleted: onClearEndDate,
                  deleteButtonTooltipMessage: l10n.expense_repeatClearEnd,
                ),
            ],
          ),
          SizedBox(height: tokens.s8),
          Text(
            key: const Key('repeat_schedule'),
            scheduleText(l10n, schedule),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        FieldError(error),
      ],
    );
  }
}
