import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/config/firebase_config.dart';
import 'package:dailytrack/core/support/crash_redaction.dart';
import 'package:flutter_test/flutter_test.dart';

/// Crash reports never carry user data (Constitution III, spec §2): only
/// the error's type leaves the device.
void main() {
  test('a crash report keeps the error type and drops its message', () {
    final redacted = redactError(
      StateError('Lunch at Café Mocha ₹850, habit "Quit smoking"'),
    );
    expect(redacted.type, 'StateError');
    expect('$redacted', 'StateError');
    expect('$redacted', isNot(contains('850')));
    expect('$redacted', isNot(contains('Quit smoking')));
  });

  test('app failures keep their type only', () {
    expect(
      '${redactError(const BackupInvalid('setting note=Rent'))}',
      'BackupInvalid',
    );
  });

  test('without build values Firebase stays off (tests, CI, fresh clones)', () {
    expect(FirebaseConfig.available, isFalse);
    expect(FirebaseConfig.options, isNull);
  });
}
