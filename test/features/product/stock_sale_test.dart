import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/entities/stock_sale_line.dart';
import 'package:billing_app/features/product/domain/failures/stock_failure.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  group('consolidateStockSaleLines', () {
    test('normalizes identifiers and merges duplicate products', () {
      final result = consolidateStockSaleLines(const [
        StockSaleLine(productId: ' soap ', productName: ' Soap ', quantity: 2),
        StockSaleLine(productId: 'soap', productName: '', quantity: 3),
        StockSaleLine(productId: 'water', productName: 'Water', quantity: 1),
      ]);

      expect(result, const [
        StockSaleLine(productId: 'soap', productName: 'Soap', quantity: 5),
        StockSaleLine(productId: 'water', productName: 'Water', quantity: 1),
      ]);
    });
  });

  group('stock failures', () {
    test(
      'deleted and insufficient stock remain distinguishable and useful',
      () {
        final deleted = ProductDeletedFailure(
          productId: 'soap',
          productName: 'Soap',
          requestedQuantity: 2,
        );
        final insufficient = InsufficientStockFailure(
          productId: 'soap',
          productName: 'Soap',
          availableQuantity: 1,
          requestedQuantity: 2,
        );

        expect(deleted, isA<ProductDeletedFailure>());
        expect(insufficient, isA<InsufficientStockFailure>());
        expect(deleted.productId, 'soap');
        expect(deleted.requestedQuantity, 2);
        expect(insufficient.availableQuantity, 1);
        expect(insufficient.requestedQuantity, 2);
        expect(deleted, isNot(equals(insufficient)));
      },
    );
  });

  test(
    'CompleteSaleUseCase delegates typed lines and returns updated products',
    () async {
      const updated = Product(
        id: 'soap',
        name: 'Soap',
        barcode: '123',
        price: 500,
        stock: 3,
      );
      final repository = _RecordingProductRepository(const Right([updated]));
      final useCase = CompleteSaleUseCase(repository);
      const lines = [
        StockSaleLine(productId: 'soap', productName: 'Soap', quantity: 2),
      ];

      final result = await useCase(lines);

      expect(repository.receivedLines, lines);
      result.fold(
        (failure) => fail('Expected updated products, got $failure'),
        (products) => expect(products, const [updated]),
      );
    },
  );
}

final class _RecordingProductRepository implements ProductRepository {
  _RecordingProductRepository(this.result);

  final Either<Failure, List<Product>> result;
  List<StockSaleLine>? receivedLines;

  @override
  Future<Either<Failure, List<Product>>> completeSale(
    List<StockSaleLine> lines,
  ) async {
    receivedLines = lines;
    return result;
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async =>
      const Right(null);

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async =>
      const Right(null);

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async =>
      const Left(CacheFailure('Not used'));

  @override
  Future<Either<Failure, List<Product>>> getProducts() async => const Right([]);

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async =>
      const Right(null);
}
