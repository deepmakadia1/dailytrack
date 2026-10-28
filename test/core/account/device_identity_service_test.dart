import 'package:dailytrack/core/account/device_identity_service.dart';
import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

/// The device ID in the no-backup file with its copy in `settings`
/// (feature 010 T021, research R4, FR-044, §16 "Two installs never share a
/// `deviceId`").
void main() {
  late FakeDeviceIdFile file;
  late FakeSettingsRepository settings;
  late int made;

  DeviceIdentityService service() => DeviceIdentityService(
    file: file,
    settings: settings,
    info: FakeDeviceInfoSource(),
    newId: () => 'id-${++made}',
  );

  setUp(() {
    file = FakeDeviceIdFile();
    settings = FakeSettingsRepository();
    made = 0;
  });

  test('§16 a first start makes one ID and writes it to the file and the '
      'settings copy', () async {
    expect(await service().ensure(), DeviceIdOrigin.created);
    expect(file.value, 'id-1');
    expect((await settings.load()).deviceId, 'id-1');
  });

  test('§16 a normal start keeps the ID and writes nothing', () async {
    file.value = 'id-0';
    settings = FakeSettingsRepository(
      initial: const AppSettings(deviceId: 'id-0'),
    );
    expect(await service().ensure(), DeviceIdOrigin.existing);
    expect(made, 0);
    expect(settings.calls['setDeviceIdCopy'] ?? 0, 0);
  });

  test('§16 two installs never share a deviceId: a settings copy without '
      'the file (Android restore) gets a new ID in both places', () async {
    settings = FakeSettingsRepository(
      initial: const AppSettings(deviceId: 'other-phone'),
    );
    expect(await service().ensure(), DeviceIdOrigin.restoredFromAndroidBackup);
    expect(file.value, 'id-1');
    expect((await settings.load()).deviceId, 'id-1');
  });

  test('§16 a database replaced from elsewhere: the file wins and the copy '
      'is rewritten from it', () async {
    file.value = 'mine';
    settings = FakeSettingsRepository(
      initial: const AppSettings(deviceId: 'theirs'),
    );
    expect(await service().ensure(), DeviceIdOrigin.restoredFromAndroidBackup);
    expect(made, 0);
    expect((await settings.load()).deviceId, 'mine');
  });

  test(
    'without a no-backup folder the settings copy alone keeps the ID',
    () async {
      file.unavailable = true;
      expect(await service().ensure(), DeviceIdOrigin.created);
      final first = (await settings.load()).deviceId;
      expect(first, 'id-1');

      expect(await service().ensure(), DeviceIdOrigin.existing);
      expect((await settings.load()).deviceId, first);
    },
  );

  test('current() gives the ID and the live device name, running ensure() '
      'when no ID exists yet', () async {
    final identity = await service().current();
    expect(identity.id, 'id-1');
    expect(identity.name, 'Google Pixel 7');
    expect(file.value, 'id-1');
  });

  test('current() reads the settings copy in a background container', () async {
    settings = FakeSettingsRepository(
      initial: const AppSettings(deviceId: 'copied'),
    );
    expect((await service().current()).id, 'copied');
    expect(made, 0);
  });
}
