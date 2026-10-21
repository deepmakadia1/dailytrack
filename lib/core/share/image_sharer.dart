import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:share_plus/share_plus.dart';

part 'image_sharer.g.dart';

/// Shares a PNG through the system share sheet (feature 005 research R12):
/// the milestone streak card and, later, the HAB-03 heatmap. User-initiated
/// only; nothing is uploaded anywhere (Constitution III).
abstract interface class ImageSharer {
  Future<void> sharePng(
    Uint8List png, {
    required String fileName,
    String? text,
  });
}

/// Writes the image to the app's temporary `share/` folder, then opens the
/// share sheet. Platform calls only, so it is covered by the device check.
// coverage:ignore-start
final class SharePlusImageSharer implements ImageSharer {
  const new({this.beforeLeaving});

  /// Called before the share sheet opens (feature 007 research R15).
  final void Function()? beforeLeaving;

  @override
  Future<void> sharePng(
    Uint8List png, {
    required String fileName,
    String? text,
  }) async {
    final dir = Directory('${(await getTemporaryDirectory()).path}/share');
    await dir.create(recursive: true);
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(png, flush: true);
    beforeLeaving?.call();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        text: text,
      ),
    );
  }
}
// coverage:ignore-end

/// Widget tests override this with a recording fake.
@Riverpod(keepAlive: true)
ImageSharer imageSharer(Ref ref) => SharePlusImageSharer(
  beforeLeaving: ref.read(externalActivityGuardProvider).expectExternalActivity,
);
