import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/config/app_links.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'web_page_controller.g.dart';

/// Loading state of the in-app web view (SET-01 Privacy, FR-011).
enum WebPageStatus { loading, loaded, failed }

/// The policy or terms URL for a `/more/web/:page` value, or null for an
/// unknown page.
Uri? webPageUrl(String page) => switch (page) {
  Routes.webPagePrivacy => Uri.parse(AppLinks.privacyPolicyUrl),
  Routes.webPageTerms => Uri.parse(AppLinks.termsUrl),
  _ => null,
};

/// One controller per web page screen. The web view reports page events;
/// the screen shows a progress bar, the page, or the error with "Try
/// again".
@riverpod
class WebPageController extends _$WebPageController {
  @override
  WebPageStatus build(String page) => WebPageStatus.loading;

  void started() => state = WebPageStatus.loading;

  void finished() {
    // A failed load also reports "finished"; keep the error showing.
    if (state != WebPageStatus.failed) state = WebPageStatus.loaded;
  }

  void failed() => state = WebPageStatus.failed;
}
