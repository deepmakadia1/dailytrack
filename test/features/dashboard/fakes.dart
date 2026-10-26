import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/ads/widgets/app_native_ad.dart';
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

/// DSH-01 has no banner and one native slot (feature 009, spec §11). Widget
/// tests use `NoAdsService`, so the slot must take no space at all.
void expectNoVisibleAd(WidgetTester tester) {
  expect(find.byType(AppBannerAd), findsNothing);
  for (final e in find.byType(AppNativeAd).evaluate()) {
    expect(tester.getSize(find.byWidget(e.widget)).height, 0);
  }
}

/// Shorthand for an [Insight] with a route.
Insight insight(String ruleId, {String? location}) =>
    Insight(ruleId: ruleId, text: 'Tip $ruleId', location: location);
