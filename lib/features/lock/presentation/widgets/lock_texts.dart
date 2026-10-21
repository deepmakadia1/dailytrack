/// A lockout countdown as `m:ss`, e.g. "0:28", "14:59". Rounds up, so the
/// last second still shows "0:01".
String formatCountdown(Duration remaining) {
  final seconds = (remaining.inMilliseconds / 1000).ceil();
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}
