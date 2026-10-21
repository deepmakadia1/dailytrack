import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/features/habit/domain/usecases/validate_habit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// HAB-01 number entry for count habits (US1-5): a whole value 0–9,999.
/// Returns the value, or null when cancelled.
Future<int?> showValueEntryDialog(
  BuildContext context, {
  required String habitName,
  required int value,
}) => showDialog<int>(
  context: context,
  builder: (context) => _ValueEntryDialog(name: habitName, value: value),
);

class _ValueEntryDialog extends StatefulWidget {
  const new({required this.name, required this.value});

  final String name;
  final int value;

  @override
  State<_ValueEntryDialog> createState() => _ValueEntryDialogState();
}

class _ValueEntryDialogState extends State<_ValueEntryDialog> {
  late final _text = TextEditingController(text: '${widget.value}');
  var _invalid = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final v = int.tryParse(_text.text.trim());
    if (v == null || v < 0 || v > maxHabitTarget) {
      setState(() => _invalid = true);
      return;
    }
    Navigator.of(context).pop(v);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.habit_valueEntryTitle(widget.name)),
      content: TextField(
        key: const Key('value_entry_field'),
        controller: _text,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(5),
        ],
        decoration: InputDecoration(
          helperText: l10n.habit_valueEntryHint,
          errorText: _invalid ? l10n.habit_valueEntryError : null,
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          key: const Key('value_entry_set'),
          onPressed: _submit,
          child: Text(l10n.habit_set),
        ),
      ],
    );
  }
}

/// Longest day note (data-model §3.3).
const int maxDayNoteLength = 200;

/// "Add note for today" (US1-10): the note text, '' to remove it, or null
/// when cancelled.
Future<String?> showNoteDialog(BuildContext context, {String? note}) =>
    showDialog<String>(
      context: context,
      builder: (context) => _NoteDialog(note: note),
    );

class _NoteDialog extends StatefulWidget {
  const new({required this.note});

  final String? note;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _text = TextEditingController(text: widget.note ?? '');

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.habit_noteTitle),
      content: TextField(
        key: const Key('note_field'),
        controller: _text,
        autofocus: true,
        maxLength: maxDayNoteLength,
        maxLines: 3,
        minLines: 1,
        decoration: InputDecoration(hintText: l10n.habit_noteHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          key: const Key('note_save'),
          onPressed: () => Navigator.of(context).pop(_text.text),
          child: Text(l10n.habit_noteSave),
        ),
      ],
    );
  }
}
