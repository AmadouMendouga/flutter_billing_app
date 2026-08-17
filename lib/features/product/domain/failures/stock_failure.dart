import '../../../../core/error/failure.dart';

sealed class StockFailure extends Failure {
  const StockFailure({
    required String message,
    required this.productId,
    required this.productName,
    required this.requestedQuantity,
  }) : super(message);

  final String productId;
  final String productName;
  final int requestedQuantity;

  @override
  List<Object> get props => [
    message,
    productId,
    productName,
    requestedQuantity,
  ];
}

/// The product existed when it was added to the cart but no longer exists
/// when the sale is finalized.
final class ProductDeletedFailure extends StockFailure {
  ProductDeletedFailure({
    required String productId,
    required String productName,
    required int requestedQuantity,
  }) : super(
         message:
             'Product no longer exists: $productName '
             '($productId), requested: $requestedQuantity',
         productId: productId,
         productName: productName,
         requestedQuantity: requestedQuantity,
       );
}

/// The authoritative Firestore stock is lower than the quantity being sold.
final class InsufficientStockFailure extends StockFailure {
  InsufficientStockFailure({
    required String productId,
    required String productName,
    required this.availableQuantity,
    required int requestedQuantity,
  }) : super(
         message:
             'Insufficient stock for $productName ($productId): '
             '$availableQuantity available, $requestedQuantity requested',
         productId: productId,
         productName: productName,
         requestedQuantity: requestedQuantity,
       );

  final int availableQuantity;

  @override
  List<Object> get props => [...super.props, availableQuantity];
}

/// Guards the repository boundary against malformed cart quantities.
final class InvalidStockQuantityFailure extends StockFailure {
  InvalidStockQuantityFailure({
    required String productId,
    required String productName,
    required int requestedQuantity,
  }) : super(
         message:
             'Invalid sale quantity for $productName ($productId): '
             '$requestedQuantity',
         productId: productId,
         productName: productName,
         requestedQuantity: requestedQuantity,
       );
}
