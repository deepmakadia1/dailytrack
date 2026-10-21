import 'package:dailytrack/core/module/insight.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

// DSH-01 daily insight rotation (feature 006 research R6, clarification
// Q1, data-model.md §6). Pure Dart: dates are local `yyyy-MM-dd` keys.

/// The pick stored in settings (`dailyInsightDate`, `dailyInsightId`).
@immutable
final class StoredInsightPick {
  const new({required this.date, required this.ruleId});

  final String date;
  final String ruleId;

  @override
  bool operator ==(Object other) =>
      other is StoredInsightPick &&
      other.date == date &&
      other.ruleId == ruleId;

  @override
  int get hashCode => Object.hash(date, ruleId);
}

/// What Home shows in the insight card.
sealed class InsightPick {
  const new();
}

/// A real insight. [persist] means the stored pick must change to today and
/// this rule.
@immutable
final class Picked extends InsightPick {
  const new(this.insight, {required this.persist});

  final Insight insight;
  final bool persist;

  @override
  bool operator ==(Object other) =>
      other is Picked && other.insight == insight && other.persist == persist;

  @override
  int get hashCode => Object.hash(insight, persist);

  @override
  String toString() => 'Picked(${insight.ruleId}, persist: $persist)';
}

/// No rule applies: the starter tip. Nothing is written, so rotation resumes
/// from the last real pick.
@immutable
final class Starter extends InsightPick {
  const new();

  @override
  bool operator ==(Object other) => other is Starter;

  @override
  int get hashCode => (Starter).hashCode;
}

/// Picks today's insight.
///
/// - [order]: the `ruleIds` of visible modules, in module order.
/// - [applicable]: rule id → insight, for rules that apply now. Ids outside
///   [order] are ignored.
/// - Same day: keep the stored rule while it applies; otherwise take the
///   next applicable rule after it, cycling.
/// - New day: take the first applicable rule after the stored one, cycling
///   and skipping it; the stored rule only if nothing else applies.
/// - A stored rule not in [order] starts from the top.
InsightPick pickDailyInsight({
  required String today,
  required List<String> order,
  required Map<String, Insight> applicable,
  StoredInsightPick? stored,
}) {
  final first = order.where(applicable.containsKey).firstOrNull;
  if (first == null) return const Starter();
  if (stored == null || !order.contains(stored.ruleId)) {
    return Picked(applicable[first]!, persist: true);
  }
  if (stored.date == today && applicable.containsKey(stored.ruleId)) {
    return Picked(applicable[stored.ruleId]!, persist: false);
  }
  final start = order.indexOf(stored.ruleId);
  for (var k = 1; k < order.length; k++) {
    final id = order[(start + k) % order.length];
    if (applicable.containsKey(id)) {
      return Picked(applicable[id]!, persist: true);
    }
  }
  // Only the stored rule applies (a new day): show it again under today.
  return Picked(applicable[stored.ruleId]!, persist: true);
}
