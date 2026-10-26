import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/config/app_links.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/share/text_sharer.dart';
import 'package:dailytrack/core/support/app_info_source.dart';
import 'package:dailytrack/core/support/app_review_service.dart';
import 'package:dailytrack/core/support/device_info_source.dart';
import 'package:dailytrack/core/support/external_launcher.dart';
import 'package:dailytrack/core/support/feedback_email.dart';
import 'package:dailytrack/core/widgets/settings_section.dart';
import 'package:dailytrack/features/settings/presentation/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Package name used before `package_info_plus` answers.
const String _fallbackPackage = 'com.midexcode.daily.track.dailytrack';

/// SET-01 Privacy (FR-011): "Ad privacy choices" while the consent SDK
/// requires it (feature 009 FR-014), then the policy and terms in the
/// in-app web view.
class PrivacySection extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final adChoices = ref.watch(privacyOptionsRequiredProvider).value ?? false;
    return SettingsSection(
      title: l10n.settings_privacy,
      children: [
        if (adChoices)
          ListTile(
            key: const Key('ad_privacy_choices'),
            leading: const Icon(Icons.ads_click_outlined),
            title: Text(l10n.privacy_adChoices),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => unawaited(
              ref.read(consentServiceProvider).showPrivacyOptionsForm(),
            ),
          ),
        ListTile(
          key: const Key('settings_privacy_policy'),
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(l10n.settings_privacyPolicy),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => unawaited(
            context.push(Routes.webPagePath(Routes.webPagePrivacy)),
          ),
        ),
        ListTile(
          key: const Key('settings_terms'),
          leading: const Icon(Icons.description_outlined),
          title: Text(l10n.settings_terms),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              unawaited(context.push(Routes.webPagePath(Routes.webPageTerms))),
        ),
      ],
    );
  }
}

/// SET-01 About (FR-012): rate, share, feedback (device facts only, never
/// app data), version, and open-source licenses.
class AboutSection extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final info = ref.watch(appInfoProvider).value;
    final version = info == null
        ? null
        : l10n.settings_appVersionValue(info.version, info.buildNumber);

    Future<void> shareApp() async {
      final url = AppLinks.storeUrl(info?.packageName ?? _fallbackPackage);
      await ref
          .read(textSharerProvider)
          .shareText(l10n.settings_shareAppText(url));
    }

    Future<void> sendFeedback() async {
      final app =
          info ??
          const AppInfo(
            version: '',
            buildNumber: '',
            packageName: _fallbackPackage,
          );
      final device = await ref.read(deviceInfoSourceProvider).load();
      if (!context.mounted) return;
      final mail = buildFeedbackEmail(
        l10n,
        app: app,
        device: device,
        // The phone's language, never the app setting (Constitution III).
        deviceLocale: View.of(context).platformDispatcher.locale,
      );
      final opened = await ref
          .read(externalLauncherProvider)
          .email(
            to: AppLinks.supportEmail,
            subject: mail.subject,
            body: mail.body,
          );
      if (!opened && context.mounted) await _showNoEmailApp(context);
    }

    return SettingsSection(
      title: l10n.settings_about,
      children: [
        ListTile(
          key: const Key('settings_rate'),
          leading: const Icon(Icons.star_outline),
          title: Text(l10n.settings_rateUs),
          onTap: () => unawaited(ref.read(appReviewServiceProvider).rateApp()),
        ),
        ListTile(
          key: const Key('settings_share_app'),
          leading: const Icon(Icons.share_outlined),
          title: Text(l10n.settings_shareApp),
          onTap: () => unawaited(shareApp()),
        ),
        ListTile(
          key: const Key('settings_feedback'),
          leading: const Icon(Icons.mail_outline),
          title: Text(l10n.settings_sendFeedback),
          onTap: () => unawaited(sendFeedback()),
        ),
        ListTile(
          key: const Key('settings_version'),
          leading: const Icon(Icons.info_outline),
          title: Text(l10n.settings_appVersion),
          subtitle: version == null ? null : Text(version),
        ),
        ListTile(
          key: const Key('settings_licenses'),
          leading: const Icon(Icons.article_outlined),
          title: Text(l10n.settings_licenses),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLicensePage(
            context: context,
            applicationName: l10n.appName,
            applicationVersion: version,
          ),
        ),
      ],
    );
  }

  /// No email app (US8-4): show the address with a Copy action.
  static Future<void> _showNoEmailApp(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        content: Text(l10n.settings_noEmailApp(AppLinks.supportEmail)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(),
            child: Text(l10n.settings_close),
          ),
          TextButton(
            key: const Key('settings_copy_email'),
            onPressed: () async {
              await Clipboard.setData(
                const ClipboardData(text: AppLinks.supportEmail),
              );
              if (!dialog.mounted) return;
              Navigator.of(dialog).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.settings_emailCopied)),
              );
            },
            child: Text(l10n.settings_copyEmail),
          ),
        ],
      ),
    );
  }
}
