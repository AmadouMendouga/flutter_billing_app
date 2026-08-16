import '../../../product/domain/entities/product.dart';
import '../entities/product_copy_report.dart';

class ProductCopyPlan {
  final List<Product> products;
  final ProductCopyReport report;

  const ProductCopyPlan({required this.products, required this.report});
}

String canonicalProductBarcode(String barcode) => barcode.trim().toUpperCase();

ProductCopyPlan planMissingProductCopies({
  required Iterable<Product> sourceProducts,
  required Iterable<Product> targetProducts,
}) {
  final source = sourceProducts.toList(growable: false);
  final targetBarcodes =
      targetProducts
          .map((product) => canonicalProductBarcode(product.barcode))
          .where((barcode) => barcode.isNotEmpty)
          .toSet();
  final plannedBarcodes = <String>{};
  final products = <Product>[];
  final existing = <String>[];
  final duplicateSource = <String>[];
  var missingBarcodeCount = 0;

  for (final product in source) {
    final barcode = canonicalProductBarcode(product.barcode);
    if (barcode.isEmpty) {
      missingBarcodeCount++;
      continue;
    }
    if (targetBarcodes.contains(barcode)) {
      existing.add(product.barcode.trim());
      continue;
    }
    if (!plannedBarcodes.add(barcode)) {
      duplicateSource.add(product.barcode.trim());
      continue;
    }
    products.add(
      Product(
        id: product.id,
        name: product.name,
        barcode: product.barcode.trim(),
        price: product.price,
        stock: 0,
      ),
    );
  }

  return ProductCopyPlan(
    products: List.unmodifiable(products),
    report: ProductCopyReport(
      sourceCount: source.length,
      copiedCount: products.length,
      existingBarcodes: List.unmodifiable(existing),
      duplicateSourceBarcodes: List.unmodifiable(duplicateSource),
      missingBarcodeCount: missingBarcodeCount,
    ),
  );
}
