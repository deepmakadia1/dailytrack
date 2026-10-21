// `@immutable` via freezed_annotation's re-export of package:meta, so this
// file stays pure Dart without a new direct dependency.
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// A gated feature (spec §4 `unlocks.featureKey`, research R13). A value
/// class rather than an enum because premium themes carry a name; stored as
/// [storageKey] text. Pure Dart.
@immutable
final class FeatureKey {
  const new _(this.storageKey);

  /// `premiumTheme_<name>`.
  factory premiumTheme(String name) => FeatureKey._('premiumTheme_$name');

  /// Any stored key, including ones a newer app version wrote.
  factory fromStorage(String storageKey) => FeatureKey._(storageKey);

  static const FeatureKey exportCsv = FeatureKey._('exportCsv');
  static const FeatureKey exportPdf = FeatureKey._('exportPdf');
  static const FeatureKey advancedReports = FeatureKey._('advancedReports');
  static const FeatureKey adFreeDay = FeatureKey._('adFreeDay');
  static const FeatureKey streakFreeze = FeatureKey._('streakFreeze');

  final String storageKey;

  @override
  bool operator ==(Object other) =>
      other is FeatureKey && other.storageKey == storageKey;

  @override
  int get hashCode => storageKey.hashCode;

  @override
  String toString() => 'FeatureKey($storageKey)';
}
