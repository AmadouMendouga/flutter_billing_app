import 'package:billing_app/features/product/data/product_barcode_index.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const first = Product(
    id: 'one',
    name: 'Premier',
    barcode: '00123',
    price: 100,
  );
  const updated = Product(
    id: 'one',
    name: 'Premier modifié',
    barcode: '00999',
    price: 150,
  );

  test('indexes normalized strings without losing leading zeroes', () {
    final index = ProductBarcodeIndex()..replace('user-a', [first]);

    expect(index.find(' 00123 '), first);
    expect(index.find('123'), isNull);
    expect(index.isFullyLoaded, isTrue);
  });

  test('updating a product removes its previous barcode', () {
    final index = ProductBarcodeIndex()..replace('user-a', [first]);

    index.upsert('user-a', updated);

    expect(index.find('00123'), isNull);
    expect(index.find('00999'), updated);
  });

  test('delete and user changes cannot leak indexed products', () {
    final index = ProductBarcodeIndex()..replace('user-a', [first]);

    index.remove('user-a', first.id);
    expect(index.find(first.barcode), isNull);

    index.upsert('user-a', first);
    index.bind('user-b');
    expect(index.find(first.barcode), isNull);
    expect(index.isFullyLoaded, isFalse);
  });
}
