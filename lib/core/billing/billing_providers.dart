import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:dailytrack/core/billing/pro_service.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'billing_providers.g.dart';

// Typed to interfaces only (Constitution II). The composition root binds
// the `in_app_purchase` store; tests keep the default or bind a fake.

/// Google Play Billing for Pro. Default: no store.
@Riverpod(keepAlive: true)
ProStore proStore(Ref ref) => const UnavailableProStore();

/// Purchase, restore, and the start-up ownership check (spec PRM-01).
@Riverpod(keepAlive: true)
ProService proService(Ref ref) {
  final service = ProService(
    store: ref.watch(proStoreProvider),
    settings: ref.watch(settingsRepositoryProvider),
    beforeExternal: () =>
        ref.read(externalActivityGuardProvider).expectExternalActivity(),
  );
  ref.onDispose(service.dispose);
  return service;
}

/// Whether the app acts as Pro now, live: Pro is owned
/// (`removeAdsPurchased`), or dev tools are available and "Unlock all
/// features (debug)" is on (FR-037, FR-041). False until settings load.
@Riverpod(keepAlive: true)
bool proOwned(Ref ref) {
  final debugTools = ref.watch(debugToolsAvailableProvider);
  return ref.watch(
    appSettingsProvider.select((s) {
      final v = s.value;
      if (v == null) return false;
      return v.removeAdsPurchased || (debugTools && v.debugUnlockAll);
    }),
  );
}
