import 'dart:async';

import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/categories_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/category_sheet.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/field_error.dart';
import 'package:dailytrack/features/expense/presentation/widgets/replacement_category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// EXP-04 Categories (spec §8, FR-024, FR-026): Expense and Income tabs,
/// drag to reorder, this month's total per category, a collapsed Hidden
/// section, and Add / edit through EXP-05. No ads (banner slot empty until
/// T4.2).
class CategoriesScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() {
      if (!_tabs.indexIsChanging) {
        _controller.setTab(CategoryType.values[_tabs.index]);
      }
    });

  CategoriesController get _controller =>
      ref.read(categoriesControllerProvider.notifier);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _edit(Category c) =>
      CategorySheet.show(context, type: c.type, id: c.id);

  Future<void> _toggleHidden(Category c) async {
    final l10n = AppLocalizations.of(context);
    final undo = await _controller.toggleHidden(c.id);
    if (undo == null || !mounted) return;
    UndoSnackBar.show(
      context,
      message: c.isHidden
          ? l10n.expense_categoryShown
          : l10n.expense_categoryHidden,
      onUndo: () => unawaited(undo()),
    );
  }

  Future<void> _delete(Category c) async {
    final l10n = AppLocalizations.of(context);
    final outcome = await _controller.delete(c.id);
    if (!mounted) return;
    switch (outcome) {
      case CategoryDeleted(:final undo):
        UndoSnackBar.show(
          context,
          message: l10n.expense_categoryDeleted,
          onUndo: () => unawaited(undo()),
        );
      case CategoryNeedsReplacement(:final transactionCount, :final options):
        final replacement = await ReplacementCategorySheet.show(
          context,
          options: options,
          transactionCount: transactionCount,
        );
        if (replacement != null) {
          await _controller.deleteWithReplacement(c.id, replacement);
        }
      case CategoryDeleteFailed():
        break;
    }
  }

  Future<void> _menu(Category c) async {
    final l10n = AppLocalizations.of(context);
    final action = await AppBottomSheet.show<String>(
      context,
      title: l10n.categoryName(c),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('category_menu_rename'),
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.expense_rename),
            onTap: () => Navigator.of(context).pop('rename'),
          ),
          ListTile(
            key: const Key('category_menu_hide'),
            leading: Icon(
              c.isHidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
            title: Text(c.isHidden ? l10n.expense_unhide : l10n.expense_hide),
            onTap: () => Navigator.of(context).pop('hide'),
          ),
          // Default categories can be renamed and hidden, never deleted.
          if (!c.isDefault)
            ListTile(
              key: const Key('category_menu_delete'),
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(l10n.expense_deleteCategory),
              onTap: () => Navigator.of(context).pop('delete'),
            ),
        ],
      ),
    );
    switch (action) {
      case 'rename':
        await _edit(c);
      case 'hide':
        await _toggleHidden(c);
      case 'delete':
        await _delete(c);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(categoriesControllerProvider);

    return AppScaffold(
      title: l10n.expense_categoriesTitle,
      // Spec §11: the bottom banner (no space until an ad loads).
      bannerSlot: const AppBannerAd(),
      padBody: false,
      // §15.1: the empty state's own button is the one primary action.
      fab: state.items.value?.isEmpty ?? false
          ? null
          : FloatingActionButton(
              key: const Key('add_category'),
              tooltip: l10n.expense_addCategory,
              onPressed: () =>
                  unawaited(CategorySheet.show(context, type: state.tab)),
              child: const Icon(Icons.add),
            ),
      body: Column(
        children: [
          TabBar(
            controller: _tabs,
            tabs: [
              Tab(text: l10n.expense_typeExpense),
              Tab(text: l10n.expense_typeIncome),
            ],
          ),
          Expanded(
            child: switch (state.items) {
              AsyncValue(:final value?) when value.isEmpty => EmptyState(
                key: const Key('no_categories_here'),
                title: l10n.expense_noCategoriesHere,
                actionLabel: l10n.expense_addCategory,
                onAction: () =>
                    unawaited(CategorySheet.show(context, type: state.tab)),
              ),
              AsyncValue(hasValue: true) => _List(
                state: state,
                onTap: (c) => unawaited(_edit(c)),
                onLongPress: (c) => unawaited(_menu(c)),
                onReorder: (a, b) => unawaited(_controller.reorder(a, b)),
                onHiddenExpanded: (e) =>
                    _controller.setHiddenExpanded(expanded: e),
              ),
              AsyncError() => ErrorState(
                message: l10n.expense_loadDataError,
                onRetry: _controller.retry,
              ),
              _ => const DelayedSkeleton(child: SkeletonList()),
            },
          ),
        ],
      ),
    );
  }
}

class _List extends ConsumerWidget {
  const new({
    required this.state,
    required this.onTap,
    required this.onLongPress,
    required this.onReorder,
    required this.onHiddenExpanded,
  });

  final CategoriesState state;
  final ValueChanged<Category> onTap;
  final ValueChanged<Category> onLongPress;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<bool> onHiddenExpanded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final visible = state.visible ?? const [];
    final hidden = state.hidden ?? const [];
    final pad = tokens.sidePadding(MediaQuery.sizeOf(context).width);

    return ReorderableListView(
      key: const Key('categories_list'),
      buildDefaultDragHandles: false,
      padding: EdgeInsets.fromLTRB(pad, tokens.s8, pad, tokens.s48 * 2),
      onReorderItem: onReorder,
      header: state.reorderFailed
          ? FieldError(
              key: const Key('reorder_error'),
              l10n.expense_reorderError,
            )
          : null,
      footer: hidden.isEmpty
          ? null
          : ExpansionTile(
              key: const Key('hidden_section'),
              tilePadding: EdgeInsets.zero,
              title: Text(l10n.expense_hiddenSection),
              initiallyExpanded: state.hiddenExpanded,
              onExpansionChanged: onHiddenExpanded,
              children: [
                for (final s in hidden)
                  _Row(
                    key: ValueKey('hidden_${s.category.id}'),
                    item: s,
                    onTap: () => onTap(s.category),
                    onLongPress: () => onLongPress(s.category),
                  ),
              ],
            ),
      children: [
        for (final (i, s) in visible.indexed)
          _Row(
            key: ValueKey('category_row_${s.category.id}'),
            item: s,
            onTap: () => onTap(s.category),
            onLongPress: () => onLongPress(s.category),
            dragHandle: ReorderableDragStartListener(
              index: i,
              child: SizedBox.square(
                dimension: tokens.minTouchTarget,
                child: Icon(
                  Icons.drag_handle,
                  semanticLabel: l10n.expense_reorderHandle(
                    l10n.categoryName(s.category),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Row extends ConsumerWidget {
  const new({
    required this.item,
    required this.onTap,
    required this.onLongPress,
    super.key,
    this.dragHandle,
  });

  final CategoryWithStats item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final Widget? dragHandle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final c = item.category;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minTileHeight: tokens.s48 + tokens.s16,
      onTap: onTap,
      onLongPress: onLongPress,
      leading: CategoryAvatar(
        icon: AppIcons.byKey(c.iconKey),
        color: colorFromHex(c.colorHex),
        semanticLabel: l10n.categoryName(c),
      ),
      title: Text(
        l10n.categoryName(c),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AmountText(
            key: ValueKey('month_total_${c.id}'),
            amountMinor: item.monthTotalMinor,
            currencyCode: currencyCodeOf(ref),
            kind: c.type == CategoryType.income
                ? AmountKind.income
                : AmountKind.expense,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          ?dragHandle,
        ],
      ),
    );
  }
}
