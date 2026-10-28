import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// §16 criterion "No account or backup text in the app says "Synced" or
/// "Sync"; status uses "Backed up to Google."" (feature 010 T101a, FR-051),
/// and SET-01 "No text on this screen says "Synced" or "Sync."" for the
/// login, account card, and log-out strings (feature 011 T059).
void main() {
  Map<String, Object?> arb(String lang) =>
      jsonDecode(File('lib/core/l10n/app_$lang.arb').readAsStringSync())
          as Map<String, Object?>;

  // "Sync" as written in each language, transliterated or not.
  final sync = {
    'en': RegExp('sync', caseSensitive: false),
    'hi': RegExp('sync|सिंक', caseSensitive: false),
    'gu': RegExp('sync|સિંક', caseSensitive: false),
  };

  for (final MapEntry(key: lang, value: word) in sync.entries) {
    test('§16 no account, backup, login, account card, or log-out text says '
        '"sync" ($lang)', () {
      const prefixes = [
        'account_',
        'backup_',
        'auth_',
        'accountCard_',
        'logOutGuest_',
        'settings_logOutGuest',
      ];
      final offenders = [
        for (final MapEntry(:key, :value) in arb(lang).entries)
          if (prefixes.any(key.startsWith) &&
              value is String &&
              word.hasMatch(value))
            key,
      ];
      expect(offenders, isEmpty);
    });
  }

  test('§16 the status says "Backed up to Google"', () {
    expect(arb('en')['account_statusBackedUp'], 'Backed up to Google');
    expect(arb('en')['accountCard_backedUp'], 'Backed up to Google · {time}');
  });

  test('no UI string in any language says "sync"', () {
    for (final MapEntry(key: lang, value: word) in sync.entries) {
      final offenders = [
        for (final MapEntry(:key, :value) in arb(lang).entries)
          if (!key.startsWith('@') && value is String && word.hasMatch(value))
            key,
      ];
      expect(offenders, isEmpty, reason: lang);
    }
  });
}
