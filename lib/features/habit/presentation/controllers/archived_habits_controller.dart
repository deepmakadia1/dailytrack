import 'dart:async';

import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'archived_habits_controller.freezed.dart';
part 'archived_habits_controller.g.dart';

/// One HAB-04 row (contracts/screens.md).
@freezed
abstract class ArchivedHabitRow with _$ArchivedHabitRow {
  const factory({
    required Habit habit,
    required DateTime archivedAt,
    required int bestStreak,
    required StreakUnit unit,
  }) = _ArchivedHabitRow;
}

/// HAB-04 Archived habits (T088, FR-033). The screen's only notifier. The
/// best streak comes from a one-shot full history per habit (research R7).
@riverpod
class ArchivedHabitsController extends _$ArchivedHabitsController {
  StreamSubscription<List<Habit>>? _sub;
  var _seq = 0;

  @override
  AsyncValue<List<ArchivedHabitRow>> build() {
    ref
      ..watch(streakEngineProvider)
      ..onDispose(() => unawaited(_sub?.cancel()));
    _sub = ref
        .read(habitRepositoryProvider)
        .watchArchived()
        .listen(
          (habits) => unawaited(_load(habits)),
          onError: (Object e, StackTrace st) {
            if (ref.mounted) state = AsyncError(e, st);
          },
        );
    return const AsyncLoading();
  }

  Future<void> _load(List<Habit> habits) async {
    final seq = ++_seq;
    final engine = ref.read(streakEngineProvider);
    final entries = ref.read(habitEntryRepositoryProvider);
    try {
      final rows = <ArchivedHabitRow>[];
      for (final h in habits) {
        final history = await entries.history(h.id);
        final summary = history == null ? null : engine.summarize(history);
        rows.add(
          ArchivedHabitRow(
            habit: h,
            archivedAt: h.archivedAt ?? h.updatedAt,
            bestStreak: summary?.best ?? 0,
            unit: summary?.unit ?? StreakUnit.days,
          ),
        );
      }
      if (ref.mounted && seq == _seq) state = AsyncData(rows);
    } on Object catch (e, st) {
      if (ref.mounted && seq == _seq) state = AsyncError(e, st);
    }
  }

  /// Restore (US6-2): back at the end of HAB-01, reminders rescheduled.
  /// Returns its Undo (archive again), or null on failure.
  Future<Future<void> Function()?> restore(String id) async {
    final repo = ref.read(habitRepositoryProvider);
    final scheduler = ref.read(habitReminderSchedulerProvider);
    try {
      await repo.restore(id);
    } on Object {
      return null;
    }
    await _bestEffort(() => scheduler.reconcile(id));
    return () async {
      try {
        await repo.archive(id);
      } on Object {
        return;
      }
      await _bestEffort(() => scheduler.cancel(id));
    };
  }

  /// Delete permanently (US6-3), after the screen's confirmation. False on
  /// failure.
  Future<bool> deletePermanently(String id) async {
    try {
      await ref.read(habitRepositoryProvider).delete(id);
    } on Object {
      return false;
    }
    await _bestEffort(
      () => ref.read(habitReminderSchedulerProvider).cancel(id),
    );
    return true;
  }

  void retry() => ref.invalidateSelf();

  static Future<void> _bestEffort(Future<void> Function() body) async {
    try {
      await body();
    } on Object {
      // Reminders are reconciled again on the next app open.
    }
  }
}
