import 'package:clock/clock.dart';

/// A `package:clock` [Clock] that returns [value] until it is reassigned or
/// [advance]d (research R2 of feature 003). Replaces feature 002's
/// `FixedClock`.
final class MutableClock extends Clock {
  new(this.value);

  /// Local wall-clock time returned by [now].
  DateTime value;

  @override
  DateTime now() => value;

  void advance(Duration by) => value = value.add(by);
}
