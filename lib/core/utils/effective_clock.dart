/// The later of [clockNow] and the latest time the app has ever seen
/// (`latestSeenAt`, UTC epoch milliseconds), in UTC. Moving the device clock
/// back therefore never revives an expired unlock or resets an ad cap
/// (feature 009 research R9, R12). Pure Dart.
DateTime effectiveNow(DateTime clockNow, int? latestSeenAtMs) {
  final now = clockNow.toUtc();
  if (latestSeenAtMs == null) return now;
  final seen = DateTime.fromMillisecondsSinceEpoch(latestSeenAtMs, isUtc: true);
  return seen.isAfter(now) ? seen : now;
}
