import 'package:dailytrack/core/feature_gate/domain/feature_gate.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'feature_gate_providers.g.dart';

// Typed to domain interfaces and free of data/ and Drift imports, so any
// module's presentation code can depend on them (Constitution II).
// `production_overrides.dart` binds the Drift implementations; widget tests
// bind fakes.

@Riverpod(keepAlive: true)
FeatureGate featureGate(Ref ref) =>
    throw UnimplementedError('featureGateProvider must be overridden');

@Riverpod(keepAlive: true)
UnlockRepository unlockRepository(Ref ref) =>
    throw UnimplementedError('unlockRepositoryProvider must be overridden');

/// Whether developer tools (the "Unlock all features" switch) exist in this
/// build. `production_overrides.dart` sets it to
/// `!FlavorConfig.current.isProd`, so features never import `app/flavor.dart`
/// (FR-041).
@Riverpod(keepAlive: true)
bool debugToolsAvailable(Ref ref) => false;
