/// The one-time Pro product in Google Play (spec PRM-01).
const String proProductId = 'pro_lifetime';

/// The Pro product as the store sells it. [price] is localized by the
/// store and shown as-is (FR-037). Pure Dart.
final class StoreProduct {
  const new({required this.id, required this.title, required this.price});

  final String id;
  final String title;
  final String price;
}

/// A purchase update from the store.
enum StorePurchaseStatus { purchased, restored, pending, canceled, error }

final class StorePurchase {
  const new({
    required this.productId,
    required this.status,
    this.needsCompletion = false,
    this.native,
  });

  final String productId;
  final StorePurchaseStatus status;

  /// Not yet acknowledged; the store adapter completes it (FR-039, FR-040).
  final bool needsCompletion;

  /// The plugin's own object, passed back to [ProStore.complete].
  final Object? native;
}

/// What a start-up ownership check found (research R13).
enum OwnershipCheck {
  /// Play reports `pro_lifetime` owned.
  owned,

  /// A payment for it is pending.
  pending,

  /// Play answered, and the user does not own it (e.g. refunded).
  notOwned,

  /// Offline, the store is unavailable, or the check failed: no answer.
  unavailable,
}

/// Google Play Billing for Pro. The `in_app_purchase` adapter lives in
/// `data/`; tests use a fake.
abstract interface class ProStore {
  /// Every purchase update, including ones that completed while the app was
  /// closed. Listen before any other call.
  Stream<List<StorePurchase>> get purchaseUpdates;

  Future<bool> isAvailable();

  /// The Pro product, or null when the store can't sell it now.
  Future<StoreProduct?> loadProduct();

  /// Starts the Play purchase flow; the result arrives on [purchaseUpdates].
  Future<void> buy(StoreProduct product);

  /// Asks Play which purchases the user owns now, and acknowledges any
  /// owned Pro purchase that still needs it.
  Future<OwnershipCheck> queryOwnership();

  /// Acknowledges [purchase] (Play requires it within 3 days).
  Future<void> complete(StorePurchase purchase);
}

/// No store: tests and platforms without Play. Never sells or owns Pro.
final class UnavailableProStore implements ProStore {
  const new();

  @override
  Stream<List<StorePurchase>> get purchaseUpdates => const Stream.empty();

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<StoreProduct?> loadProduct() async => null;

  @override
  Future<void> buy(StoreProduct product) async {}

  @override
  Future<OwnershipCheck> queryOwnership() async => OwnershipCheck.unavailable;

  @override
  Future<void> complete(StorePurchase purchase) async {}
}
