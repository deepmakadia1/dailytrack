// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_info_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Widget tests override this with a fixed fake.

@ProviderFor(appInfoSource)
final appInfoSourceProvider = AppInfoSourceProvider._();

/// Widget tests override this with a fixed fake.

final class AppInfoSourceProvider
    extends $FunctionalProvider<AppInfoSource, AppInfoSource, AppInfoSource>
    with $Provider<AppInfoSource> {
  /// Widget tests override this with a fixed fake.
  AppInfoSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInfoSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInfoSourceHash();

  @$internal
  @override
  $ProviderElement<AppInfoSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppInfoSource create(Ref ref) {
    return appInfoSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppInfoSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppInfoSource>(value),
    );
  }
}

String _$appInfoSourceHash() => r'bfc5b94144daa402836baff91e2a3f28c3b18728';
