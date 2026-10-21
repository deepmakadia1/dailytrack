import 'package:dailytrack/features/lock/presentation/widgets/lock_texts.dart';
import 'package:dailytrack/features/lock/presentation/widgets/pin_dots.dart';
import 'package:dailytrack/features/lock/presentation/widgets/pin_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

/// PinDots and PinKeypad (T023).
void main() {
  testWidgets('dots say how many digits are entered, never which', (
    tester,
  ) async {
    await tester.pumpWidget(themed(const PinDots(filled: 2)));
    expect(find.bySemanticsLabel('2 of 4 digits entered'), findsOneWidget);
  });

  testWidgets('a shake plays when shakeCount changes, unless animations are '
      'off', (tester) async {
    await tester.pumpWidget(themed(const PinDots(filled: 0)));
    await tester.pumpWidget(themed(const PinDots(filled: 0, shakeCount: 1)));
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();

    await tester.pumpWidget(
      themed(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: PinDots(filled: 0, shakeCount: 1),
        ),
      ),
    );
    await tester.pumpWidget(
      themed(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: PinDots(filled: 0, shakeCount: 2),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    final transform = tester.widget<Transform>(
      find.descendant(
        of: find.byType(PinDots),
        matching: find.byType(Transform),
      ),
    );
    expect(transform.transform.getTranslation().x, 0);
  });

  Future<List<String>> pumpKeypad(
    WidgetTester tester, {
    bool enabled = true,
    bool biometric = true,
  }) async {
    final taps = <String>[];
    await tester.pumpWidget(
      themed(
        PinKeypad(
          enabled: enabled,
          onDigit: taps.add,
          onBackspace: () => taps.add('del'),
          onBiometric: biometric ? () => taps.add('bio') : null,
        ),
      ),
    );
    return taps;
  }

  testWidgets('12 cells: digits, delete, and the biometric key; each at '
      'least 48 dp and labeled; a light haptic per key', (tester) async {
    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          haptics.add(call.arguments as String);
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final taps = await pumpKeypad(tester);
    for (final id in [
      ...List.generate(10, (i) => '$i'),
      'backspace',
      'biometric',
    ]) {
      final key = find.byKey(Key('pin_key_$id'));
      expect(key, findsOneWidget, reason: id);
      expect(tester.getSize(key).height, greaterThanOrEqualTo(48), reason: id);
    }
    expect(find.bySemanticsLabel('Delete'), findsOneWidget);
    expect(find.bySemanticsLabel('Use fingerprint'), findsOneWidget);

    await tester.tap(find.byKey(const Key('pin_key_7')));
    await tester.tap(find.byKey(const Key('pin_key_backspace')));
    await tester.tap(find.byKey(const Key('pin_key_biometric')));
    expect(taps, ['7', 'del', 'bio']);
    expect(haptics, hasLength(3));
  });

  testWidgets('without biometrics the cell is blank', (tester) async {
    await pumpKeypad(tester, biometric: false);
    expect(find.byKey(const Key('pin_key_biometric')), findsNothing);
  });

  testWidgets('disabled: digits and delete ignore taps, the biometric key '
      'still works (Q3)', (tester) async {
    final taps = await pumpKeypad(tester, enabled: false);
    await tester.tap(find.byKey(const Key('pin_key_1')));
    await tester.tap(find.byKey(const Key('pin_key_backspace')));
    await tester.tap(find.byKey(const Key('pin_key_biometric')));
    expect(taps, ['bio']);
  });

  test('the countdown reads m:ss and rounds up', () {
    expect(formatCountdown(const Duration(seconds: 30)), '0:30');
    expect(formatCountdown(const Duration(milliseconds: 29001)), '0:30');
    expect(formatCountdown(const Duration(milliseconds: 500)), '0:01');
    expect(formatCountdown(const Duration(minutes: 15)), '15:00');
  });
}
