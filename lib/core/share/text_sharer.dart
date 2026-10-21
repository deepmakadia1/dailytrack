import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'text_sharer.g.dart';

/// Shares plain text through the system share sheet (EXP-03 "Share").
/// User-initiated only; nothing is sent anywhere else (Constitution III).
abstract interface class TextSharer {
  Future<void> shareText(String text, {String? subject});
}

/// The `share_plus` implementation. Platform channel only, so it is covered
/// by the device check rather than unit tests.
// coverage:ignore-start
final class SharePlusTextSharer implements TextSharer {
  const new({this.beforeLeaving});

  /// Called before the share sheet opens, so the trip out does not lock
  /// the app (feature 007 research R15).
  final void Function()? beforeLeaving;

  @override
  Future<void> shareText(String text, {String? subject}) async {
    beforeLeaving?.call();
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}
// coverage:ignore-end

/// Widget tests override this with a recording fake.
@Riverpod(keepAlive: true)
TextSharer textSharer(Ref ref) => SharePlusTextSharer(
  beforeLeaving: ref.read(externalActivityGuardProvider).expectExternalActivity,
);
