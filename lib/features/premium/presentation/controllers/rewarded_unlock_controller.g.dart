// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewarded_unlock_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// PRM-02 (spec §10, feature 009 research R11): loads one rewarded ad when
/// the sheet opens, shows it on request, and grants only from the reward
/// callback. An early close grants nothing and loads a new ad.

@ProviderFor(RewardedUnlockController)
final rewardedUnlockControllerProvider = RewardedUnlockControllerFamily._();

/// PRM-02 (spec §10, feature 009 research R11): loads one rewarded ad when
/// the sheet opens, shows it on request, and grants only from the reward
/// callback. An early close grants nothing and loads a new ad.
final class RewardedUnlockControllerProvider
    extends $NotifierProvider<RewardedUnlockController, RewardedUnlockState> {
  /// PRM-02 (spec §10, feature 009 research R11): loads one rewarded ad when
  /// the sheet opens, shows it on request, and grants only from the reward
  /// callback. An early close grants nothing and loads a new ad.
  RewardedUnlockControllerProvider._({
    required RewardedUnlockControllerFamily super.from,
    required FeatureKey super.argument,
  }) : super(
         retry: null,
         name: r'rewardedUnlockControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rewardedUnlockControllerHash();

  @override
  String toString() {
    return r'rewardedUnlockControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RewardedUnlockController create() => RewardedUnlockController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RewardedUnlockState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RewardedUnlockState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RewardedUnlockControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rewardedUnlockControllerHash() =>
    r'f7308a5ecdf13abbc2bb3720bd8fa2825aa18a59';

/// PRM-02 (spec §10, feature 009 research R11): loads one rewarded ad when
/// the sheet opens, shows it on request, and grants only from the reward
/// callback. An early close grants nothing and loads a new ad.

final class RewardedUnlockControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RewardedUnlockController,
          RewardedUnlockState,
          RewardedUnlockState,
          RewardedUnlockState,
          FeatureKey
        > {
  RewardedUnlockControllerFamily._()
    : super(
        retry: null,
        name: r'rewardedUnlockControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// PRM-02 (spec §10, feature 009 research R11): loads one rewarded ad when
  /// the sheet opens, shows it on request, and grants only from the reward
  /// callback. An early close grants nothing and loads a new ad.

  RewardedUnlockControllerProvider call(FeatureKey key) =>
      RewardedUnlockControllerProvider._(argument: key, from: this);

  @override
  String toString() => r'rewardedUnlockControllerProvider';
}

/// PRM-02 (spec §10, feature 009 research R11): loads one rewarded ad when
/// the sheet opens, shows it on request, and grants only from the reward
/// callback. An early close grants nothing and loads a new ad.

abstract class _$RewardedUnlockController
    extends $Notifier<RewardedUnlockState> {
  late final _$args = ref.$arg as FeatureKey;
  FeatureKey get key => _$args;

  RewardedUnlockState build(FeatureKey key);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RewardedUnlockState, RewardedUnlockState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RewardedUnlockState, RewardedUnlockState>,
              RewardedUnlockState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
