// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-11 Reports (T089, T096, contracts/screens.md). The screen's only
/// notifier. Every figure comes from the same ledger and breakdown queries
/// as EXP-01's summary strip, so the totals match (EXP-11 criterion 2).
/// Nothing is loaded while the current tab is locked: the overlay shows
/// sample data instead.

@ProviderFor(ReportsController)
final reportsControllerProvider = ReportsControllerProvider._();

/// EXP-11 Reports (T089, T096, contracts/screens.md). The screen's only
/// notifier. Every figure comes from the same ledger and breakdown queries
/// as EXP-01's summary strip, so the totals match (EXP-11 criterion 2).
/// Nothing is loaded while the current tab is locked: the overlay shows
/// sample data instead.
final class ReportsControllerProvider
    extends $NotifierProvider<ReportsController, ReportsState> {
  /// EXP-11 Reports (T089, T096, contracts/screens.md). The screen's only
  /// notifier. Every figure comes from the same ledger and breakdown queries
  /// as EXP-01's summary strip, so the totals match (EXP-11 criterion 2).
  /// Nothing is loaded while the current tab is locked: the overlay shows
  /// sample data instead.
  ReportsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsControllerHash();

  @$internal
  @override
  ReportsController create() => ReportsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportsState>(value),
    );
  }
}

String _$reportsControllerHash() => r'6a412ee5012491c5aca9433eba50af156ec03edb';

/// EXP-11 Reports (T089, T096, contracts/screens.md). The screen's only
/// notifier. Every figure comes from the same ledger and breakdown queries
/// as EXP-01's summary strip, so the totals match (EXP-11 criterion 2).
/// Nothing is loaded while the current tab is locked: the overlay shows
/// sample data instead.

abstract class _$ReportsController extends $Notifier<ReportsState> {
  ReportsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ReportsState, ReportsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ReportsState, ReportsState>,
              ReportsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
