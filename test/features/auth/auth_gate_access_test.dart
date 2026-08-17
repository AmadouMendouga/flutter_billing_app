import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/admin/domain/entities/admin_access.dart';
import 'package:billing_app/features/admin/domain/entities/admin_shop.dart';
import 'package:billing_app/features/admin/domain/entities/product_copy_report.dart';
import 'package:billing_app/features/admin/domain/repositories/admin_repository.dart';
import 'package:billing_app/features/auth/domain/entities/app_user.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/widgets/auth_gate.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/entities/stock_sale_line.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:billing_app/features/shop/domain/repositories/shop_repository.dart';
import 'package:billing_app/features/shop/domain/usecases/shop_usecases.dart';
import 'package:billing_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  const user = AppUser(
    uid: 'user-1',
    email: 'owner@example.com',
    emailVerified: true,
  );

  testWidgets('an administrator opens the dashboard without creating a shop', (
    tester,
  ) async {
    const adminRepository = _FakeAdminRepository(
      AdminAccess(uid: 'user-1', role: AdminRole.superAdmin, isActive: true),
    );
    final shopRepository = _FakeShopRepository(
      const Shop(status: ShopStatus.pending),
    );

    await _pumpGate(
      tester,
      user: user,
      adminRepository: adminRepository,
      shopRepository: shopRepository,
    );

    expect(find.text('Administration'), findsOneWidget);
    expect(find.byKey(const ValueKey('admin-app')), findsOneWidget);
    expect(shopRepository.ensureCalls, 0);
  });

  testWidgets('a pending shop cannot enter the billing application', (
    tester,
  ) async {
    final shopRepository = _FakeShopRepository(
      const Shop(
        name: 'Boutique test',
        ownerUid: 'user-1',
        ownerEmail: 'owner@example.com',
        status: ShopStatus.pending,
      ),
    );

    await _pumpGate(
      tester,
      user: user,
      adminRepository: const _FakeAdminRepository(AdminAccess.denied('user-1')),
      shopRepository: shopRepository,
    );

    expect(find.byKey(const ValueKey('shop-status-pending')), findsOneWidget);
    expect(find.text('APPLICATION BOUTIQUE'), findsNothing);
    expect(shopRepository.ensureCalls, 1);
  });

  testWidgets('an active legacy shop enters the billing application', (
    tester,
  ) async {
    await _pumpGate(
      tester,
      user: user,
      adminRepository: const _FakeAdminRepository(AdminAccess.denied('user-1')),
      shopRepository: _FakeShopRepository(
        const Shop(name: 'Ancienne boutique', status: ShopStatus.active),
      ),
    );

    expect(find.text('APPLICATION BOUTIQUE'), findsOneWidget);
    expect(find.byKey(const ValueKey('authenticated-app')), findsOneWidget);
  });

  testWidgets('a suspended shop sees the localized blocking message', (
    tester,
  ) async {
    await _pumpGate(
      tester,
      user: user,
      adminRepository: const _FakeAdminRepository(AdminAccess.denied('user-1')),
      shopRepository: _FakeShopRepository(
        const Shop(
          name: 'Boutique suspendue',
          status: ShopStatus.suspended,
          statusReason: 'Contrôle en cours',
        ),
      ),
    );

    expect(find.byKey(const ValueKey('shop-status-suspended')), findsOneWidget);
    expect(
      find.text(
        'Cette boutique est momentanément désactivée. '
        'Merci pour votre compréhension.',
      ),
      findsOneWidget,
    );
    expect(find.text('APPLICATION BOUTIQUE'), findsNothing);
  });
}

