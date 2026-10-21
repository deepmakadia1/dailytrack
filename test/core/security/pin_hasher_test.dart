import 'dart:convert';

import 'package:dailytrack/core/security/domain/pin_hasher.dart';
import 'package:flutter_test/flutter_test.dart';

/// SYS-03 salted PIN hash (T008, research R3, Constitution III).
void main() {
  // Fast in tests; the production count is checked separately.
  PinHasher fast() =>
      PinHasher(iterations: 1000, runner: (f) async => await f());

  String hex(List<int> bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  test('PBKDF2-HMAC-SHA256 matches the RFC 7914 test vector', () async {
    final key = await PinHasher.derive('password', utf8.encode('salt'), 1);
    expect(
      hex(key),
      '120fb6cffcf8b32c43e7225256c4f837a86548c92ccc35480805987cb70be17b',
    );
  });

  test('the production default is 120,000 iterations', () {
    expect(PinHasher.defaultIterations, 120000);
    expect(PinHasher().iterations, 120000);
  });

  test('two hashes of the same PIN use different salts and hashes', () async {
    final hasher = fast();
    final a = await hasher.hash('1234');
    final b = await hasher.hash('1234');
    expect(a.salt, hasLength(16));
    expect(a.hash, hasLength(32));
    expect(a.salt, isNot(b.salt));
    expect(a.hash, isNot(b.hash));
  });

  test('verify accepts only the PIN that was hashed', () async {
    final hasher = fast();
    final record = await hasher.hash('1234');
    expect(await hasher.verify('1234', record), isTrue);
    for (final wrong in ['1235', '0000', '12345', '']) {
      expect(await hasher.verify(wrong, record), isFalse, reason: wrong);
    }
  });

  test('verify uses the iteration count stored in the record', () async {
    final record = await PinHasher(
      iterations: 1000,
      runner: (f) async => await f(),
    ).hash('4321');
    // A hasher whose default differs still verifies the old record.
    final other = PinHasher(iterations: 2000, runner: (f) async => await f());
    expect(record.iterations, 1000);
    expect(await other.verify('4321', record), isTrue);
  });

  test(
    'a record round-trips through JSON, and never contains the PIN',
    () async {
      final record = await fast().hash('2468');
      final json = record.toJson();
      expect(json['v'], 1);
      expect(json['alg'], 'pbkdf2-sha256');
      expect(json['iter'], 1000);
      expect(jsonEncode(json), isNot(contains('2468')));
      expect(record.toString(), isNot(contains('2468')));
      final back = PinRecord.fromJson(json);
      expect(back.salt, record.salt);
      expect(back.hash, record.hash);
      expect(await fast().verify('2468', back), isTrue);
    },
  );

  test('an unknown record version or algorithm is rejected', () {
    final valid = {
      'v': 1,
      'alg': 'pbkdf2-sha256',
      'iter': 1000,
      'salt': base64.encode(List.filled(16, 1)),
      'hash': base64.encode(List.filled(32, 2)),
    };
    expect(PinRecord.fromJson(valid).iterations, 1000);
    expect(() => PinRecord.fromJson({...valid, 'v': 2}), throwsFormatException);
    expect(
      () => PinRecord.fromJson({...valid, 'alg': 'sha1'}),
      throwsFormatException,
    );
    expect(
      () => PinRecord.fromJson({...valid, 'salt': 42}),
      throwsFormatException,
    );
  });

  test(
    'hashing runs through the injected runner (an isolate in the app)',
    () async {
      var runs = 0;
      final hasher = PinHasher(
        iterations: 1000,
        runner: (f) async {
          runs++;
          return await f();
        },
      );
      final record = await hasher.hash('1111');
      await hasher.verify('1111', record);
      expect(runs, 2);
    },
  );
}
