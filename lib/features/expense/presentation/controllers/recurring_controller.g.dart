// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-10 Recurring transactions (T080). The screen's only notifier.

@ProviderFor(RecurringController)
final recurringControllerProvider = RecurringControllerProvider._();

/// EXP-10 Recurring transactions (T080). The screen's only notifier.
final class RecurringControllerProvider
    extends $StreamNotifierProvider<RecurringController, RecurringData> {
  /// EXP-10 Recurring transactions (T080). The screen's only notifier.
  RecurringControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recurringControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recurringControllerHash();

  @$internal
  @override
  RecurringController create() => RecurringController();
}

String _$recurringControllerHash() =>
    r'7e0cd36e63c4e82feca12085347b9b923a764981';

/// EXP-10 Recurring transactions (T080). The screen's only notifier.

abstract class _$RecurringController extends $StreamNotifier<RecurringData> {
  Stream<RecurringData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RecurringData>, RecurringData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RecurringData>, RecurringData>,
              AsyncValue<RecurringData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
