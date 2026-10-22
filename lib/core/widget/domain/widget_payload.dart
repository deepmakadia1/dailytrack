import 'dart:convert';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:intl/intl.dart';

/// The `home_widget` key holding the payload.
const String widgetPayloadKey = 'glance.v1';

/// `yyyy-MM-dd` of a local day, as Kotlin compares it with the device date.
String glanceDateKey(DateTime day) =>
    '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';

/// The `glance.v1` JSON (data-model §6, research R20). Every string is
/// localized and formatted here, so Kotlin only displays it, and status is
/// always written out, never shown by color alone (FR-050). [hidden] keeps
/// only "Open DailyTrack" (FR-047).
String encodeWidgetPayload(
  HomeGlance? today,
  HomeGlance? next, {
  required bool hidden,
  required AppLocalizations l10n,
  required String locale,
}) => jsonEncode({
  'v': 1,
  'mode': hidden ? 'hidden' : 'data',
  'openLabel': l10n.widget_open,
  'today': hidden || today == null ? null : _day(today, l10n, locale),
  'next': hidden || next == null ? null : _day(next, l10n, locale),
});

Map<String, Object?> _day(
  HomeGlance glance,
  AppLocalizations l10n,
  String locale,
) {
  final spend = glance.spend;
  return {
    'dateKey': glanceDateKey(glance.date),
    'spend': spend == null ? null : _spend(spend, l10n),
    'budget': spend == null ? null : _budget(spend, l10n, locale),
    'habits': [
      for (final h in glance.habits?.items ?? const <GlanceHabit>[])
        _habit(h, l10n),
    ],
  };
}

Map<String, Object?> _spend(GlanceSpend spend, AppLocalizations l10n) {
  final amount = MoneyFormatter.format(
    spend.todayMinor,
    currencyCode: spend.currencyCode,
  );
  return {
    'label': l10n.widget_spentToday,
    'amount': amount,
    'a11y': l10n.widget_spentTodayA11y(amount),
  };
}

Map<String, Object?> _budget(
  GlanceSpend spend,
  AppLocalizations l10n,
  String locale,
) {
  final budget = spend.budget;
  if (budget == null) return {'none': l10n.widget_noBudget};
  String money(int minor) =>
      MoneyFormatter.format(minor, currencyCode: spend.currencyCode);
  return {
    'label': l10n.widget_monthBudget(
      DateFormat.MMMM(locale).format(spend.monthStart),
    ),
    'percent': budget.percent,
    'text': l10n.widget_budgetText(
      budget.percent,
      money(budget.spentMinor),
      money(budget.limitMinor),
    ),
    'level': budget.level.name,
  };
}

Map<String, Object?> _habit(GlanceHabit h, AppLocalizations l10n) {
  final count = h.kind == GlanceHabitKind.count;
  final unit = h.unit;
  final progress = !count
      ? null
      : unit == null || unit.isEmpty
      ? l10n.widget_progress(h.value, h.target)
      : l10n.widget_progressUnit(h.value, h.target, unit);
  return {
    'id': h.id,
    'name': h.name,
    'kind': h.kind.name,
    'done': h.done,
    'progress': progress,
    'colorHex': h.colorHex,
    'a11y': count
        ? l10n.widget_habitCountA11y(h.name, progress!)
        : h.done
        ? l10n.widget_habitDoneA11y(h.name)
        : l10n.widget_habitTodoA11y(h.name),
  };
}
