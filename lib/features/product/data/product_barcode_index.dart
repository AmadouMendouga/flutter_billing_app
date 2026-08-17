import '../domain/entities/product.dart';

/// Per-user, write-through index used by the checkout scanner. Barcode keys
/// stay as strings so leading zeroes are never lost.
final class ProductBarcodeIndex {
  String? _uid;
  bool _fullyLoaded = false;
  final Map<String, Product> _byBarcode = {};
  final Map<String, Product> _byId = {};

  bool get isFullyLoaded => _fullyLoaded;

  void bind(String? uid) {
    if (_uid == uid) return;
    _uid = uid;
    _fullyLoaded = false;
    _byBarcode.clear();
    _byId.clear();
  }

  Product? find(String barcode) => _byBarcode[_normalize(barcode)];

  void replace(String uid, Iterable<Product> products) {
    bind(uid);
    _byBarcode.clear();
    _byId.clear();
    for (final product in products) {
      _put(product);
    }
    _fullyLoaded = true;
  }

  void upsert(String uid, Product product) {
    bind(uid);
    final previous = _byId[product.id];
    if (previous != null) {
      final previousKey = _normalize(previous.barcode);
      if (_byBarcode[previousKey]?.id == product.id) {
        _byBarcode.remove(previousKey);
      }
    }
    _put(product);
  }

  void upsertAll(String uid, Iterable<Product> products) {
    bind(uid);
    for (final product in products) {
      final previous = _byId[product.id];
      if (previous != null) {
        final previousKey = _normalize(previous.barcode);
        if (_byBarcode[previousKey]?.id == product.id) {
          _byBarcode.remove(previousKey);
        }
      }
      _put(product);
    }
  }

  void remove(String uid, String id) {
    bind(uid);
    final product = _byId.remove(id);
    if (product == null) return;
    final barcodeKey = _normalize(product.barcode);
    if (_byBarcode[barcodeKey]?.id == id) {
      _byBarcode.remove(barcodeKey);
    }
  }

  void _put(Product product) {
    _byId[product.id] = product;
    _byBarcode[_normalize(product.barcode)] = product;
  }

  String _normalize(String barcode) => barcode.trim();
}
