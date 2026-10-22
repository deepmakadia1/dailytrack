import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'file_sharer.g.dart';

/// Shares a file through the system share sheet (SET-02 "Share", later
/// SET-03 exports). User-initiated only (Constitution III).
abstract interface class FileSharer {
  Future<void> shareFile(String path, {required String mimeType});
}

/// The `share_plus` implementation. Platform channel only, so it is covered
/// by the device check rather than unit tests.
// coverage:ignore-start
final class SharePlusFileSharer implements FileSharer {
  const new({this.beforeLeaving});

  /// Called before the share sheet opens, so the trip out does not lock
  /// the app (feature 007 research R15).
  final void Function()? beforeLeaving;

  @override
  Future<void> shareFile(String path, {required String mimeType}) async {
    beforeLeaving?.call();
    await SharePlus.instance.share(
      ShareParams(files: [XFile(path, mimeType: mimeType)]),
    );
  }
}
// coverage:ignore-end

/// Widget tests override this with a recording fake.
@Riverpod(keepAlive: true)
FileSharer fileSharer(Ref ref) => SharePlusFileSharer(
  beforeLeaving: ref.read(externalActivityGuardProvider).expectExternalActivity,
);
