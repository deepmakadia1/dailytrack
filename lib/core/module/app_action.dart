import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_action.g.dart';

/// Where an [AppAction] came from (feature 008 data-model §7).
enum AppActionSource { notification, widget, system }

/// Something the user did outside the app's screens, such as a
/// notification button or a home screen widget check (research R17, R20).
/// Core cannot import a module, so modules claim actions by [name] through
/// `TrackerModule.handleAction`.
final class AppAction {
  const new({required this.source, required this.name, this.params = const {}});

  final AppActionSource source;

  /// E.g. `habit.markDone`, `habit.snooze`, `habit.widgetCheck`.
  final String name;

  /// Query parameters of the notification payload or widget URI.
  final Map<String, String> params;

  @override
  String toString() => 'AppAction($source, $name, $params)';
}

/// Offers an [AppAction] to each visible module in the user's order until
/// one handles it (research R17). Disabled modules are skipped, and a
/// throwing module counts as not handled, so the next one still gets it.
final class AppActionDispatcher {
  const new();

  Future<bool> dispatch(AppAction action, ProviderReader read) async {
    final settings = await read(settingsRepositoryProvider).load();
    for (final module in read(moduleRegistryProvider).visible(settings)) {
      try {
        if (await module.handleAction(action, read)) return true;
      } on Object {
        // Counts as not handled.
      }
    }
    return false;
  }
}

@Riverpod(keepAlive: true)
AppActionDispatcher appActionDispatcher(Ref ref) => const AppActionDispatcher();
