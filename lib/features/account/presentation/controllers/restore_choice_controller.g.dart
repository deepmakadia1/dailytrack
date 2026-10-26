// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restore_choice_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ACC-02 Restore choice controller for [newest].

@ProviderFor(RestoreChoiceController)
final restoreChoiceControllerProvider = RestoreChoiceControllerFamily._();

/// ACC-02 Restore choice controller for [newest].
final class RestoreChoiceControllerProvider
    extends $NotifierProvider<RestoreChoiceController, RestoreChoiceState> {
  /// ACC-02 Restore choice controller for [newest].
  RestoreChoiceControllerProvider._({
    required RestoreChoiceControllerFamily super.from,
    required DriveBackupEntry super.argument,
  }) : super(
         retry: null,
         name: r'restoreChoiceControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$restoreChoiceControllerHash();

  @override
  String toString() {
    return r'restoreChoiceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RestoreChoiceController create() => RestoreChoiceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RestoreChoiceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RestoreChoiceState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RestoreChoiceControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$restoreChoiceControllerHash() =>
    r'be21820c7a96a9f9e89b0038fd1fd311ad79ae0c';

/// ACC-02 Restore choice controller for [newest].

final class RestoreChoiceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          RestoreChoiceController,
          RestoreChoiceState,
          RestoreChoiceState,
          RestoreChoiceState,
          DriveBackupEntry
        > {
  RestoreChoiceControllerFamily._()
    : super(
        retry: null,
        name: r'restoreChoiceControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ACC-02 Restore choice controller for [newest].

  RestoreChoiceControllerProvider call(DriveBackupEntry newest) =>
      RestoreChoiceControllerProvider._(argument: newest, from: this);

  @override
  String toString() => r'restoreChoiceControllerProvider';
}

/// ACC-02 Restore choice controller for [newest].

abstract class _$RestoreChoiceController extends $Notifier<RestoreChoiceState> {
  late final _$args = ref.$arg as DriveBackupEntry;
  DriveBackupEntry get newest => _$args;

  RestoreChoiceState build(DriveBackupEntry newest);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<RestoreChoiceState, RestoreChoiceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RestoreChoiceState, RestoreChoiceState>,
              RestoreChoiceState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
