import 'package:dailytrack/core/account/account_ui.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/features/account/presentation/widgets/account_card.dart';
import 'package:dailytrack/features/account/presentation/widgets/guest_sign_in.dart';
import 'package:dailytrack/features/account/presentation/widgets/log_out_guest_dialog.dart';
import 'package:dailytrack/features/account/presentation/widgets/restore_choice_sheet.dart';
import 'package:flutter/widgets.dart';

/// The account feature's [AccountUi], bound in `production_overrides.dart`
/// (feature 010 research R18, feature 011 research R11).
final class AccountFeatureUi implements AccountUi {
  const new();

  @override
  Future<RestoreChoiceResult> showRestoreChoice(
    BuildContext context, {
    required DriveBackupEntry newest,
    required bool afterSignIn,
  }) => showRestoreChoiceFor(context, newest: newest, afterSignIn: afterSignIn);

  @override
  Widget accountCard() => const AccountCard();

  @override
  Future<void> startGuestSignIn(BuildContext context) =>
      runGuestSignIn(context);

  @override
  Future<void> showLogOutGuest(BuildContext context) =>
      showLogOutGuestDialog(context);
}
