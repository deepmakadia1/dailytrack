import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../account/account_test_app.dart';

/// Sign-in from the SET-02 Drive card, the §16 "Guest sign-in" steps
/// (feature 010 T054a, T063a; spec US2, FR-007, FR-009; feature 011 T041
/// in test/features/account/guest_sign_in_test.dart). The
/// success, ACC-02, no-data, cancel, and failure paths are also in
/// backup_screen_test.dart.
void main() {
  final signedOut = guest;

  testWidgets('SET-02 offline, "Sign in with Google" says "Connect to the '
      'internet to sign in with Google" and makes no request', (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: signedOut,
      location: Routes.backup,
      network: FakeNetworkStateSource(online: false),
    );
    await tapKey(tester, 'backup_signIn');
    expect(
      find.text('Connect to the internet to sign in with Google'),
      findsOneWidget,
    );
    expect(world.auth.signIns, 0);
    expect(world.drive.calls, isEmpty);
    expect(world.settings.current.backupAccountEmail, isNull);
  });

  testWidgets('SET-02 a failed first backup leaves the user signed in; auto '
      'backup tries again', (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: signedOut,
      location: Routes.backup,
    );
    world.backup.error = const DriveOffline();
    await tapKey(tester, 'backup_signIn');
    expect(world.settings.current.backupAccountEmail, 'me@example.com');
    expect(world.backup.driveBackups, 0);
    expect(world.scheduler.periodic, isNotEmpty);
  });

  testWidgets('SET-02 signing in to an account with a backup opens ACC-02; '
      'neither choice combines rows', (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: signedOut,
      location: Routes.backup,
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    await tapKey(tester, 'backup_signIn');
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    expect(find.byKey(const Key('acc02_close')), findsNothing);
    await tapKey(tester, 'acc02_keep');
    expect(world.restore.kept, hasLength(1));
    expect(world.restore.applied, isEmpty);
  });
}
