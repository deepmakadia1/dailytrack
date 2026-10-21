import 'package:dailytrack/core/module/insight.dart';
import 'package:dailytrack/core/module/insight_source.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:flutter_test/flutter_test.dart';

// Fakes for DSH-01 tests: insight sources driven by plain data, so Home tests
// never import a feature module.

/// An [InsightSource] that returns [insights] (or throws [error]) and counts
/// its evaluations.
final class FakeInsightSource implements InsightSource {
  new(this.ruleIds, {this.insights = const [], this.error});

  @override
  final List<String> ruleIds;

  /// What the next evaluation returns; tests may replace it.
  List<Insight> insights;

  /// When set, [evaluate] throws it.
  Object? error;

  int calls = 0;

  @override
  Future<List<Insight>> evaluate(ProviderReader read) async {
    calls++;
    if (error case final Error e) throw e;
    if (error case final Exception e) throw e;
    return insights;
  }
}

/// The ad widgets arrive in feature 008 (T4.1); matching them by name keeps
/// this check valid once they exist. DSH-01 shows no ads in feature 006.
final Finder anyAdWidget = find.byWidgetPredicate(
  (w) => const {'AppNativeAd', 'AppBannerAd'}.contains('${w.runtimeType}'),
);

/// Shorthand for an [Insight] with a route.
Insight insight(String ruleId, {String? location}) =>
    Insight(ruleId: ruleId, text: 'Tip $ruleId', location: location);
