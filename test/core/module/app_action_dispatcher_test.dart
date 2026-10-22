import 'package:dailytrack/core/module/app_action.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

/// AppActionDispatcher (feature 008 T011, research R17).
void main() {
  late FakeTrackerModule a;
  late FakeTrackerModule b;
  late FakeTrackerModule off;
  late ProviderContainer container;

  const action = AppAction(
    source: AppActionSource.notification,
    name: 'x.do',
    params: {'id': '1'},
  );

  setUp(() {
    a = FakeTrackerModule(id: 'a');
    b = FakeTrackerModule(id: 'b');
    off = FakeTrackerModule(id: 'off')..handles = true;
    container = ProviderContainer(
      overrides: [
        moduleRegistryProvider.overrideWithValue(ModuleRegistry([a, b, off])),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(
            initial: const AppSettings(
              enabledModules: ['a', 'b'],
              moduleOrder: ['a', 'b', 'off'],
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<bool> dispatch() => container
      .read(appActionDispatcherProvider)
      .dispatch(action, container.read);

  test('stops at the first visible module that handles it', () async {
    a.handles = true;
    b.handles = true;
    expect(await dispatch(), isTrue);
    expect(a.actions.single.params, {'id': '1'});
    expect(b.actions, isEmpty);
  });

  test('disabled modules are skipped', () async {
    expect(await dispatch(), isFalse);
    expect(off.actions, isEmpty);
  });

  test('a throwing module counts as not handled; later modules still get '
      'it', () async {
    a.handleError = StateError('boom');
    b.handles = true;
    expect(await dispatch(), isTrue);
    expect(b.actions, hasLength(1));
  });

  test('false when no module handles it', () async {
    expect(await dispatch(), isFalse);
    expect((a.actions.length, b.actions.length), (1, 1));
  });
}
