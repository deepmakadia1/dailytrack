/// How long an app-initiated trip out of the app (camera, share sheet,
/// email) may last before it locks anyway (research R15).
const Duration externalActivityGrace = Duration(minutes: 5);

/// Whether returning to the app at [now] must show SYS-03 (FR-043,
/// feature 007 data-model §3). Pure Dart.
///
/// Locks when the lock is on, the app was backgrounded, and either the
/// clock moved back (fail safe), or the time away reached
/// [lockAfterSeconds] (any time for 0, "Immediately"). A trip the app
/// started itself ([externalActivity]) locks only after
/// [externalActivityGrace].
bool shouldLockOnResume({
  required bool lockEnabled,
  required DateTime? backgroundedAt,
  required DateTime now,
  required int lockAfterSeconds,
  required bool externalActivity,
}) {
  if (!lockEnabled || backgroundedAt == null) return false;
  final away = now.difference(backgroundedAt);
  if (away.isNegative) return true;
  if (externalActivity) return away > externalActivityGrace;
  if (lockAfterSeconds == 0) return true;
  return away >= Duration(seconds: lockAfterSeconds);
}
