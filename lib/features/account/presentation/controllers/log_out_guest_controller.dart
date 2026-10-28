import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:dailytrack/core/reset/reset_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'log_out_guest_controller.g.dart';

/// ACC-04 states (feature 011 contracts/screens.md): a fixed dialog, so no
/// loading or empty state.
enum LogOutGuestState {
  ready,

  /// Progress on the confirm button; every action disabled.
  deleting,

  /// The erase failed: nothing was deleted and the user stays a guest.
  error,
}

/// ACC-04 Log out of guest (spec §16).
@riverpod
class LogOutGuestController extends _$LogOutGuestController {
  @override
  LogOutGuestState build() => LogOutGuestState.ready;

  /// "Log out and delete": the guest erase, one transaction that also sets
  /// `authMode = none`, then notifications, jobs, files, and secure storage
  /// (best effort). True when it ran; the router then opens AUTH-01.
  Future<bool> confirm() async {
    if (state == LogOutGuestState.deleting) return false;
    state = LogOutGuestState.deleting;
    try {
      await ref
          .read(appResetServiceProvider)
          .eraseAll(scope: EraseScope.guestLogOut);
      return true;
    } on Object {
      if (ref.mounted) state = LogOutGuestState.error;
      return false;
    }
  }
}
