import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';

class InAppRepo {
  // this is the product Id as created for the consumable on app connect and google play
  static const _coffeeId = 'coffee';
  final Set<String> _productIds = <String>{_coffeeId};
  Stream<List<PurchaseDetails>> get purchaseStream =>
      InAppPurchaseConnection.instance.purchaseUpdatedStream;

  StreamSubscription _subscription;

  InAppRepo();

  /// purchase coffee
  void purchaseCoffee() async {
    // if (AppConstants.mockInAppPurchaseForTesting) {
    //   await _enableAdFreeOnPurchaseOrRestore(GamePurchasedStatus.Purchased);
    //   return;
    // }
    //user will now buy the product
    final availableProducts = await _getAvailableProducts();
    if (availableProducts.isNotEmpty) {
      final productDetails = availableProducts
          .firstWhere((productDetail) => productDetail.id == _coffeeId);
      final purchaseParam = PurchaseParam(productDetails: productDetails);
      await InAppPurchaseConnection.instance.isAvailable();
      InAppPurchaseConnection.instance
          .buyConsumable(purchaseParam: purchaseParam);
    }
  }

  void completePurchase(PurchaseDetails purchaseDetails) {
    InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
  }

  ///called on dispose of main
  Future disablePurchaseUpdatedStreamSubscription() => _subscription?.cancel();

  // /// restore purchase
  // void restorePurchase() async {
  //   List<PurchaseDetails> purchases = await _getPastPurchases();
  //   bool hasPurchases = false;
  //
  //   if (purchases.isNotEmpty) {
  //     PurchaseDetails purchasedProductDetails = purchases.firstWhere((productDetail) => productDetail.productID == _removeAdId);
  //     //user has already purchased the our product
  //     if (purchasedProductDetails != null) {
  //       await _enableAdFreeOnPurchaseOrRestore(GamePurchasedStatus.Restored);
  //       hasPurchases = true;
  //     }
  //   }
  //
  //   if (!hasPurchases) {
  //     _gameProvider.setJustPurchased(GamePurchasedStatus.NothingToRestore);
  //     _gameProvider.initNewGame(notify: true);
  //   }
  // }

  // Future<void> _enableAdFreeOnPurchaseOrRestore(GamePurchasedStatus purchasedStatus) async {
  //   await _settingsRepo.setAdFreeVersion(true);
  //   _gameProvider.setJustPurchased(purchasedStatus);
  //   _gameProvider.initNewGame(notify: true);
  // }

  /// get products
  Future<List<ProductDetails>> _getAvailableProducts() async {
    final productDetailQueryResponse =
        await InAppPurchaseConnection.instance.queryProductDetails(_productIds);
    return Future.value(productDetailQueryResponse.error == null
        ? productDetailQueryResponse.productDetails
        : <ProductDetails>[]);
  }

  /// get past purchases
  // Future<List<PurchaseDetails>> _getPastPurchases() async {
  //   QueryPurchaseDetailsResponse purchaseDetailsResponse =
  //       await InAppPurchaseConnection.instance.queryPastPurchases();
  //   return Future.value(purchaseDetailsResponse.error == null
  //       ? purchaseDetailsResponse.pastPurchases
  //       : <PurchaseDetails>[]);
  // }
}
