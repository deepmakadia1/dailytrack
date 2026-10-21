# Contract: Repository and settings additions (feature 006)

Only additions are listed; existing members are unchanged.

## `SettingsRepository` (`lib/core/settings/domain/settings_repository.dart`)

```dart
/// Stores the Home daily insight pick. Both keys are written in one transaction.
Future<void> setDailyInsight({required String dateKey, required String ruleId});

/// Coming soon card dismissal. Undo writes false.
Future<void> setHomeComingSoonDismissed({required bool dismissed});
```

`watch()` emits after each write, as it already does. `FakeSettingsRepository` (`test/helpers/fakes.dart`)
implements both.

## `TransactionRepository` (`lib/features/expense/domain/repositories/transaction_repository.dart`)

```dart
/// The newest [limit] non-deleted transactions of every type, newest first
/// (occurredAt DESC, createdAt DESC). Re-emits on any transactions,
/// categories or accounts change.
Stream<List<TransactionView>> watchRecent({int limit = 5});
```

Drift implementation in `drift_transaction_repository.dart`, using the `transactions_occurred` index.
Tests run it against a real in-memory database: ordering, the limit, soft-deleted rows excluded,
transfers included.

## Reused as is (no changes)

| Need | Member |
| --- | --- |
| Spent today / this month | `TransactionRepository.watchTodayAndMonthSpend(now)` |
| Overall budget bar | `BudgetRepository.watchOverview(monthKey).overall` |
| Category spend, this month vs last month (insight inputs) | `TransactionRepository.watchBreakdown(query).first` with two `CustomPeriod` ranges (`lib/core/utils/period.dart`) |
| Habits, streaks, this week | `HabitRepository.watchActive()`, `HabitEntryRepository.watchActiveHistories(from:)`, `StreakEngine.summarize`, `StreakEngine.weekProgress` |
| Check-ins | `HabitEntryRepository.apply(habitId, date, op)` (via `HabitDashboardController`) |
