import 'package:dailytrack/core/module/insight.dart';
import 'package:dailytrack/core/module/provider_reader.dart';

/// A module's rule-based insights for the Home insight card
/// (`TrackerModule.insights()`, feature 006 data-model.md §2). Exempt from
/// the pure-Dart import scan because it needs [ProviderReader].
abstract interface class InsightSource {
  /// Every rule the module may return, in its fixed rotation order. No
  /// duplicates. Constant for a given app version.
  List<String> get ruleIds;

  /// Applicable insights only, at most one per rule id, each id contained in
  /// [ruleIds]. Must not throw: a failing rule is skipped. Reads only local
  /// data through [read] and makes no network calls.
  Future<List<Insight>> evaluate(ProviderReader read);
}
