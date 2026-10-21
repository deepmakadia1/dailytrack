import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/widgets/color_picker_row.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/icon_picker_grid.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/widgets/category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-05 Add / edit category sheet (spec §8, US4, T085).
void main() {
  /// Opens the app on EXP-04, then the sheet; returns the sheet's result,
  /// which completes when the sheet closes.
  Future<({Future<Category?> result})> openSheet(
    WidgetTester tester, {
    CategoryType type = CategoryType.expense,
    String? id,
    ExpenseFakes? fakes,
  }) async {
    await pumpExpenseApp(
      tester,
      fakes: fakes,
      location: Routes.expenseCategories,
    );
    final context = tester.element(find.byType(Scaffold).last);
    final result = CategorySheet.show(context, type: type, id: id);
    await tester.pumpAndSettle();
    return (result: result);
  }

  Future<void> tapSave(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('save_category')));
    await tester.tap(find.byKey(const Key('save_category')));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'EXP-05 "Duplicate names within the same type are rejected with an '
    'inline error."',
    (tester) async {
      final f = ExpenseFakes.withDefaults();
      await openSheet(tester, fakes: f);
      final before = f.world.categories.length;
      await tester.enterText(find.byKey(const Key('category_name')), 'Food');
      await tapSave(tester);
      expect(
        find.text('A category with this name already exists'),
        findsOneWidget,
      );
      expect(f.world.categories, hasLength(before));
      expect(
        find.byKey(const Key('save_category')),
        findsOneWidget,
        reason: 'the sheet stays open',
      );
    },
  );

  group('EXP-05 US4 scenarios', () {
    testWidgets('fields: name (max 30, hint), type, icon grid, color row', (
      tester,
    ) async {
      await openSheet(tester);
      final field = tester.widget<TextField>(
        find.byKey(const Key('category_name')),
      );
      expect(field.maxLength, 30);
      expect(find.text('Up to 30 characters'), findsOneWidget);
      expect(find.byKey(const Key('category_type')), findsOneWidget);
      expect(find.byType(IconPickerGrid), findsOneWidget);
      expect(find.byType(ColorPickerRow), findsOneWidget);
    });

    testWidgets('a Gujarati duplicate of a default is rejected (Q5)', (
      tester,
    ) async {
      await openSheet(tester);
      await tester.enterText(find.byKey(const Key('category_name')), 'ખોરાક');
      await tapSave(tester);
      expect(
        find.text('A category with this name already exists'),
        findsOneWidget,
      );
    });

    testWidgets('save creates the category with the chosen icon and color '
        'and returns it', (tester) async {
      final f = ExpenseFakes.withDefaults();
      final (:result) = await openSheet(tester, fakes: f);
      await tester.enterText(
        find.byKey(const Key('category_name')),
        'Chai & snacks',
      );
      await tester.ensureVisible(find.byKey(const ValueKey('icon_local_cafe')));
      await tester.tap(find.byKey(const ValueKey('icon_local_cafe')));
      await tester.pump();
      await tapSave(tester);
      final created = await result;
      expect(created!.name, 'Chai & snacks');
      expect(created.iconKey, 'local_cafe');
      expect(created.type, CategoryType.expense);
      expect(f.world.categories[created.id], isNotNull);
    });

    testWidgets('editing: type is read-only and an untouched default keeps '
        'its translated key', (tester) async {
      final f = ExpenseFakes.withDefaults();
      await openSheet(tester, fakes: f, id: 'food');
      expect(find.byKey(const Key('category_type')), findsNothing);
      expect(find.byKey(const Key('category_type_fixed')), findsOneWidget);
      expect(
        tester
            .widget<TextField>(find.byKey(const Key('category_name')))
            .controller!
            .text,
        'Food',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('icon_lunch_dining')),
      );
      await tester.tap(find.byKey(const ValueKey('icon_lunch_dining')));
      await tapSave(tester);
      expect(f.world.categories['food']!.name, 'expense_cat_food');
      expect(f.world.categories['food']!.iconKey, 'lunch_dining');
    });

    testWidgets('states: empty (new, name focused) and error with retry', (
      tester,
    ) async {
      await openSheet(tester);
      final field = tester.widget<TextField>(
        find.byKey(const Key('category_name')),
      );
      expect(field.autofocus, isTrue);
      expect(field.controller!.text, isEmpty);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      final f = ExpenseFakes.withDefaults();
      await openSheet(tester, fakes: f, id: 'missing');
      expect(find.byType(ErrorState), findsOneWidget);
    });

    testWidgets('a save failure keeps the sheet open', (tester) async {
      final f = ExpenseFakes.withDefaults();
      await openSheet(tester, fakes: f);
      await tester.enterText(find.byKey(const Key('category_name')), 'Pets');
      f.world.failNextWrite = true;
      await tapSave(tester);
      expect(find.byKey(const Key('save_category')), findsOneWidget);
      expect(
        find.text("Couldn't save. Your changes are still here. Try again."),
        findsOneWidget,
      );
    });
  });
}
