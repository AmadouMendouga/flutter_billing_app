import 'package:billing_app/features/admin/data/models/admin_access_model.dart';
import 'package:billing_app/features/admin/data/models/admin_shop_model.dart';
import 'package:billing_app/features/admin/domain/entities/admin_access.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminAccessModel', () {
    test('requires enabled true and a known role', () {
      final access = AdminAccessModel.fromMap('admin-1', {
        'enabled': true,
        'role': 'super_admin',
      });

      expect(access.role, AdminRole.superAdmin);
      expect(access.canOpenDashboard, isTrue);
      expect(
        AdminAccessModel.fromMap('admin-2', {
          'enabled': false,
          'role': 'super_admin',
        }).canOpenDashboard,
        isFalse,
      );
      expect(AdminAccessModel.fromMap('missing', null).canOpenDashboard, false);
    });
  });

  group('AdminShopModel', () {
    test('keeps a legacy shop without status active', () {
      final shop = AdminShopModel.fromMap('owner-1', {'name': 'Legacy shop'});

      expect(shop.ownerUid, 'owner-1');
      expect(shop.status, ShopStatus.active);
    });

    test('does not grant access for an unknown explicit status', () {
      final shop = AdminShopModel.fromMap('owner-1', {'status': 'unexpected'});

      expect(shop.status, ShopStatus.pending);
    });
  });
}
