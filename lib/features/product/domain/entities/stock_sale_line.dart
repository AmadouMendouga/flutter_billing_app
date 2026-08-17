import 'package:equatable/equatable.dart';

/// A product quantity that must be removed from stock when a sale is
/// completed.
///
/// This deliberately contains only product identity and quantity. The
/// repository reloads the authoritative product document inside the Firestore
/// transaction before changing its stock.
final class StockSaleLine extends Equatable {
  const StockSaleLine({
    required this.productId,
    required this.productName,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final int quantity;

  StockSaleLine copyWith({
    String? productId,
    String? productName,
    int? quantity,
  }) {
    return StockSaleLine(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object> get props => [productId, productName, quantity];
}

/// Normalizes product identifiers and merges duplicate sale lines.
///
/// A cart normally has one line per product, but consolidating here keeps the
/// stock transaction safe when called by another client or after a future cart
/// implementation change.
List<StockSaleLine> consolidateStockSaleLines(Iterable<StockSaleLine> lines) {
  final consolidated = <String, StockSaleLine>{};

  for (final line in lines) {
    final productId = line.productId.trim();
    final productName = line.productName.trim();
    final previous = consolidated[productId];

    consolidated[productId] = StockSaleLine(
      productId: productId,
      productName:
          productName.isNotEmpty
              ? productName
              : (previous?.productName ?? productId),
      quantity: (previous?.quantity ?? 0) + line.quantity,
    );
  }

  return List<StockSaleLine>.unmodifiable(consolidated.values);
}
