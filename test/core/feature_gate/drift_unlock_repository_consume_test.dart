import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/feature_gate/data/drift_unlock_repository.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mutable_clock.dart';

/// One-time export unlocks (feature 008 T088, research R15, Q2).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late MutableClock clock;
  late DriftUnlockRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    clock = MutableClock(DateTime.utc(2026, 10, 21, 9));
    repo = DriftUnlockRepository(db, clock);
  });
  tearDown(() => db.close());

  Future<List<String>> live() async => [
    for (final u in await repo.watchLive().first) u.id,
  ];

  test('uses up the oldest live rewarded unlock for that key only', () async {
    final first = await repo.grant(
      FeatureKey.exportCsv,
      source: UnlockSource.rewardedAd,
    );
    clock.advance(const Duration(minutes: 1));
    final second = await repo.grant(
      FeatureKey.exportCsv,
      source: UnlockSource.rewardedAd,
    );
    final pdf = await repo.grant(
      FeatureKey.exportPdf,
      source: UnlockSource.rewardedAd,
    );
    expect(await repo.consumeOne(FeatureKey.exportCsv), isTrue);
    expect(await live(), unorderedEquals([second.id, pdf.id]));
    expect(first.id, isNot(second.id));
  });

  test('a purchase is never used up', () async {
    await repo.grant(FeatureKey.exportCsv, source: UnlockSource.purchase);
    expect(await repo.consumeOne(FeatureKey.exportCsv), isFalse);
    expect(await live(), hasLength(1));
  });

  test('an expired unlock is not used', () async {
    await repo.grant(
      FeatureKey.exportCsv,
      source: UnlockSource.rewardedAd,
      expiresAt: clock.now().subtract(const Duration(minutes: 1)),
    );
    expect(await repo.consumeOne(FeatureKey.exportCsv), isFalse);
  });

  test('nothing to use: false', () async {
    expect(await repo.consumeOne(FeatureKey.exportPdf), isFalse);
  });
}
