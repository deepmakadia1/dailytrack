import 'package:dailytrack/core/account/domain/account_card_view.dart';
import 'package:dailytrack/core/backup/domain/backup_status_policy.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

/// The SET-01 account card status (feature 011 T039, data-model §5,
/// clarification Q3). Pure.
void main() {
  final now = DateTime.utc(2026, 10, 28, 12);
  final nowMs = now.millisecondsSinceEpoch;
  const at = 1792540800000;

  CardStatus derive(
    AppSettings s, {
    bool online = true,
    bool metered = false,
  }) => AccountCardPolicy.derive(
    s: s,
    online: online,
    metered: metered,
    now: now,
  );

  test('a last backup → backed up at that time; none → not backed up yet', () {
    expect(
      derive(const AppSettings(lastBackupAt: at)),
      isA<CardBackedUp>().having((c) => c.lastBackupAt, 'at', at),
    );
    expect(derive(const AppSettings()), isA<CardNotBackedUpYet>());
  });

  test('offline keeps the last successful state (clarification Q3)', () {
    expect(
      derive(const AppSettings(lastBackupAt: at), online: false),
      isA<CardBackedUp>(),
    );
    expect(
      derive(const AppSettings(), online: false),
      isA<CardNotBackedUpYet>(),
    );
  });

  test('waiting for Wi-Fi keeps the last successful state', () {
    const waiting = AppSettings(
      lastBackupAt: at,
      lastBackgroundBackupAt: at + 1000,
      autoBackupFrequency: AutoBackupFrequency.daily,
    );
    expect(derive(waiting, metered: true), isA<CardBackedUp>());
  });

  test('a lease later than now → backing up; an expired lease → not', () {
    expect(
      derive(AppSettings(lastBackupAt: at, backupLeaseUntil: nowMs + 1)),
      isA<CardBackingUp>(),
    );
    expect(
      derive(AppSettings(lastBackupAt: at, backupLeaseUntil: nowMs - 1)),
      isA<CardBackedUp>(),
    );
  });

  test('paused and failed pass through', () {
    expect(
      derive(const AppSettings(autoBackupPausedByConflict: true)),
      isA<CardPaused>(),
    );
    expect(derive(const AppSettings(autoBackupFailures: 2)), isA<CardFailed>());
  });

  test('backing up wins over paused and failed, as on ACC-01', () {
    expect(
      derive(
        AppSettings(
          autoBackupPausedByConflict: true,
          autoBackupFailures: 1,
          backupLeaseUntil: nowMs + 1000,
        ),
      ),
      isA<CardBackingUp>(),
    );
  });
}
