// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewarded_unlock.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rewardedUnlockPresenter)
final rewardedUnlockPresenterProvider = RewardedUnlockPresenterProvider._();

final class RewardedUnlockPresenterProvider
    extends
        $FunctionalProvider<
          RewardedUnlockPresenter,
          RewardedUnlockPresenter,
          RewardedUnlockPresenter
        >
    with $Provider<RewardedUnlockPresenter> {
  RewardedUnlockPresenterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rewardedUnlockPresenterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rewardedUnlockPresenterHash();

  @$internal
  @override
  $ProviderElement<RewardedUnlockPresenter> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RewardedUnlockPresenter create(Ref ref) {
    return rewardedUnlockPresenter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RewardedUnlockPresenter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RewardedUnlockPresenter>(value),
    );
  }
}

String _$rewardedUnlockPresenterHash() =>
    r'cc294597903a461b35545df8432551b25851ed22';
