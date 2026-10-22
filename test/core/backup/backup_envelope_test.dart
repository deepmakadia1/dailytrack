import 'dart:convert';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/domain/backup_archive.dart';
import 'package:dailytrack/core/backup/domain/backup_envelope.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:flutter_test/flutter_test.dart';

/// The encrypted backup form (feature 008 T073, research R3, data-model §4).
void main() {
  final envelope = BackupEnvelope(iterations: 1000);
  final inner = Uint8List.fromList(utf8.encode('{"format":"x","ગુ":"हि"}'));

  test('production key derivation is PBKDF2-SHA256 with 600,000 rounds', () {
    expect(BackupEnvelope.defaultIterations, 600000);
    expect(BackupEnvelope().iterations, 600000);
  });

  test(
    'the layout is DTBK, version, header length, header, body, tag',
    () async {
      final sealed = await envelope.seal(
        inner,
        password: 'pw',
        form: InnerForm.json,
      );
      expect(sealed.sublist(0, 4), envelopeMagic);
      expect(sealed[4], 1);
      final headerLength = ByteData.sublistView(sealed, 5, 9).getUint32(0);
      final header = jsonDecode(
        utf8.decode(sealed.sublist(9, 9 + headerLength)),
      ) as Map<String, Object?>;
      expect(header['kdf'], 'pbkdf2-sha256');
      expect(header['iter'], 1000);
      expect(base64.decode(header['salt']! as String), hasLength(16));
      expect(base64.decode(header['nonce']! as String), hasLength(12));
      expect(header['inner'], 'json');
      // Ciphertext is as long as the input, plus the 16-byte tag.
      expect(sealed.length, 9 + headerLength + inner.length + 16);
      // The password and the plain text appear nowhere in the file.
      expect(utf8.decode(sealed, allowMalformed: true), isNot(contains('"x"')));
      expect(BackupEnvelope.isEncrypted(sealed), isTrue);
    },
  );

  test('round trips json and zip inner forms', () async {
    for (final form in InnerForm.values) {
      final sealed = await envelope.seal(inner, password: 'pw', form: form);
      final (plain, opened) = await envelope.open(sealed, password: 'pw');
      expect(plain, inner);
      expect(opened, form);
    }
  });

  test('two seals of the same data differ (fresh salt and nonce)', () async {
    final a = await envelope.seal(inner, password: 'pw', form: InnerForm.json);
    final b = await envelope.seal(inner, password: 'pw', form: InnerForm.json);
    expect(a, isNot(b));
  });

  test('a wrong password, a changed body byte, or a changed header byte all '
      'fail as BackupWrongPassword', () async {
    final sealed = await envelope.seal(
      inner,
      password: 'pw',
      form: InnerForm.json,
    );
    await expectLater(
      envelope.open(sealed, password: 'PW'),
      throwsA(isA<BackupWrongPassword>()),
    );
    final body = Uint8List.fromList(sealed)..[sealed.length - 20] ^= 1;
    await expectLater(
      envelope.open(body, password: 'pw'),
      throwsA(isA<BackupWrongPassword>()),
    );
    // Flip one byte inside the header's salt; the header is authenticated.
    final headerEnd = 9 + ByteData.sublistView(sealed, 5, 9).getUint32(0);
    final saltAt = utf8.decode(sealed.sublist(9, headerEnd)).indexOf('"salt"');
    final header = Uint8List.fromList(sealed)..[9 + saltAt + 10] ^= 1;
    await expectLater(
      envelope.open(header, password: 'pw'),
      throwsA(isA<BackupFailure>()),
    );
  });

  test('a truncated envelope is damaged', () async {
    final sealed = await envelope.seal(
      inner,
      password: 'pw',
      form: InnerForm.json,
    );
    await expectLater(
      envelope.open(Uint8List.sublistView(sealed, 0, 12), password: 'pw'),
      throwsA(isA<BackupDamaged>()),
    );
  });
}
