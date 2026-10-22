import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/module_registry.dart';

/// Each module's summary line for the restore preview ("1,240
/// transactions"), by module id, through the registry (Constitution II).
Map<String, String Function(Map<String, int>)> backupSummaries(
  ModuleRegistry registry,
  AppLocalizations l10n,
) => {
  for (final m in registry.all)
    if (m.backupSection() case final section?)
      m.id: (counts) => section.summary(l10n, counts),
};
