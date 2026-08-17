import 'dart:async';

import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/billing/domain/services/whatsapp_invoice_service.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/features/billing/presentation/pages/checkout_page.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/entities/stock_sale_line.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
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
  const product = Product(
    id: 'soap',
    name: 'Savon',
    barcode: '123',
    price: 1500,
    stock: 10,
  );
  const shop = Shop(name: 'Ma Boutique', addressLine1: 'Douala');

  late BillingBloc billingBloc;
  late ShopBloc shopBloc;

  setUp(() async {
    const productRepository = _FakeProductRepository(product);
    billingBloc = BillingBloc(
      getProductByBarcodeUseCase: GetProductByBarcodeUseCase(
        productRepository,
      ),
      completeSaleUseCase: CompleteSaleUseCase(productRepository),
    );
    final cartReady = billingBloc.stream.firstWhere(
      (state) => state.cartItems.isNotEmpty,
    );
    billingBloc.add(const AddProductToCartEvent(product));
    await cartReady;

    const shopRepository = _FakeShopRepository(shop);
    shopBloc = ShopBloc(
      getShopUseCase: GetShopUseCase(shopRepository),
      updateShopUseCase: UpdateShopUseCase(shopRepository),
    );
    final shopReady = shopBloc.stream.firstWhere(
      (state) => state is ShopLoaded,
    );
    shopBloc.add(LoadShopEvent());
    await shopReady;
  });

  tearDown(() async {
    await billingBloc.close();
    await shopBloc.close();
  });

  testWidgets('the WhatsApp button shares the current localized invoice', (
    tester,
  ) async {
    final service = _FakeWhatsAppInvoiceService();
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_buildCheckout(billingBloc, shopBloc, service));

    final button = find.byKey(const ValueKey('send-invoice-whatsapp'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('whatsapp-phone-field')),
      '6 99 00 11 22',
    );
    await tester.tap(find.byKey(const ValueKey('continue-to-whatsapp')));
    await tester.pumpAndSettle();

    expect(service.messages, hasLength(1));
    expect(service.phoneNumbers, ['237699001122']);
    expect(service.messages.single, contains('Ma Boutique'));
    expect(service.messages.single, contains('Savon'));
    expect(service.messages.single, contains('*TOTAL: 1500 FCFA*'));
  });

  testWidgets(
    'WhatsApp is optional and the customer number dialog can cancel',
    (tester) async {
      final service = _FakeWhatsAppInvoiceService();
      await tester.binding.setSurfaceSize(const Size(900, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_buildCheckout(billingBloc, shopBloc, service));

      final button = find.byKey(const ValueKey('send-invoice-whatsapp'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('whatsapp-phone-field')),
        findsOneWidget,
      );
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('whatsapp-phone-field')), findsNothing);
      expect(service.messages, isEmpty);
      expect(find.text('Imprimer le reçu'), findsOneWidget);
    },
  );

  testWidgets('a WhatsApp launch failure is visible and unlocks the button', (
    tester,
  ) async {
    final service =
        _FakeWhatsAppInvoiceService()
          ..error = const WhatsAppInvoiceShareException();
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_buildCheckout(billingBloc, shopBloc, service));

    final button = find.byKey(const ValueKey('send-invoice-whatsapp'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('whatsapp-phone-field')),
      '+237 699 00 11 22',
    );
    await tester.tap(find.byKey(const ValueKey('continue-to-whatsapp')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Impossible d’ouvrir WhatsApp. Vérifie qu’il est installé puis réessaie.',
      ),
      findsOneWidget,
    );
    final action = tester.widget<FilledButton>(
      find.byKey(const ValueKey('continue-to-whatsapp')),
    );
    expect(action.onPressed, isNotNull);
  });

  testWidgets('the WhatsApp button blocks duplicate taps while opening', (
    tester,
  ) async {
    final service = _FakeWhatsAppInvoiceService()..pending = Completer<void>();
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(_buildCheckout(billingBloc, shopBloc, service));

    final button = find.byKey(const ValueKey('send-invoice-whatsapp'));
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('whatsapp-phone-field')),
      '699001122',
    );
    await tester.tap(find.byKey(const ValueKey('continue-to-whatsapp')));
    await tester.pump();

    expect(service.messages, hasLength(1));
    expect(find.text('Ouverture de WhatsApp…'), findsWidgets);
    final action = tester.widget<FilledButton>(
      find.byKey(const ValueKey('continue-to-whatsapp')),
    );
    expect(action.onPressed, isNull);

    service.pending!.complete();
    await tester.pumpAndSettle();
  });
}

Widget _buildCheckout(
  BillingBloc billingBloc,
  ShopBloc shopBloc,
  WhatsAppInvoiceService service,
) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<BillingBloc>.value(value: billingBloc),
      BlocProvider<ShopBloc>.value(value: shopBloc),
    ],
    child: MaterialApp(
      locale: const Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CheckoutPage(
        whatsAppInvoiceService: service,
        now: () => DateTime(2026, 8, 16, 3, 18),
      ),
    ),
  );
}

final class _FakeWhatsAppInvoiceService implements WhatsAppInvoiceService {
  final messages = <String>[];
  final phoneNumbers = <String>[];
  Object? error;
  Completer<void>? pending;

  @override
  Future<void> share({
    required String recipientPhoneNumber,
    required String message,
  }) async {
    phoneNumbers.add(recipientPhoneNumber);
    messages.add(message);
    final currentError = error;
    if (currentError != null) throw currentError;
    await pending?.future;
  }
}

final class _FakeProductRepository implements ProductRepository {
  const _FakeProductRepository(this.product);

  final Product product;

  @override
  Future<Either<Failure, List<Product>>> completeSale(
    List<StockSaleLine> lines,
  ) async => Right([product]);

  @override
  Future<Either<Failure, void>> addProduct(Product product) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async =>
      Right(product);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async =>
      Right([product]);

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async =>
      const Right(null);
}

final class _FakeShopRepository implements ShopRepository {
  const _FakeShopRepository(this.shop);

  final Shop shop;

  @override
  Future<Either<Failure, Shop>> getShop() async => Right(shop);

  @override
  Future<Either<Failure, Shop>> ensureShop({String initialName = ''}) async =>
      Right(shop);

  @override
  Stream<Either<Failure, Shop>> watchShop() => Stream.value(Right(shop));

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async =>
      const Right(null);
}
