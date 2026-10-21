import 'package:intl/intl.dart';

/// The default full-date pattern (`FullDateFormat.dMMMy`), usable as a
/// const default value.
const String defaultFullDatePattern = 'd MMM y';

/// The SET-01 "Date format" choices (feature 007 research R13). They apply
/// to full dates only; list headers (`EEE, d MMM`) and "Today"/"Yesterday"
/// never change (clarification Q5). [name] is the stored setting value.
enum FullDateFormat {
  dMMMy(defaultFullDatePattern),
  ddMMy('dd/MM/y'),
  mmddy('MM/dd/y'),
  iso('y-MM-dd');

  new(this.pattern);

  /// The `intl` pattern; `y` is the full year.
  final String pattern;

  /// The format stored as [value]; anything unknown gives [dMMMy].
  static FullDateFormat fromStorage(String value) =>
      values.firstWhere((f) => f.name == value, orElse: () => dMMMy);
}

/// [local] as a full date, e.g. "5 Mar 2026" or "05/03/2026".
String formatFullDate(DateTime local, FullDateFormat format, String locale) =>
    DateFormat(format.pattern, locale).format(local);

/// [local] as a full date followed by the localized time, e.g.
/// "05/03/2026 2:30 PM".
String formatFullDateTime(
  DateTime local,
  FullDateFormat format,
  String locale,
) => DateFormat(format.pattern, locale).add_jm().format(local);
