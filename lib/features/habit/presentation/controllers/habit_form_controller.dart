import 'dart:async';

import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_template.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';
import 'package:dailytrack/features/habit/domain/usecases/validate_habit.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_form_state.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/habit/presentation/controllers/habit_form_state.dart';

part 'habit_form_controller.g.dart';

/// HAB-02 Add / edit habit (T057, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id to edit, or null for a new one.
@riverpod
class HabitFormController extends _$HabitFormController {
  /// Icon of a new habit before the user picks one.
  static const String defaultIconKey = 'star';

  /// "Times per week" when the user first switches to it.
  static const int defaultTimesPerWeek = 3;

  @override
  HabitFormState build(String? id) {
    unawaited(_loadHints());
    if (id == null) {
      final draft = HabitDraft(
        name: '',
        iconKey: defaultIconKey,
        colorHex: AppColors.toHex(AppColors.palette[9]),
        kind: HabitKind.yesNo,
        schedule: const HabitSchedule(type: ScheduleType.daily, target: 1),
        startDate: LocalDate.fromDateTime(ref.read(clockProvider).now()),
      );
      return HabitFormState(
        status: HabitFormStatus.ready,
        draft: draft,
        initial: draft,
      );
    }
    unawaited(_load(id));
    return HabitFormState(
      status: HabitFormStatus.loading,
      draft: HabitDraft(
        name: '',
        iconKey: defaultIconKey,
        colorHex: AppColors.toHex(AppColors.palette[9]),
        kind: HabitKind.yesNo,
        schedule: const HabitSchedule(type: ScheduleType.daily, target: 1),
        startDate: LocalDate.fromDateTime(ref.read(clockProvider).now()),
      ),
    );
  }

  Future<void> _load(String id) async {
    try {
      final habit = await ref.read(habitRepositoryProvider).byId(id);
      if (!ref.mounted) return;
      if (habit == null) {
        state = state.copyWith(status: HabitFormStatus.notFound);
        return;
      }
      final draft = HabitDraft(
        name: habit.name,
        iconKey: habit.iconKey,
        colorHex: habit.colorHex,
        kind: habit.kind,
        schedule: habit.schedule,
        startDate: habit.startDate,
        reminderTimes: habit.reminderTimes,
        remindOnlyIfNotDone: habit.remindOnlyIfNotDone,
        unit: habit.unit,
      );
      state = state.copyWith(
        status: HabitFormStatus.ready,
        original: habit,
        draft: draft,
        initial: draft,
      );
    } on Object {
      if (ref.mounted) {
        state = state.copyWith(status: HabitFormStatus.loadError);
      }
    }
  }

  /// Notification permission and exact alarms, for the HAB-02 hints.
  Future<void> _loadHints() async {
    var allowed = true;
    var exact = true;
    try {
      allowed = await ref.read(notificationServiceProvider).canNotify();
    } on Object {
      // Keep the hint hidden when unknown.
    }
    try {
      exact = await ref
          .read(habitReminderSchedulerProvider)
          .exactAlarmsAllowed();
    } on Object {
      // Same.
    }
    if (ref.mounted) {
      state = state.copyWith(
        notificationsAllowed: allowed,
        exactAlarmsAllowed: exact,
      );
    }
  }

  void _set(HabitDraft draft, {List<HabitFieldError> clear = const []}) =>
      state = state.copyWith(
        draft: draft,
        errors: [
          for (final e in state.errors)
            if (!clear.contains(e)) e,
        ],
        saveFailed: false,
      );

  /// Prefills a new habit from [template] once (FR-022). [name] and [unit]
  /// are the localized texts, saved as shown (spec Assumptions).
  void applyTemplate(
    HabitTemplate template, {
    required String name,
    String? unit,
  }) {
    if (state.isEdit) return;
    final draft = state.draft.copyWith(
      name: name,
      iconKey: template.iconKey,
      colorHex: template.colorHex,
      kind: template.kind,
      unit: unit,
      schedule: HabitSchedule(
        type: ScheduleType.daily,
        target: template.target,
      ),
    );
    final first = state.templateId == null && state.draft == state.initial;
    state = state.copyWith(
      draft: draft,
      initial: first ? draft : state.initial,
      templateId: template.id,
      errors: const [],
    );
  }

  void setName(String name) => _set(
    state.draft.copyWith(name: name),
    clear: const [HabitFieldError.nameRequired, HabitFieldError.nameTooLong],
  );

  void setIcon(String key) => _set(state.draft.copyWith(iconKey: key));

  void setColor(String hex) => _set(state.draft.copyWith(colorHex: hex));

