import 'dart:async';

import 'package:dailytrack/core/l10n/currency_names.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/currency_picker_list.dart';
import 'package:dailytrack/core/widgets/settings_section.dart';
import 'package:dailytrack/features/settings/presentation/controllers/settings_controller.dart';
import 'package:dailytrack/features/settings/presentation/widgets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SET-01 General (FR-002 – FR-005): language, currency, first day of week,
/// and date format. Each row shows its current value and writes at once.
class GeneralSection extends ConsumerWidget {
  const new({required this.settings, super.key});

  final AppSettings settings;

  static String languageName(AppLocalizations l10n, String? code) =>
      switch (code) {
        'en' => l10n.language_en,
        'hi' => l10n.language_hi,
        'gu' => l10n.language_gu,
        _ => l10n.settings_languageSystem,
      };

  static String dayName(AppLocalizations l10n, int day) => switch (day) {
    6 => l10n.settings_saturday,
    7 => l10n.settings_sunday,
    _ => l10n.settings_monday,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(settingsControllerProvider.notifier);
    final today = ref.read(clockProvider).now();
    final format = FullDateFormat.fromStorage(settings.dateFormat);

    Future<void> pickLanguage() async {
      final picked = await showChoiceSheet<String?>(
        context,
        title: l10n.settings_language,
        selected: settings.locale,
        choices: [
          for (final code in <String?>[null, ...supportedLanguageCodes])
            (
              value: code,
              label: languageName(l10n, code),
              key: Key('language_${code ?? 'system'}'),
            ),
        ],
      );
      if (picked != null) await controller.setLocale(picked.value);
    }

    Future<void> pickCurrency() async {
      final picked = await AppBottomSheet.show<String>(
        context,
        title: l10n.settings_currency,
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.7,
          child: Builder(
            builder: (sheet) => CurrencyPickerList(
              selectedCode: settings.currencyCode,
              onSelected: (code) => Navigator.of(sheet).pop(code),
            ),
          ),
        ),
      );
      if (picked != null) await controller.setCurrency(picked);
    }

    Future<void> pickFirstDay() async {
      final picked = await showChoiceSheet<int>(
        context,
        title: l10n.settings_firstDayOfWeek,
        selected: settings.firstDayOfWeek,
        choices: [
          for (final day in firstDayOfWeekOptions)
            (value: day, label: dayName(l10n, day), key: Key('first_day_$day')),
        ],
      );
      if (picked != null) await controller.setFirstDayOfWeek(picked.value);
    }

    Future<void> pickDateFormat() async {
      final picked = await showChoiceSheet<FullDateFormat>(
        context,
        title: l10n.settings_dateFormat,
        selected: format,
        choices: [
          // Each option shows today's date in that format.
          for (final f in FullDateFormat.values)
            (
              value: f,
              label: formatFullDate(today, f, l10n.localeName),
              key: Key('date_format_${f.name}'),
            ),
        ],
      );
      if (picked != null) await controller.setDateFormat(picked.value.name);
    }

    return SettingsSection(
      title: l10n.settings_general,
      children: [
        ListTile(
          key: const Key('settings_language'),
          leading: const Icon(Icons.translate),
          title: Text(l10n.settings_language),
          subtitle: Text(languageName(l10n, settings.locale)),
          onTap: () => unawaited(pickLanguage()),
        ),
        ListTile(
          key: const Key('settings_currency'),
          leading: const Icon(Icons.currency_exchange),
          title: Text(l10n.settings_currency),
          subtitle: Text(currencyName(l10n, settings.currencyCode)),
          trailing: Text(settings.currencyCode),
          onTap: () => unawaited(pickCurrency()),
        ),
        ListTile(
          key: const Key('settings_first_day'),
          leading: const Icon(Icons.calendar_view_week_outlined),
          title: Text(l10n.settings_firstDayOfWeek),
          subtitle: Text(dayName(l10n, settings.firstDayOfWeek)),
          onTap: () => unawaited(pickFirstDay()),
        ),
        ListTile(
          key: const Key('settings_date_format'),
          leading: const Icon(Icons.event_outlined),
          title: Text(l10n.settings_dateFormat),
          subtitle: Text(formatFullDate(today, format, l10n.localeName)),
          onTap: () => unawaited(pickDateFormat()),
        ),
      ],
    );
  }
}
