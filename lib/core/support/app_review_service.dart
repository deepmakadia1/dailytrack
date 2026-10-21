import 'package:dailytrack/core/security/external_activity_guard.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_review_service.g.dart';

/// SET-01 "Rate us" (feature 007 research R14).
abstract interface class AppReviewService {
  /// Asks for the in-app review sheet, or opens the store page when in-app
  /// review is unavailable. Play limits how often the sheet appears, so a
  /// call may show nothing; that is expected.
  Future<void> rateApp();
}

/// `in_app_review`. Platform calls only, so it is covered by the device
/// check.
// coverage:ignore-start
final class PlayAppReviewService implements AppReviewService {
  const new({this.beforeLeaving});

  /// Called before the review sheet or the store opens (feature 007 R15).
  final void Function()? beforeLeaving;

  @override
  Future<void> rateApp() async {
    final review = InAppReview.instance;
    beforeLeaving?.call();
    try {
      if (await review.isAvailable()) {
        await review.requestReview();
      } else {
        await review.openStoreListing();
      }
    } on Object {
      // No store on this device; nothing else to do.
    }
  }
}
// coverage:ignore-end

/// Widget tests override this with a recording fake.
@Riverpod(keepAlive: true)
AppReviewService appReviewService(Ref ref) => PlayAppReviewService(
  beforeLeaving: ref.read(externalActivityGuardProvider).expectExternalActivity,
);
