import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'repeat_settings.freezed.dart';

/// EXP-02's Repeat section (FR-021, data-model.md §4). New rules use an
/// interval of 1 (spec Assumptions).
@freezed
abstract class RepeatSettings with _$RepeatSettings {
  const factory({
    @Default(Frequency.monthly) Frequency frequency,

    /// Last local day an occurrence may fall on (inclusive); null = no end.
    DateTime? endDate,
  }) = _RepeatSettings;

  const new _();

  /// The stored `end_at`: the last moment of [endDate] in local time, so an
  /// occurrence later that day still counts.
  DateTime? get endAt => switch (endDate) {
    final d? => DateTime(
      d.year,
      d.month,
      d.day + 1,
    ).subtract(const Duration(milliseconds: 1)),
    null => null,
  };
}
