@Tags(['golden'])
library;

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/color_picker_row.dart';
import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/icon_picker_grid.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/core/widgets/period_selector.dart';
import 'package:dailytrack/core/widgets/progress_status.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/summary_card.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/widget_wrapper.dart';

/// Golden tests for every §15.4 shared component (T093), in light and dark,
/// plus Gujarati for widgets that show localized text. Baselines are made
/// and compared on Linux only (research R11):
/// `flutter test --tags golden --update-goldens`.
void main() {
  final cases = <_Case>[
    _Case(
      'app_scaffold',
      fullScreen: true,
      build: (context, l10n) => AppScaffold(
        title: l10n.nav_home,
        largeTitle: true,
        showBack: false,
        body: EmptyState(title: l10n.common_placeholderMessage),
      ),
    ),
    _Case(
      'amount_text',
      localized: false,
      build: (context, l10n) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AmountText(
            amountMinor: 123456700,
            currencyCode: 'INR',
            kind: AmountKind.expense,
            showSign: true,
          ),
          AmountText(
            amountMinor: 1050,
            currencyCode: 'INR',
            kind: AmountKind.income,
            showSign: true,
          ),
          AmountText(amountMinor: 123456789, currencyCode: 'USD'),
        ],
      ),
    ),
    _Case(
      'category_avatar',
      localized: false,
      build: (context, l10n) => CategoryAvatar(
        icon: Icons.restaurant,
        color: Theme.of(context).colorScheme.primary,
        semanticLabel: 'food',
      ),
    ),
    _Case(
      'summary_card',
      build: (context, l10n) => SummaryCard(
        title: l10n.nav_expenses,
        value: const AmountText(amountMinor: 1250000, currencyCode: 'INR'),
        progress: ProgressBarStatus(ratio: 0.6, label: l10n.nav_expenses),
      ),
    ),
    _Case(
      'progress_bar_status',
      build: (context, l10n) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final ratio in const [0.5, 0.85, 1.2])
            Padding(
              padding: EdgeInsets.only(bottom: AppTokens.of(context).s16),
              child: ProgressBarStatus(ratio: ratio, label: l10n.nav_expenses),
            ),
        ],
      ),
    ),
    _Case(
      'progress_ring',
      build: (context, l10n) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final ratio in const [0.5, 0.85, 1.2])
            ProgressRing(ratio: ratio, label: l10n.nav_habits),
        ],
      ),
    ),
    _Case(
      'period_selector',
      build: (context, l10n) => PeriodSelector(
        period: MonthPeriod(DateTime(2026, 10)),
        now: DateTime(2026, 10, 14),
        onChanged: (_) {},
      ),
    ),
    _Case(
      'icon_picker_grid',
      build: (context, l10n) => SingleChildScrollView(
        child: IconPickerGrid(selectedKey: 'local_cafe', onSelected: (_) {}),
      ),
    ),
    _Case(
      'color_picker_row',
      build: (context, l10n) =>
          ColorPickerRow(selectedHex: '#2B7ACA', onSelected: (_) {}),
    ),
    _Case(
      'chip_selector',
      build: (context, l10n) => ChipSelector<String>(
        options: const ['home', 'expenses', 'habits'],
        selected: const {'expenses'},
        labelBuilder: (id) => switch (id) {
          'home' => l10n.nav_home,
          'expenses' => l10n.nav_expenses,
          _ => l10n.nav_habits,
        },
        onChanged: (_) {},
      ),
    ),
    _Case(
      'numeric_keypad',
      build: (context, l10n) => NumericKeypad(
        onKey: (_) {},
        onBackspace: () {},
        onOperator: (_) {},
        onDone: () {},
      ),
    ),
    _Case(
      'app_bottom_sheet',
      open: (context, l10n) => AppBottomSheet.show<void>(
        context,
        title: l10n.onboarding_currencyTitle,
        child: TextField(
          decoration: InputDecoration(
            hintText: l10n.onboarding_currencySearchHint,
          ),
        ),
      ),
    ),
    _Case(
      'empty_state',
      build: (context, l10n) => EmptyState(
        title: l10n.common_placeholderMessage,
        message: l10n.onboarding_privacyBody,
        actionLabel: l10n.common_next,
        onAction: () {},
      ),
    ),
    _Case(
      'error_state',
      build: (context, l10n) =>
          ErrorState(message: l10n.splash_errorMessage, onRetry: () {}),
    ),
    _Case(
      'skeleton',
      localized: false,
      build: (context, l10n) => const Column(
        mainAxisSize: MainAxisSize.min,
        children: [SkeletonCard(), SkeletonList(itemCount: 2)],
      ),
    ),
    _Case(
      'undo_snack_bar',
      open: (context, l10n) async => UndoSnackBar.show(
        context,
        message: l10n.modules_atLeastOne,
        onUndo: () {},
      ),
    ),
    _Case(
      'confirm_dialog',
      open: (context, l10n) => ConfirmDialog.show(
        context,
        title: l10n.modules_title,
        consequence: l10n.modules_atLeastOne,
        confirmLabel: l10n.common_next,
        destructive: true,
      ),
    ),
    _Case(
      'locked_feature_overlay',
      build: (context, l10n) => LockedFeatureOverlay(
        onWatchAd: () {},
        onGetPro: () {},
        child: SummaryCard(
          title: l10n.nav_expenses,
          value: const AmountText(amountMinor: 1250000, currencyCode: 'INR'),
          progress: ProgressBarStatus(ratio: 0.9, label: l10n.nav_expenses),
        ),
      ),
    ),
  ];

  for (final c in cases) {
    for (final brightness in Brightness.values) {
      for (final lang in c.localized ? const ['en', 'gu'] : const ['en']) {
        final name = '${c.name}_${brightness.name}_$lang';
        testWidgets('§15.4 $name golden', (tester) async {
          tester.view
            ..physicalSize = const Size(360, 640)
            ..devicePixelRatio = 1;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            themed(
              MediaQuery.withNoTextScaling(
                child: Builder(
                  builder: (context) {
                    // Skeletons hold still, so the image is deterministic.
                    final data = MediaQuery.of(context)
                        .copyWith(disableAnimations: true);
                    return MediaQuery(
                      data: data,
                      child: Builder(builder: c.screen),
                    );
                  },
                ),
              ),
              locale: Locale(lang),
              brightness: brightness,
              wrapInScaffold: false,
            ),
          );
          await tester.pumpAndSettle();

          if (c.open case final open?) {
            final context = tester.element(find.byKey(_Case.anchor));
            // Not awaited: dialogs and sheets complete only when closed.
            open(context, AppLocalizations.of(context)).ignore();
            await tester.pumpAndSettle();
          }

          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile('$name.png'),
          );
        });
      }
    }
  }
}

typedef _Build = Widget Function(BuildContext context, AppLocalizations l10n);
typedef _Open = Future<void> Function(
  BuildContext context,
  AppLocalizations l10n,
);

class _Case {
  new(
    this.name, {
    this.build,
    this.open,
    this.localized = true,
    this.fullScreen = false,
  });

  static const Key anchor = ValueKey('golden_anchor');

  final String name;
  final _Build? build;

  /// Opens an overlay (sheet, dialog, snackbar) over an empty screen.
  final _Open? open;

  /// Also render in Gujarati.
  final bool localized;

  /// [build] returns a whole screen rather than a component.
  final bool fullScreen;

  Widget screen(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    if (fullScreen) return build!(context, l10n);
    return Scaffold(
      key: anchor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(tokens.screenPadding),
          child: Center(child: build?.call(context, l10n)),
        ),
      ),
    );
  }
}
