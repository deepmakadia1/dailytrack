import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// TrackerModule optional members (T003, contracts/tracker_module.md of
/// feature 006): a module that implements only the required members gets
/// empty defaults.
void main() {
  const module = _MinimalModule('minimal');

  test('optional members default to empty or null', () {
    expect(module.quickAddActions(), isEmpty);
    expect(module.dashboardSections(), isEmpty);
    expect(module.insights(), isNull);
  });

  testWidgets('appBarBadge defaults to null', (tester) async {
    late Widget? badge;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          badge = module.appBarBadge(context);
          return const SizedBox.shrink();
        },
      ),
    );
    expect(badge, isNull);
  });

  test('ModuleRegistry.visible still orders by moduleOrder', () {
    const a = _MinimalModule('expense');
    const b = _MinimalModule('habit');
    final registry = ModuleRegistry([a, b]);
    expect(
      registry.visible(const AppSettings(moduleOrder: ['habit', 'expense'])),
      [b, a],
    );
  });

  test('Insight equality is by value', () {
    const x = Insight(ruleId: 'm.r', text: 't', location: '/m');
    expect(x, const Insight(ruleId: 'm.r', text: 't', location: '/m'));
    expect(
      x.hashCode,
      const Insight(ruleId: 'm.r', text: 't', location: '/m').hashCode,
    );
    expect(x, isNot(const Insight(ruleId: 'm.r', text: 't')));
    expect(x, isNot(const Insight(ruleId: 'm.r', text: 'u', location: '/m')));
  });
}

/// Only the required members.
final class _MinimalModule extends TrackerModule {
  const new(this.id);

  @override
  final String id;

  @override
  String displayName(BuildContext context) => id;

  @override
  String tabLabel(BuildContext context) => id;

  @override
  IconData get icon => Icons.extension_outlined;

  @override
  IconData get selectedIcon => Icons.extension;

  @override
  String get rootPath => '/$id';

  @override
  List<RouteBase> get routes => const [];

  @override
  Widget dashboardCard(BuildContext context) => const SizedBox.shrink();

  @override
  BackupSection? backupSection() => null;

  @override
  List<Seeder> get seeders => const [];

  @override
  Future<void> onEnable(ProviderReader read) async {}

  @override
  Future<void> onDisable(ProviderReader read) async {}

  @override
  Future<void> onAppOpen(ProviderReader read) async {}

  @override
  Map<String, BackgroundTask> get backgroundTasks => const {};
}
