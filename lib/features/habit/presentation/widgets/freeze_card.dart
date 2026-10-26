import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Most freezes a habit can hold (FR-034).
const int maxFreezes = 2;

/// HAB-03 streak freeze card (US5-7 – US5-9, FR-034 – FR-037): the count,
/// "Use a freeze" on a missed day 1–3 days back, "Watch an ad to get a
/// freeze" (PRM-02, feature 009 FR-034), and the dev-only grant.
class FreezeCard extends StatelessWidget {
  const new({
    required this.freezes,
    required this.freezeableDays,
    required this.showDebugButton,
    required this.onUse,
    required this.onAddDebug,
    required this.onWatchAd,
    this.isPro = false,
    this.onAddPro,
    super.key,
  });

  final int freezes;
  final List<LocalDate> freezeableDays;
  final bool showDebugButton;
  final ValueChanged<LocalDate> onUse;
  final VoidCallback onAddDebug;

  /// Opens PRM-02 for one more freeze; disabled at [maxFreezes].
  final VoidCallback onWatchAd;

  /// Pro: freezes come without an ad, up to the cap (FR-044).
  final bool isPro;
  final VoidCallback? onAddPro;

  Future<void> _pick(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final format = DateFormat.MMMEd(l10n.localeName);
    final day = await AppBottomSheet.show<LocalDate>(
      context,
      title: l10n.habit_useFreeze,
      child: Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final d in freezeableDays)
              ListTile(
                key: ValueKey('freeze_day_${d.key}'),
                leading: const Icon(Icons.ac_unit),
                title: Text(
                  l10n.habit_useFreezeOn(
                    format.format(DateTime(d.year, d.month, d.day)),
                  ),
                ),
                onTap: () => Navigator.of(context).pop(d),
              ),
          ],
        ),
      ),
    );
    if (day != null) onUse(day);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final canUse = freezes > 0 && freezeableDays.isNotEmpty;
    return Card(
      key: const Key('freeze_card'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(tokens.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.ac_unit, color: theme.colorScheme.primary),
                SizedBox(width: tokens.s8),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      l10n.habit_freezeTitle,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: tokens.s8),
            Text(
              l10n.habit_freezesAvailable(freezes),
              key: const Key('freezes_available'),
              style: theme.textTheme.bodyLarge,
            ),
            SizedBox(height: tokens.s4),
            Text(l10n.habit_freezeExplain, style: theme.textTheme.bodySmall),
            if (freezes >= maxFreezes) ...[
              SizedBox(height: tokens.s4),
              Text(
                l10n.habit_freezeCapReached,
                style: theme.textTheme.bodySmall,
              ),
            ],
            if (freezes > 0 && freezeableDays.isEmpty) ...[
              SizedBox(height: tokens.s4),
              Text(
                l10n.habit_noFreezeableDay,
                key: const Key('no_freezeable_day'),
                style: theme.textTheme.bodySmall,
              ),
            ],
            SizedBox(height: tokens.s12),
            Wrap(
              spacing: tokens.s8,
              runSpacing: tokens.s8,
              children: [
                FilledButton.tonalIcon(
                  key: const Key('use_freeze'),
                  onPressed: canUse ? () => _pick(context) : null,
                  icon: const Icon(Icons.ac_unit),
                  label: Text(l10n.habit_useFreeze),
                ),
                if (isPro)
                  OutlinedButton.icon(
                    key: const Key('add_freeze_pro'),
                    onPressed: freezes < maxFreezes ? onAddPro : null,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.habit_addFreezePro),
                  )
                else
                  OutlinedButton.icon(
                    key: const Key('watch_ad_freeze'),
                    onPressed: freezes < maxFreezes ? onWatchAd : null,
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(l10n.locked_watchAdFreeze),
                  ),
                if (showDebugButton)
                  OutlinedButton(
                    key: const Key('add_freeze_debug'),
                    onPressed: freezes < maxFreezes ? onAddDebug : null,
                    child: Text(l10n.habit_addFreezeDebug),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// HAB-03 notes (US5-6): newest first with their dates, or one line.
class NotesList extends StatelessWidget {
  const new({required this.notes, super.key});

  final List<({LocalDate date, String note})> notes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final format = FullDateFormatScope.of(context);
    if (notes.isEmpty) {
      return Text(
        l10n.habit_notesEmpty,
        key: const Key('notes_empty'),
        style: theme.textTheme.bodyMedium,
      );
    }
    return Column(
      children: [
        for (final n in notes)
          ListTile(
            key: ValueKey('note_${n.date.key}'),
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.sticky_note_2_outlined),
            title: Text(n.note),
            subtitle: Text(
              formatFullDate(
                DateTime(n.date.year, n.date.month, n.date.day),
                format,
                l10n.localeName,
              ),
            ),
          ),
      ],
    );
  }
}
