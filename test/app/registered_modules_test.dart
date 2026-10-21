import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('module ids are unique', () {
    final ids = registeredModules.map((m) => m.id).toList();
    expect(ids.toSet(), hasLength(ids.length));
  });

  test('no two modules share a root path', () {
    final roots = registeredModules.map((m) => m.rootPath).toList();
    expect(roots.toSet(), hasLength(roots.length));
  });

  test('every module route lives under its root path', () {
    for (final m in registeredModules) {
      for (final route in m.routes.whereType<GoRoute>()) {
        expect(
          route.path == m.rootPath || route.path.startsWith('${m.rootPath}/'),
          isTrue,
          reason: '${m.id}: ${route.path}',
        );
      }
    }
  });

  test('registered ids do not collide with coming-soon entries', () {
    final ids = registeredModules.map((m) => m.id).toSet();
    expect(comingSoonModules.where((c) => ids.contains(c.id)), isEmpty);
  });
}
