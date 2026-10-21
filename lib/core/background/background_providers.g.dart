// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Daily background jobs (research R10). `production_overrides.dart` binds
/// `WorkmanagerBackgroundScheduler`; tests bind `FakeBackgroundScheduler`.

@ProviderFor(backgroundScheduler)
final backgroundSchedulerProvider = BackgroundSchedulerProvider._();

/// Daily background jobs (research R10). `production_overrides.dart` binds
/// `WorkmanagerBackgroundScheduler`; tests bind `FakeBackgroundScheduler`.

final class BackgroundSchedulerProvider
    extends
        $FunctionalProvider<
          BackgroundScheduler,
          BackgroundScheduler,
          BackgroundScheduler
        >
    with $Provider<BackgroundScheduler> {
  /// Daily background jobs (research R10). `production_overrides.dart` binds
  /// `WorkmanagerBackgroundScheduler`; tests bind `FakeBackgroundScheduler`.
  BackgroundSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundSchedulerHash();

  @$internal
  @override
  $ProviderElement<BackgroundScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  BackgroundScheduler create(Ref ref) {
    return backgroundScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundScheduler>(value),
    );
  }
}

String _$backgroundSchedulerHash() =>
    r'59b09d507b878c8a36d4efa1672b0b8cf59a46fc';
