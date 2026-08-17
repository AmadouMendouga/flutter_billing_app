import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../../product/presentation/bloc/product_bloc.dart';
import '../../domain/services/whatsapp_invoice_service.dart';
import '../bloc/billing_bloc.dart';
import '../services/invoice_message_builder.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({
    super.key,
    required this.whatsAppInvoiceService,
    this.messageBuilder = const InvoiceMessageBuilder(),
    this.now = DateTime.now,
  });

  final WhatsAppInvoiceService whatsAppInvoiceService;
  final InvoiceMessageBuilder messageBuilder;
  final DateTime Function() now;

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isSharingInvoice = false;

  Future<void> _promptForCustomerNumber(
    BillingState billingState,
    ShopState shopState,
  ) async {
    if (_isSharingInvoice) return;
    final localizations = AppLocalizations.of(context);
    if (billingState.cartItems.isEmpty) {
      _showError(localizations.emptyInvoiceCannotShare);
      return;
    }
    if (shopState is! ShopLoaded) {
      _showError(localizations.shopDetailsNotLoaded);
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => _WhatsAppNumberDialog(
            onSubmit:
                (phoneNumber) => _shareInvoice(
                  billingState: billingState,
                  shopState: shopState,
                  phoneNumber: phoneNumber,
                ),
          ),
    );
  }

  Future<bool> _shareInvoice({
    required BillingState billingState,
    required ShopLoaded shopState,
    required String phoneNumber,
  }) async {
    if (_isSharingInvoice) return false;
    final localizations = AppLocalizations.of(context);
    final message = widget.messageBuilder.build(
      localizations: localizations,
      shop: shopState.shop,
      items: billingState.cartItems,
      issuedAt: widget.now(),
    );
    setState(() => _isSharingInvoice = true);
    try {
      await widget.whatsAppInvoiceService.share(
        recipientPhoneNumber: phoneNumber,
        message: message,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      if (mounted) setState(() => _isSharingInvoice = false);
    }
  }

  void _showError(String message) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: scheme.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = scheme.outlineVariant;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        context.read<BillingBloc>().add(ClearCartEvent());
        context.go('/');
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context).checkoutTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.chevron_left,
              size: 28,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              context.read<BillingBloc>().add(ClearCartEvent());
              context.go('/');
            },
          ),
        ),
        body: BlocConsumer<BillingBloc, BillingState>(
          listenWhen:
              (previous, current) =>
                  (!previous.printSuccess && current.printSuccess) ||
                  (!previous.saleCompleted && current.saleCompleted) ||
                  (previous.issue != current.issue && current.issue != null),
          listener: (context, state) {
            if (state.saleCompleted) {
              context.read<ProductBloc>().add(LoadProducts());
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).saleCompleted),
                  backgroundColor: Colors.green,
                ),
              );
              context.go('/');
              return;
            }
            if (state.issue != null) {
              _showError(_localizedBillingIssue(state.issue!));
              return;
            }
            if (state.printSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).printedSuccessfully,
                  ),
                  backgroundColor: Colors.green,
                ),
              );
              // context.read<BillingBloc>().add(ClearCartEvent());
              // context.go('/');
            }
          },
          builder: (context, billingState) {
            return BlocBuilder<ShopBloc, ShopState>(
              builder: (context, shopState) {
                String upiId = '';

                if (shopState is ShopLoaded) {
                  upiId = shopState.shop.upiId;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Column(
                          children: [
                            // Table
                            Container(
                              decoration: BoxDecoration(
                                color: scheme.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: scheme.shadow.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Table(
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                      color: borderColor,
                                    ),
                                    bottom: BorderSide(color: borderColor),
                                  ),
                                  children: [
                                    // Header row
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color: scheme.surfaceContainerHigh,
                                        border: Border(
                                          bottom: BorderSide(
                                            color: borderColor,
                                          ),
                                        ),
                                      ),
                                      children: [
                                        _buildHeaderCell(
                                          context,
                                          AppLocalizations.of(
                                            context,
                                          ).productName,
                                          TextAlign.left,
                                        ),
                                        _buildHeaderCell(
                                          context,
                                          AppLocalizations.of(context).price,
                                          TextAlign.right,
                                        ),
                                        _buildHeaderCell(
                                          context,
                                          AppLocalizations.of(context).total,
                                          TextAlign.right,
                                        ),
                                      ],
                                    ),
                                    // Items rows
                                    ...billingState.cartItems.map((item) {
                                      return TableRow(
                                        children: [
                                          _buildDataCell(
                                            context,
                                            '${item.quantity} x ${item.product.name}',
                                            TextAlign.left,
                                          ),
                                          _buildDataCell(
                                            context,
                                            '${item.product.price.toStringAsFixed(0)} FCFA',
                                            TextAlign.right,
                                            isSubtitle: true,
                                          ),
                                          _buildDataCell(
                                            context,
                                            '${item.total.toStringAsFixed(0)} FCFA',
                                            TextAlign.right,
                                            isBold: true,
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            const SizedBox(
                              height: 120,
                            ), // padding for bottom fixed bar
                          ],
                        ),
                      ),
                    ),

                    // Bottom Bar
                    Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(24),
                          right: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                upiId.isNotEmpty
                                    ? Column(
                                      children: [
                                        Text(
                                          AppLocalizations.of(
                                            context,
                                          ).scanToPayOrangeMoney,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: scheme.onSurface,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          width: 180,
                                          height: 180,
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: PrettyQrView.data(
                                            data:
                                                'tel:%23150*11*$upiId*${billingState.totalAmount.toStringAsFixed(0)}%23',
                                          ),
                                        ),
                                      ],
                                    )
                                    : const SizedBox.shrink(),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      AppLocalizations.of(context).total,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: scheme.onSurfaceVariant,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    Text(
                                      '${billingState.totalAmount.toStringAsFixed(0)} FCFA',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                        color: scheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                            child: Column(
                              children: [
                                _buildActionButton(
                                  key: const ValueKey('send-invoice-whatsapp'),
                                  onPressed:
                                      _isSharingInvoice ||
                                              billingState.isPrinting ||
                                              billingState.isCompletingSale
                                          ? null
                                          : () => _promptForCustomerNumber(
                                            billingState,
                                            shopState,
                                          ),
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label:
                                      _isSharingInvoice
                                          ? AppLocalizations.of(
                                            context,
                                          ).openingWhatsApp
                                          : AppLocalizations.of(
                                            context,
                                          ).sendInvoiceWhatsApp,
                                  isLoading: _isSharingInvoice,
                                  backgroundColor: const Color(0xFF075E54),
                                  foregroundColor: Colors.white,
                                ),
                                const SizedBox(height: 12),
                                _buildActionButton(
                                  onPressed:
                                      billingState.isPrinting ||
                                              _isSharingInvoice ||
                                              billingState.isCompletingSale
                                          ? null
                                          : () {
                                            if (shopState is ShopLoaded) {
                                              context.read<BillingBloc>().add(
                                                PrintReceiptEvent(
                                                  shopName: shopState.shop.name,
                                                  address1:
                                                      shopState
                                                          .shop
                                                          .addressLine1,
                                                  address2:
                                                      shopState
                                                          .shop
                                                          .addressLine2,
                                                  phone:
                                                      shopState
                                                          .shop
                                                          .phoneNumber,
                                                  footer:
                                                      shopState.shop.footerText,
                                                ),
                                              );
                                            } else {
                                              _showError(
                                                AppLocalizations.of(
                                                  context,
                                                ).shopDetailsNotLoaded,
                                              );
                                            }
                                          },
                                  icon: Icons.print,
                                  label:
                                      AppLocalizations.of(context).printReceipt,
                                  isLoading: billingState.isPrinting,
                                  backgroundColor: scheme.primary,
                                  foregroundColor: scheme.onPrimary,
                                ),
                                const SizedBox(height: 12),
                                _buildActionButton(
                                  key: const ValueKey('complete-sale-button'),
                                  onPressed:
                                      billingState.cartItems.isEmpty ||
                                              billingState.isPrinting ||
                                              _isSharingInvoice ||
                                              billingState.isCompletingSale
                                          ? null
                                          : () =>
                                              context.read<BillingBloc>().add(
                                                const CompleteSaleEvent(),
                                              ),
                                  icon: Icons.check_circle_outline_rounded,
                                  label:
                                      billingState.isCompletingSale
                                          ? AppLocalizations.of(
                                            context,
                                          ).completingSale
                                          : AppLocalizations.of(
                                            context,
                                          ).completeSale,
                                  isLoading: billingState.isCompletingSale,
                                  backgroundColor: const Color(0xFF2E7D32),
                                  foregroundColor: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _localizedBillingIssue(BillingIssue issue) {
    final l10n = AppLocalizations.of(context);
    return switch (issue.type) {
      BillingIssueType.productNotFound => l10n.barcodeNotFound(issue.barcode),
      BillingIssueType.outOfStock => l10n.productOutOfStock(issue.productName),
      BillingIssueType.stockLimitReached => l10n.stockLimitReached(
        issue.productName,
        issue.availableStock,
      ),
      BillingIssueType.saleProductMissing => l10n.saleProductMissing(
        issue.productName,
      ),
      BillingIssueType.saleInsufficientStock => l10n.saleInsufficientStock(
        issue.productName,
        issue.availableStock,
        issue.requestedQuantity,
      ),
      BillingIssueType.saleFailed => l10n.saleFailed,
    };
  }

  Widget _buildHeaderCell(BuildContext context, String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        text.toUpperCase(),
        textAlign: align,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    Key? key,
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required bool isLoading,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return SizedBox(
      key: key,
      width: double.infinity,
      height: 50,
      child: FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.55),
          disabledForegroundColor: foregroundColor.withValues(alpha: 0.85),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        icon:
            isLoading
                ? SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foregroundColor,
                  ),
                )
                : Icon(icon),
        label: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDataCell(
    BuildContext context,
    String text,
    TextAlign align, {
    bool isBold = false,
    bool isSubtitle = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isSubtitle ? 12 : 14,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          color:
              isSubtitle
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}

typedef _SubmitWhatsAppNumber = Future<bool> Function(String phoneNumber);

class _WhatsAppNumberDialog extends StatefulWidget {
  const _WhatsAppNumberDialog({required this.onSubmit});

  final _SubmitWhatsAppNumber onSubmit;

  @override
  State<_WhatsAppNumberDialog> createState() => _WhatsAppNumberDialogState();
}

class _WhatsAppNumberDialogState extends State<_WhatsAppNumberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isSubmitting = false;
  bool _shareFailed = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !_formKey.currentState!.validate()) return;
    final phoneNumber = normalizeWhatsAppPhoneNumber(_phoneController.text)!;
    setState(() {
      _isSubmitting = true;
      _shareFailed = false;
    });

    final didOpen = await widget.onSubmit(phoneNumber);
    if (!mounted) return;
    if (didOpen) {
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _isSubmitting = false;
      _shareFailed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    const whatsAppGreen = Color(0xFF075E54);

    return PopScope(
      canPop: !_isSubmitting,
      child: AlertDialog(
        icon: const Icon(
          Icons.chat_bubble_outline_rounded,
          color: whatsAppGreen,
          size: 36,
        ),
        title: Text(
          localizations.clientWhatsAppNumber,
          textAlign: TextAlign.center,
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                localizations.clientWhatsAppNumberHelp,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const ValueKey('whatsapp-phone-field'),
                controller: _phoneController,
                autofocus: true,
                enabled: !_isSubmitting,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                maxLength: 24,
                decoration: InputDecoration(
                  hintText: localizations.clientWhatsAppNumberHint,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return localizations.clientPhoneNumberRequired;
                  }
                  if (normalizeWhatsAppPhoneNumber(value) == null) {
                    return localizations.invalidWhatsAppNumber;
                  }
                  return null;
                },
                onFieldSubmitted: (_) {
                  if (!_isSubmitting) _submit();
                },
              ),
              if (_shareFailed) ...[
                const SizedBox(height: 12),
                Text(
                  localizations.whatsAppShareFailed,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
            child: Text(localizations.cancel),
          ),
          FilledButton.icon(
            key: const ValueKey('continue-to-whatsapp'),
            onPressed: _isSubmitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: whatsAppGreen,
              foregroundColor: Colors.white,
              disabledBackgroundColor: whatsAppGreen.withValues(alpha: 0.55),
              disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
            ),
            icon:
                _isSubmitting
                    ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Icon(Icons.arrow_forward_rounded),
            label: Text(
              _isSubmitting
                  ? localizations.openingWhatsApp
                  : localizations.continueToWhatsApp,
            ),
          ),
        ],
      ),
    );
  }
}
