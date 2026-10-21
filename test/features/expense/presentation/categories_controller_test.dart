import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/categories_controller.dart';
import 'package:dailytrack/features/expense/presentation/controllers/category_form_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

/// EXP-04 and EXP-05 controller intents (T087).
void main() {
  late ExpenseFakes f;
  late ProviderContainer c;

  Future<void> settle() async {
    for (var i = 0; i < 5; i++) {
      await pumpEventQueue();
    }
  }

  setUp(() async {
    f = ExpenseFakes.withDefaults();
    c = ProviderContainer(overrides: f.overrides);
    addTearDown(c.dispose);
  });

  group('CategoriesController', () {
    CategoriesState state() => c.read(categoriesControllerProvider);
    CategoriesController ctrl() =>
        c.read(categoriesControllerProvider.notifier);

    setUp(() async {
      c.listen(categoriesControllerProvider, (_, _) {});
      await settle();
    });

    test('starts on Expense; setTab switches the list', () async {
      expect(state().tab, CategoryType.expense);
      expect(state().visible, hasLength(12));
      ctrl().setTab(CategoryType.income);
      await settle();
      expect(state().visible, hasLength(5));
    });

    test('reorder shows at once and persists; a failure reverts', () async {
      await ctrl().reorder(2, 0);
      expect(state().visible!.first.category.id, 'transport');
      await settle();
      expect(f.world.categories['transport']!.sortOrder, 0);

      f.world.failNextWrite = true;
      await ctrl().reorder(1, 0);
      expect(state().reorderFailed, isTrue);
      expect(state().visible!.first.category.id, 'transport');
    });

    test('toggleHidden hides and its undo shows again', () async {
      final undo = await ctrl().toggleHidden('fuel');
      await settle();
      expect(state().hidden!.single.category.id, 'fuel');
      await undo!();
      await settle();
      expect(state().hidden, isEmpty);
    });

    test('delete branches on the transaction count', () async {
      f
        ..addCategory('Chai', id: 'chai')
        ..addCategory('Snacks', id: 'snacks')
        ..addTransaction(amount: 1, category: 'snacks');
      await settle();

      expect(await ctrl().delete('food'), isA<CategoryDeleteFailed>());
      final unused = await ctrl().delete('chai');
      expect(unused, isA<CategoryDeleted>());
      await (unused as CategoryDeleted).undo();

      final used = await ctrl().delete('snacks');
      expect(used, isA<CategoryNeedsReplacement>());
      final needs = used as CategoryNeedsReplacement;
      expect(needs.transactionCount, 1);
      expect(needs.options.map((x) => x.id), isNot(contains('snacks')));
      expect(await ctrl().deleteWithReplacement('snacks', 'food'), isTrue);
      expect(f.active.single.categoryId, 'food');
    });
  });

  group('CategoryFormController', () {
    Future<CategoryFormControllerProvider> ready(CategoryFormArgs args) async {
      final p = categoryFormControllerProvider(args);
      c.listen(p, (_, _) {});
      await settle();
      return p;
    }

    test(
      'new: defaults to the first icon and color, type from the caller',
      () async {
        final p = await ready(
          const CategoryFormArgs(type: CategoryType.income),
        );
        final s = c.read(p);
        expect(s.status, CategoryFormStatus.ready);
        expect(s.isEdit, isFalse);
        expect(s.type, CategoryType.income);
        expect(s.iconKey, 'restaurant');
        expect(s.colorHex, startsWith('#'));
      },
    );

    test(
      'save rejects a duplicate and keeps the name error until edited',
      () async {
        final p = await ready(
          const CategoryFormArgs(type: CategoryType.expense),
        );
        final ctrl = c.read(p.notifier)..setName('FOOD');
        expect(await ctrl.save(), isNull);
        expect(c.read(p).nameError, isNotNull);
        ctrl.setName('Chai');
        expect(c.read(p).nameError, isNull);
        expect((await ctrl.save())!.name, 'Chai');
      },
    );

    test(
      'edit: the type is fixed; a renamed default stores the new text',
      () async {
        final p = await ready(
          const CategoryFormArgs(type: CategoryType.expense, id: 'food'),
        );
        final ctrl = c.read(p.notifier)
          ..setType(CategoryType.income)
          ..setName('Meals');
        expect(c.read(p).type, CategoryType.expense);
        await ctrl.save();
        expect(f.world.categories['food']!.name, 'Meals');
      },
    );

    test('a missing category is a load error', () async {
      final p = await ready(
        const CategoryFormArgs(type: CategoryType.expense, id: 'missing'),
      );
      expect(c.read(p).status, CategoryFormStatus.loadError);
    });
  });
}
