import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/entities/stock_sale_line.dart';
import 'package:billing_app/features/product/domain/failures/stock_failure.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';
import '../../domain/entities/billing_issue.dart';

export '../../domain/entities/billing_issue.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final CompleteSaleUseCase completeSaleUseCase;
  bool _saleInFlight = false;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.completeSaleUseCase,
  }) : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<CompleteSaleEvent>(_onCompleteSale);
    on<PrintReceiptEvent>(_onPrintReceipt);
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    final result = await getProductByBarcodeUseCase(event.barcode);
    result.fold(
      (failure) => _emitIssue(
        emit,
        BillingIssue(
          type: BillingIssueType.productNotFound,
          barcode: event.barcode,
        ),
      ),
      (product) => _addProductToCart(product, emit),
    );
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    _addProductToCart(event.product, emit);
  }

  void _addProductToCart(Product product, Emitter<BillingState> emit) {
    if (product.stock <= 0) {
      _emitIssue(
        emit,
        BillingIssue(
          type: BillingIssueType.outOfStock,
          productName: product.name,
        ),
      );
      return;
    }

    final cleanState = state.copyWith(
      clearError: true,
      clearIssue: true,
      saleCompleted: false,
    );

    final existingIndex = cleanState.cartItems
        .indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      final existingItem = cleanState.cartItems[existingIndex];
      if (existingItem.quantity >= product.stock) {
        _emitIssue(
          emit,
          BillingIssue(
            type: BillingIssueType.stockLimitReached,
            productName: product.name,
            availableStock: product.stock,
            requestedQuantity: existingItem.quantity + 1,
          ),
        );
        return;
      }
      final backendItems = List<CartItem>.from(cleanState.cartItems);
      backendItems[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(
        cleanState.copyWith(
          cartItems: backendItems,
          clearError: true,
          clearIssue: true,
        ),
      );
    } else {
      final newItem = CartItem(product: product);
      emit(
        cleanState.copyWith(
          cartItems: [...cleanState.cartItems, newItem],
          clearError: true,
          clearIssue: true,
        ),
      );
    }
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedList));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }

    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final item = state.cartItems[index];
      if (event.quantity > item.product.stock) {
        _emitIssue(
          emit,
          BillingIssue(
            type: BillingIssueType.stockLimitReached,
            productName: item.product.name,
            availableStock: item.product.stock,
            requestedQuantity: event.quantity,
          ),
        );
        return;
      }
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      emit(
        state.copyWith(
          cartItems: items,
          clearIssue: true,
          saleCompleted: false,
        ),
      );
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  Future<void> _onCompleteSale(
    CompleteSaleEvent event,
    Emitter<BillingState> emit,
  ) async {
    if (_saleInFlight || state.cartItems.isEmpty) return;
    _saleInFlight = true;
    final items = List<CartItem>.from(state.cartItems);
    emit(
      state.copyWith(
        isCompletingSale: true,
        saleCompleted: false,
        clearError: true,
        clearIssue: true,
      ),
    );

    try {
      final result = await completeSaleUseCase(
        items
            .map(
              (item) => StockSaleLine(
                productId: item.product.id,
                productName: item.product.name,
                quantity: item.quantity,
              ),
            )
            .toList(growable: false),
      );

      result.fold(
        (failure) {
          if (failure is ProductDeletedFailure) {
            emit(
              state.copyWith(
                isCompletingSale: false,
                saleCompleted: false,
                issue: BillingIssue(
                  type: BillingIssueType.saleProductMissing,
                  productName: failure.productName,
                  requestedQuantity: failure.requestedQuantity,
                ),
              ),
            );
            return;
          }
          if (failure is InsufficientStockFailure) {
            emit(
              state.copyWith(
                isCompletingSale: false,
                saleCompleted: false,
                issue: BillingIssue(
                  type: BillingIssueType.saleInsufficientStock,
                  productName: failure.productName,
                  availableStock: failure.availableQuantity,
                  requestedQuantity: failure.requestedQuantity,
                ),
              ),
            );
            return;
          }
          emit(
            state.copyWith(
              isCompletingSale: false,
              saleCompleted: false,
              issue: const BillingIssue(type: BillingIssueType.saleFailed),
            ),
          );
        },
        (_) => emit(const BillingState(saleCompleted: true)),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isCompletingSale: false,
          saleCompleted: false,
          issue: const BillingIssue(type: BillingIssueType.saleFailed),
        ),
      );
    } finally {
      _saleInFlight = false;
    }
  }

  void _emitIssue(Emitter<BillingState> emit, BillingIssue issue) {
    if (state.issue != null) {
      emit(state.copyWith(clearIssue: true));
    }
    emit(state.copyWith(issue: issue));
  }

  Future<void> _onPrintReceipt(
      PrintReceiptEvent event, Emitter<BillingState> emit) async {
    final printerHelper = PrinterHelper();

    if (!printerHelper.isConnected) {
      final savedMac = HiveDatabase.settingsBox.get('printer_mac');
      if (savedMac != null) {
        final connected = await printerHelper.connect(savedMac);
        if (!connected) {
          emit(state.copyWith(
              error: 'Failed to auto-connect to printer!', clearError: false));
          emit(state.copyWith(clearError: true));
          return;
        }
      } else {
        emit(state.copyWith(
            error: 'Printer not connected & no saved printer found!',
            clearError: false));
        emit(state.copyWith(clearError: true));
        return;
      }
    }

    emit(state.copyWith(
        isPrinting: true, printSuccess: false, clearError: true));

    try {
      final items = state.cartItems
          .map((item) => {
                'name': item.product.name,
                'qty': item.quantity,
                'price': item.product.price,
                'total': item.total,
              })
          .toList();

      await printerHelper.printReceipt(
          shopName: event.shopName,
          address1: event.address1,
          address2: event.address2,
          phone: event.phone,
          items: items,
          total: state.totalAmount,
          footer: event.footer);

      emit(state.copyWith(isPrinting: false, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(
          isPrinting: false, error: 'Print failed: $e', clearError: false));
      // Reset error instantly avoids sticky error
      emit(state.copyWith(clearError: true));
    }
  }
}
