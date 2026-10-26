/// "Changed since the last backup" (feature 010 research R5). SQLite
/// triggers raise `dataChangeCounter` on every write to a backed-up table
/// or restorable setting; a successful backup stores the value it read
/// inside its own snapshot as `backedUpChangeCounter`. Pure.
abstract final class ChangeCounter {
  static bool changed({required int current, required int backedUp}) =>
      current != backedUp;
}
