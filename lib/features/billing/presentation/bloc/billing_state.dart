part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final BillingIssue? issue;
  final bool isPrinting;
  final bool printSuccess;
  final bool isCompletingSale;
  final bool saleCompleted;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.issue,
    this.isPrinting = false,
    this.printSuccess = false,
    this.isCompletingSale = false,
    this.saleCompleted = false,
  });

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.total);

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    BillingIssue? issue,
    bool clearIssue = false,
    bool? isPrinting,
    bool? printSuccess,
    bool? isCompletingSale,
    bool? saleCompleted,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      issue: clearIssue ? null : (issue ?? this.issue),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      isCompletingSale: isCompletingSale ?? this.isCompletingSale,
      saleCompleted: saleCompleted ?? this.saleCompleted,
    );
  }

  @override
  List<Object?> get props => [
    cartItems,
    error,
    issue,
    isPrinting,
    printSuccess,
    isCompletingSale,
    saleCompleted,
  ];
}
