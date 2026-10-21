// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The color theme the app shows (FR-017, FR-020): the stored theme when it
/// is free or unlocked, otherwise Default teal. The stored choice is never
/// overwritten, so the premium theme comes back as soon as the gate says so
/// (e.g. the dev "Unlock all features" switch).

@ProviderFor(effectiveColorTheme)
final effectiveColorThemeProvider = EffectiveColorThemeProvider._();

/// The color theme the app shows (FR-017, FR-020): the stored theme when it
/// is free or unlocked, otherwise Default teal. The stored choice is never
/// overwritten, so the premium theme comes back as soon as the gate says so
/// (e.g. the dev "Unlock all features" switch).

final class EffectiveColorThemeProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppColorTheme>,
          AppColorTheme,
          Stream<AppColorTheme>
        >
    with $FutureModifier<AppColorTheme>, $StreamProvider<AppColorTheme> {
  /// The color theme the app shows (FR-017, FR-020): the stored theme when it
  /// is free or unlocked, otherwise Default teal. The stored choice is never
  /// overwritten, so the premium theme comes back as soon as the gate says so
  /// (e.g. the dev "Unlock all features" switch).
  EffectiveColorThemeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveColorThemeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveColorThemeHash();

  @$internal
  @override
  $StreamProviderElement<AppColorTheme> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppColorTheme> create(Ref ref) {
    return effectiveColorTheme(ref);
  }
}

String _$effectiveColorThemeHash() =>
    r'86ae968fa9855934a4552ac74e5be995a18d8fcc';

/// Whether the theme [id] can be applied: always for a free theme,
/// otherwise live from the feature gate.

@ProviderFor(colorThemeUnlocked)
final colorThemeUnlockedProvider = ColorThemeUnlockedFamily._();

/// Whether the theme [id] can be applied: always for a free theme,
/// otherwise live from the feature gate.

final class ColorThemeUnlockedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the theme [id] can be applied: always for a free theme,
  /// otherwise live from the feature gate.
  ColorThemeUnlockedProvider._({
    required ColorThemeUnlockedFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'colorThemeUnlockedProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$colorThemeUnlockedHash();

  @override
  String toString() {
    return r'colorThemeUnlockedProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    final argument = this.argument as String;
    return colorThemeUnlocked(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ColorThemeUnlockedProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$colorThemeUnlockedHash() =>
    r'c224e697ec400aa9f0d979a546c58a8bcb3145d5';

/// Whether the theme [id] can be applied: always for a free theme,
/// otherwise live from the feature gate.

final class ColorThemeUnlockedFamily extends $Family
    with $FunctionalFamilyOverride<Stream<bool>, String> {
  ColorThemeUnlockedFamily._()
    : super(
        retry: null,
        name: r'colorThemeUnlockedProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the theme [id] can be applied: always for a free theme,
  /// otherwise live from the feature gate.

  ColorThemeUnlockedProvider call(String id) =>
      ColorThemeUnlockedProvider._(argument: id, from: this);

  @override
  String toString() => r'colorThemeUnlockedProvider';
}
