// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one DSH-01 notifier (Constitution II, research R7, R14, R18).
///
/// `build()` watches only the registry and the settings that change what
/// Home lists (`locale`, `enabledModules`, `moduleOrder`). Writing the
/// insight pick or the Coming soon flag never re-runs it, and it never
/// watches data streams: cards and sections watch their own modules.

@ProviderFor(HomeController)
final homeControllerProvider = HomeControllerProvider._();

/// The one DSH-01 notifier (Constitution II, research R7, R14, R18).
///
/// `build()` watches only the registry and the settings that change what
/// Home lists (`locale`, `enabledModules`, `moduleOrder`). Writing the
/// insight pick or the Coming soon flag never re-runs it, and it never
/// watches data streams: cards and sections watch their own modules.
final class HomeControllerProvider
    extends $NotifierProvider<HomeController, HomeState> {
  /// The one DSH-01 notifier (Constitution II, research R7, R14, R18).
  ///
  /// `build()` watches only the registry and the settings that change what
  /// Home lists (`locale`, `enabledModules`, `moduleOrder`). Writing the
  /// insight pick or the Coming soon flag never re-runs it, and it never
  /// watches data streams: cards and sections watch their own modules.
  HomeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeControllerHash();

  @$internal
  @override
  HomeController create() => HomeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeControllerHash() => r'a241984fe01868a6d5a6438c2f7f416dc9c52744';

/// The one DSH-01 notifier (Constitution II, research R7, R14, R18).
///
/// `build()` watches only the registry and the settings that change what
/// Home lists (`locale`, `enabledModules`, `moduleOrder`). Writing the
/// insight pick or the Coming soon flag never re-runs it, and it never
/// watches data streams: cards and sections watch their own modules.

abstract class _$HomeController extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeState, HomeState>,
              HomeState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
