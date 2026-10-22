import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';

/// Builds the [HomeGlance] of [nowLocal]'s day from the enabled modules
/// (feature 008 research R19). A module that throws leaves its part empty,
/// so one failure never blanks the whole widget.
Future<HomeGlance> buildHomeGlance(
  ProviderReader read,
  DateTime nowLocal,
) async {
  final settings = await read(settingsRepositoryProvider).load();
  final builder = GlanceBuilder(
    DateTime(nowLocal.year, nowLocal.month, nowLocal.day),
  );
  for (final module in read(moduleRegistryProvider).visible(settings)) {
    try {
      await module.contributeGlance(builder, read, nowLocal);
    } on Object {
      // That module's part stays empty.
    }
  }
  return builder.build();
}
