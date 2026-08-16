import 'package:equatable/equatable.dart';

class ProductCopyReport extends Equatable {
  final int sourceCount;
  final int copiedCount;
  final List<String> existingBarcodes;
  final List<String> duplicateSourceBarcodes;
  final int missingBarcodeCount;

  const ProductCopyReport({
    required this.sourceCount,
    required this.copiedCount,
    required this.existingBarcodes,
    required this.duplicateSourceBarcodes,
    required this.missingBarcodeCount,
  });

  int get skippedCount =>
      existingBarcodes.length +
      duplicateSourceBarcodes.length +
      missingBarcodeCount;

  @override
  List<Object?> get props => [
    sourceCount,
    copiedCount,
    existingBarcodes,
    duplicateSourceBarcodes,
    missingBarcodeCount,
  ];
}
