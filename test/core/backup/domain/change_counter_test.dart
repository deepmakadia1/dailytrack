import 'package:dailytrack/core/backup/domain/change_counter.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Changed since the last backup" (feature 010 T016, research R5,
/// FR-031). Pure.
void main() {
  test('§16 unchanged while the counter equals the backed-up value', () {
    expect(ChangeCounter.changed(current: 0, backedUp: 0), isFalse);
    expect(ChangeCounter.changed(current: 42, backedUp: 42), isFalse);
  });

  test('§16 changed after any write since the backup snapshot', () {
    expect(ChangeCounter.changed(current: 43, backedUp: 42), isTrue);
  });

  test('§16 changed when the counter went down (Erase all data reset it, or '
      'a restore brought an older database), so nothing is skipped', () {
    expect(ChangeCounter.changed(current: 0, backedUp: 42), isTrue);
  });
}
