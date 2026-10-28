// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bound to the platform channel in `lib/app/production_overrides.dart`.

@ProviderFor(startupReporter)
final startupReporterProvider = StartupReporterProvider._();

/// Bound to the platform channel in `lib/app/production_overrides.dart`.

final class StartupReporterProvider
    extends
        $FunctionalProvider<StartupReporter, StartupReporter, StartupReporter>
    with $Provider<StartupReporter> {
  /// Bound to the platform channel in `lib/app/production_overrides.dart`.
  StartupReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupReporterHash();

  @$internal
  @override
  $ProviderElement<StartupReporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StartupReporter create(Ref ref) {
    return startupReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartupReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartupReporter>(value),
    );
  }
}

String _$startupReporterHash() => r'c858e0ac79ae15ba36f2bbf4e2f41ec9a60963fe';

/// Calls [StartupReporter.homeShown] once per app run, however often DSH-01
/// builds (feature 012 T043).

@ProviderFor(reportHomeShown)
final reportHomeShownProvider = ReportHomeShownProvider._();

/// Calls [StartupReporter.homeShown] once per app run, however often DSH-01
/// builds (feature 012 T043).

final class ReportHomeShownProvider
    extends
        $FunctionalProvider<void Function(), void Function(), void Function()>
    with $Provider<void Function()> {
  /// Calls [StartupReporter.homeShown] once per app run, however often DSH-01
  /// builds (feature 012 T043).
  ReportHomeShownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportHomeShownProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportHomeShownHash();

  @$internal
  @override
  $ProviderElement<void Function()> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void Function() create(Ref ref) {
    return reportHomeShown(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void Function()>(value),
    );
  }
}

String _$reportHomeShownHash() => r'b5e6a06d7c7c6d1a7eeca0a7fd10d0c234fa52ce';
