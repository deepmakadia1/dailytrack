import 'dart:async';
import 'dart:typed_data';

import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/share/image_sharer.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/streaks/freeze_policy.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:dailytrack/features/habit/domain/usecases/schedule_text.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_detail_state.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_view_models.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/habit/presentation/controllers/habit_detail_state.dart';

part 'habit_detail_controller.g.dart';

/// File name of the shared heatmap image.
const String heatmapShareFileName = 'heatmap.png';

/// HAB-03 Habit detail (T082, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id. Builds the view model once per
/// history change (research R13).
@riverpod
class HabitDetailController extends _$HabitDetailController {
  /// View models built so far, for the "built once per change" test.
  @visibleForTesting
  static int viewModelBuilds = 0;

  final _subs = <StreamSubscription<Object?>>[];
  Habit? _habit;
  HabitHistory? _history;
  List<HabitEntry>? _notes;
  bool? _unlocked;
  var _gone = false;
  var _showDebug = false;
  HabitHistory? _vmFor;
  HabitDetailViewModel? _vm;

  StreakEngine get _engine => ref.read(streakEngineProvider);

  @override
  HabitDetailState build(String id) {
    ref
      ..watch(streakEngineProvider)
      ..onDispose(() {
        for (final s in _subs) {
          unawaited(s.cancel());
        }
      });
    final debug =
        ref.watch(debugToolsAvailableProvider) &&
        (ref.watch(appSettingsProvider).value?.debugUnlockAll ?? false);
    _showDebug = debug;
    final habits = ref.read(habitRepositoryProvider);
    final entries = ref.read(habitEntryRepositoryProvider);
    _subs.addAll([
      habits.watchById(id).listen((h) {
        _habit = h;
        _gone = h == null || h.isArchived;
        _emit();
      }, onError: _onError),
      entries.watchHistory(id).listen((h) {
        _history = h;
        _emit();
      }, onError: _onError),
      entries.watchNotes(id).listen((n) {
        _notes = n;
        _emit();
      }, onError: _onError),
      ref
          .read(featureGateProvider)
          .watch(FeatureKey.advancedReports)
          .listen(
            (u) {
              _unlocked = u;
              _emit();
            },
            onError: (Object _) {
              _unlocked = false;
              _emit();
            },
          ),
    ]);
    return const HabitDetailState();
  }

  void _onError(Object e, StackTrace st) {
    if (ref.mounted) state = state.copyWith(data: AsyncError(e, st));
  }

  void _emit() {
    if (!ref.mounted) return;
    if (_gone) {
      state = state.copyWith(notFound: true);
      return;
    }
    final habit = _habit;
    final history = _history;
    final notes = _notes;
    final unlocked = _unlocked;
    if (habit == null || history == null || notes == null || unlocked == null) {
      return;
    }
    final engine = _engine;
    if (_vm == null || _vmFor != history) {
      _vm = buildDetailViewModel(engine, history);
      _vmFor = history;
      viewModelBuilds++;
    }
    state = HabitDetailState(
      data: AsyncData(
        HabitDetailData(
          habit: habit,
          summary: engine.summarize(history),
          vm: _vm!,
          schedule: scheduleText(
            habit.schedule,
            doneThisWeek: engine.weekProgress(history, engine.today).done,
            firstDayOfWeek: engine.firstDayOfWeek,
          ),
          notes: notes,
          advancedReportsUnlocked: unlocked,
          showDebugFreezeButton: _showDebug,
          freezeableDays: _freezeable(engine, history),
        ),
      ),
    );
  }

  /// Missed days 1–3 back (FR-035): the freeze card offers these.
  static List<LocalDate> _freezeable(StreakEngine engine, HabitHistory h) {
    final policy = FreezePolicy(engine);
    return [
      for (var back = 1; back <= FreezePolicy.maxDaysBack; back++)
        if (policy.check(
          h,
          engine.today.addDays(-back),
          allowToday: false,
          available: 1,
        ) is FreezeAllowed)
          engine.today.addDays(-back),
    ];
  }

  Future<DayWriteResult?> _write(LocalDate day, DayOp op) async {
    try {
      return await ref.read(habitDayWriterProvider).write(id, day, op);
    } on Object {
      return null;
    }
  }

  /// Calendar day edit (FR-030): a yes/no [done], or a count [value], and
  /// the [note] ('' or null removes it). Returns the value write's result
  /// (which carries any milestone), or the note write's; null on failure.
  Future<DayWriteResult?> editDay(
    LocalDate day, {
    bool? done,
    int? value,
    String? note,
    bool noteChanged = false,
  }) async {
    final habit = _habit;
    if (habit == null) return null;
    DayWriteResult? result;
    final newValue = habit.kind == HabitKind.yesNo
        ? (done == null ? null : (done ? 1 : 0))
        : value;
    if (newValue != null) {
      result = await _write(day, SetValue(newValue));
      if (result == null) return null;
    }
    if (noteChanged) {
      final noteResult = await _write(day, SetNote(note));
      if (noteResult == null) return null;
      result ??= noteResult;
    }
    return result;
  }

  /// Uses a freeze on [day] (FR-035). Null on failure.
  Future<DayWriteResult?> useFreeze(LocalDate day) =>
      _write(day, const UseFreeze(allowToday: false));

  /// Undo of a day write: the day and the freeze count go back.
  Future<DayWriteResult?> undo(EntrySnapshot before) =>
      _write(before.date, Restore(before));

  /// Dev-only grant (FR-037). The new count, or null on failure.
  Future<int?> addDebugFreeze() async {
    if (!_showDebug) return null;
    try {
      return await ref.read(habitRepositoryProvider).addFreeze(id);
    } on Object {
      return null;
    }
  }

  /// A rewarded freeze (PRM-02, feature 009): runs only from the ad's
  /// reward callback. The repository caps freezes at 2.
  Future<void> addRewardedFreeze() async {
    await ref.read(habitRepositoryProvider).addFreeze(id);
  }

  /// Pro adds a freeze without an ad, up to the cap (FR-044).
  Future<void> addProFreeze() async {
    if (!ref.read(proOwnedProvider)) return;
    try {
      await ref.read(habitRepositoryProvider).addFreeze(id);
    } on Object {
      // The card keeps its count; the user can tap again.
    }
  }

  /// Heatmap share (US5-4). False on failure.
  Future<bool> shareHeatmap(Uint8List png) async {
    try {
      await ref
          .read(imageSharerProvider)
          .sharePng(png, fileName: heatmapShareFileName);
      return true;
    } on Object {
      return false;
    }
  }

  void retry() => ref.invalidateSelf();
}
