// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lock_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the app is locked right now (research R7). Bootstrap starts it
/// from `settings.lockEnabled`; the app's lifecycle listener locks it again
/// after the "Lock after" time.

@ProviderFor(LockSession)
final lockSessionProvider = LockSessionProvider._();

/// Whether the app is locked right now (research R7). Bootstrap starts it
/// from `settings.lockEnabled`; the app's lifecycle listener locks it again
/// after the "Lock after" time.
final class LockSessionProvider
    extends $NotifierProvider<LockSession, LockSessionState> {
  /// Whether the app is locked right now (research R7). Bootstrap starts it
  /// from `settings.lockEnabled`; the app's lifecycle listener locks it again
  /// after the "Lock after" time.
  LockSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockSessionHash();

  @$internal
  @override
  LockSession create() => LockSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LockSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LockSessionState>(value),
    );
  }
}

String _$lockSessionHash() => r'38660e20c394b0c35eba0857bd47ade9f5c1ee2e';

/// Whether the app is locked right now (research R7). Bootstrap starts it
/// from `settings.lockEnabled`; the app's lifecycle listener locks it again
/// after the "Lock after" time.

abstract class _$LockSession extends $Notifier<LockSessionState> {
  LockSessionState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LockSessionState, LockSessionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LockSessionState, LockSessionState>,
              LockSessionState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
