import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/expense/data/seed/expense_defaults_seeder.dart';
import 'package:dailytrack/features/settings/presentation/controllers/modules_controller.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/real_container.dart';

/// SET-06 Modules controller (T087, data-model.md §6 "Module").
void main() {
  late FakeTrackerModule expense;
  late FakeTrackerModule habit;

  setUp(() {
    expense = FakeTrackerModule(id: 'expense', rootPath: '/expenses');
    habit = FakeTrackerModule(id: 'habit', rootPath: '/habits');
  });

  Future<(ProviderContainer, FakeSettingsRepository)> make({
    AppSettings settings = const AppSettings(onboardingDone: true),
  }) async {
    final repo = FakeSettingsRepository(initial: settings);
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        moduleRegistryProvider.overrideWithValue(
          ModuleRegistry([expense, habit]),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.listen(modulesControllerProvider, (_, _) {});
    await container.read(modulesControllerProvider.future);
    return (container, repo);
  }

  ModulesState stateOf(ProviderContainer c) =>
      c.read(modulesControllerProvider).requireValue;

  ModulesController ctrl(ProviderContainer c) =>
      c.read(modulesControllerProvider.notifier);

  test('SET-06 rows follow moduleOrder with their enabled flag', () async {
    final (c, _) = await make(
      settings: const AppSettings(
        onboardingDone: true,
        moduleOrder: ['habit', 'expense'],
        enabledModules: ['habit'],
      ),
    );
    expect(stateOf(c).rows, const [
      ModuleRow(id: 'habit', enabled: true),
      ModuleRow(id: 'expense', enabled: false),
    ]);
    expect(stateOf(c).messageKey, isNull);
  });

  test('SET-06 toggle off writes settings then calls onDisable once', () async {
    final (c, repo) = await make();
    await ctrl(c).toggle('expense');

    expect(repo.calls['setModules'], 1);
    expect(repo.current.enabledModules, ['habit']);
    expect(repo.current.moduleOrder, ['expense', 'habit']);
    expect(expense.disableCalls, 1);
    expect(expense.enableCalls, 0);
    expect(habit.disableCalls, 0);
  });

  test(
    'SET-06 toggle on restores the module in order and calls onEnable',
    () async {
      final (c, repo) = await make(
        settings: const AppSettings(
          onboardingDone: true,
          enabledModules: ['habit'],
        ),
      );
      await ctrl(c).toggle('expense');

      expect(repo.current.enabledModules, ['expense', 'habit']);
      expect(expense.enableCalls, 1);
      expect(expense.disableCalls, 0);
    },
  );

  test('SET-06 at least one module stays enabled', () async {
    final (c, repo) = await make(
      settings: const AppSettings(
        onboardingDone: true,
        enabledModules: ['habit'],
      ),
    );
    await ctrl(c).toggle('habit');

    expect(stateOf(c).messageKey, 'modules_atLeastOne');
    expect(repo.current.enabledModules, ['habit']);
    expect(habit.disableCalls, 0);
    expect(repo.calls['setModules'], isNull);
  });

  test('SET-06 a LastModuleError from the repository sets the message and '
      'calls no hook', () async {
    // The repository only knows 'habit', so disabling it alone is rejected
    // there even though the controller sees two modules enabled.
    final repo = FakeSettingsRepository(
      initial: const AppSettings(onboardingDone: true),
      knownModuleIds: const ['habit'],
    );
    final c = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        moduleRegistryProvider.overrideWithValue(
          ModuleRegistry([expense, habit]),
        ),
      ],
    );
    addTearDown(c.dispose);
    c.listen(modulesControllerProvider, (_, _) {});
    await c.read(modulesControllerProvider.future);

    await ctrl(c).toggle('habit');

    expect(stateOf(c).messageKey, 'modules_atLeastOne');
    expect(habit.disableCalls, 0);
    expect(expense.disableCalls, 0);
  });

  test('SET-06 a successful toggle clears the message', () async {
    final (c, _) = await make(
      settings: const AppSettings(
        onboardingDone: true,
        enabledModules: ['habit'],
      ),
    );
    await ctrl(c).toggle('habit');
    expect(stateOf(c).messageKey, 'modules_atLeastOne');

    await ctrl(c).toggle('expense');
    await pumpEventQueue();
    expect(stateOf(c).messageKey, isNull);
  });

  test(
    'SET-06 reorder persists the new order and keeps the enabled set',
    () async {
      final (c, repo) = await make(
        settings: const AppSettings(
          onboardingDone: true,
          enabledModules: ['habit'],
        ),
      );
      // Habit (index 1) ends at index 0.
      await ctrl(c).reorder(1, 0);

      expect(repo.current.moduleOrder, ['habit', 'expense']);
      expect(repo.current.enabledModules, ['habit']);
      expect(stateOf(c).rows.map((r) => r.id), ['habit', 'expense']);
      expect(expense.enableCalls + expense.disableCalls, 0);
      expect(habit.enableCalls + habit.disableCalls, 0);
    },
  );

  test('SET-06 reorder to the same index writes nothing', () async {
    final (c, repo) = await make();
    await ctrl(c).reorder(0, 0);
    expect(repo.calls['setModules'], isNull);
  });

  test('SET-06 disabling a module keeps its data', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await SeedRunner(db).runAll([const ExpenseDefaultsSeeder()]);
    final c = makeRealContainer(db);
    // Onboarding is done in a real install before SET-06 is reachable.
    await c
        .read(settingsRepositoryProvider)
        .completeOnboarding(
          const OnboardingChoices(
            locale: null,
            currencyCode: 'INR',
            moduleOrder: ['expense', 'habit'],
            enabledModules: ['expense', 'habit'],
          ),
        );
    c.listen(modulesControllerProvider, (_, _) {});
    await c.read(modulesControllerProvider.future);

    Future<void> expectDataKept() async {
      final categories = await db.select(db.categories).get();
      final accounts = await db.select(db.accounts).get();
      expect(categories, hasLength(17));
      expect(accounts, hasLength(1));
      expect(categories.every((r) => r.deletedAt == null), isTrue);
      expect(accounts.every((r) => r.deletedAt == null), isTrue);
    }

    await expectDataKept();

    await c.read(modulesControllerProvider.notifier).toggle('expense');
    expect((await c.read(settingsRepositoryProvider).load()).enabledModules, [
      'habit',
    ]);
    await expectDataKept();

    await c.read(modulesControllerProvider.notifier).toggle('expense');
    expect((await c.read(settingsRepositoryProvider).load()).enabledModules, [
      'expense',
      'habit',
    ]);
    await expectDataKept();
  });
}
