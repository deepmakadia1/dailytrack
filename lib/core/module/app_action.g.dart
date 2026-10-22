// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_action.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appActionDispatcher)
final appActionDispatcherProvider = AppActionDispatcherProvider._();

final class AppActionDispatcherProvider
    extends
        $FunctionalProvider<
          AppActionDispatcher,
          AppActionDispatcher,
          AppActionDispatcher
        >
    with $Provider<AppActionDispatcher> {
  AppActionDispatcherProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appActionDispatcherProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appActionDispatcherHash();

  @$internal
  @override
  $ProviderElement<AppActionDispatcher> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppActionDispatcher create(Ref ref) {
    return appActionDispatcher(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppActionDispatcher value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppActionDispatcher>(value),
    );
  }
}

String _$appActionDispatcherHash() =>
    r'3d07caeef3e4e08b680df5de2cca592164560979';
