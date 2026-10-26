// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SET-02 Backup and restore controller (FR-012 – FR-021).

@ProviderFor(BackupController)
final backupControllerProvider = BackupControllerProvider._();

/// SET-02 Backup and restore controller (FR-012 – FR-021).
final class BackupControllerProvider
    extends $AsyncNotifierProvider<BackupController, BackupState> {
  /// SET-02 Backup and restore controller (FR-012 – FR-021).
  BackupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupControllerHash();

  @$internal
  @override
  BackupController create() => BackupController();
}

String _$backupControllerHash() => r'c77929ac3e703bd0730f5dcd1c8a9c3f2842499c';

/// SET-02 Backup and restore controller (FR-012 – FR-021).

abstract class _$BackupController extends $AsyncNotifier<BackupState> {
  FutureOr<BackupState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BackupState>, BackupState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BackupState>, BackupState>,
              AsyncValue<BackupState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
