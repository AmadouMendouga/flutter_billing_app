import 'package:equatable/equatable.dart';

enum BillingIssueType {
  productNotFound,
  outOfStock,
  stockLimitReached,
  saleProductMissing,
  saleInsufficientStock,
  saleFailed,
}

/// A presentation-neutral description of a billing problem.
///
/// Keeping structured values here lets each screen translate the message at
/// the edge instead of passing user-facing strings through the BLoC.
final class BillingIssue extends Equatable {
  const BillingIssue({
    required this.type,
    this.barcode = '',
    this.productName = '',
    this.availableStock = 0,
    this.requestedQuantity = 0,
  });

  final BillingIssueType type;
  final String barcode;
  final String productName;
  final int availableStock;
  final int requestedQuantity;

  @override
  List<Object> get props => [
    type,
    barcode,
    productName,
    availableStock,
    requestedQuantity,
  ];
}
