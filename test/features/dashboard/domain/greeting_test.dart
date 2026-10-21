import 'package:dailytrack/features/dashboard/domain/greeting.dart';
import 'package:flutter_test/flutter_test.dart';

/// DSH-01 greeting by time of day (T012, data-model.md §4).
void main() {
  DateTime at(int h, int m) => DateTime(2026, 10, 20, h, m);

  test('DSH-01 greeting boundaries', () {
    expect(greetingFor(at(4, 59)), Greeting.evening);
    expect(greetingFor(at(5, 0)), Greeting.morning);
    expect(greetingFor(at(11, 59)), Greeting.morning);
    expect(greetingFor(at(12, 0)), Greeting.afternoon);
    expect(greetingFor(at(16, 59)), Greeting.afternoon);
    expect(greetingFor(at(17, 0)), Greeting.evening);
    expect(greetingFor(at(23, 59)), Greeting.evening);
    expect(greetingFor(at(0, 0)), Greeting.evening);
  });

  test('nextGreetingBoundary is the next 05:00, 12:00, or 17:00', () {
    expect(nextGreetingBoundary(at(0, 0)), DateTime(2026, 10, 20, 5));
    expect(nextGreetingBoundary(at(4, 59)), DateTime(2026, 10, 20, 5));
    expect(nextGreetingBoundary(at(5, 0)), DateTime(2026, 10, 20, 12));
    expect(nextGreetingBoundary(at(11, 59)), DateTime(2026, 10, 20, 12));
    expect(nextGreetingBoundary(at(12, 0)), DateTime(2026, 10, 20, 17));
    expect(nextGreetingBoundary(at(17, 0)), DateTime(2026, 10, 21, 5));
    expect(nextGreetingBoundary(at(23, 59)), DateTime(2026, 10, 21, 5));
  });

  test('nextGreetingBoundary crosses month and year ends', () {
    expect(
      nextGreetingBoundary(DateTime(2026, 10, 31, 18)),
      DateTime(2026, 11, 1, 5),
    );
    expect(
      nextGreetingBoundary(DateTime(2026, 12, 31, 22)),
      DateTime(2027, 1, 1, 5),
    );
    expect(
      nextGreetingBoundary(DateTime(2028, 2, 28, 20)),
      DateTime(2028, 2, 29, 5),
    );
  });
}
