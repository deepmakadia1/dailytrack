import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/features/habit/domain/entities/day_status.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/usecases/validate_habit.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_view_models.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_calendar.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// What the day edit sheet saved: the new done/value (null = unchanged)
/// and the note (when `noteChanged`).
typedef DayEdit = ({bool? done, int? value, String? note, bool noteChanged});

/// HAB-03 day edit (US5-3, FR-030): toggle (yes/no) or value (count) and
/// the note (≤ 200 characters). Null when dismissed.
Future<DayEdit?> showDayEditSheet(
  BuildContext context, {
  required DayCell cell,
  required HabitKind kind,
}) => AppBottomSheet.show<DayEdit>(
  context,
  title: AppLocalizations.of(context).habit_editDayTitle(
    dayLabel(
      AppLocalizations.of(context),
      cell,
      format: FullDateFormatScope.of(context),
    ),
  ),
  child: _DayEdit(cell: cell, kind: kind),
);

class _DayEdit extends StatefulWidget {
  const new({required this.cell, required this.kind});

  final DayCell cell;
  final HabitKind kind;

  @override
  State<_DayEdit> createState() => _DayEditState();
}

class _DayEditState extends State<_DayEdit> {
  late var _done = widget.cell.status == DayStatus.done;
  late final _value = TextEditingController(text: '${widget.cell.value}');
  late final _note = TextEditingController(text: widget.cell.note ?? '');
  var _invalid = false;

  @override
  void dispose() {
    _value.dispose();
    _note.dispose();
    super.dispose();
  }

  void _save() {
    final yesNo = widget.kind == HabitKind.yesNo;
    int? value;
    if (!yesNo) {
      value = int.tryParse(_value.text.trim());
      if (value == null || value < 0 || value > maxHabitTarget) {
        setState(() => _invalid = true);
        return;
      }
    }
    final note = _note.text.trim();
    final oldNote = widget.cell.note ?? '';
    final wasDone = widget.cell.status == DayStatus.done;
    Navigator.of(context).pop<DayEdit>((
      done: yesNo && _done != wasDone ? _done : null,
      value: !yesNo && value != widget.cell.value ? value : null,
      note: note.isEmpty ? null : note,
      noteChanged: note != oldNote,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.kind == HabitKind.yesNo)
          SwitchListTile(
            key: const Key('day_done'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.habit_dayDoneToggle),
            value: _done,
            onChanged: (v) => setState(() => _done = v),
          )
        else
          TextField(
            key: const Key('day_value'),
            controller: _value,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(5),
            ],
            decoration: InputDecoration(
              labelText: l10n.habit_dayValueLabel,
              helperText: l10n.habit_valueEntryHint,
              errorText: _invalid ? l10n.habit_valueEntryError : null,
            ),
          ),
        SizedBox(height: tokens.s12),
        TextField(
          key: const Key('day_note'),
          controller: _note,
          maxLength: maxDayNoteLength,
          maxLines: 3,
          minLines: 1,
          decoration: InputDecoration(
            labelText: l10n.habit_noteTitle,
            hintText: l10n.habit_noteHint,
          ),
        ),
        SizedBox(height: tokens.s12),
        FilledButton(
          key: const Key('day_save'),
          onPressed: _save,
          child: Text(l10n.habit_daySave),
        ),
        SizedBox(height: tokens.s8),
      ],
    );
  }
}
