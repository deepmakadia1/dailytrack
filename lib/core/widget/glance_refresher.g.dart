// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glance_refresher.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(glanceRefresher)
final glanceRefresherProvider = GlanceRefresherProvider._();

final class GlanceRefresherProvider
    extends
        $FunctionalProvider<GlanceRefresher, GlanceRefresher, GlanceRefresher>
    with $Provider<GlanceRefresher> {
  GlanceRefresherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'glanceRefresherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$glanceRefresherHash();

  @$internal
  @override
  $ProviderElement<GlanceRefresher> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GlanceRefresher create(Ref ref) {
    return glanceRefresher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlanceRefresher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlanceRefresher>(value),
    );
  }
}

String _$glanceRefresherHash() => r'1033eca278ec4611e4887c4b74f5adaf6bb43f94';
