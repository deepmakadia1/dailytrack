import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/color_picker_row.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/icon_picker_grid.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_category_name.dart';
import 'package:dailytrack/features/expense/presentation/controllers/category_form_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/field_error.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// EXP-05 Add / edit category (spec §8, FR-025): a bottom sheet with name,
/// icon, color and type (fixed when editing). No ads.
abstract final class CategorySheet {
  /// Returns the saved category, or null if dismissed.
  static Future<Category?> show(
    BuildContext context, {
    required CategoryType type,
    String? id,
  }) {
    final l10n = AppLocalizations.of(context);
    return AppBottomSheet.show<Category>(
      context,
      title: id == null
          ? l10n.expense_newCategoryTitle
          : l10n.expense_editCategoryTitle,
      child: _CategoryForm(
        args: CategoryFormArgs(type: type, id: id),
      ),
    );
  }
}

class _CategoryForm extends ConsumerStatefulWidget {
  const new({required this.args});

  final CategoryFormArgs args;

  @override
  ConsumerState<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<_CategoryForm> {
  final _name = TextEditingController();

  CategoryFormControllerProvider get _provider =>
      categoryFormControllerProvider(widget.args);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final saved = await ref.read(_provider.notifier).save();
    if (saved != null && mounted) Navigator.of(context).pop(saved);
  }

  String? _error(AppLocalizations l10n, CategoryNameError? e) => switch (e) {
    null => null,
    CategoryNameError.required => l10n.expense_errNameRequired,
    CategoryNameError.tooLong => l10n.expense_errNameTooLong,
    CategoryNameError.reserved => l10n.expense_errNameReserved,
    CategoryNameError.duplicate => l10n.expense_errNameDuplicate,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(_provider);
    final controller = ref.read(_provider.notifier);

    // Fill the name once loaded; a default shows its translated name.
    ref.listen(_provider, (previous, next) {
      if (previous?.status != CategoryFormStatus.ready &&
          next.status == CategoryFormStatus.ready) {
        final original = next.original;
        final shown = original == null ? '' : l10n.categoryName(original);
        _name.text = shown;
        if (shown != next.name) controller.setName(shown);
      }
    });

    switch (state.status) {
      case CategoryFormStatus.loading:
        return const DelayedSkeleton(child: SkeletonList());
      case CategoryFormStatus.loadError:
        return ErrorState(
          message: l10n.expense_loadDataError,
          onRetry: controller.retry,
        );
      case CategoryFormStatus.ready:
        break;
    }

    Widget label(String text) => Padding(
      padding: EdgeInsets.only(top: tokens.s16, bottom: tokens.s8),
      child: Text(text, style: theme.textTheme.titleSmall),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CategoryAvatar(
                      icon: AppIcons.byKey(state.iconKey),
                      color: colorFromHex(state.colorHex),
                      semanticLabel: state.name,
                    ),
                    SizedBox(width: tokens.s12),
                    Expanded(
                      child: TextField(
                        key: const Key('category_name'),
                        controller: _name,
                        autofocus: !state.isEdit,
                        maxLength: ValidateCategoryName.maxLength,
                        textInputAction: TextInputAction.done,
                        onChanged: controller.setName,
                        onSubmitted: (_) => unawaited(_save()),
                        decoration: InputDecoration(
                          labelText: l10n.expense_categoryName,
                          helperText: l10n.expense_nameLimit,
                        ),
                      ),
                    ),
                  ],
                ),
                FieldError(_error(l10n, state.nameError)),
                label(l10n.expense_type),
                if (state.isEdit)
                  Text(
                    key: const Key('category_type_fixed'),
                    state.type == CategoryType.expense
                        ? l10n.expense_typeExpense
                        : l10n.expense_typeIncome,
                    style: theme.textTheme.bodyLarge,
                  )
                else
                  SegmentedButton<CategoryType>(
                    key: const Key('category_type'),
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: CategoryType.expense,
                        label: Text(l10n.expense_typeExpense),
                      ),
                      ButtonSegment(
                        value: CategoryType.income,
                        label: Text(l10n.expense_typeIncome),
                      ),
                    ],
                    selected: {state.type},
                    onSelectionChanged: (s) => controller.setType(s.single),
                  ),
                label(l10n.expense_icon),
                IconPickerGrid(
                  selectedKey: state.iconKey,
                  onSelected: controller.setIcon,
                ),
                label(l10n.expense_color),
                ColorPickerRow(
                  selectedHex: state.colorHex,
                  onSelected: controller.setColor,
                ),
                if (state.saveFailed) FieldError(l10n.expense_saveError),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(top: tokens.s16),
          child: FilledButton(
            key: const Key('save_category'),
            onPressed: state.saving ? null : () => unawaited(_save()),
            child: Text(l10n.expense_saveCategory),
          ),
        ),
      ],
    );
  }
}
