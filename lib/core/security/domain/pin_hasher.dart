import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

/// Runs the slow key derivation; production uses [Isolate.run] so the
/// keypad never janks, tests run it inline.
typedef HashRunner = Future<List<int>> Function(
  FutureOr<List<int>> Function() compute,
);

/// The stored PIN credential (`lock.pin`, feature 007 data-model §2): a
/// PBKDF2-HMAC-SHA256 hash and its salt. The plain PIN is never kept.
final class PinRecord {
  const new({required this.iterations, required this.salt, required this.hash});

  /// Throws [FormatException] for an unknown version, algorithm, or a
  /// malformed field.
  factory fromJson(Map<String, Object?> json) {
    if (json['v'] != version || json['alg'] != algorithm) {
      throw const FormatException('unsupported PIN record');
    }
    final iter = json['iter'];
    final salt = json['salt'];
    final hash = json['hash'];
    if (iter is! int || iter < 1 || salt is! String || hash is! String) {
      throw const FormatException('malformed PIN record');
    }
    return PinRecord(
      iterations: iter,
      salt: base64.decode(salt),
      hash: base64.decode(hash),
    );
  }

  static const int version = 1;
  static const String algorithm = 'pbkdf2-sha256';

  final int iterations;
  final List<int> salt;
  final List<int> hash;

  Map<String, Object?> toJson() => {
    'v': version,
    'alg': algorithm,
    'iter': iterations,
    'salt': base64.encode(salt),
    'hash': base64.encode(hash),
  };

  @override
  String toString() => 'PinRecord(v$version, $algorithm, $iterations)';
}

/// Salted, slow PIN hashing (SYS-03, Constitution III, research R3).
/// A 4-digit PIN has only 10,000 values, so the real protection is that the
/// record stays in Keystore-backed secure storage, plus the online lockout;
/// the hash keeps the plain PIN off the disk.
final class PinHasher {
  new({this.iterations = defaultIterations, Random? random, HashRunner? runner})
    : _random = random ?? Random.secure(),
      _runner = runner ?? _inIsolate;

  /// About 150–300 ms on a mid-range phone in an isolate (plan SC-002).
  static const int defaultIterations = 120000;
  static const int saltLength = 16;
  static const int hashLength = 32;

  /// Iterations for new hashes; [verify] uses the record's own count.
  final int iterations;
  final Random _random;
  final HashRunner _runner;

  static Future<List<int>> _inIsolate(FutureOr<List<int>> Function() compute) =>
      Isolate.run(compute);

  /// PBKDF2-HMAC-SHA256 of [secret] with [salt], [hashLength] bytes.
  static Future<List<int>> derive(
    String secret,
    List<int> salt,
    int iterations,
  ) async {
    final key = await Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: hashLength * 8,
    ).deriveKeyFromPassword(password: secret, nonce: salt);
    return await key.extractBytes();
  }

  /// A new record with a fresh random salt.
  Future<PinRecord> hash(String pin) async {
    final salt = [for (var i = 0; i < saltLength; i++) _random.nextInt(256)];
    final n = iterations;
    final hash = await _runner(() => derive(pin, salt, n));
    return PinRecord(iterations: n, salt: salt, hash: hash);
  }

  /// Whether [pin] matches [record], compared in constant time.
  Future<bool> verify(String pin, PinRecord record) async {
    final salt = record.salt;
    final n = record.iterations;
    final candidate = await _runner(() => derive(pin, salt, n));
    return _equal(candidate, record.hash);
  }

  static bool _equal(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
