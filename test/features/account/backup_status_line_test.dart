import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_status_policy.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/account/presentation/widgets/backup_status_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

/// The ACC-01 state line texts (feature 010 T061a, data-model §7, FR-008,
/// FR-051): an icon with every state, never color alone, and never "Sync".
void main() {
  const cases = <(BackupStatus, String, bool)>[
    (BackupStatusBackedUp(lastBackupAt: 1), 'Backed up to Google', false),
    (BackupStatusBackingUp(), 'Backing up…', false),
    (
      BackupStatusPaused(),
      'Backup paused: a newer backup from another phone exists',
      true,
    ),
    (BackupStatusWaitingForWifi(), 'Waiting for Wi-Fi', false),
    (
      BackupStatusOffline(),
      "You're offline. Backups resume when you're back online.",
      true,
    ),
    (BackupStatusFailed(), 'Backup failed', true),
    (
      BackupStatusFailed(error: BackupNeedsPassword()),
      'Backup failed: set your backup password in Backup and restore',
      true,
    ),
  ];

  for (final (status, text, warn) in cases) {
    testWidgets('ACC-01 state line: "$text" with an icon', (tester) async {
      await tester.pumpWidget(themed(BackupStatusLine(status: status)));
      expect(find.text(text), findsOneWidget);
      final icon = tester.widget<Icon>(find.byType(Icon));
      final context = tester.element(find.byType(BackupStatusLine));
      final tokens = AppTokens.of(context);
      if (warn) {
        expect(icon.color, tokens.warning);
      } else {
        expect(icon.color, isNot(tokens.warning));
      }
      expect(
        find.textContaining(RegExp('sync', caseSensitive: false)),
        findsNothing,
      );
    });
  }

  testWidgets('ACC-01 a failure seen this session adds its message', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        const BackupStatusLine(
          status: BackupStatusFailed(error: DriveQuotaExceeded()),
        ),
      ),
    );
    expect(find.text('Backup failed'), findsOneWidget);
    expect(find.byKey(const Key('acc01_failureDetail')), findsOneWidget);
  });
}
