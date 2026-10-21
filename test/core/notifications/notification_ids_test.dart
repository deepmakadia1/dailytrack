import 'package:dailytrack/core/notifications/notification_ids.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scheduled notifications are replaced and cancelled by id, so these values
/// must never change (feature 005 T002, research R10).
void main() {
  test('ids are pinned', () {
    expect(stableNotificationId('b1:p80'), 1844500286);
    expect(stableNotificationId('habit:h1:0:0'), 1540581298);
    expect(stableNotificationId(''), 0x011c9dc5);
  });

  test('ids are 31-bit and differ for different keys', () {
    final ids = {
      for (var i = 0; i < 1000; i++) stableNotificationId('habit:h$i:0:0'),
    };
    expect(ids, hasLength(1000));
    for (final id in ids) {
      expect(id, inInclusiveRange(0, 0x7fffffff));
    }
  });
}
