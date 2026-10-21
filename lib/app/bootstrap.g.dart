// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SYS-01 startup (T080):
///  1. open the database (runs migrations) and load settings,
///  2. seed defaults for every registered module, exactly once,
///  3. start the ads SDK unless Remove Ads was purchased (never blocks),
///  4. start notifications and the app-open hooks (never block),
///  5. pick the first route (a tapped notification's location if allowed).
/// A failure in steps 1–2 gives [BootstrapFailed], shown with "Retry".

@ProviderFor(Bootstrap)
final bootstrapProvider = BootstrapProvider._();

/// SYS-01 startup (T080):
///  1. open the database (runs migrations) and load settings,
///  2. seed defaults for every registered module, exactly once,
///  3. start the ads SDK unless Remove Ads was purchased (never blocks),
///  4. start notifications and the app-open hooks (never block),
///  5. pick the first route (a tapped notification's location if allowed).
/// A failure in steps 1–2 gives [BootstrapFailed], shown with "Retry".
final class BootstrapProvider
    extends $AsyncNotifierProvider<Bootstrap, BootstrapResult> {
  /// SYS-01 startup (T080):
  ///  1. open the database (runs migrations) and load settings,
  ///  2. seed defaults for every registered module, exactly once,
  ///  3. start the ads SDK unless Remove Ads was purchased (never blocks),
  ///  4. start notifications and the app-open hooks (never block),
  ///  5. pick the first route (a tapped notification's location if allowed).
  /// A failure in steps 1–2 gives [BootstrapFailed], shown with "Retry".
  BootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bootstrapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bootstrapHash();

  @$internal
  @override
  Bootstrap create() => Bootstrap();
}

String _$bootstrapHash() => r'140ef36c21fdb61b317b27a0fdafc8f8ee34fdde';

/// SYS-01 startup (T080):
///  1. open the database (runs migrations) and load settings,
///  2. seed defaults for every registered module, exactly once,
///  3. start the ads SDK unless Remove Ads was purchased (never blocks),
///  4. start notifications and the app-open hooks (never block),
///  5. pick the first route (a tapped notification's location if allowed).
/// A failure in steps 1–2 gives [BootstrapFailed], shown with "Retry".

abstract class _$Bootstrap extends $AsyncNotifier<BootstrapResult> {
  FutureOr<BootstrapResult> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<BootstrapResult>, BootstrapResult>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<BootstrapResult>, BootstrapResult>,
              AsyncValue<BootstrapResult>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
