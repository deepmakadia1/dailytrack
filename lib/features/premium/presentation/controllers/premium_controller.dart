import 'dart:async';

import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:dailytrack/core/billing/pro_service.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'premium_controller.freezed.dart';
part 'premium_controller.g.dart';

/// Where PRM-01 is (feature 009 data-model §5).
enum PremiumPhase {
  /// Asking Google Play for the price.
  loading,

  /// The price button can be tapped.
  ready,

  /// Play can't sell Pro right now (offline, no product, no Play).
  unavailable,

  /// The Play purchase dialog is open.
  purchasing,

  /// The payment is pending; Pro unlocks when it completes.
  pending,

  /// The purchase failed; "Try again".
  error,

  /// Pro is owned.
  owned,
}

@freezed
abstract class PremiumState with _$PremiumState {
  const factory({
    @Default(PremiumPhase.loading) PremiumPhase phase,
    StoreProduct? product,
  }) = _PremiumState;
}

/// PRM-01 Premium (spec §10, feature 009 contracts/screens.md). Pro itself
/// lives in settings (`removeAdsPurchased`), written by `ProService`; this
/// screen follows it live.
@riverpod
class PremiumController extends _$PremiumController {
  @override
  PremiumState build() {
    final (owned, pending) = ref.watch(
      appSettingsProvider.select(
        (s) => (
          s.value?.removeAdsPurchased ?? false,
          s.value?.proPurchasePending ?? false,
        ),
      ),
    );
    // SYS-01 already started it; starting again is a no-op.
    final service = ref.read(proServiceProvider)..start();
    final events = service.events.listen(_onEvent);
    ref.onDispose(events.cancel);
    if (owned) return const PremiumState(phase: PremiumPhase.owned);
    if (pending) return const PremiumState(phase: PremiumPhase.pending);
    unawaited(_load());
    return const PremiumState();
  }

  Future<void> _load() async {
    final product = await ref.read(proServiceProvider).loadProduct();
    if (!ref.mounted || state.phase != PremiumPhase.loading) return;
    state = product == null
        ? const PremiumState(phase: PremiumPhase.unavailable)
        : PremiumState(phase: PremiumPhase.ready, product: product);
  }

  void _onEvent(PurchaseEvent event) {
    if (!ref.mounted) return;
    switch (event) {
      // Owned and pending arrive through settings (build runs again).
      case PurchaseEvent.purchased || PurchaseEvent.pending:
        break;
      case PurchaseEvent.canceled:
        // No message (US3-3).
        if (state.phase == PremiumPhase.purchasing) {
          state = state.copyWith(phase: PremiumPhase.ready);
        }
      case PurchaseEvent.error:
        if (state.phase == PremiumPhase.purchasing) {
          state = state.copyWith(phase: PremiumPhase.error);
        }
    }
  }

  /// The price button. Ignored unless ready, so a double tap starts one
  /// purchase (FR-046).
  Future<void> buy() async {
    final product = state.product;
    if (state.phase != PremiumPhase.ready || product == null) return;
    state = state.copyWith(phase: PremiumPhase.purchasing);
    final started = await ref.read(proServiceProvider).buy(product);
    if (!started && ref.mounted && state.phase == PremiumPhase.purchasing) {
      state = state.copyWith(phase: PremiumPhase.error);
    }
  }

  /// "Try again" after a failure or an unavailable store.
  Future<void> retry() async {
    final product = state.product;
    if (state.phase == PremiumPhase.error && product != null) {
      state = state.copyWith(phase: PremiumPhase.ready);
      return;
    }
    state = const PremiumState();
    await _load();
  }

  /// "Restore purchase" (FR-042). Owned or pending show through settings.
  Future<RestoreResult> restore() => ref.read(proServiceProvider).restore();
}
