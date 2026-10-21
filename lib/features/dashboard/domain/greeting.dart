// DSH-01 greeting by time of day (feature 006 data-model.md §4). Pure Dart.

enum Greeting { morning, afternoon, evening }

/// 05:00–11:59 morning, 12:00–16:59 afternoon, otherwise evening.
Greeting greetingFor(DateTime local) => switch (local.hour) {
  >= 5 && < 12 => Greeting.morning,
  >= 12 && < 17 => Greeting.afternoon,
  _ => Greeting.evening,
};

/// Hours at which [greetingFor] changes.
const List<int> _boundaryHours = [5, 12, 17];

/// The next local moment the greeting changes: today's next 05:00, 12:00,
/// or 17:00, else tomorrow's 05:00. Built from calendar fields, so month and
/// year ends roll over correctly.
DateTime nextGreetingBoundary(DateTime local) {
  for (final h in _boundaryHours) {
    final b = DateTime(local.year, local.month, local.day, h);
    if (b.isAfter(local)) return b;
  }
  return DateTime(local.year, local.month, local.day + 1, _boundaryHours.first);
}
