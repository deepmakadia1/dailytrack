import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:dailytrack/core/billing/pro_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

/// Purchase, acknowledgement, restore, and the start-up check (feature 009
/// T082, spec PRM-01, FR-039 – FR-042).
void main() {
  late FakeProStore store;
  late FakeSettingsRepository settings;
  late ProService service;
  late int externalCalls;

  setUp(() {
    store = FakeProStore();
    settings = FakeSettingsRepository();
    externalCalls = 0;
    service = ProService(
      store: store,
      settings: settings,
      beforeExternal: () => externalCalls++,
    );
  });
  tearDown(() => service.dispose());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('start() listens once, before any other call', () {
    service
      ..start()
      ..start();
    expect(store.listens, 1);
    expect(store.ownershipQueries, 0);
  });

  test('FR-039 a purchase grants Pro and acknowledges it', () async {
    final events = <PurchaseEvent>[];
    service
      ..start()
      ..events.listen(events.add);
    store.emit(StorePurchaseStatus.purchased, needsCompletion: true);
    await settle();
    await settle();
    expect(settings.current.removeAdsPurchased, isTrue);
    expect(store.completed, hasLength(1));
    expect(events, [PurchaseEvent.purchased]);
  });

  test('US3-5 a pending payment marks it pending; completing later grants '
      'Pro', () async {
    service.start();
    store.emit(StorePurchaseStatus.pending);
    await settle();
    expect(settings.current.proPurchasePending, isTrue);
    expect(settings.current.removeAdsPurchased, isFalse);
    store.emit(StorePurchaseStatus.purchased, needsCompletion: true);
    await settle();
    expect(settings.current.removeAdsPurchased, isTrue);
    expect(settings.current.proPurchasePending, isFalse);
  });

  test('US3-3 a cancel changes nothing; an error is reported', () async {
    final events = <PurchaseEvent>[];
    service
      ..start()
      ..events.listen(events.add);
    store
      ..emit(StorePurchaseStatus.canceled)
      ..emit(StorePurchaseStatus.error);
    await settle();
    expect(settings.current.removeAdsPurchased, isFalse);
    expect(events, [PurchaseEvent.canceled, PurchaseEvent.error]);
  });

  test("buy() is the app's own trip out (no SYS-03 on return)", () async {
    final product = (await service.loadProduct())!;
    expect(product.price, '₹299.00');
    expect(await service.buy(product), isTrue);
    expect(externalCalls, 1);
    expect(store.bought.single.id, proProductId);
  });

  test('no store → no product', () async {
    store.available = false;
    expect(await service.loadProduct(), isNull);
  });

  group('verifyOwnership (FR-041, clarification Q1)', () {
    test('owned → Pro (e.g. after a reinstall)', () async {
      store.ownership = OwnershipCheck.owned;
      await service.verifyOwnership();
      expect(settings.current.removeAdsPurchased, isTrue);
    });

    test('offline trusts the saved Pro', () async {
      settings = FakeSettingsRepository(
        initial: const AppSettings(removeAdsPurchased: true),
      );
      service = ProService(store: store..available = false, settings: settings);
      await service.verifyOwnership();
      expect(settings.current.removeAdsPurchased, isTrue);
      expect(settings.calls['setProState'], isNull);
    });

    test('two "not owned" in a row stage the removal; the next start '
        'applies it', () async {
      settings = FakeSettingsRepository(
        initial: const AppSettings(removeAdsPurchased: true),
      );
      service = ProService(store: store, settings: settings);
      await service.verifyOwnership();
      expect(settings.current.removeAdsPurchased, isTrue);
      expect(settings.current.proNotOwnedStreak, 1);
      await service.verifyOwnership();
      expect(settings.current.removeAdsPurchased, isTrue);
      expect(settings.current.proRemovalPending, isTrue);
      expect(await service.applyStagedRemoval(), isTrue);
      expect(settings.current.removeAdsPurchased, isFalse);
      expect(settings.current.proRemovalPending, isFalse);
      expect(await service.applyStagedRemoval(), isFalse);
    });
  });

  group('restore (FR-042)', () {
    test('owned → restored and Pro', () async {
      store.ownership = OwnershipCheck.owned;
      expect(await service.restore(), RestoreResult.restored);
      expect(settings.current.removeAdsPurchased, isTrue);
    });

    test('not owned → notFound, and it never counts toward removal', () async {
      settings = FakeSettingsRepository(
        initial: const AppSettings(removeAdsPurchased: true),
      );
      service = ProService(store: store, settings: settings);
      expect(await service.restore(), RestoreResult.notFound);
      expect(await service.restore(), RestoreResult.notFound);
      expect(settings.current.proNotOwnedStreak, 0);
      expect(settings.current.proRemovalPending, isFalse);
    });

    test('offline → unavailable; pending → pending', () async {
      store.available = false;
      expect(await service.restore(), RestoreResult.unavailable);
      store
        ..available = true
        ..ownership = OwnershipCheck.pending;
      expect(await service.restore(), RestoreResult.pending);
      expect(settings.current.proPurchasePending, isTrue);
    });
  });
}
