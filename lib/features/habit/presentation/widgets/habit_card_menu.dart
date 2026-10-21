import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habits_today_state.dart';
import 'package:flutter/material.dart';

/// What the HAB-01 long-press menu chose.
enum HabitCardAction { edit, addNote, skipToday, archive }

/// HAB-01 long-press menu (US1-10, FR-020): Edit, Add note, Skip today
/// (disabled with "No freezes left" without freezes, FR-036), Archive.
/// Skip today is shown only when today is scheduled and not done.
Future<HabitCardAction?> showHabitCardMenu(
  BuildContext context, {
  required HabitCardData card,
  required bool selectedIsToday,
}) {
  final l10n = AppLocalizations.of(context);
  final freezes = card.habit.freezesAvailable;
  return AppBottomSheet.show<HabitCardAction>(
    context,
    title: card.habit.name,
    child: Builder(
      builder: (context) {
        void pick(HabitCardAction a) => Navigator.of(context).pop(a);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('menu_edit'),
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.habit_menuEdit),
              onTap: () => pick(HabitCardAction.edit),
            ),
            ListTile(
              key: const Key('menu_add_note'),
              leading: const Icon(Icons.sticky_note_2_outlined),
              title: Text(
                selectedIsToday
                    ? l10n.habit_menuAddNote
                    : l10n.habit_menuAddNoteDay,
              ),
              onTap: () => pick(HabitCardAction.addNote),
            ),
            if (card.canSkipToday)
              ListTile(
                key: const Key('menu_skip_today'),
                leading: const Icon(Icons.ac_unit),
                enabled: freezes > 0,
                title: Text(l10n.habit_menuSkipToday),
                subtitle: Text(
                  freezes > 0
                      ? l10n.habit_skipTodayHint(freezes)
                      : l10n.habit_noFreezesLeft,
                ),
                onTap: () => pick(HabitCardAction.skipToday),
              ),
            ListTile(
              key: const Key('menu_archive'),
              leading: const Icon(Icons.archive_outlined),
              title: Text(l10n.habit_menuArchive),
              onTap: () => pick(HabitCardAction.archive),
            ),
          ],
        );
      },
    ),
  );
}
