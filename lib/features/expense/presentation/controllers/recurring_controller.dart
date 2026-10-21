import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recurring_controller.freezed.dart';
part 'recurring_controller.g.dart';

/// EXP-10 data (contracts/screens.md): active rules, and paused or ended
/// ones in a separate section.
@freezed
abstract class RecurringData with _$RecurringData {
  const factory({
    @Default(<RecurringRuleView>[]) List<RecurringRuleView> active,
    @Default(<RecurringRuleView>[]) List<RecurringRuleView> paused,
  }) = _RecurringData;

  const new _();

  bool get isEmpty => active.isEmpty && paused.isEmpty;
}

/// EXP-10 Recurring transactions (T080). The screen's only notifier.
@riverpod
class RecurringController extends _$RecurringController {
  @override
  Stream<RecurringData> build() => ref
      .watch(recurringRuleRepositoryProvider)
      .watchAll()
      .map(
        (all) => RecurringData(
          active: [
            for (final v in all)
              if (v.rule.isActive) v,
          ],
          paused: [
            for (final v in all)
              if (!v.rule.isActive) v,
          ],
        ),
      );

  /// Pause or resume (US3 s9, s10). Directly reversible, so no Undo
  /// (FR-048). Returns false when the write failed.
  Future<bool> setPaused(String id, {required bool paused}) async {
    final rules = ref.read(recurringRuleRepositoryProvider);
    try {
      paused ? await rules.pause(id) : await rules.resume(id);
      return true;
    } on Object {
      return false;
    }
  }

  /// Soft delete (US3 s9): generated entries are kept. Returns the Undo, or
  /// null when the write failed.
  Future<Future<void> Function()?> delete(String id) async {
    final rules = ref.read(recurringRuleRepositoryProvider);
    try {
      await rules.softDelete(id);
    } on Object {
      return null;
    }
    return () => rules.undelete(id);
  }

  void retry() => ref.invalidateSelf();
}
