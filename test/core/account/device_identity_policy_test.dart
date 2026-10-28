import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Where this start's device ID came from, and the device name shown in
/// backups (feature 010 research R4, R3, FR-044). Pure.
void main() {
  group('§16 DeviceIdentityPolicy.resolve (the research R4 table)', () {
    test('file and settings copy agree: a normal start', () {
      expect(
        DeviceIdentityPolicy.resolve(fileId: 'a', settingsId: 'a'),
        DeviceIdOrigin.existing,
      );
    });

    test('neither exists: a first start, or an update from before feature '
        '010, never mistaken for an Android restore', () {
      expect(
        DeviceIdentityPolicy.resolve(fileId: null, settingsId: null),
        DeviceIdOrigin.created,
      );
    });

    test('a settings copy without the file: the database came from Android '
        'Auto Backup or device transfer', () {
      expect(
        DeviceIdentityPolicy.resolve(fileId: null, settingsId: 'a'),
        DeviceIdOrigin.restoredFromAndroidBackup,
      );
    });

    test('a file with a different or missing copy: the database was '
        'replaced from elsewhere', () {
      expect(
        DeviceIdentityPolicy.resolve(fileId: 'a', settingsId: 'b'),
        DeviceIdOrigin.restoredFromAndroidBackup,
      );
      expect(
        DeviceIdentityPolicy.resolve(fileId: 'a', settingsId: null),
        DeviceIdOrigin.restoredFromAndroidBackup,
      );
    });
  });

  group('§16 DeviceIdentityPolicy.displayName', () {
    test('joins manufacturer and model', () {
      expect(
        DeviceIdentityPolicy.displayName('Xiaomi', 'Redmi Note 12'),
        'Xiaomi Redmi Note 12',
      );
    });

    test('drops the manufacturer when the model already starts with it', () {
      expect(
        DeviceIdentityPolicy.displayName('Google', 'Google Pixel 7'),
        'Google Pixel 7',
      );
      expect(
        DeviceIdentityPolicy.displayName('samsung', 'Samsung Galaxy A15'),
        'Samsung Galaxy A15',
      );
    });

    test('uses whichever part is known, trimmed', () {
      expect(DeviceIdentityPolicy.displayName('', ' Pixel 7 '), 'Pixel 7');
      expect(DeviceIdentityPolicy.displayName(' OnePlus ', ''), 'OnePlus');
    });

    test('"Android phone" when neither is known', () {
      expect(
        DeviceIdentityPolicy.displayName('', '  '),
        DeviceIdentityPolicy.fallbackName,
      );
      expect(DeviceIdentityPolicy.fallbackName, 'Android phone');
    });

    test('keeps at most 60 characters, counting whole characters', () {
      final name = DeviceIdentityPolicy.displayName('', 'ગ' * 80);
      expect(name.runes, hasLength(DeviceIdentityPolicy.maxNameLength));
    });
  });
}