Future<void> _pumpGate(
  WidgetTester tester, {
  required AppUser user,
  required AdminRepository adminRepository,
  required _FakeShopRepository shopRepository,
}) async {
  final authBloc = AuthBloc(authRepository: _FakeAuthRepository(user));
  final authenticated = authBloc.stream.firstWhere(
    (state) => state is AuthAuthenticated,
  );
  authBloc.add(AuthUserChanged(user));
  await authenticated;

  final productRepository = _FakeProductRepository();
  final productBloc = ProductBloc(
    getProductsUseCase: GetProductsUseCase(productRepository),
    addProductUseCase: AddProductUseCase(productRepository),
    updateProductUseCase: UpdateProductUseCase(productRepository),
    deleteProductUseCase: DeleteProductUseCase(productRepository),
  );
  final shopBloc = ShopBloc(
    getShopUseCase: GetShopUseCase(shopRepository),
    updateShopUseCase: UpdateShopUseCase(shopRepository),
  );
  final billingBloc = BillingBloc(
    getProductByBarcodeUseCase: GetProductByBarcodeUseCase(productRepository),
    completeSaleUseCase: CompleteSaleUseCase(productRepository),
  );
  addTearDown(authBloc.close);
  addTearDown(productBloc.close);
  addTearDown(shopBloc.close);
  addTearDown(billingBloc.close);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<ProductBloc>.value(value: productBloc),
        BlocProvider<ShopBloc>.value(value: shopBloc),
        BlocProvider<BillingBloc>.value(value: billingBloc),
      ],
      child: MaterialApp(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: AuthGate(
          authenticatedChild: const Scaffold(
            body: Text('APPLICATION BOUTIQUE'),
          ),
          adminRepository: adminRepository,
          shopRepository: shopRepository,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeAdminRepository implements AdminRepository {
  const _FakeAdminRepository(this.access);

  final AdminAccess access;

  @override
  Stream<AdminAccess> watchAdminAccess(String uid) => Stream.value(access);

  @override
  Stream<List<AdminShop>> watchShops() => Stream.value(const []);

  @override
  Stream<List<Product>> watchProducts(String shopId) => Stream.value(const []);

  @override
  Future<void> setShopStatus({
    required String shopId,
    required ShopStatus status,
    required String adminUid,
    String reason = '',
  }) async {}

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
}

class _FakeShopRepository implements ShopRepository {
  _FakeShopRepository(this.shop);

  Shop shop;
  int ensureCalls = 0;

  @override
  Future<Either<Failure, Shop>> ensureShop({String initialName = ''}) async {
    ensureCalls++;
    if (shop.name.isEmpty && initialName.isNotEmpty) {
      shop = shop.copyWith(name: initialName);
    }
    return Right(shop);
  }

  @override
  Future<Either<Failure, Shop>> getShop() async => Right(shop);

  @override
  Stream<Either<Failure, Shop>> watchShop() => Stream.value(Right(shop));

  @override
  Future<Either<Failure, void>> updateShop(Shop value) async {
    shop = value;
    return const Right(null);
  }
}

class _FakeProductRepository implements ProductRepository {
  @override
  Future<Either<Failure, List<Product>>> completeSale(
    List<StockSaleLine> lines,
  ) async => const Right([]);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async => const Right([]);

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async =>
      const Left(CacheFailure('Not found'));

  @override
  Future<Either<Failure, void>> addProduct(Product product) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async =>
      const Right(null);
}

class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository(this.user);

  final AppUser user;

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> get authStateChanges => Stream.value(user);

  @override
  Future<Either<Failure, void>> logOut() async => const Right(null);

  @override
  Future<Either<Failure, AppUser>> logIn(String email, String password) async =>
      Right(user);

  @override
  Future<Either<Failure, AppUser>> signUp(
    String email,
    String password,
  ) async => Right(user);

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async => Right(user);

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> sendVerificationCode() async =>
      const Right(null);

  @override
  Future<Either<Failure, AppUser>> verifyEmailCode(String code) async =>
      Right(user);

  @override
  Future<Either<Failure, void>> sendVerificationEmail() async =>
      const Right(null);

  @override
  Future<Either<Failure, AppUser>> refreshEmailVerificationStatus() async =>
      Right(user);
}
