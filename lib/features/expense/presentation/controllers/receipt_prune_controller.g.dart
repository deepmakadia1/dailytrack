// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_prune_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Deletes orphaned receipt files once per app process (T059, research R8).
/// Read from EXP-01 and EXP-02; never awaited by the UI, and failures are
/// ignored because pruning is housekeeping.

@ProviderFor(receiptPrune)
final receiptPruneProvider = ReceiptPruneProvider._();

/// Deletes orphaned receipt files once per app process (T059, research R8).
/// Read from EXP-01 and EXP-02; never awaited by the UI, and failures are
/// ignored because pruning is housekeeping.

final class ReceiptPruneProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Deletes orphaned receipt files once per app process (T059, research R8).
  /// Read from EXP-01 and EXP-02; never awaited by the UI, and failures are
  /// ignored because pruning is housekeeping.
  ReceiptPruneProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'receiptPruneProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$receiptPruneHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return receiptPrune(ref);
  }
}

String _$receiptPruneHash() => r'75ebfe5e3b39a9cc063cb62729ba66e8257db933';
