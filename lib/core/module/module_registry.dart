import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_registry.g.dart';

/// Display-only rows shown as "Coming soon" in SYS-02 step 3 and SET-06.
const List<ComingSoonModule> comingSoonModules = [
  ComingSoonModule(id: 'water', nameKey: 'modules_water'),
  ComingSoonModule(id: 'period', nameKey: 'modules_period'),
];

/// The registered tracker modules (contracts/tracker_module.md).
/// Features import this file, never `lib/app/module_registry.dart`, so there
/// is no app ↔ features import cycle.
class ModuleRegistry {
  new(List<TrackerModule> modules) : all = List.unmodifiable(modules);

  /// Registry order.
  final List<TrackerModule> all;

  List<String> get ids => [for (final m in all) m.id];

  TrackerModule? byId(String id) {
    for (final m in all) {
      if (m.id == id) return m;
    }
    return null;
  }

  /// Enabled modules in the user's order (moduleOrder ∩ enabledModules).
  List<TrackerModule> visible(AppSettings settings) => [
    for (final id in settings.moduleOrder)
      if (settings.enabledModules.contains(id)) ?byId(id),
  ];

  /// The module that owns [location] (prefix match on `rootPath`), if any.
  TrackerModule? owning(String location) {
    for (final m in all) {
      if (location == m.rootPath || location.startsWith('${m.rootPath}/')) {
        return m;
      }
    }
    return null;
  }
}

/// Overridden in `production_overrides.dart` with the real modules and in tests
/// with fakes.
@Riverpod(keepAlive: true)
ModuleRegistry moduleRegistry(Ref ref) =>
    throw UnimplementedError('moduleRegistryProvider must be overridden');
