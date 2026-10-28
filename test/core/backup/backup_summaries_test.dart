import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/core/backup/presentation/backup_summaries.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Count labels from each module's backup section (feature 010 FR-042,
/// §16 "`counts` are shown in plain words using ARB plurals ("1,240
/// transactions · 8 habits"). Each module provides the labels for its own
/// counts through `TrackerModule.backupSection()`.").
void main() {
  final registry = ModuleRegistry(registeredModules);
  final en = lookupAppLocalizations(const Locale('en'));

  test('§16 metadata counts read as one line in plain words, in registry '
      'order', () {
    expect(
      backupCountsLine(registry, en, const {
        'habit.habits': 8,
        'expense.transactions': 1240,
        'expense.accounts': 3,
      }),
      '1,240 transactions · 8 habits',
    );
  });

  test('§16 each module labels only its own counts, with plurals', () {
    expect(
      backupCountsLine(registry, en, const {
        'expense.transactions': 1,
        'habit.habits': 0,
      }),
      '1 transaction · No habits',
    );
  });

  test('FR-043 modules missing from the counts are left out, and no counts '
      'give an empty line', () {
    expect(
      backupCountsLine(registry, en, const {'habit.habits': 2}),
      '2 habits',
    );
    expect(backupCountsLine(registry, en, const {}), isEmpty);
  });

  test("§16 counts of a module this install doesn't have are ignored", () {
    expect(
      backupCountsLine(registry, en, const {
        'water.glasses': 9,
        'expense.transactions': 2,
      }),
      '2 transactions',
    );
  });

  test('§16 the labels are translated (Hindi and Gujarati)', () {
    for (final lang in ['hi', 'gu']) {
      final l10n = lookupAppLocalizations(Locale(lang));
      final line = backupCountsLine(registry, l10n, const {
        'expense.transactions': 3,
        'habit.habits': 2,
      });
      expect(line, isNot(contains('transactions')), reason: lang);
      expect(line, contains(' · '), reason: lang);
    }
  });
}
