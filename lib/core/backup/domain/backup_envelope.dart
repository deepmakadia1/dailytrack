import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:dailytrack/core/backup/domain/backup_archive.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';

/// Runs [compute] off the UI thread; tests may pass a direct runner.
typedef EnvelopeRunner = Future<Uint8List> Function(
  FutureOr<Uint8List> Function() compute,
);

/// The encrypted backup form (feature 008 research R3, data-model §4):
///
/// `"DTBK" | 0x01 | uint32 BE header length | header JSON | ciphertext | tag`
///
/// The key is PBKDF2-HMAC-SHA256 of the password; the cipher is AES-256-GCM.
/// The header is the associated data, so a changed header fails like a
/// wrong password. Pure Dart.
final class BackupEnvelope {
  new({
    this.iterations = defaultIterations,
    Random? random,
    EnvelopeRunner? runner,
  }) : _random = random ?? Random.secure(),
       _runner = runner ?? _inIsolate;

  /// OWASP guidance for PBKDF2-HMAC-SHA256.
  static const int defaultIterations = 600000;
  static const int version = 1;
  static const int saltLength = 16;
  static const int nonceLength = 12;
  static const int tagLength = 16;

  /// Larger inputs are refused instead of risking running out of memory.
  static const int maxPlainBytes = 256 * 1024 * 1024;

  static const String _kdf = 'pbkdf2-sha256';

  final int iterations;
  final Random _random;
  final EnvelopeRunner _runner;

  static Future<Uint8List> _inIsolate(FutureOr<Uint8List> Function() compute) =>
      Isolate.run(compute);

  static bool isEncrypted(Uint8List bytes) =>
      detectForm(bytes) == ContainerForm.encrypted;

  static Future<SecretKey> _key(String password, List<int> salt, int iter) =>
      Pbkdf2(
        macAlgorithm: Hmac.sha256(),
        iterations: iter,
        bits: 256,
      ).deriveKeyFromPassword(password: password, nonce: salt);

  List<int> _randomBytes(int n) => [
    for (var i = 0; i < n; i++) _random.nextInt(256),
  ];

  /// Encrypts [inner] (a JSON document or a zip, per [form]).
  Future<Uint8List> seal(
    Uint8List inner, {
    required String password,
    required InnerForm form,
  }) async {
    if (inner.length > maxPlainBytes) throw const BackupTooLargeToEncrypt();
    final salt = _randomBytes(saltLength);
    final nonce = _randomBytes(nonceLength);
    final header = utf8.encode(
      jsonEncode({
        'kdf': _kdf,
        'iter': iterations,
        'salt': base64.encode(salt),
        'nonce': base64.encode(nonce),
        'inner': form.name,
      }),
    );
    final n = iterations;
    return await _runner(() async {
      final box = await AesGcm.with256bits().encrypt(
        inner,
        secretKey: await _key(password, salt, n),
        nonce: nonce,
        aad: header,
      );
      final out = BytesBuilder(copy: false)
        ..add(envelopeMagic)
        ..addByte(version)
        ..add((ByteData(4)..setUint32(0, header.length)).buffer.asUint8List())
        ..add(header)
        ..add(box.cipherText)
        ..add(box.mac.bytes);
      return out.takeBytes();
    });
  }

  /// Decrypts an envelope. Throws [BackupWrongPassword] when it does not
  /// authenticate, and [BackupDamaged] when the layout is broken.
  Future<(Uint8List, InnerForm)> open(
    Uint8List file, {
    required String password,
  }) async {
    final headerStart = envelopeMagic.length + 1 + 4;
    if (!isEncrypted(file) || file.length < headerStart) {
      throw const BackupDamaged('envelope too short');
    }
    if (file[envelopeMagic.length] != version) {
      throw const BackupDamaged('unsupported envelope version');
    }
    final headerLength = ByteData.sublistView(
      file,
      envelopeMagic.length + 1,
      headerStart,
    ).getUint32(0);
    final bodyStart = headerStart + headerLength;
    if (file.length < bodyStart + tagLength) {
      throw const BackupDamaged('envelope truncated');
    }
    final header = Uint8List.sublistView(file, headerStart, bodyStart);
    final (salt, nonce, iter, form) = _parseHeader(header);
    final cipherText = Uint8List.sublistView(
      file,
      bodyStart,
      file.length - tagLength,
    );
    final mac = Mac(Uint8List.sublistView(file, file.length - tagLength));
    final aad = Uint8List.fromList(header);
    final body = Uint8List.fromList(cipherText);
    final plain = await _runner(() async {
      try {
        final clear = await AesGcm.with256bits().decrypt(
          SecretBox(body, nonce: nonce, mac: mac),
          secretKey: await _key(password, salt, iter),
          aad: aad,
        );
        return Uint8List.fromList(clear);
      } on SecretBoxAuthenticationError {
        // Sent back as an empty marker: errors do not cross isolates as types.
        return Uint8List(0);
      }
    });
    if (plain.isEmpty) throw const BackupWrongPassword();
    return (plain, form);
  }

  static (List<int>, List<int>, int, InnerForm) _parseHeader(Uint8List header) {
    try {
      final json = jsonDecode(utf8.decode(header));
      if (json is! Map<String, Object?> || json['kdf'] != _kdf) {
        throw const BackupDamaged('unsupported envelope header');
      }
      final iter = json['iter'];
      final salt = base64.decode(json['salt']! as String);
      final nonce = base64.decode(json['nonce']! as String);
      final form = InnerForm.values.byName(json['inner']! as String);
      if (iter is! int || iter < 1 || nonce.length != nonceLength) {
        throw const BackupDamaged('bad envelope header');
      }
      return (salt, nonce, iter, form);
    } on BackupFailure {
      rethrow;
    } on Object {
      throw const BackupDamaged('bad envelope header');
    }
  }
}
