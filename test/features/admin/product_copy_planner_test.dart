import 'package:billing_app/features/admin/domain/services/product_copy_planner.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copies only missing barcodes and always resets stock to zero', () {
    const source = [
      Product(id: 'one', name: 'Existing', barcode: '111', price: 10, stock: 5),
      Product(
        id: 'two',
        name: 'Copy me',
        barcode: ' abc ',
        price: 20,
        stock: 9,
      ),
      Product(id: 'three', name: 'Duplicate', barcode: 'ABC', price: 30),
      Product(id: 'four', name: 'No barcode', barcode: ' ', price: 40),
    ];
    const target = [
      Product(id: 'target', name: 'Already there', barcode: '111', price: 1),
    ];

    final plan = planMissingProductCopies(
      sourceProducts: source,
      targetProducts: target,
    );

    expect(plan.products, hasLength(1));
    expect(plan.products.single.name, 'Copy me');
    expect(plan.products.single.barcode, 'abc');
    expect(plan.products.single.stock, 0);
    expect(plan.report.sourceCount, 4);
    expect(plan.report.copiedCount, 1);
    expect(plan.report.existingBarcodes, ['111']);
    expect(plan.report.duplicateSourceBarcodes, ['ABC']);
    expect(plan.report.missingBarcodeCount, 1);
    expect(plan.report.skippedCount, 3);
  });
}
