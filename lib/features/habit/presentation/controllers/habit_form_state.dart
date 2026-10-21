import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_form_state.freezed.dart';

enum HabitFormStatus { loading, ready, notFound, loadError }

/// HAB-02 state (contracts/screens.md). [initial] is the draft as loaded
/// (or as prefilled from a template), so [dirty] means "has unsaved
/// changes" for the discard guard (US1-13).
@freezed
abstract class HabitFormState with _$HabitFormState {
  const factory({
    required HabitFormStatus status,
    required HabitDraft draft,
    HabitDraft? initial,

    /// The habit being edited; null for a new one.
    Habit? original,
    @Default(<HabitFieldError>[]) List<HabitFieldError> errors,
    @Default(false) bool saving,
    @Default(false) bool saveFailed,

    /// Hints (US4-7, FR-041).
    @Default(true) bool notificationsAllowed,
    @Default(true) bool exactAlarmsAllowed,

    /// Why the last "Add reminder" was refused, if it was.
    HabitFieldError? reminderError,

    /// The template applied, so it is applied only once.
    String? templateId,
  }) = _HabitFormState;

  const new _();

  bool get isEdit => original != null;

  bool get dirty => initial != null && draft != initial;

  bool hasError(HabitFieldError e) => errors.contains(e);
}
