// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether [format] is unlocked, live (FR-031): the debug switch and, later,
/// rewarded unlocks and Pro change it while SET-03 is open.

@ProviderFor(exportUnlocked)
final exportUnlockedProvider = ExportUnlockedFamily._();

/// Whether [format] is unlocked, live (FR-031): the debug switch and, later,
/// rewarded unlocks and Pro change it while SET-03 is open.

final class ExportUnlockedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether [format] is unlocked, live (FR-031): the debug switch and, later,
  /// rewarded unlocks and Pro change it while SET-03 is open.
  ExportUnlockedProvider._({
    required ExportUnlockedFamily super.from,
    required ExportFormat super.argument,
  }) : super(
         retry: null,
         name: r'exportUnlockedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exportUnlockedHash();

  @override
  String toString() {
    return r'exportUnlockedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as ExportFormat;
    return exportUnlocked(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ExportUnlockedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exportUnlockedHash() => r'39fe6295cb5fb3cc38df8798cd7cdd44e4c710d1';

/// Whether [format] is unlocked, live (FR-031): the debug switch and, later,
/// rewarded unlocks and Pro change it while SET-03 is open.

final class ExportUnlockedFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, ExportFormat> {
  ExportUnlockedFamily._()
    : super(
        retry: null,
        name: r'exportUnlockedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [format] is unlocked, live (FR-031): the debug switch and, later,
  /// rewarded unlocks and Pro change it while SET-03 is open.

  ExportUnlockedProvider call(ExportFormat format) =>
      ExportUnlockedProvider._(argument: format, from: this);

  @override
  String toString() => r'exportUnlockedProvider';
}

/// SET-03 Export data controller (FR-026 – FR-033). [datasetId] and
/// [periodQuery] prefill it, e.g. from EXP-11 "Export this report".

@ProviderFor(ExportController)
final exportControllerProvider = ExportControllerFamily._();

/// SET-03 Export data controller (FR-026 – FR-033). [datasetId] and
/// [periodQuery] prefill it, e.g. from EXP-11 "Export this report".
final class ExportControllerProvider
    extends $AsyncNotifierProvider<ExportController, ExportState> {
  /// SET-03 Export data controller (FR-026 – FR-033). [datasetId] and
  /// [periodQuery] prefill it, e.g. from EXP-11 "Export this report".
  ExportControllerProvider._({
    required ExportControllerFamily super.from,
    required ({String? datasetId, String? periodQuery}) super.argument,
  }) : super(
         retry: null,
         name: r'exportControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$exportControllerHash();

  @override
  String toString() {
    return r'exportControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ExportController create() => ExportController();

  @override
  bool operator ==(Object other) {
    return other is ExportControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$exportControllerHash() => r'55e4c916342c32e1af018cc8124f0e5b9efb3e8c';

/// SET-03 Export data controller (FR-026 – FR-033). [datasetId] and
/// [periodQuery] prefill it, e.g. from EXP-11 "Export this report".

final class ExportControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ExportController,
          AsyncValue<ExportState>,
          ExportState,
          FutureOr<ExportState>,
          ({String? datasetId, String? periodQuery})
        > {
  ExportControllerFamily._()
    : super(
        retry: null,
        name: r'exportControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// SET-03 Export data controller (FR-026 – FR-033). [datasetId] and
  /// [periodQuery] prefill it, e.g. from EXP-11 "Export this report".

  ExportControllerProvider call({String? datasetId, String? periodQuery}) =>
      ExportControllerProvider._(
        argument: (datasetId: datasetId, periodQuery: periodQuery),
        from: this,
      );

  @override
  String toString() => r'exportControllerProvider';
}

/// SET-03 Export data controller (FR-026 – FR-033). [datasetId] and
/// [periodQuery] prefill it, e.g. from EXP-11 "Export this report".

abstract class _$ExportController extends $AsyncNotifier<ExportState> {
  late final _$args = ref.$arg as ({String? datasetId, String? periodQuery});
  String? get datasetId => _$args.datasetId;
  String? get periodQuery => _$args.periodQuery;

  FutureOr<ExportState> build({String? datasetId, String? periodQuery});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ExportState>, ExportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ExportState>, ExportState>,
              AsyncValue<ExportState>,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(datasetId: _$args.datasetId, periodQuery: _$args.periodQuery),
    );
  }
}
