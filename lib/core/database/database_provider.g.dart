// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single app database. Widget tests override this with a provider that
/// throws, so they can never touch Drift (Constitution IV, task T059).
// Production binding: opens the on-device file, so it is exercised by
// integration_test/app_smoke_test.dart rather than unit tests.
// coverage:ignore-start

@ProviderFor(appDatabase)
final appDatabaseProvider = AppDatabaseProvider._();

/// The single app database. Widget tests override this with a provider that
/// throws, so they can never touch Drift (Constitution IV, task T059).
// Production binding: opens the on-device file, so it is exercised by
// integration_test/app_smoke_test.dart rather than unit tests.
// coverage:ignore-start

final class AppDatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  /// The single app database. Widget tests override this with a provider that
  /// throws, so they can never touch Drift (Constitution IV, task T059).
  // Production binding: opens the on-device file, so it is exercised by
  // integration_test/app_smoke_test.dart rather than unit tests.
  // coverage:ignore-start
  AppDatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appDatabaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appDatabaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return appDatabase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$appDatabaseHash() => r'365ef3f215d780c29a21b6328f0b547a8363c6a6';
