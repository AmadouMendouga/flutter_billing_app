import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/entities/stock_sale_line.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/presentation/pages/add_product_page.dart';
import 'package:billing_app/features/product/presentation/pages/edit_product_page.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('product stock forms', () {
    testWidgets('adding a product saves the entered stock quantity', (
      tester,
    ) async {
      final repository = _RecordingProductRepository();
      await _pumpForm(
        tester,
        repository: repository,
        page: const AddProductPage(),
      );

      await _fillAddProductForm(
        tester,
        barcode: ' 00123 ',
        name: 'Savon',
        price: '1500',
        stock: '12',
      );
      await _submit(tester);

      expect(repository.addedProduct, isNotNull);
      expect(repository.addedProduct!.barcode, '00123');
      expect(repository.addedProduct!.name, 'Savon');
      expect(repository.addedProduct!.price, 1500);
      expect(repository.addedProduct!.stock, 12);
    });

    testWidgets('zero is a valid initial stock quantity', (tester) async {
      final repository = _RecordingProductRepository();
      await _pumpForm(
        tester,
        repository: repository,
        page: const AddProductPage(),
      );

      await _fillAddProductForm(
        tester,
        barcode: '456',
        name: 'Produit en attente',
        price: '250',
        stock: '0',
      );
      await _submit(tester);

      expect(repository.addedProduct, isNotNull);
      expect(repository.addedProduct!.stock, 0);
    });

    testWidgets('an empty stock quantity is rejected in French', (
      tester,
    ) async {
      final repository = _RecordingProductRepository();
      await _pumpForm(
        tester,
        repository: repository,
        page: const AddProductPage(),
      );

      await _fillAddProductForm(
        tester,
        barcode: '789',
        name: 'Riz',
        price: '500',
        stock: '',
      );
      await _submit(tester);

      expect(repository.addedProduct, isNull);
      expect(find.text('Saisis une quantité en stock valide'), findsOneWidget);
      expect(find.byType(AddProductPage), findsOneWidget);
    });

    testWidgets('non-integer stock input cannot be submitted', (tester) async {
      final repository = _RecordingProductRepository();
      await _pumpForm(
        tester,
        repository: repository,
        page: const AddProductPage(),
      );

      await _fillAddProductForm(
        tester,
        barcode: '790',
        name: 'Huile',
        price: '1200',
        stock: 'abc',
      );
      await _submit(tester);

      expect(repository.addedProduct, isNull);
      expect(find.text('Saisis une quantité en stock valide'), findsOneWidget);
    });

    testWidgets('editing pre-fills and preserves the current stock', (
      tester,
    ) async {
      const product = Product(
        id: 'soap',
        name: 'Savon',
        barcode: '123',
        price: 1500,
        stock: 9,
      );
      final repository = _RecordingProductRepository([product]);
      await _pumpForm(
        tester,
        repository: repository,
        page: const EditProductPage(product: product),
      );

      expect(_stockText(tester), '9');
      await tester.enterText(find.byType(TextFormField).first, 'Savon doux');
      await _submit(tester);

      expect(repository.updatedProduct, isNotNull);
      expect(repository.updatedProduct!.name, 'Savon doux');
      expect(repository.updatedProduct!.stock, 9);
    });

    testWidgets('editing can update the stock quantity', (tester) async {
      const product = Product(
        id: 'rice',
        name: 'Riz',
        barcode: '987',
        price: 500,
        stock: 4,
      );
      final repository = _RecordingProductRepository([product]);
      await _pumpForm(
        tester,
        repository: repository,
        page: const EditProductPage(product: product),
      );

      await tester.enterText(
        find.byKey(const ValueKey('product-stock-field')),
        '17',
      );
      await _submit(tester);

      expect(repository.updatedProduct, isNotNull);
      expect(repository.updatedProduct!.id, product.id);
      expect(repository.updatedProduct!.barcode, product.barcode);
      expect(repository.updatedProduct!.stock, 17);
    });
  });
}

Future<void> _pumpForm(
  WidgetTester tester, {
  required _RecordingProductRepository repository,
  required Widget page,
}) async {
  final bloc = ProductBloc(
    getProductsUseCase: GetProductsUseCase(repository),
    addProductUseCase: AddProductUseCase(repository),
    updateProductUseCase: UpdateProductUseCase(repository),
    deleteProductUseCase: DeleteProductUseCase(repository),
  );
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder:
            (context, state) => Scaffold(
              body: Center(
                child: FilledButton(
                  key: const ValueKey('open-product-form'),
                  onPressed: () => context.push('/form'),
                  child: const Text('Ouvrir'),
                ),
              ),
            ),
      ),
      GoRoute(path: '/form', builder: (context, state) => page),
    ],
  );
  addTearDown(router.dispose);
  addTearDown(bloc.close);

  await tester.pumpWidget(
    BlocProvider<ProductBloc>.value(
      value: bloc,
      child: MaterialApp.router(
        locale: const Locale('fr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
      ),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('open-product-form')));
  await tester.pumpAndSettle();
}

Future<void> _fillAddProductForm(
  WidgetTester tester, {
  required String barcode,
  required String name,
  required String price,
  required String stock,
}) async {
  final fields = find.byType(TextFormField);
  expect(fields, findsNWidgets(4));
  await tester.enterText(fields.at(0), barcode);
  await tester.enterText(fields.at(1), name);
  await tester.enterText(fields.at(2), price);
  await tester.enterText(
    find.byKey(const ValueKey('product-stock-field')),
    stock,
  );
}

Future<void> _submit(WidgetTester tester) async {
  await tester.tap(find.byType(PrimaryButton));
  await tester.pumpAndSettle();
}

String _stockText(WidgetTester tester) {
  final editable = tester.widget<EditableText>(
    find.descendant(
      of: find.byKey(const ValueKey('product-stock-field')),
      matching: find.byType(EditableText),
    ),
  );
  return editable.controller.text;
}

final class _RecordingProductRepository implements ProductRepository {
  _RecordingProductRepository([Iterable<Product> initialProducts = const []])
    : products = List<Product>.of(initialProducts);

  final List<Product> products;
  Product? addedProduct;
  Product? updatedProduct;

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    addedProduct = product;
    products.add(product);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Product>>> completeSale(
    List<StockSaleLine> lines,
  ) async => const Right(<Product>[]);

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    products.removeWhere((product) => product.id == id);
    return const Right(null);
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    final normalizedBarcode = barcode.trim();
    for (final product in products) {
      if (product.barcode == normalizedBarcode) return Right(product);
    }
    return const Left(CacheFailure('Product not found'));
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts() async =>
      Right(List<Product>.unmodifiable(products));

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    updatedProduct = product;
    final index = products.indexWhere((current) => current.id == product.id);
    if (index == -1) {
      products.add(product);
    } else {
      products[index] = product;
    }
    return const Right(null);
  }
}
