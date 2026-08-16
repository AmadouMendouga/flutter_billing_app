import 'package:billing_app/features/admin/domain/entities/admin_access.dart';
import 'package:billing_app/features/admin/domain/entities/admin_shop.dart';
import 'package:billing_app/features/admin/domain/entities/product_copy_report.dart';
import 'package:billing_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:billing_app/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('refuses a disabled administrator', (tester) async {
    const repository = _FakeAdminRepository(
      access: AdminAccess(
        uid: 'admin',
        role: AdminRole.superAdmin,
        isActive: false,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: AdminDashboardPage(
          repository: repository,
          adminUid: 'admin',
          onOpenShop: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('admin-access-denied')), findsOneWidget);
    expect(
      find.text('Ce compte n’a plus accès à l’administration.'),
      findsOneWidget,
    );
  });

  testWidgets('filters shops and opens the selected shop', (tester) async {
    const repository = _FakeAdminRepository(
      access: AdminAccess(
        uid: 'admin',
        role: AdminRole.superAdmin,
        isActive: true,
      ),
      shops: [
        AdminShop(
          id: 'pending-shop',
          ownerUid: 'owner-1',
          ownerEmail: 'one@example.com',
          name: 'Boutique Alpha',
          addressLine1: '',
          addressLine2: '',
          phoneNumber: '',
          status: ShopStatus.pending,
        ),
        AdminShop(
          id: 'active-shop',
          ownerUid: 'owner-2',
          ownerEmail: 'two@example.com',
          name: 'Boutique Beta',
          addressLine1: '',
          addressLine2: '',
          phoneNumber: '',
          status: ShopStatus.active,
        ),
      ],
    );
    AdminShop? opened;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fr'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: AdminDashboardPage(
          repository: repository,
          adminUid: 'admin',
          onOpenShop: (shop) => opened = shop,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Boutique Alpha'), findsOneWidget);
    expect(find.text('Boutique Beta'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('shop-filter-pending')));
    await tester.pump();

    expect(find.text('Boutique Alpha'), findsOneWidget);
    expect(find.text('Boutique Beta'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('admin-shop-pending-shop')));
    expect(opened?.id, 'pending-shop');
  });
}

class _FakeAdminRepository implements AdminRepository {
  final AdminAccess access;
  final List<AdminShop> shops;

  const _FakeAdminRepository({required this.access, this.shops = const []});

  @override
  Stream<AdminAccess> watchAdminAccess(String uid) => Stream.value(access);

  @override
  Stream<List<AdminShop>> watchShops() => Stream.value(shops);

  @override
  Stream<List<Product>> watchProducts(String shopId) => Stream.value(const []);

  @override
  Future<ProductCopyReport> copyMissingProducts({
    required String sourceShopId,
    required String targetShopId,
    required String adminUid,
  }) async => const ProductCopyReport(
    sourceCount: 0,
    copiedCount: 0,
    existingBarcodes: [],
    duplicateSourceBarcodes: [],
    missingBarcodeCount: 0,
  );

  @override
  Future<void> setShopStatus({
    required String shopId,
    required ShopStatus status,
    required String adminUid,
    String reason = '',
  }) async {}
}
