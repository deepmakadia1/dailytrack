import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_status_policy.dart';
import 'package:flutter_test/flutter_test.dart';

/// The ACC-01 state line (feature 010 T055, data-model §7). Precedence:
/// offline > backingUp > paused > failed > waitingForWifi > backedUp.
void main() {
  BackupStatus derive({
    bool online = true,
    bool backingUp = false,
    bool paused = false,
    int failures = 0,
    Object? failure,
    int? lastBackupAt = 1000,
    int? lastBackgroundBackupAt,
    bool wifiOnly = false,
    bool metered = false,
  }) => BackupStatusPolicy.derive(
    online: online,
    backingUp: backingUp,
    paused: paused,
    autoBackupFailures: failures,
    failure: failure,
    lastBackupAt: lastBackupAt,
    lastBackgroundBackupAt: lastBackgroundBackupAt,
    wifiOnly: wifiOnly,
    metered: metered,
  );

  /// Everything that could show at once.
  BackupStatus all({
    bool online = true,
    bool backingUp = true,
    bool paused = true,
    int failures = 1,
  }) => derive(
    online: online,
    backingUp: backingUp,
    paused: paused,
    failures: failures,
    lastBackgroundBackupAt: 2000,
    wifiOnly: true,
    metered: true,
  );

  test('§16 offline wins over everything', () {
    expect(all(online: false), isA<BackupStatusOffline>());
  });

  test('§16 then backing up, then paused, then failed, then waiting for '
      'Wi-Fi', () {
    expect(all(), isA<BackupStatusBackingUp>());
    expect(all(backingUp: false), isA<BackupStatusPaused>());
    expect(all(backingUp: false, paused: false), isA<BackupStatusFailed>());
    expect(
      all(backingUp: false, paused: false, failures: 0),
      isA<BackupStatusWaitingForWifi>(),
    );
  });

  test('§16 a failure seen this session is failed, with its error', () {
    expect(
      derive(failure: const BackupNeedsPassword()),
      isA<BackupStatusFailed>().having(
        (s) => s.error,
        'error',
        isA<BackupNeedsPassword>(),
      ),
    );
  });

  group('§16 waiting for Wi-Fi needs all three', () {
    test('a pending background backup, Wi-Fi only, and a metered network', () {
      expect(
        derive(lastBackgroundBackupAt: 2000, wifiOnly: true, metered: true),
        isA<BackupStatusWaitingForWifi>(),
      );
    });

    test('not metered: backed up', () {
      expect(
        derive(lastBackgroundBackupAt: 2000, wifiOnly: true),
        isA<BackupStatusBackedUp>(),
      );
    });

    test('Wi-Fi only off: backed up', () {
      expect(
        derive(lastBackgroundBackupAt: 2000, metered: true),
        isA<BackupStatusBackedUp>(),
      );
    });

    test('the background request already backed up: backed up', () {
      expect(
        derive(lastBackgroundBackupAt: 900, wifiOnly: true, metered: true),
        isA<BackupStatusBackedUp>(),
      );
    });

    test('no backup yet counts as pending', () {
      expect(
        derive(
          lastBackupAt: null,
          lastBackgroundBackupAt: 1,
          wifiOnly: true,
          metered: true,
        ),
        isA<BackupStatusWaitingForWifi>(),
      );
    });
  });

  test('§16 otherwise backed up, with the last backup time', () {
    expect(
      derive(),
      isA<BackupStatusBackedUp>().having(
        (s) => s.lastBackupAt,
        'lastBackupAt',
        1000,
      ),
    );
  });
}
