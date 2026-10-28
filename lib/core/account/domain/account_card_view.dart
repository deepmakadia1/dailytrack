import 'package:dailytrack/core/account/domain/account.dart';

/// What the SET-01 account card shows (spec §10 SET-01 item 1, feature 011
/// data-model §5). Pure Dart (Constitution II).
sealed class AccountCardView {
  const new();
}

/// A guest: "Guest · Data saved only on this phone" and "Sign in with
/// Google", which says "Connect to the internet…" when [offline].
final class GuestCard extends AccountCardView {
  const new({required this.offline});

  final bool offline;
}

/// Signed in with Google.
final class GoogleCard extends AccountCardView {
  const new({required this.profile, required this.status});

  final AccountProfile profile;
  final CardStatus status;
}

/// The card's status line. While a backup waits for Wi-Fi or the phone is
/// offline, the card keeps the last successful state (clarification Q3).
sealed class CardStatus {
  const new();
}

/// "Backed up to Google · {time}".
final class CardBackedUp extends CardStatus {
  const new(this.lastBackupAt);

  /// UTC epoch milliseconds.
  final int lastBackupAt;
}

/// "Not backed up yet".
final class CardNotBackedUpYet extends CardStatus {
  const new();
}

/// "Backing up…".
final class CardBackingUp extends CardStatus {
  const new();
}

/// "Backup paused", in `warning` color with an icon.
final class CardPaused extends CardStatus {
  const new();
}

/// "Backup failed", in `warning` color with an icon.
final class CardFailed extends CardStatus {
  const new();
}
