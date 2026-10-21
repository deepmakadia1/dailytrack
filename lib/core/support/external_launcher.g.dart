// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_launcher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Widget tests override this with a recording fake.

@ProviderFor(externalLauncher)
final externalLauncherProvider = ExternalLauncherProvider._();

/// Widget tests override this with a recording fake.

final class ExternalLauncherProvider
    extends
        $FunctionalProvider<
          ExternalLauncher,
          ExternalLauncher,
          ExternalLauncher
        >
    with $Provider<ExternalLauncher> {
  /// Widget tests override this with a recording fake.
  ExternalLauncherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'externalLauncherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$externalLauncherHash();

  @$internal
  @override
  $ProviderElement<ExternalLauncher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExternalLauncher create(Ref ref) {
    return externalLauncher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExternalLauncher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExternalLauncher>(value),
    );
  }
}

String _$externalLauncherHash() => r'14a4969ad334ae403400902e3fd4dfe49154e045';
