import 'package:dailytrack/app/background_dispatcher.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

/// runBackgroundTask (T020, research R10): the pure lookup and run logic of
/// the WorkManager entry point.
void main() {
  late List<String> ran;

  ProviderContainer container({
    List<String> enabled = const ['expense', 'habit'],
    Future<bool> Function()? body,
  }) {
    ran = [];
    final expense = FakeTrackerModule(
      id: 'expense',
      backgroundTasks: {
        'expense.recurring': (read) async {
          ran.add('expense.recurring');
          // The task reads providers through the container's reader.
          read(settingsRepositoryProvider);
          return body == null || await body();
        },
      },
    );
    final c = ProviderContainer(
      overrides: [
        moduleRegistryProvider.overrideWithValue(
          ModuleRegistry([expense, FakeTrackerModule(id: 'habit')]),
        ),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(initial: AppSettings(enabledModules: enabled)),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  test(
    'a known task of an enabled module runs and its result is returned',
    () async {
      expect(await runBackgroundTask('expense.recurring', container()), isTrue);
      expect(ran, ['expense.recurring']);
      expect(
        await runBackgroundTask(
          'expense.recurring',
          container(body: () async => false),
        ),
        isFalse,
      );
    },
  );

  test('a disabled module is done without running', () async {
    final c = container(enabled: ['habit']);
    expect(await runBackgroundTask('expense.recurring', c), isTrue);
    expect(ran, isEmpty);
  });

  test('an unknown task is done', () async {
    expect(await runBackgroundTask('nope', container()), isTrue);
    expect(ran, isEmpty);
  });

  test('a task that throws returns false so the OS retries', () async {
    final c = container(body: () async => throw StateError('db locked'));
    expect(await runBackgroundTask('expense.recurring', c), isFalse);
  });
}
