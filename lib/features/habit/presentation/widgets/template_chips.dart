import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_template.dart';
import 'package:dailytrack/features/habit/domain/templates.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:flutter/material.dart';

/// The six template chips of the empty HAB-01 (US1-1, FR-022).
class TemplateChips extends StatelessWidget {
  const new({required this.onSelected, super.key});

  final ValueChanged<HabitTemplate> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return Wrap(
      spacing: tokens.s8,
      runSpacing: tokens.s8,
      alignment: WrapAlignment.center,
      children: [
        for (final t in habitTemplates)
          ActionChip(
            key: ValueKey('template_${t.id}'),
            avatar: Icon(
              AppIcons.byKey(t.iconKey),
              color: AppColors.fromHex(t.colorHex),
            ),
            label: Text(templateName(l10n, t)),
            onPressed: () => onSelected(t),
          ),
      ],
    );
  }
}
