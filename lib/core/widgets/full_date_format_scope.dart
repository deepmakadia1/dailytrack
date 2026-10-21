import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:flutter/widgets.dart';

/// Makes the SET-01 date format available to every widget below the app
/// root, so screens format full dates without passing the setting down
/// (feature 007 research R13). `DailyTrackApp` places it above the router.
class FullDateFormatScope extends InheritedWidget {
  const new({required this.format, required super.child, super.key});

  final FullDateFormat format;

  /// The nearest format, or the default when there is no scope (widget
  /// tests that pump a single widget).
  static FullDateFormat of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<FullDateFormatScope>()
          ?.format ??
      FullDateFormat.dMMMy;

  @override
  bool updateShouldNotify(FullDateFormatScope oldWidget) =>
      format != oldWidget.format;
}
