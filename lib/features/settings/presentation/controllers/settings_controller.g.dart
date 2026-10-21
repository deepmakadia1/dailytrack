// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SET-01 controller. Follows the settings stream, so every row shows the
/// stored value right after a write.

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// SET-01 controller. Follows the settings stream, so every row shows the
/// stored value right after a write.
final class SettingsControllerProvider
    extends $AsyncNotifierProvider<SettingsController, SettingsViewData> {
  /// SET-01 controller. Follows the settings stream, so every row shows the
  /// stored value right after a write.
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();
}

String _$settingsControllerHash() =>
    r'8ad38948ed8b2cfba93545a7d80c6a43e2b9b3f0';

/// SET-01 controller. Follows the settings stream, so every row shows the
/// stored value right after a write.

abstract class _$SettingsController extends $AsyncNotifier<SettingsViewData> {
  FutureOr<SettingsViewData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SettingsViewData>, SettingsViewData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SettingsViewData>, SettingsViewData>,
              AsyncValue<SettingsViewData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The installed version for the About section. Kept for the session.

@ProviderFor(appInfo)
final appInfoProvider = AppInfoProvider._();

/// The installed version for the About section. Kept for the session.

final class AppInfoProvider
    extends $FunctionalProvider<AsyncValue<AppInfo>, AppInfo, FutureOr<AppInfo>>
    with $FutureModifier<AppInfo>, $FutureProvider<AppInfo> {
  /// The installed version for the About section. Kept for the session.
  AppInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoHash();

  @$internal
  @override
  $FutureProviderElement<AppInfo> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<AppInfo> create(Ref ref) {
    return appInfo(ref);
  }
}

String _$appInfoHash() => r'8e7e8c8ce5a2bcd55fb22caa7cfa872789ebd9e2';

/// Whether the OS lets the app notify (SET-01 "Notifications are blocked").
/// The screen refreshes it on resume, after a trip to system settings.

@ProviderFor(notificationsAllowed)
final notificationsAllowedProvider = NotificationsAllowedProvider._();

/// Whether the OS lets the app notify (SET-01 "Notifications are blocked").
/// The screen refreshes it on resume, after a trip to system settings.

final class NotificationsAllowedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the OS lets the app notify (SET-01 "Notifications are blocked").
  /// The screen refreshes it on resume, after a trip to system settings.
  NotificationsAllowedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsAllowedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsAllowedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return notificationsAllowed(ref);
  }
}

String _$notificationsAllowedHash() =>
    r'bd2ffe0a31f2168dbcde06dbd241a6c6d7475a87';
