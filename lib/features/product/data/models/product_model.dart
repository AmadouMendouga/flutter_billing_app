import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.barcode,
    required super.price,
    required super.stock,
  });

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: product.barcode.trim(),
      price: product.price,
      stock: product.stock,
    );
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      barcode: (map['barcode'] as String? ?? '').trim(),
      price: (map['price'] as num?)?.toDouble() ?? 0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'barcode': barcode.trim(),
      'price': price,
      'stock': stock,
    };
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      stock: stock,
    );
  }
}
