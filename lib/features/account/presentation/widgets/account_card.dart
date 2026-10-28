import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/domain/account_card_view.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/features/account/presentation/widgets/guest_sign_in.dart';
import 'package:dailytrack/features/account/presentation/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// SET-01 item 1, the account card (spec §10, feature 011
/// contracts/screens.md), from the plain `accountCardViewProvider`. As a
/// guest: "Guest · Data saved only on this phone" and "Sign in with Google"
/// (guest sign-in); the card itself has no tap. Signed in with Google: the
/// photo or initial, name, email, and the backup status; a tap opens
/// ACC-01. Never says "Synced". Re-reads the network on resume.
class AccountCard extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends ConsumerState<AccountCard> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(accountCardViewProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final view = ref.watch(accountCardViewProvider).value;
    final Widget? body = switch (view) {
      GuestCard(:final offline) => _Guest(offline: offline),
      GoogleCard() => _Google(view: view),
      null => null,
    };
    if (body == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(tokens.s16, tokens.s8, tokens.s16, 0),
      child: Card(
        key: const Key('set01_accountCard'),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: body,
      ),
    );
  }
}

class _Guest extends ConsumerWidget {
  const new({required this.offline});

  final bool offline;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return Padding(
      key: const Key('set01_accountGuest'),
      padding: EdgeInsets.all(tokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CategoryAvatar(
                icon: Icons.person_outline,
                color: theme.colorScheme.primary,
                semanticLabel: l10n.accountCard_guestTitle,
              ),
              SizedBox(width: tokens.s16),
              Expanded(
                child: Text(
                  l10n.accountCard_guestTitle,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          SizedBox(height: tokens.s12),
          FilledButton(
            key: const Key('set01_accountSignIn'),
            onPressed: () => unawaited(runGuestSignIn(context)),
            child: Text(l10n.account_signIn),
          ),
          if (offline) ...[
            SizedBox(height: tokens.s8),
            Text(
              l10n.account_signInOffline,
              key: const Key('set01_accountOffline'),
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _Google extends ConsumerWidget {
  const new({required this.view});

  final GoogleCard view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final profile = view.profile;
    final warning = view.status is CardPaused || view.status is CardFailed;
    final status = switch (view.status) {
      CardBackedUp(:final lastBackupAt) => l10n.accountCard_backedUp(
        _ago(context, lastBackupAt, ref.read(clockProvider).now()),
      ),
      CardNotBackedUpYet() => l10n.backup_notBackedUp,
      CardBackingUp() => l10n.account_statusBackingUp,
      CardPaused() => l10n.accountCard_paused,
      CardFailed() => l10n.account_statusFailed,
    };
    final statusStyle = theme.textTheme.bodySmall?.copyWith(
      color: warning ? tokens.warning : theme.colorScheme.onSurfaceVariant,
    );
    return ListTile(
      key: const Key('set01_accountGoogle'),
      contentPadding: EdgeInsets.all(tokens.s16),
      leading: ProfileAvatar(profile: profile, keyPrefix: 'set01'),
      title: Text(
        profile.displayName ?? profile.email,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (profile.displayName != null) Text(profile.email),
          SizedBox(height: tokens.s4),
          Row(
            key: const Key('set01_accountStatus'),
            children: [
              // Never color alone: paused and failed carry an icon.
              if (warning) ...[
                Icon(
                  Icons.error_outline,
                  size: tokens.chipIconSize,
                  color: tokens.warning,
                  semanticLabel: status,
                ),
                SizedBox(width: tokens.s4),
              ],
              Expanded(child: Text(status, style: statusStyle)),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => unawaited(context.push(Routes.account)),
    );
  }
}

/// The last backup's time, relative to [now] ("5 min ago"); a full date
/// after a week.
String _ago(BuildContext context, int utcMs, DateTime now) {
  final l10n = AppLocalizations.of(context);
  final at = Epoch.toLocal(utcMs);
  final elapsed = now.difference(at);
  if (elapsed.inMinutes < 1) return l10n.accountCard_justNow;
  if (elapsed.inHours < 1) {
    return l10n.accountCard_minutesAgo(elapsed.inMinutes);
  }
  if (elapsed.inDays < 1) return l10n.accountCard_hoursAgo(elapsed.inHours);
  if (elapsed.inDays < 7) return l10n.accountCard_daysAgo(elapsed.inDays);
  return formatFullDate(
    at,
    FullDateFormatScope.of(context),
    Localizations.localeOf(context).toString(),
  );
}
