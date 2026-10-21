import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/settings/presentation/controllers/modules_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/settings/presentation/controllers/modules_state.dart';

part 'modules_controller.g.dart';

const String atLeastOneModuleKey = 'modules_atLeastOne';

/// SET-06 Modules controller (T088, data-model.md §6 "Module"). Follows the
/// settings stream, so the screen, nav bar and Home stay in step.
@riverpod
class ModulesController extends _$ModulesController {
  @override
  Future<ModulesState> build() async {
    final settings = await ref.watch(appSettingsProvider.future);
    return ModulesState(rows: _rowsFor(settings));
  }

  /// Registered modules in `moduleOrder`; any registered module missing
  /// from the stored order is appended in registry order.
  List<ModuleRow> _rowsFor(AppSettings settings) {
    final ids = ref.read(moduleRegistryProvider).ids;
    final order = [
      for (final id in settings.moduleOrder)
        if (ids.contains(id)) id,
      for (final id in ids)
        if (!settings.moduleOrder.contains(id)) id,
    ];
    return [
      for (final id in order)
        ModuleRow(id: id, enabled: settings.enabledModules.contains(id)),
    ];
  }

  /// Turns a module on or off, then runs its enable/disable hook. Refuses
  /// to turn off the last enabled module. Never deletes data.
  Future<void> toggle(String id) async {
    final current = state.value;
    if (current == null) return;
    final rows = [
      for (final r in current.rows)
        if (r.id == id) r.copyWith(enabled: !r.enabled) else r,
    ];
    final enabling = rows.any((r) => r.id == id && r.enabled);
    if (!rows.any((r) => r.enabled)) {
      state = AsyncData(current.copyWith(messageKey: atLeastOneModuleKey));
      return;
    }
    try {
      await _write(rows);
    } on LastModuleError {
      state = AsyncData(current.copyWith(messageKey: atLeastOneModuleKey));
      return;
    } on Object catch (e, st) {
      state = AsyncError(e, st);
      return;
    }
    final module = ref.read(moduleRegistryProvider).byId(id);
    if (enabling) {
      await module?.onEnable(ref.read);
    } else {
      await module?.onDisable(ref.read);
    }
  }

  /// Moves the row at [oldIndex] so it ends at [newIndex] (the index after
  /// removal, as `ReorderableListView.onReorderItem` reports it).
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.value;
    if (current == null || oldIndex == newIndex) return;
    final rows = [...current.rows];
    rows.insert(newIndex, rows.removeAt(oldIndex));
    // Show the new order immediately; the settings stream confirms it.
    state = AsyncData(current.copyWith(rows: rows));
    try {
      await _write(rows);
    } on Object catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Error state "Retry": re-reads settings from storage.
  void retry() => ref.invalidate(appSettingsProvider);

  Future<void> _write(List<ModuleRow> rows) async {
    await ref
        .read(settingsRepositoryProvider)
        .setModules(
          order: [for (final r in rows) r.id],
          enabled: [
            for (final r in rows)
              if (r.enabled) r.id,
          ],
        );
    // Keep the rows current until the settings stream rebuilds them, so a
    // quick second tap works from the new state.
    if (ref.mounted) state = AsyncData(ModulesState(rows: rows));
  }
}
