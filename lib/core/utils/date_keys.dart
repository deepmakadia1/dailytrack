import 'package:clock/clock.dart';
import 'package:intl/intl.dart';

/// Local `yyyy-MM-dd` date keys for habit days (Constitution III).
abstract final class DateKeys {
  static final RegExp _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  static String fromLocal(DateTime local) {
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Parses a key into local midnight. Throws [FormatException] if malformed.
  static DateTime parse(String key) {
    final match = _pattern.firstMatch(key);
    if (match == null) throw FormatException('Invalid date key', key);
    final y = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final d = int.parse(match.group(3)!);
    final date = DateTime(y, m, d);
    if (date.month != m || date.day != d) {
      throw FormatException('Invalid date key', key);
    }
    return date;
  }
}

/// UTC epoch-millisecond timestamps (Constitution III).
abstract final class Epoch {
  /// Reads the zone-aware `clock` global (`package:clock`) instead of the
  /// system time directly, so tests can control it with `withClock`.
  static int nowUtcMs() => clock.now().toUtc().millisecondsSinceEpoch;

  static DateTime toLocal(int utcMs) =>
      DateTime.fromMillisecondsSinceEpoch(utcMs, isUtc: true).toLocal();
}

/// Localized words for relative days, passed in from ARB strings so this
/// file stays free of user-facing text.
final class RelativeDayLabels {
  const new({required this.today, required this.yesterday});

  final String today;
  final String yesterday;
}

/// "Today", "Yesterday", or `EEE, d MMM` (spec §15.7).
String relativeDayLabel(
  DateTime local, {
  required DateTime now,
  required RelativeDayLabels labels,
  required String locale,
}) {
  final day = DateTime(local.year, local.month, local.day);
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return labels.today;
  if (diff == 1) return labels.yesterday;
  return DateFormat('EEE, d MMM', locale).format(local);
}
