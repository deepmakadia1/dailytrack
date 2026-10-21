import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/support/external_launcher.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/features/settings/presentation/controllers/web_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Privacy policy or Terms in an in-app web view (SET-01 Privacy, FR-011,
/// research R14). JavaScript is off; links to other hosts open in the
/// browser. A failed load shows the error state with "Try again".
class WebPageScreen extends ConsumerStatefulWidget {
  const new({required this.page, required this.url, super.key});

  /// [Routes.webPagePrivacy] or [Routes.webPageTerms].
  final String page;
  final Uri url;

  @override
  ConsumerState<WebPageScreen> createState() => _WebPageScreenState();
}

class _WebPageScreenState extends ConsumerState<WebPageScreen> {
  late final WebViewController _web;

  WebPageController get _status =>
      ref.read(webPageControllerProvider(widget.page).notifier);

  @override
  void initState() {
    super.initState();
    _web = WebViewController();
    unawaited(_load());
  }

  Future<void> _load() async {
    await _web.setJavaScriptMode(JavaScriptMode.disabled);
    await _web.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (_) => _status.started(),
        onPageFinished: (_) => _status.finished(),
        onWebResourceError: (error) {
          // Only the page itself failing counts, not a missing image.
          if (error.isForMainFrame ?? true) _status.failed();
        },
        onNavigationRequest: (request) {
          final uri = Uri.tryParse(request.url);
          if (uri == null || uri.host == widget.url.host) {
            return NavigationDecision.navigate;
          }
          unawaited(ref.read(externalLauncherProvider).openUrl(uri));
          return NavigationDecision.prevent;
        },
      ),
    );
    await _web.loadRequest(widget.url);
  }

  void _retry() {
    _status.started();
    unawaited(_web.loadRequest(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(webPageControllerProvider(widget.page));
    return AppScaffold(
      title: widget.page == Routes.webPageTerms
          ? l10n.settings_terms
          : l10n.settings_privacyPolicy,
      padBody: false,
      body: status == WebPageStatus.failed
          ? ErrorState(message: l10n.web_loadError, onRetry: _retry)
          : Column(
              children: [
                if (status == WebPageStatus.loading)
                  const LinearProgressIndicator(key: Key('web_loading')),
                Expanded(child: WebViewWidget(controller: _web)),
              ],
            ),
    );
  }
}