  /// Goal type; fixed in edit mode (spec Edge Cases "Goal type").
  void setKind(HabitKind kind) {
    if (state.isEdit) return;
    final count = kind == HabitKind.count;
    _set(
      state.draft.copyWith(
        kind: kind,
        schedule: state.draft.schedule.copyWith(
          target: count ? state.draft.schedule.target : 1,
        ),
      ),
      clear: const [HabitFieldError.targetOutOfRange],
    );
  }

  /// Count target as typed; an unparsable value becomes 0 (an error).
  void setTarget(String text) => _set(
    state.draft.copyWith(
      schedule: state.draft.schedule.copyWith(
        target: int.tryParse(text.trim()) ?? 0,
      ),
    ),
    clear: const [HabitFieldError.targetOutOfRange],
  );

  void setUnit(String unit) => _set(
    state.draft.copyWith(unit: unit),
    clear: const [HabitFieldError.unitTooLong],
  );

  void setScheduleType(ScheduleType type) {
    final s = state.draft.schedule;
    _set(
      state.draft.copyWith(
        schedule: s.copyWith(
          type: type,
          timesPerWeek: type == ScheduleType.timesPerWeek
              ? (s.timesPerWeek ?? defaultTimesPerWeek)
              : s.timesPerWeek,
        ),
      ),
      clear: const [
        HabitFieldError.weekdayRequired,
        HabitFieldError.timesOutOfRange,
      ],
    );
  }

  void setWeekdays(Set<int> weekdays) => _set(
    state.draft.copyWith(
      schedule: state.draft.schedule.copyWith(weekdays: {...weekdays}),
    ),
    clear: const [HabitFieldError.weekdayRequired],
  );

  /// 1–6 (the stepper never goes outside).
  void setTimesPerWeek(int times) => _set(
    state.draft.copyWith(
      schedule: state.draft.schedule.copyWith(timesPerWeek: times.clamp(1, 6)),
    ),
    clear: const [HabitFieldError.timesOutOfRange],
  );

  /// Adds [time]; refused when already there or 3 are set (FR-038).
  void addReminder(ReminderTime time) {
    final times = state.draft.reminderTimes;
    if (times.contains(time)) {
      state = state.copyWith(reminderError: HabitFieldError.duplicateReminder);
      return;
    }
    if (times.length >= maxReminders) {
      state = state.copyWith(reminderError: HabitFieldError.tooManyReminders);
      return;
    }
    _set(state.draft.copyWith(reminderTimes: [...times, time]..sort()));
    state = state.copyWith(reminderError: null);
  }

  void removeReminder(ReminderTime time) {
    _set(
      state.draft.copyWith(
        reminderTimes: [
          for (final t in state.draft.reminderTimes)
            if (t != time) t,
        ],
      ),
    );
    state = state.copyWith(reminderError: null);
  }

  void setRemindOnlyIfNotDone({required bool on}) =>
      _set(state.draft.copyWith(remindOnlyIfNotDone: on));

  void setStartDate(LocalDate date) =>
      _set(state.draft.copyWith(startDate: date));

  /// Validates (FR-025), saves, then reconciles reminders (FR-026,
  /// FR-038). Null when invalid or the write failed.
  Future<Habit?> save() async {
    final errors = validateHabit(state.draft, existing: state.original);
    if (errors.isNotEmpty) {
      state = state.copyWith(errors: errors);
      return null;
    }
    state = state.copyWith(saving: true, saveFailed: false);
    final draft = normalizeHabitDraft(state.draft);
    final repo = ref.read(habitRepositoryProvider);
    try {
      final original = state.original;
      final saved = original == null
          ? await repo.create(draft)
          : await repo.update(original.id, draft);
      await _bestEffort(
        () => ref.read(habitReminderSchedulerProvider).reconcile(saved.id),
      );
      if (ref.mounted) state = state.copyWith(saving: false, initial: draft);
      return saved;
    } on Object {
      if (ref.mounted) state = state.copyWith(saving: false, saveFailed: true);
      return null;
    }
  }

  /// Edit-mode Archive (FR-028): keeps history, cancels reminders. Returns
  /// the Undo, which outlives this screen: it puts the habit back at the
  /// same position with `HabitRepository.undoArchive` and reschedules its
  /// reminders (contracts/screens.md). Null on failure.
  Future<Future<void> Function()?> archive() async {
    final id = state.original?.id;
    if (id == null) return null;
    final repo = ref.read(habitRepositoryProvider);
    final scheduler = ref.read(habitReminderSchedulerProvider);
    try {
      await repo.archive(id);
    } on Object {
      return null;
    }
    await _bestEffort(() => scheduler.cancel(id));
    return () async {
      try {
        await repo.undoArchive(id);
      } on Object {
        return;
      }
      await _bestEffort(() => scheduler.reconcile(id));
    };
  }

  /// Edit-mode Delete after confirmation (FR-028). False on failure.
  Future<bool> delete() async {
    final id = state.original?.id;
    if (id == null) return false;
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
