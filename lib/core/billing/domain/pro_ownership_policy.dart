import 'package:dailytrack/core/billing/domain/pro_store.dart';
// `@immutable` via freezed_annotation's re-export of package:meta, so this
// file stays pure Dart without a new direct dependency.
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// Pro ownership as stored in settings (feature 009 data-model §5). Pure.
@immutable
final class ProState {
  const new({
    required this.owned,
    this.notOwnedStreak = 0,
    this.pending = false,
    this.removalPending = false,
  });

  final bool owned;

  /// Online starts in a row that reported Pro not owned.
  final int notOwnedStreak;
  final bool pending;

  /// Pro will be removed at the next cold start (analysis I1).
  final bool removalPending;

  @override
  bool operator ==(Object other) =>
      other is ProState &&
      other.owned == owned &&
      other.notOwnedStreak == notOwnedStreak &&
      other.pending == pending &&
      other.removalPending == removalPending;

  @override
  int get hashCode =>
      Object.hash(owned, notOwnedStreak, pending, removalPending);

  @override
  String toString() =>
      'ProState(owned: $owned, streak: $notOwnedStreak, pending: $pending, '
      'removalPending: $removalPending)';
}

/// What a start-up ownership check does to [ProState] (spec PRM-01,
/// clarification Q1): Pro is never removed on one answer, and never
/// mid-session. The second online "not owned" in a row only stages the
/// removal; the next cold start applies it.
abstract final class ProOwnershipPolicy {
  static const int removeAfter = 2;

  static ProState apply(ProState s, OwnershipCheck check) => switch (check) {
    OwnershipCheck.owned => const ProState(owned: true),
    OwnershipCheck.pending => ProState(
      owned: s.owned,
      notOwnedStreak: s.notOwnedStreak,
      pending: true,
      removalPending: s.removalPending,
    ),
    OwnershipCheck.notOwned when !s.owned => const ProState(owned: false),
    OwnershipCheck.notOwned when s.notOwnedStreak + 1 >= removeAfter =>
      const ProState(owned: true, removalPending: true),
    OwnershipCheck.notOwned => ProState(
      owned: true,
      notOwnedStreak: s.notOwnedStreak + 1,
      removalPending: s.removalPending,
    ),
    // Offline or failed: no answer, nothing changes.
    OwnershipCheck.unavailable => s,
  };
}
