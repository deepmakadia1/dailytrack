/// A finished action that may be followed by an interstitial (spec §11,
/// feature 009 research R10). Pure Dart.
sealed class AdTrigger {
  const new();
}

/// A new EXP-02 entry was saved (edits never send this, clarification Q4).
/// [screenClosing] is false for "Save and add another".
final class ExpenseSaved extends AdTrigger {
  const new({required this.screenClosing});

  final bool screenClosing;
}

/// A new habit was saved in HAB-02 (not an edit).
final class HabitCreated extends AdTrigger {
  const new();
}

/// "Save backup file" or Drive "Back up now" succeeded in SET-02.
final class ManualBackupSucceeded extends AdTrigger {
  const new();
}
