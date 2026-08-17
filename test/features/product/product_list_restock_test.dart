import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/entities/stock_sale_line.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/presentation/pages/product_list_page.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('product list scan-to-restock', () {
    testWidgets(
      'scanning a known barcode opens a dialog to add stock quantity',
      (tester) async {
        const product = Product(
          id: 'soap',
          name: 'Savon',
          barcode: '123',
          price: 1500,
          stock: 9,
        );
        final repository = _RecordingProductRepository([product]);
        final bloc = ProductBloc(
          getProductsUseCase: GetProductsUseCase(repository),
          addProductUseCase: AddProductUseCase(repository),
          updateProductUseCase: UpdateProductUseCase(repository),
          deleteProductUseCase: DeleteProductUseCase(repository),
        )..add(LoadProducts());
        addTearDown(bloc.close);

        final router = _buildRouter(bloc: bloc, scannedBarcode: '123');
        addTearDown(router.dispose);

        await tester.pumpWidget(_wrap(router));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.qr_code_scanner));
        await tester.pumpAndSettle();

        expect(find.text('Ajouter du stock'), findsOneWidget);
        expect(find.text('Stock actuel : 9'), findsOneWidget);

        await tester.enterText(
          find.byKey(const ValueKey('restock-quantity-field')),
          '5',
        );
        await tester.tap(find.text('Ajouter au stock'));
        await tester.pumpAndSettle();

        expect(repository.updatedProduct, isNotNull);
        expect(repository.updatedProduct!.id, 'soap');
        expect(repository.updatedProduct!.stock, 14);
      },
    );

    testWidgets('a zero or empty quantity is rejected in French', (
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
      final bloc = ProductBloc(
        getProductsUseCase: GetProductsUseCase(repository),
        addProductUseCase: AddProductUseCase(repository),
        updateProductUseCase: UpdateProductUseCase(repository),
        deleteProductUseCase: DeleteProductUseCase(repository),
      )..add(LoadProducts());
      addTearDown(bloc.close);

      final router = _buildRouter(bloc: bloc, scannedBarcode: '123');
      addTearDown(router.dispose);

      await tester.pumpWidget(_wrap(router));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.qr_code_scanner));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ajouter au stock'));
      await tester.pumpAndSettle();

      expect(repository.updatedProduct, isNull);
      expect(find.text('Saisis une quantité supérieure à 0'), findsOneWidget);
    });

    testWidgets(
      'scanning an unknown barcode falls back to the search field',
      (tester) async {
        final repository = _RecordingProductRepository(const []);
        final bloc = ProductBloc(
          getProductsUseCase: GetProductsUseCase(repository),
          addProductUseCase: AddProductUseCase(repository),
          updateProductUseCase: UpdateProductUseCase(repository),
          deleteProductUseCase: DeleteProductUseCase(repository),
        )..add(LoadProducts());
        addTearDown(bloc.close);

        final router = _buildRouter(bloc: bloc, scannedBarcode: '999');
        addTearDown(router.dispose);

        await tester.pumpWidget(_wrap(router));
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.qr_code_scanner));
        await tester.pumpAndSettle();

        expect(find.text('Ajouter du stock'), findsNothing);
        expect(find.text('999'), findsOneWidget);
      },
    );
  });
}

GoRouter _buildRouter({
  required ProductBloc bloc,
  required String scannedBarcode,
}) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder:
            (context, state) => BlocProvider<ProductBloc>.value(
              value: bloc,
              child: const ProductListPage(),
            ),
      ),
      GoRoute(
        path: '/scanner',
        builder: (context, state) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) Navigator.of(context).pop(scannedBarcode);
          });
          return const SizedBox.shrink();
        },
      ),
    ],
  );
}

Widget _wrap(GoRouter router) {
  return MaterialApp.router(
    locale: const Locale('fr'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    routerConfig: router,
  );
}

final class _RecordingProductRepository implements ProductRepository {
  _RecordingProductRepository(Iterable<Product> initialProducts)
    : products = List<Product>.of(initialProducts);

  final List<Product> products;
  Product? updatedProduct;

  @override
  Future<Either<Failure, void>> addProduct(Product product) async =>
      const Right(null);

  @override
  Future<Either<Failure, List<Product>>> completeSale(
    List<StockSaleLine> lines,
  ) async => const Right(<Product>[]);

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    for (final product in products) {
      if (product.barcode == barcode) return Right(product);
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
