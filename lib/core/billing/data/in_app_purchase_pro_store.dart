import 'dart:async';

import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// [ProStore] over `in_app_purchase` and Google Play Billing (feature 009
/// research R13). The only file that imports the billing plugins.
// Device bindings; exercised on a device (quickstart §4.4), not unit tests.
// coverage:ignore-start
final class InAppPurchaseProStore implements ProStore {
  new();

  InAppPurchase get _iap => InAppPurchase.instance;

  /// Product details by id, kept for [buy].
  final _products = <String, ProductDetails>{};

  static StorePurchaseStatus _status(PurchaseStatus s) => switch (s) {
    PurchaseStatus.purchased => StorePurchaseStatus.purchased,
    PurchaseStatus.restored => StorePurchaseStatus.restored,
    PurchaseStatus.pending => StorePurchaseStatus.pending,
    PurchaseStatus.canceled => StorePurchaseStatus.canceled,
    PurchaseStatus.error => StorePurchaseStatus.error,
  };

  static StorePurchase _toStore(PurchaseDetails p) => StorePurchase(
    productId: p.productID,
    status: _status(p.status),
    needsCompletion: p.pendingCompletePurchase,
    native: p,
  );

  @override
  Stream<List<StorePurchase>> get purchaseUpdates =>
      _iap.purchaseStream.map((list) => [for (final p in list) _toStore(p)]);

  @override
  Future<bool> isAvailable() async {
    try {
      return await _iap.isAvailable();
    } on Object {
      return false;
    }
  }

  @override
  Future<StoreProduct?> loadProduct() async {
    final response = await _iap.queryProductDetails({proProductId});
    if (response.error != null) return null;
    final product = response.productDetails
        .where((p) => p.id == proProductId)
        .firstOrNull;
    if (product == null || product.price.isEmpty) return null;
    _products[product.id] = product;
    return StoreProduct(
      id: product.id,
      title: product.title,
      price: product.price,
    );
  }

  @override
  Future<void> buy(StoreProduct product) async {
    final details = _products[product.id];
    if (details == null) return;
    await _iap.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  @override
  Future<OwnershipCheck> queryOwnership() async {
    if (!await isAvailable()) return OwnershipCheck.unavailable;
    final QueryPurchaseDetailsResponse response;
    try {
      response = await _iap
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>()
          .queryPastPurchases();
    } on Object {
      return OwnershipCheck.unavailable;
    }
    if (response.error != null) return OwnershipCheck.unavailable;
    final pro = response.pastPurchases.where(
      (p) => p.productID == proProductId,
    );
    var pending = false;
    for (final p in pro) {
      if (p.status == PurchaseStatus.pending) {
        pending = true;
        continue;
      }
      // Owned. Acknowledge it if that never happened (FR-040).
      if (p.pendingCompletePurchase) {
        try {
          await _iap.completePurchase(p);
        } on Object {
          // Tried again at the next start, well inside Play's 3 days.
        }
      }
      return OwnershipCheck.owned;
    }
    return pending ? OwnershipCheck.pending : OwnershipCheck.notOwned;
  }

  @override
  Future<void> complete(StorePurchase purchase) async {
    final native = purchase.native;
    if (native is PurchaseDetails && native.pendingCompletePurchase) {
      await _iap.completePurchase(native);
    }
  }
}
// coverage:ignore-end
