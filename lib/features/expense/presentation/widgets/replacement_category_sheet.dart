import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:flutter/material.dart';

/// EXP-04 "delete a custom category that has transactions" (T092, FR-026):
/// pick a same-type replacement. It states how many transactions move
/// before anything happens (FR-037); there is no undo afterwards.
abstract final class ReplacementCategorySheet {
  /// Returns the chosen replacement id, or null when cancelled.
  static Future<String?> show(
    BuildContext context, {
    required List<Category> options,
    required int transactionCount,
  }) {
    final l10n = AppLocalizations.of(context);
    return AppBottomSheet.show<String>(
      context,
      title: l10n.expense_moveTitle,
      child: _Picker(options: options, count: transactionCount),
    );
  }
}

class _Picker extends StatefulWidget {
  const new({required this.options, required this.count});

  final List<Category> options;
  final int count;

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(key: const Key('move_body'), l10n.expense_moveBody(widget.count)),
        SizedBox(height: tokens.s8),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final c in widget.options)
                ListTile(
                  key: ValueKey('replacement_${c.id}'),
                  leading: CategoryAvatar(
                    icon: AppIcons.byKey(c.iconKey),
                    color: colorFromHex(c.colorHex),
                    semanticLabel: l10n.categoryName(c),
                  ),
                  title: Text(l10n.categoryName(c)),
                  selected: c.id == _selected,
                  trailing: c.id == _selected ? const Icon(Icons.check) : null,
                  onTap: () => setState(() => _selected = c.id),
                ),
            ],
          ),
        ),
        SizedBox(height: tokens.s8),
        Wrap(
          alignment: WrapAlignment.end,
          spacing: tokens.s8,
          children: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              key: const Key('move_and_delete'),
              style: FilledButton.styleFrom(
                backgroundColor: scheme.error,
                foregroundColor: scheme.onError,
              ),
              onPressed: _selected == null
                  ? null
                  : () => Navigator.of(context).pop(_selected),
              child: Text(l10n.expense_moveConfirm),
            ),
          ],
        ),
      ],
    );
  }
}
