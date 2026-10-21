// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_page_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One controller per web page screen. The web view reports page events;
/// the screen shows a progress bar, the page, or the error with "Try
/// again".

@ProviderFor(WebPageController)
final webPageControllerProvider = WebPageControllerFamily._();

/// One controller per web page screen. The web view reports page events;
/// the screen shows a progress bar, the page, or the error with "Try
/// again".
final class WebPageControllerProvider
    extends $NotifierProvider<WebPageController, WebPageStatus> {
  /// One controller per web page screen. The web view reports page events;
  /// the screen shows a progress bar, the page, or the error with "Try
  /// again".
  WebPageControllerProvider._({
    required WebPageControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'webPageControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$webPageControllerHash();

  @override
  String toString() {
    return r'webPageControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WebPageController create() => WebPageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebPageStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebPageStatus>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WebPageControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$webPageControllerHash() => r'1136cccfb362c91668b90f82bd65432eb6472543';

/// One controller per web page screen. The web view reports page events;
/// the screen shows a progress bar, the page, or the error with "Try
/// again".

final class WebPageControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          WebPageController,
          WebPageStatus,
          WebPageStatus,
          WebPageStatus,
          String
        > {
  WebPageControllerFamily._()
    : super(
        retry: null,
        name: r'webPageControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One controller per web page screen. The web view reports page events;
  /// the screen shows a progress bar, the page, or the error with "Try
  /// again".

  WebPageControllerProvider call(String page) =>
      WebPageControllerProvider._(argument: page, from: this);

  @override
  String toString() => r'webPageControllerProvider';
}

/// One controller per web page screen. The web view reports page events;
/// the screen shows a progress bar, the page, or the error with "Try
/// again".

abstract class _$WebPageController extends $Notifier<WebPageStatus> {
  late final _$args = ref.$arg as String;
  String get page => _$args;

  WebPageStatus build(String page);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WebPageStatus, WebPageStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WebPageStatus, WebPageStatus>,
              WebPageStatus,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
