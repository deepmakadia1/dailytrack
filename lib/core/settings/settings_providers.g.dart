// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Typed to the domain interface and free of data/ and Drift imports, so
/// presentation code can depend on it (Constitution II).
/// `production_overrides.dart` binds the Drift implementation; tests bind fakes
/// or use `makeRealContainer`.

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// Typed to the domain interface and free of data/ and Drift imports, so
/// presentation code can depend on it (Constitution II).
/// `production_overrides.dart` binds the Drift implementation; tests bind fakes
/// or use `makeRealContainer`.

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          SettingsRepository,
          SettingsRepository,
          SettingsRepository
        >
    with $Provider<SettingsRepository> {
  /// Typed to the domain interface and free of data/ and Drift imports, so
  /// presentation code can depend on it (Constitution II).
  /// `production_overrides.dart` binds the Drift implementation; tests bind fakes
  /// or use `makeRealContainer`.
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsRepository create(Ref ref) {
    return settingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsRepository>(value),
    );
  }
}

String _$settingsRepositoryHash() =>
    r'bf51f20b3aa94846233f7a124aa3408a7bc277de';

/// Live settings; the locale, router and navigation bar rebuild from this.

@ProviderFor(appSettings)
final appSettingsProvider = AppSettingsProvider._();

/// Live settings; the locale, router and navigation bar rebuild from this.

final class AppSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppSettings>,
          AppSettings,
          Stream<AppSettings>
        >
    with $FutureModifier<AppSettings>, $StreamProvider<AppSettings> {
  /// Live settings; the locale, router and navigation bar rebuild from this.
  AppSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appSettingsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appSettingsHash();

  @$internal
  @override
  $StreamProviderElement<AppSettings> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppSettings> create(Ref ref) {
    return appSettings(ref);
  }
}

String _$appSettingsHash() => r'4e19cc65dff1981e29d3100fb9d3281635e180e3';

/// The SET-01 full-date format, for code without a `BuildContext` (e.g.
/// share text). Widgets use `FullDateFormatScope.of(context)`.

@ProviderFor(fullDateFormat)
final fullDateFormatProvider = FullDateFormatProvider._();

/// The SET-01 full-date format, for code without a `BuildContext` (e.g.
/// share text). Widgets use `FullDateFormatScope.of(context)`.

final class FullDateFormatProvider
    extends $FunctionalProvider<FullDateFormat, FullDateFormat, FullDateFormat>
    with $Provider<FullDateFormat> {
  /// The SET-01 full-date format, for code without a `BuildContext` (e.g.
  /// share text). Widgets use `FullDateFormatScope.of(context)`.
  FullDateFormatProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fullDateFormatProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fullDateFormatHash();

  @$internal
  @override
  $ProviderElement<FullDateFormat> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FullDateFormat create(Ref ref) {
    return fullDateFormat(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FullDateFormat value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FullDateFormat>(value),
    );
  }
}

String _$fullDateFormatHash() => r'0a763eddc4c514b457674eccd1315d2ccf760324';

/// The sign-in mode (feature 011 research R6); `none` until settings load.
/// The router, the lock session, and SET-01 read it.

@ProviderFor(authMode)
final authModeProvider = AuthModeProvider._();

/// The sign-in mode (feature 011 research R6); `none` until settings load.
/// The router, the lock session, and SET-01 read it.

final class AuthModeProvider
    extends $FunctionalProvider<AuthMode, AuthMode, AuthMode>
    with $Provider<AuthMode> {
  /// The sign-in mode (feature 011 research R6); `none` until settings load.
  /// The router, the lock session, and SET-01 read it.
  AuthModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authModeHash();

  @$internal
  @override
  $ProviderElement<AuthMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthMode create(Ref ref) {
    return authMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthMode>(value),
    );
  }
}

String _$authModeHash() => r'bd8122b12e2d47021cb8554f88bc3c6381702f8c';
