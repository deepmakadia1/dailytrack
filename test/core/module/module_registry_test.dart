import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  final a = FakeTrackerModule(id: 'expense', rootPath: '/expenses');
  final b = FakeTrackerModule(id: 'habit', rootPath: '/habits');
  final registry = ModuleRegistry([a, b]);

  test('visible respects the user order and the enabled filter', () {
    expect(registry.visible(const AppSettings()), [a, b]);
    expect(
      registry.visible(const AppSettings(moduleOrder: ['habit', 'expense'])),
      [b, a],
    );
    expect(registry.visible(const AppSettings(enabledModules: ['habit'])), [b]);
  });

  test('owning matches the root path and anything below it', () {
    expect(registry.owning('/expenses'), a);
    expect(registry.owning('/expenses/x'), a);
    expect(registry.owning('/expensesX'), isNull);
    expect(registry.owning('/more'), isNull);
  });

  test('byId returns null for unknown ids', () {
    expect(registry.byId('habit'), b);
    expect(registry.byId('water'), isNull);
  });

  test('coming soon entries are Water and Period', () {
    expect(comingSoonModules.map((m) => m.id), ['water', 'period']);
  });
}
