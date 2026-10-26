import 'package:dailytrack/core/billing/domain/pro_ownership_policy.dart';
import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Start-up ownership checks (feature 009 T081, clarification Q1, analysis
/// I1, data-model §5).
void main() {
  ProState apply(ProState s, OwnershipCheck c) =>
      ProOwnershipPolicy.apply(s, c);
  const owned = ProState(owned: true);

  test('owned → Pro, and every counter and flag clears', () {
    const before = ProState(
      owned: true,
      notOwnedStreak: 1,
      pending: true,
      removalPending: true,
    );
    expect(apply(before, OwnershipCheck.owned), owned);
    expect(
      apply(const ProState(owned: false), OwnershipCheck.owned),
      owned,
      reason: 'a reinstall gets Pro back on its own',
    );
  });

  test('pending keeps Pro and the streak, and marks the payment pending', () {
    const before = ProState(owned: false);
    expect(
      apply(before, OwnershipCheck.pending),
      const ProState(owned: false, pending: true),
    );
  });

  test('Q1: one "not owned" keeps Pro', () {
    expect(
      apply(owned, OwnershipCheck.notOwned),
      const ProState(owned: true, notOwnedStreak: 1),
    );
  });

  test('Q1 and I1: the second "not owned" in a row only stages the '
      'removal; Pro stays for this session', () {
    final second = apply(
      const ProState(owned: true, notOwnedStreak: 1),
      OwnershipCheck.notOwned,
    );
    expect(second.owned, isTrue);
    expect(second.removalPending, isTrue);
    expect(second.notOwnedStreak, 0);
  });

  test('an "owned" between two "not owned" starts the count again', () {
    var s = apply(owned, OwnershipCheck.notOwned);
    s = apply(s, OwnershipCheck.owned);
    s = apply(s, OwnershipCheck.notOwned);
    expect(s, const ProState(owned: true, notOwnedStreak: 1));
  });

  test('offline or failed checks change nothing', () {
    const s = ProState(owned: true, notOwnedStreak: 1);
    expect(apply(s, OwnershipCheck.unavailable), s);
    var t = apply(owned, OwnershipCheck.notOwned);
    t = apply(t, OwnershipCheck.unavailable);
    t = apply(t, OwnershipCheck.unavailable);
    expect(t.notOwnedStreak, 1, reason: 'offline never resets the count');
  });

  test('without Pro, "not owned" is simply not owned', () {
    expect(
      apply(const ProState(owned: false), OwnershipCheck.notOwned),
      const ProState(owned: false),
    );
  });
}
