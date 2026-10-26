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

/// [counts] keyed `"<moduleId>.<kind>"` (backup metadata) as one line,
/// e.g. "1,240 transactions · 8 habits", in the registry's order. Modules
/// without counts are left out.
String backupCountsLine(
  ModuleRegistry registry,
  AppLocalizations l10n,
  Map<String, int> counts,
) => [
  for (final MapEntry(key: id, value: summary) in backupSummaries(
    registry,
    l10n,
  ).entries)
    if (_moduleCounts(counts, id) case final mine when mine.isNotEmpty)
      summary(mine),
].join(' · ');

Map<String, int> _moduleCounts(Map<String, int> counts, String moduleId) => {
  for (final MapEntry(:key, :value) in counts.entries)
    if (key.startsWith('$moduleId.')) key.substring(moduleId.length + 1): value,
};
