/// One day of the home screen widget and the daily summary (feature 008
/// data-model §6, research R19). Pure Dart: modules fill it through
/// `TrackerModule.contributeGlance`; the widget payload and the summary
/// text are built from it.
final class HomeGlance {
  const new({required this.date, this.spend, this.habits});

  /// The local day (midnight).
  final DateTime date;

  /// Null when Expense is disabled.
  final GlanceSpend? spend;

  /// Null when Habit is disabled.
  final GlanceHabits? habits;
}

final class GlanceSpend {
  const new({
    required this.todayMinor,
    required this.currencyCode,
    required this.monthStart,
    this.budget,
  });

  /// Expenses of the day, in minor units.
  final int todayMinor;
  final String currencyCode;

  /// The first day of the day's month, for the budget label.
  final DateTime monthStart;

  /// The month's Overall budget, or null when none is set.
  final GlanceBudget? budget;
}

/// Progress level, matching the app's budget bars (under < 80 ≤ warning ≤
/// 100 < over).
enum GlanceLevel { under, warning, over }

final class GlanceBudget {
  const new({required this.limitMinor, required this.spentMinor});

  final int limitMinor;
  final int spentMinor;

  /// Whole percent of the limit used; may exceed 100.
  int get percent => limitMinor <= 0 ? 100 : spentMinor * 100 ~/ limitMinor;

  GlanceLevel get level {
    // Compared exactly, so 79.9% is still under.
    if (spentMinor * 100 < limitMinor * 80) return GlanceLevel.under;
    if (spentMinor <= limitMinor) return GlanceLevel.warning;
    return GlanceLevel.over;
  }
}

/// The two habit kinds, named in core without importing Habit.
enum GlanceHabitKind { yesNo, count }

final class GlanceHabits {
  const new({required this.scheduled, required this.done, required this.items});

  /// Habits scheduled for the day.
  final int scheduled;

  /// Of those, done.
  final int done;

  /// At most [GlanceBuilder.maxHabits], in the user's order.
  final List<GlanceHabit> items;
}

final class GlanceHabit {
  const new({
    required this.id,
    required this.name,
    required this.kind,
    required this.value,
    required this.target,
    required this.colorHex,
    this.unit,
  });

  final String id;
  final String name;
  final GlanceHabitKind kind;
  final int value;
  final int target;
  final String colorHex;
  final String? unit;

  bool get done => value >= target;
}

/// Collects the modules' parts of one [HomeGlance].
final class GlanceBuilder {
  new(this.date);

  /// Widget habit slots (contracts/android.md).
  static const int maxHabits = 4;

  final DateTime date;
  GlanceHabits? _habits;

  /// Set by Expense.
  GlanceSpend? spend;

  /// Keeps the first [maxHabits] items.
  void setHabits(GlanceHabits habits) => _habits = GlanceHabits(
    scheduled: habits.scheduled,
    done: habits.done,
    items: habits.items.take(maxHabits).toList(growable: false),
  );

  HomeGlance build() => HomeGlance(date: date, spend: spend, habits: _habits);
}
