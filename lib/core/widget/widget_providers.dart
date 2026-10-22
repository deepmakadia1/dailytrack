import 'package:dailytrack/core/widget/domain/home_widget_bridge.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'widget_providers.g.dart';

/// The home screen widget host (feature 008 research R20).
/// `production_overrides.dart` binds `HomeWidgetPluginBridge`; without a
/// binding (widget tests) nothing is shown or launched.
@Riverpod(keepAlive: true)
HomeWidgetBridge homeWidgetBridge(Ref ref) => const NoHomeWidgetBridge();

/// A host with no widget.
final class NoHomeWidgetBridge implements HomeWidgetBridge {
  const new();

  @override
  Future<void> save(String payloadJson) async {}

  @override
  Future<void> armMidnight() async {}

  @override
  Future<String?> launchLocation() async => null;

  @override
  Stream<String> get launches => const Stream.empty();

  @override
  Future<void> registerBackgroundCallback(
    Future<void> Function(Uri? uri) callback,
  ) async {}
}
