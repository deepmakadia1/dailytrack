import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// A [WebViewPlatform] for widget tests (feature 007 T067): records what
/// the app loads and lets a test fire page events. Install it with
/// [FakeWebViewPlatform.install].
class FakeWebViewPlatform extends WebViewPlatform {
  new();

  /// Sets a new fake as the platform for the current test.
  factory install() {
    final platform = FakeWebViewPlatform();
    WebViewPlatform.instance = platform;
    return platform;
  }

  FakeWebViewController? controller;
  FakeNavigationDelegate? delegate;

  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => controller = FakeWebViewController(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => delegate = FakeNavigationDelegate(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => _FakeWebViewWidget(params);
}

class FakeWebViewController extends PlatformWebViewController {
  new(super.params) : super.implementation();

  final List<Uri> loaded = [];
  JavaScriptMode? javaScriptMode;

  @override
  Future<void> loadRequest(LoadRequestParams params) async =>
      loaded.add(params.uri);

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async =>
      this.javaScriptMode = javaScriptMode;

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}
}

class FakeNavigationDelegate extends PlatformNavigationDelegate {
  new(super.params) : super.implementation();

  NavigationRequestCallback? onNavigationRequest;
  PageEventCallback? onPageStarted;
  PageEventCallback? onPageFinished;
  WebResourceErrorCallback? onWebResourceError;

  @override
  Future<void> setOnNavigationRequest(NavigationRequestCallback c) async =>
      onNavigationRequest = c;

  @override
  Future<void> setOnPageStarted(PageEventCallback c) async => onPageStarted = c;

  @override
  Future<void> setOnPageFinished(PageEventCallback c) async =>
      onPageFinished = c;

  @override
  Future<void> setOnWebResourceError(WebResourceErrorCallback c) async =>
      onWebResourceError = c;
}

class _FakeWebViewWidget extends PlatformWebViewWidget {
  new(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) =>
      const SizedBox.expand(key: Key('fake_webview'));
}
