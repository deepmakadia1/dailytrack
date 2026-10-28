import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/backup/presentation/backup_device_name.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Device names on backups (feature 010 spec Assumptions: "when
/// unavailable, 'Android phone' is shown").
void main() {
  test('§16 a phone without a model shows "Android phone" in the user '
      'language; other names are shown as stored', () {
    final en = lookupAppLocalizations(const Locale('en'));
    final hi = lookupAppLocalizations(const Locale('hi'));
    const stored = DeviceIdentityPolicy.fallbackName;
    expect(backupDeviceName(en, stored), 'Android phone');
    expect(backupDeviceName(hi, stored), hi.account_androidPhone);
    expect(backupDeviceName(hi, 'Google Pixel 7'), 'Google Pixel 7');
  });
}
