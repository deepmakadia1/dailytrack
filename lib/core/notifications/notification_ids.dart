/// A stable 31-bit id for [key] (FNV-1a), so the same key always maps to
/// the same notification across runs and isolates. Shared by budget alerts
/// and habit reminders (feature 005 research R10); never change the hash,
/// or scheduled notifications could no longer be replaced or cancelled.
int stableNotificationId(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}
