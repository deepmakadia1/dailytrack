// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_sharer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Widget tests override this with a recording fake.

@ProviderFor(imageSharer)
final imageSharerProvider = ImageSharerProvider._();

/// Widget tests override this with a recording fake.

final class ImageSharerProvider
    extends $FunctionalProvider<ImageSharer, ImageSharer, ImageSharer>
    with $Provider<ImageSharer> {
  /// Widget tests override this with a recording fake.
  ImageSharerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageSharerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageSharerHash();

  @$internal
  @override
  $ProviderElement<ImageSharer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImageSharer create(Ref ref) {
    return imageSharer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImageSharer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImageSharer>(value),
    );
  }
}

String _$imageSharerHash() => r'e951cb01bcdf0ecbd74bc174a09160eec7b983c8';
