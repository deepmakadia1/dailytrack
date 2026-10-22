// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_summary_scheduler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dailySummaryScheduler)
final dailySummarySchedulerProvider = DailySummarySchedulerProvider._();

final class DailySummarySchedulerProvider
    extends
        $FunctionalProvider<
          DailySummaryScheduler,
          DailySummaryScheduler,
          DailySummaryScheduler
        >
    with $Provider<DailySummaryScheduler> {
  DailySummarySchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dailySummarySchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dailySummarySchedulerHash();

  @$internal
  @override
  $ProviderElement<DailySummaryScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DailySummaryScheduler create(Ref ref) {
    return dailySummaryScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DailySummaryScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DailySummaryScheduler>(value),
    );
  }
}

String _$dailySummarySchedulerHash() =>
    r'3838c1a5a738d63e3c88405b43855726db2cb9fe';
