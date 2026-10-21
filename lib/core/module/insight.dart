import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// One rule-based tip for the Home insight card (DSH-01, feature 006
/// data-model.md §2). Pure Dart: computed on demand and never stored, except
/// the daily pick's [ruleId].
@immutable
final class Insight {
  const new({
    required this.ruleId,
    required this.text,
    this.location,
    this.semanticLabel,
  });

  /// Stable across releases. Unique app-wide, prefixed with the module id
  /// (`expense.categoryVsLastMonth`).
  final String ruleId;

  /// Already localized, one sentence.
  final String text;

  /// Route opened on tap (`Routes.*`); null means not tappable.
  final String? location;

  /// Optional TalkBack text ("Open reports"); Home falls back to [text].
  final String? semanticLabel;

  @override
  bool operator ==(Object other) =>
      other is Insight &&
      other.ruleId == ruleId &&
      other.text == text &&
      other.location == location &&
      other.semanticLabel == semanticLabel;

  @override
  int get hashCode => Object.hash(ruleId, text, location, semanticLabel);

  @override
  String toString() => 'Insight($ruleId, $text)';
}
