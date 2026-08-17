import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../entities/stock_sale_line.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getProducts();
  Future<Either<Failure, Product>> getProductByBarcode(String barcode);
  Future<Either<Failure, void>> addProduct(Product product);
  Future<Either<Failure, void>> updateProduct(Product product);
  Future<Either<Failure, void>> deleteProduct(String id);
  Future<Either<Failure, List<Product>>> completeSale(
    List<StockSaleLine> lines,
  );
}
