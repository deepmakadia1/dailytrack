import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/screens/categories_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';
import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-04 Categories (spec §8, US4, T086).
void main() {
  Finder row(String id) => find.byKey(ValueKey('category_row_$id'));

  List<String> visibleOrder(WidgetTester tester) => [
    for (final e
        in find
            .byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith(
                    'category_row_',
                  ),
            )
            .evaluate())
      (e.widget.key! as ValueKey<String>).value.substring(13),
  ];

  Future<ExpenseFakes> open(
    WidgetTester tester, {
    ExpenseFakes? fakes,
    String locale = 'en',
    FakeSettingsRepository? settings,
  }) => pumpExpenseApp(
    tester,
    fakes: fakes,
    locale: locale,
    settings: settings,
    location: Routes.expenseCategories,
  );

  /// Scrolls the lazy list until [finder] is built and on screen.
  Future<void> reveal(WidgetTester tester, Finder finder) =>
      tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find
            .descendant(
              of: find.byKey(const Key('categories_list')),
              matching: find.byType(Scrollable),
            )
            .first,
      );

  /// Drags [id]'s handle by [dy] in small steps, like a finger.
  Future<void> dragHandle(WidgetTester tester, String id, double dy) async {
    final handle = find.descendant(
      of: row(id),
      matching: find.byIcon(Icons.drag_handle),
    );
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(Offset(0, dy / 10));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();
  }

  Future<void> longPressMenu(WidgetTester tester, String id) async {
    await reveal(tester, row(id));
    await tester.longPress(row(id));
    await tester.pumpAndSettle();
  }

  testWidgets("US4-1 tabs, rows with this month's total, collapsed Hidden "
      'section; the FAB adds to the current tab', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addTransaction(amount: 15550, category: 'food')
      ..addTransaction(amount: 999, category: 'food', at: DateTime(2026, 9, 3));
    f.world.categories['fuel'] = f.world.categories['fuel']!.copyWith(
      isHidden: true,
    );
    await open(tester, fakes: f);

    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(
      find.descendant(of: row('food'), matching: find.text('₹155.50')),
      findsOneWidget,
      reason: 'only October counts',
    );
    expect(row('fuel'), findsNothing);
    expect(find.text('Hidden'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('hidden_fuel')),
      findsNothing,
      reason: 'collapsed',
    );

    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(row('income_salary'), findsOneWidget);
    expect(row('food'), findsNothing);

    await tester.tap(find.byKey(const Key('add_category')));
    await tester.pumpAndSettle();
    expect(find.text('New category'), findsOneWidget);
    final segmented = tester.widget<SegmentedButton<CategoryType>>(
      find.byKey(const Key('category_type')),
    );
    expect(segmented.selected, {CategoryType.income});
  });

  testWidgets('US4-2 tap opens EXP-05 in edit mode', (tester) async {
    await open(tester);
    await tester.tap(row('food'));
    await tester.pumpAndSettle();
    expect(find.text('Edit category'), findsOneWidget);
    expect(find.byKey(const Key('category_type_fixed')), findsOneWidget);
  });

  testWidgets('US4-5 a default offers Rename and Hide but not Delete', (
    tester,
  ) async {
    await open(tester);
    await longPressMenu(tester, 'food');
    expect(find.byKey(const Key('category_menu_rename')), findsOneWidget);
    expect(find.byKey(const Key('category_menu_hide')), findsOneWidget);
    expect(find.byKey(const Key('category_menu_delete')), findsNothing);
  });

  testWidgets('US4-6 an unused custom category deletes at once with Undo', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults()..addCategory('Chai', id: 'chai');
    await open(tester, fakes: f);
    await longPressMenu(tester, 'chai');
    await tester.tap(find.byKey(const Key('category_menu_delete')));
    await tester.pumpAndSettle();
    expect(row('chai'), findsNothing);
    expect(find.text('Category deleted'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(row('chai'), findsOneWidget);
    await flushTimers(tester);
  });

  testWidgets('US4-7 a used custom category needs a same-type replacement; '
      'its transactions move', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addCategory('Chai', id: 'chai')
      ..addTransaction(amount: 100, category: 'chai')
      ..addTransaction(amount: 200, category: 'chai');
    await open(tester, fakes: f);
    await longPressMenu(tester, 'chai');
    await tester.tap(find.byKey(const Key('category_menu_delete')));
    await tester.pumpAndSettle();

    expect(find.text('Choose a new category'), findsOneWidget);
    expect(
      find.text('Move 2 transactions to the category you choose.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('replacement_chai')), findsNothing);
    expect(
      find.byKey(const ValueKey('replacement_income_salary')),
      findsNothing,
      reason: 'same type only',
    );

    await tester.tap(find.byKey(const ValueKey('replacement_food')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('move_and_delete')));
    await tester.pumpAndSettle();
    expect(row('chai'), findsNothing);
    expect(f.active.every((t) => t.categoryId == 'food'), isTrue);
    expect(find.text('Undo'), findsNothing, reason: 'no undo (FR-037)');
  });

  testWidgets('US4-8 a hidden category leaves the EXP-02 grid; existing '
      'rows still show it', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addTransaction(id: 'old', amount: 300, category: 'fuel');
    await open(tester, fakes: f);
    await longPressMenu(tester, 'fuel');
    await tester.tap(find.byKey(const Key('category_menu_hide')));
    await tester.pumpAndSettle();
    expect(f.world.categories['fuel']!.isHidden, isTrue);

    routerOf(tester).go(Routes.expenseAdd);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('category_fuel')), findsNothing);

    routerOf(tester).go(Routes.expenses);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('txn_old')),
        matching: find.text('Fuel'),
      ),
      findsOneWidget,
    );
    await flushTimers(tester);
  });

  testWidgets('US4-9 drag reorder persists after a restart', (tester) async {
    final f = ExpenseFakes.withDefaults();
    final settings = FakeSettingsRepository(
      initial: const AppSettings(onboardingDone: true),
    );
    await open(tester, fakes: f, settings: settings);
    expect(visibleOrder(tester).take(3), ['food', 'groceries', 'transport']);

    await dragHandle(tester, 'transport', -200);
    expect(visibleOrder(tester).first, 'transport');

    await restartTestApp(tester, settings: settings, expense: f);
    routerOf(tester).go(Routes.expenseCategories);
    await tester.pumpAndSettle();
    expect(visibleOrder(tester).first, 'transport');
  });

  testWidgets('US4-9 a failed reorder reverts and says so', (tester) async {
    final f = await open(tester);
    f.world.failNextWrite = true;
    await dragHandle(tester, 'groceries', -150);
    expect(visibleOrder(tester).take(2), ['food', 'groceries']);
    expect(find.byKey(const Key('reorder_error')), findsOneWidget);
  });

  testWidgets('edge case "Renamed default category": the new name shows in '
      'every language', (tester) async {
    for (final lang in ['en', 'hi', 'gu']) {
      final f = ExpenseFakes.withDefaults()
        ..addTransaction(id: 'meal', amount: 100, category: 'food');
      f.world.categories['food'] = f.world.categories['food']!.copyWith(
        name: 'Meals',
      );
      f.world.categories['rent'] = f.world.categories['rent']!.copyWith(
        isHidden: true,
      );
      await open(tester, fakes: f, locale: lang);
      expect(
        find.descendant(of: row('food'), matching: find.text('Meals')),
        findsOneWidget,
        reason: lang,
      );
      routerOf(tester).go(Routes.expenses);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('txn_meal')),
          matching: find.text('Meals'),
        ),
        findsOneWidget,
        reason: lang,
      );
    }
    // A hidden but not renamed default keeps its translated name.
    routerOf(tester).go(Routes.expenseCategories);
    await tester.pumpAndSettle();
    await reveal(tester, find.text('છુપાવેલી'));
    // Bring it fully above the navigation bar before tapping.
    await tester.drag(
      find.byKey(const Key('categories_list')),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('છુપાવેલી'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('hidden_rent')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('hidden_rent')),
        matching: find.text('ભાડું'),
      ),
      findsOneWidget,
    );
  });

  group('EXP-04 four states', () {
    testWidgets('empty tab shows a helper and "Add category"', (tester) async {
      await open(tester, fakes: ExpenseFakes.empty());
      expect(find.text('No categories here yet'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Add category'));
      await tester.pumpAndSettle();
      expect(find.text('New category'), findsOneWidget);
    });

    testWidgets('loading shows a skeleton only after 300 ms', (tester) async {
      final f = ExpenseFakes.withDefaults()
        ..world.watchDelay = const Duration(seconds: 1);
      await pumpExpenseApp(tester, fakes: f, location: Routes.home);
      routerOf(tester).go(Routes.expenseCategories);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.byType(SkeletonList), findsNothing);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SkeletonList), findsOneWidget);
      await tester.pumpAndSettle();
      expect(row('food'), findsOneWidget);
    });

    testWidgets('a load failure shows the error state; Try again recovers', (
      tester,
    ) async {
      final f = ExpenseFakes.withDefaults();
      await pumpExpenseApp(tester, fakes: f, location: Routes.home);
      f.world.failWatch = const ExpenseStorageFailure('boom');
      routerOf(tester).go(Routes.expenseCategories);
      await tester.pumpAndSettle();
      expect(find.byType(ErrorState), findsOneWidget);
      f.world.failWatch = null;
      await tester.tap(find.text('Try again'));
      await tester.pumpAndSettle();
      expect(find.byType(CategoriesScreen), findsOneWidget);
      expect(row('food'), findsOneWidget);
    });
  });

  testWidgets('EXP-02 US1-3 "+ New" opens EXP-05 and selects the new '
      'category', (tester) async {
    final f = await pumpExpenseApp(tester, location: Routes.expenseAdd);
    await tester.ensureVisible(find.byKey(const ValueKey('category_new')));
    await tester.tap(find.byKey(const ValueKey('category_new')));
    await tester.pumpAndSettle();
    expect(find.byType(CategorySheet), findsNothing);
    expect(find.text('New category'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('category_name')), 'Chai');
    await tester.ensureVisible(find.byKey(const Key('save_category')));
    await tester.tap(find.byKey(const Key('save_category')));
    await tester.pumpAndSettle();

    final chai = f.world.categories.values.singleWhere((c) => c.name == 'Chai');
    final tile = find.byKey(ValueKey('category_${chai.id}'));
    expect(tile, findsOneWidget);
    expect(tester.getSemantics(tile), isSemantics(isSelected: true));
  });
}
