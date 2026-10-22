// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'export_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Draws Hindi and Gujarati strings for the PDF. Tests override it.

@ProviderFor(shapedTextRenderer)
final shapedTextRendererProvider = ShapedTextRendererProvider._();

/// Draws Hindi and Gujarati strings for the PDF. Tests override it.

final class ShapedTextRendererProvider
    extends
        $FunctionalProvider<
          ShapedTextRenderer,
          ShapedTextRenderer,
          ShapedTextRenderer
        >
    with $Provider<ShapedTextRenderer> {
  /// Draws Hindi and Gujarati strings for the PDF. Tests override it.
  ShapedTextRendererProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shapedTextRendererProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shapedTextRendererHash();

  @$internal
  @override
  $ProviderElement<ShapedTextRenderer> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ShapedTextRenderer create(Ref ref) {
    return shapedTextRenderer(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShapedTextRenderer value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShapedTextRenderer>(value),
    );
  }
}

String _$shapedTextRendererHash() =>
    r'6e4ce6508ddd25f1f7a74a0313e42778d6054266';

/// SET-03 export (feature 008 research R12 – R15).

@ProviderFor(exportUseCase)
final exportUseCaseProvider = ExportUseCaseProvider._();

/// SET-03 export (feature 008 research R12 – R15).

final class ExportUseCaseProvider
    extends $FunctionalProvider<ExportUseCase, ExportUseCase, ExportUseCase>
    with $Provider<ExportUseCase> {
  /// SET-03 export (feature 008 research R12 – R15).
  ExportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exportUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exportUseCaseHash();

  @$internal
  @override
  $ProviderElement<ExportUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ExportUseCase create(Ref ref) {
    return exportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExportUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExportUseCase>(value),
    );
  }
}

String _$exportUseCaseHash() => r'9cbb60d4d1fe83655dbc66d6532a0dc9998542c5';
