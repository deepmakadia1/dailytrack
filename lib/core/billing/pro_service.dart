import 'dart:async';

import 'package:dailytrack/core/billing/domain/pro_ownership_policy.dart';
import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';

/// A purchase result PRM-01 reacts to.
enum PurchaseEvent { pending, purchased, canceled, error }

/// The result of "Restore purchase".
enum RestoreResult { restored, pending, notFound, unavailable }

/// Pro purchase, restore, acknowledgement, and the start-up ownership check
/// (spec PRM-01, feature 009 research R13). Pro is the `removeAdsPurchased`
/// setting: the feature gate unlocks everything for good from it, and the
/// ad service switches to no ads from it, both live. Never throws.
final class ProService {
  new({required this.store, required this.settings, this._beforeExternal});

  final ProStore store;
  final SettingsRepository settings;

  /// The Play purchase dialog is the app's own trip out: no SYS-03 on
  /// return.
  final void Function()? _beforeExternal;

  final _events = StreamController<PurchaseEvent>.broadcast();
  StreamSubscription<List<StorePurchase>>? _updates;

  Stream<PurchaseEvent> get events => _events.stream;

  /// Listens for purchases, including ones completed while the app was
  /// closed. Called once in SYS-01 before any other billing call.
  void start() {
    _updates ??= store.purchaseUpdates.listen(
      (purchases) => unawaited(_onPurchases(purchases)),
      onError: (Object _) {},
    );
  }

  static ProState _stateOf(AppSettings s) => ProState(
    owned: s.removeAdsPurchased,
    notOwnedStreak: s.proNotOwnedStreak,
    pending: s.proPurchasePending,
    removalPending: s.proRemovalPending,
  );

  Future<void> _write(ProState next) => settings.setProState(
    owned: next.owned,
    notOwnedStreak: next.notOwnedStreak,
    pending: next.pending,
    removalPending: next.removalPending,
  );

  Future<void> _onPurchases(List<StorePurchase> purchases) async {
    for (final p in purchases.where((p) => p.productId == proProductId)) {
      try {
        switch (p.status) {
          case StorePurchaseStatus.purchased || StorePurchaseStatus.restored:
            await _write(const ProState(owned: true));
            _emit(PurchaseEvent.purchased);
          case StorePurchaseStatus.pending:
            final s = _stateOf(await settings.load());
            await _write(ProOwnershipPolicy.apply(s, OwnershipCheck.pending));
            _emit(PurchaseEvent.pending);
          case StorePurchaseStatus.canceled:
            _emit(PurchaseEvent.canceled);
          case StorePurchaseStatus.error:
            _emit(PurchaseEvent.error);
        }
        // Acknowledged here, or at the next start's check (FR-040).
        if (p.needsCompletion) await store.complete(p);
      } on Object {
        // The next start's ownership check settles it.
      }
    }
  }

  void _emit(PurchaseEvent e) {
    if (!_events.isClosed) _events.add(e);
  }

  /// The start-up check (FR-041): offline or failed changes nothing, and Pro
  /// is only ever removed by the next cold start (clarification Q1).
  Future<void> verifyOwnership() async {
    try {
      final check = await store.queryOwnership();
      final before = _stateOf(await settings.load());
      final after = ProOwnershipPolicy.apply(before, check);
      if (after != before) await _write(after);
    } on Object {
      // Trust the saved state.
    }
  }

  /// Applies a removal staged by an earlier start (SYS-01 step 3b′). True
  /// when Pro was removed.
  Future<bool> applyStagedRemoval() async {
    try {
      if (!(await settings.load()).proRemovalPending) return false;
      await _write(const ProState(owned: false));
      return true;
    } on Object {
      return false;
    }
  }

  /// The product to show on PRM-01, or null when the store can't sell now.
  Future<StoreProduct?> loadProduct() async {
    try {
      if (!await store.isAvailable()) return null;
      return await store.loadProduct();
    } on Object {
      return null;
    }
  }

  /// Opens the Play purchase dialog. False when it could not start.
  Future<bool> buy(StoreProduct product) async {
    try {
      _beforeExternal?.call();
      await store.buy(product);
      return true;
    } on Object {
      return false;
    }
  }

  /// "Restore purchase" (FR-042): Pro when Play says it is owned. It never
  /// counts toward removal; only start-up checks do.
  Future<RestoreResult> restore() async {
    try {
      switch (await store.queryOwnership()) {
        case OwnershipCheck.owned:
          await _write(const ProState(owned: true));
          return RestoreResult.restored;
        case OwnershipCheck.pending:
          final s = _stateOf(await settings.load());
          await _write(ProOwnershipPolicy.apply(s, OwnershipCheck.pending));
          return RestoreResult.pending;
        case OwnershipCheck.notOwned:
          return RestoreResult.notFound;
        case OwnershipCheck.unavailable:
          return RestoreResult.unavailable;
      }
    } on Object {
      return RestoreResult.unavailable;
    }
  }

  Future<void> dispose() async {
    await _updates?.cancel();
    await _events.close();
  }
}
