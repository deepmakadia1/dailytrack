// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_out_guest_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ACC-04 Log out of guest (spec §16).

@ProviderFor(LogOutGuestController)
final logOutGuestControllerProvider = LogOutGuestControllerProvider._();

/// ACC-04 Log out of guest (spec §16).
final class LogOutGuestControllerProvider
    extends $NotifierProvider<LogOutGuestController, LogOutGuestState> {
  /// ACC-04 Log out of guest (spec §16).
  LogOutGuestControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logOutGuestControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logOutGuestControllerHash();

  @$internal
  @override
  LogOutGuestController create() => LogOutGuestController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LogOutGuestState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LogOutGuestState>(value),
    );
  }
}

String _$logOutGuestControllerHash() =>
    r'a5d2d6332326cc9ec2452525e4bf4719625fd39e';

/// ACC-04 Log out of guest (spec §16).

abstract class _$LogOutGuestController extends $Notifier<LogOutGuestState> {
  LogOutGuestState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LogOutGuestState, LogOutGuestState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LogOutGuestState, LogOutGuestState>,
              LogOutGuestState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
