/// Which erase runs (feature 011 data-model §3).
enum EraseScope {
  /// SET-01 Erase all data, SYS-03 "Forgot PIN?", ACC-03 "Remove data":
  /// this phone's data goes; the sign-in, onboarding, and the device
  /// preferences stay.
  thisPhoneData,

  /// ACC-04 Log out of guest: the guest's data and Backup settings go too,
  /// and `authMode` becomes `none` in the same transaction, so the app
  /// opens AUTH-01. Onboarding and the device preferences stay.
  guestLogOut,
}

/// "Erase all data" (SET-01 Data, SYS-03 "Forgot PIN?", ACC-03 "Remove
/// data", ACC-04 Log out of guest; feature 007 FR-047, FR-048, research
/// R16).
abstract interface class AppResetService {
  /// Deletes every row in one transaction, keeping the settings rows of
  /// [scope] (onboarding and the device preferences always; feature 011
  /// clarification Q1), then (best effort) module files and alarms,
  /// notifications, background jobs, the safety copy, the backup password,
  /// and the app lock, and restarts the app at Home (AUTH-01 after a
  /// sign-out or a guest log-out). Never calls Google. Throws only when the
  /// database step fails, in which case nothing was deleted.
  Future<void> eraseAll({EraseScope scope = EraseScope.thisPhoneData});
}
