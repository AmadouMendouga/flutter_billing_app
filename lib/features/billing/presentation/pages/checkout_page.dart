import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../shop/presentation/bloc/shop_bloc.dart';
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

  Future<void> _shareInvoice(
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

    final message = widget.messageBuilder.build(
      localizations: localizations,
      shop: shopState.shop,
      items: billingState.cartItems,
      issuedAt: widget.now(),
    );
    setState(() => _isSharingInvoice = true);
    try {
      await widget.whatsAppInvoiceService.share(message);
    } catch (_) {
      if (mounted) _showError(localizations.whatsAppShareFailed);
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
          listener: (context, state) {
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
                                              billingState.isPrinting
                                          ? null
                                          : () => _shareInvoice(
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
                                              _isSharingInvoice
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
