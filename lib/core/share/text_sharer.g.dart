// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'text_sharer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Widget tests override this with a recording fake.

@ProviderFor(textSharer)
final textSharerProvider = TextSharerProvider._();

/// Widget tests override this with a recording fake.

final class TextSharerProvider
    extends $FunctionalProvider<TextSharer, TextSharer, TextSharer>
    with $Provider<TextSharer> {
  /// Widget tests override this with a recording fake.
  TextSharerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'textSharerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$textSharerHash();

  @$internal
  @override
  $ProviderElement<TextSharer> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TextSharer create(Ref ref) {
    return textSharer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TextSharer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TextSharer>(value),
    );
  }
}

String _$textSharerHash() => r'00a2ab52681e614d2a3c286901531f09831e8992';
