// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_open_runner.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appOpenRunner)
final appOpenRunnerProvider = AppOpenRunnerProvider._();

final class AppOpenRunnerProvider
    extends $FunctionalProvider<AppOpenRunner, AppOpenRunner, AppOpenRunner>
    with $Provider<AppOpenRunner> {
  AppOpenRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appOpenRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appOpenRunnerHash();

  @$internal
  @override
  $ProviderElement<AppOpenRunner> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppOpenRunner create(Ref ref) {
    return appOpenRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppOpenRunner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppOpenRunner>(value),
    );
  }
}

String _$appOpenRunnerHash() => r'04a4a8928497bf8cd2c3094c891c3e790d96a63d';
