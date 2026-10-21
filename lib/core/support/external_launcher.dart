import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'external_launcher.g.dart';

/// Opens other apps on the user's request: email, the browser, and the
/// system notification settings (SET-01, feature 007 research R14, R17).
/// Each method returns false when nothing could handle the request.
abstract interface class ExternalLauncher {
  Future<bool> email({
    required String to,
    required String subject,
    required String body,
  });

  Future<bool> openUrl(Uri uri);

  Future<bool> openNotificationSettings();
}

/// `url_launcher`. Platform calls only, so it is covered by the device
/// check.
// coverage:ignore-start
final class UrlLauncherExternalLauncher implements ExternalLauncher {
  const new({this.beforeLeaving});

  /// Called before another app opens, so the trip out does not lock the
  /// app (feature 007 research R15).
  final void Function()? beforeLeaving;

  @override
  Future<bool> email({
    required String to,
    required String subject,
    required String body,
  }) => _launch(
    // Built by hand: Uri's queryParameters encodes spaces as "+", which
    // email apps show literally.
    Uri.parse(
      'mailto:$to?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    ),
  );

  @override
  Future<bool> openUrl(Uri uri) => _launch(uri);

  /// Android has no URL for it, so `MainActivity` opens the screen.
  @override
  Future<bool> openNotificationSettings() async {
    beforeLeaving?.call();
    try {
      return await const MethodChannel('dailytrack/window')
              .invokeMethod<bool>('openNotificationSettings') ??
          false;
    } on Object {
      return false;
    }
  }

  Future<bool> _launch(Uri uri) async {
    beforeLeaving?.call();
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on Object {
      return false;
    }
  }
}
// coverage:ignore-end

/// Widget tests override this with a recording fake.
@Riverpod(keepAlive: true)
ExternalLauncher externalLauncher(Ref ref) => UrlLauncherExternalLauncher(
  beforeLeaving: ref.read(externalActivityGuardProvider).expectExternalActivity,
);
