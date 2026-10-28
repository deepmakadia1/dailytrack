import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// The account's photo, or its initial in a circle while the photo loads
/// or when there is none. Never waits for the photo (feature 010 research
/// R17). Keys: `<keyPrefix>_photo`, `<keyPrefix>_initial`.
class ProfileAvatar extends StatelessWidget {
  const new({required this.profile, required this.keyPrefix, super.key});

  final AccountProfile profile;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final name = profile.displayName ?? profile.email;
    final initial = Container(
      key: Key('${keyPrefix}_initial'),
      width: tokens.avatarSize,
      height: tokens.avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        name.characters.first.toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
    final url = profile.photoUrl;
    return Semantics(
      label: l10n.account_photoOf(name),
      image: true,
      excludeSemantics: true,
      child: url == null
          ? initial
          : ClipOval(
              child: Image.network(
                url,
                key: Key('${keyPrefix}_photo'),
                width: tokens.avatarSize,
                height: tokens.avatarSize,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : initial,
                errorBuilder: (_, _, _) => initial,
              ),
            ),
    );
  }
}
