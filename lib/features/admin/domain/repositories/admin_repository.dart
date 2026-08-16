import '../../../product/domain/entities/product.dart';
import '../../../shop/domain/entities/shop.dart';
import '../entities/admin_access.dart';
import '../entities/admin_shop.dart';
import '../entities/product_copy_report.dart';

abstract interface class AdminRepository {
  Stream<AdminAccess> watchAdminAccess(String uid);

  Stream<List<AdminShop>> watchShops();

  Stream<List<Product>> watchProducts(String shopId);

  Future<void> setShopStatus({
    required String shopId,
    required ShopStatus status,
    required String adminUid,
    String reason = '',
  });

  Future<ProductCopyReport> copyMissingProducts({
    required String sourceShopId,
    required String targetShopId,
    required String adminUid,
  });
}
