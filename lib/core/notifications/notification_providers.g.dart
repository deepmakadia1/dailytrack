// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationPermission)
final notificationPermissionProvider = NotificationPermissionProvider._();

final class NotificationPermissionProvider
    extends
        $FunctionalProvider<
          NotificationPermission,
          NotificationPermission,
          NotificationPermission
        >
    with $Provider<NotificationPermission> {
  NotificationPermissionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPermissionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPermissionHash();

  @$internal
  @override
  $ProviderElement<NotificationPermission> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationPermission create(Ref ref) {
    return notificationPermission(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationPermission value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationPermission>(value),
    );
  }
}

String _$notificationPermissionHash() =>
    r'05a5f9e1a54033d7c02c7be1050b4ef04048014e';

/// Local notifications (research R15). `production_overrides.dart` binds
/// `LocalNotificationService`; tests bind `FakeNotificationService`.

@ProviderFor(notificationService)
final notificationServiceProvider = NotificationServiceProvider._();

/// Local notifications (research R15). `production_overrides.dart` binds
/// `LocalNotificationService`; tests bind `FakeNotificationService`.

final class NotificationServiceProvider
    extends
        $FunctionalProvider<
          NotificationService,
          NotificationService,
          NotificationService
        >
    with $Provider<NotificationService> {
  /// Local notifications (research R15). `production_overrides.dart` binds
  /// `LocalNotificationService`; tests bind `FakeNotificationService`.
  NotificationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationService create(Ref ref) {
    return notificationService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationService>(value),
    );
  }
}

String _$notificationServiceHash() =>
    r'80f67e41ddfd6f9cde1dbe78e986bff9c541ce8f';

/// The device time zone for scheduled notifications (feature 005 R1).

@ProviderFor(timeZoneSource)
final timeZoneSourceProvider = TimeZoneSourceProvider._();

/// The device time zone for scheduled notifications (feature 005 R1).

final class TimeZoneSourceProvider
    extends $FunctionalProvider<TimeZoneSource, TimeZoneSource, TimeZoneSource>
    with $Provider<TimeZoneSource> {
  /// The device time zone for scheduled notifications (feature 005 R1).
  TimeZoneSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'timeZoneSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$timeZoneSourceHash();

  @$internal
  @override
  $ProviderElement<TimeZoneSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TimeZoneSource create(Ref ref) {
    return timeZoneSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TimeZoneSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TimeZoneSource>(value),
    );
  }
}

String _$timeZoneSourceHash() => r'119ed630bbfe41dda56e1c1d83e78baae852bb93';
