import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/utils/app_validators.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _scanQR(List<Product> products) async {
    final barcode = await context.push<String>('/scanner');
    if (barcode == null || barcode.isEmpty) return;
    if (!mounted) return;

    final matchedProduct =
        products.where((p) => p.barcode == barcode).firstOrNull;
    if (matchedProduct != null) {
      await _showRestockDialog(matchedProduct);
    } else {
      _searchController.text =
          barcode; // If not found, just put barcode in search
    }
  }

  Future<void> _showRestockDialog(Product product) async {
    final quantityToAdd = await showDialog<int>(
      context: context,
      builder: (dialogContext) => _RestockDialog(product: product),
    );

    if (quantityToAdd == null || !mounted) return;

    context.read<ProductBloc>().add(
      UpdateProduct(
        Product(
          id: product.id,
          name: product.name,
          barcode: product.barcode,
          price: product.price,
          stock: product.stock + quantityToAdd,
        ),
      ),
    );
  }

  String _localizedProductMessage(
    AppLocalizations localizations,
    String message,
  ) {
    return switch (message) {
      'Product added successfully' => localizations.productAdded,
      'Product updated successfully' => localizations.productUpdated,
      'Product deleted successfully' => localizations.productDeleted,
      _ => message,
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = scheme.outlineVariant;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 28,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context).products,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _searchController,
                            textCapitalization: TextCapitalization.words,
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context).searchProducts,
                              prefixIcon: Icon(
                                Icons.search,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            validator: AppValidators.required(
                              AppLocalizations.of(context).requiredField,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: scheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.qr_code_scanner,
                              color: scheme.onPrimaryContainer,
                            ),
                            onPressed: () => _scanQR(state.products),
                            padding: const EdgeInsets.all(15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context).openScannerHint,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: BlocConsumer<ProductBloc, ProductState>(
              listener: (context, state) {
                if (state.status == ProductStatus.success &&
                    state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _localizedProductMessage(
                          AppLocalizations.of(context),
                          state.message!,
                        ),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state.status == ProductStatus.error &&
                    state.message != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message!),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == ProductStatus.loading &&
                    state.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.products.isEmpty) {
                  if (state.status == ProductStatus.error) {
                    return Center(
                      child: Text(
                        AppLocalizations.of(
                          context,
                        ).errorMessage(state.message ?? ''),
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(AppLocalizations.of(context).noProducts),
                        const SizedBox(height: 6),
                        Text(AppLocalizations.of(context).addFirstProduct),
                      ],
                    ),
                  );
                }

                final filteredProducts =
                    state.products
                        .where(
                          (product) =>
                              product.name.toLowerCase().contains(
                                _searchQuery,
                              ) ||
                              product.barcode.toLowerCase().contains(
                                _searchQuery,
                              ),
                        )
                        .toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Text(
                      AppLocalizations.of(context).noMatchingProducts,
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 8,
                    bottom: 100,
                  ),
                  itemCount: filteredProducts.length,
                  separatorBuilder:
                      (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    final isOutOfStock = product.stock == 0;
                    final isLowStock = product.stock > 0 && product.stock <= 5;
                    final stockLabel =
                        isOutOfStock
                            ? AppLocalizations.of(context).outOfStock
                            : isLowStock
                            ? AppLocalizations.of(
                              context,
                            ).lowStock(product.stock)
                            : AppLocalizations.of(
                              context,
                            ).stockAvailable(product.stock);
                    final stockBackgroundColor =
                        isOutOfStock
                            ? scheme.errorContainer
                            : isLowStock
                            ? scheme.tertiaryContainer
                            : scheme.primaryContainer;
                    final stockForegroundColor =
                        isOutOfStock
                            ? scheme.onErrorContainer
                            : isLowStock
                            ? scheme.onTertiaryContainer
                            : scheme.onPrimaryContainer;
                    return Container(
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.shadow.withValues(alpha: 0.08),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${product.price.toStringAsFixed(0)} FCFA',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Semantics(
                                  key: ValueKey(
                                    'product-stock-badge-${product.id}',
                                  ),
                                  label: stockLabel,
                                  child: ExcludeSemantics(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: stockBackgroundColor,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        border: Border.all(
                                          color: stockForegroundColor
                                              .withValues(alpha: 0.22),
                                        ),
                                      ),
                                      child: Text(
                                        stockLabel,
                                        style: TextStyle(
                                          color: stockForegroundColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: scheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit_rounded,
                                    color: scheme.onPrimaryContainer,
                                    size: 20,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  onPressed: () {
                                    context.push(
                                      '/products/edit/${product.id}',
                                      extra: product,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: scheme.errorContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete_outline_rounded,
                                    color: scheme.onErrorContainer,
                                    size: 20,
                                  ),
                                  constraints: const BoxConstraints(),
                                  padding: const EdgeInsets.all(8),
                                  onPressed:
                                      () => _confirmDelete(context, product),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/products/add'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (innerContext) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).deleteProductTitle),
          content: Text(
            AppLocalizations.of(context).deleteProductBody(product.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(innerContext),
              child: Text(AppLocalizations.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                context.read<ProductBloc>().add(DeleteProduct(product.id));
                Navigator.pop(innerContext);
              },
              child: Text(
                AppLocalizations.of(context).delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RestockDialog extends StatefulWidget {
  const _RestockDialog({required this.product});

  final Product product;

  @override
  State<_RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<_RestockDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, int.parse(_quantityController.text.trim()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.restockDialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(l10n.restockCurrentStock(widget.product.stock)),
            const SizedBox(height: 16),
            TextFormField(
              key: const ValueKey('restock-quantity-field'),
              controller: _quantityController,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.restockQuantityLabel,
                hintText: '0',
                prefixIcon: const Icon(Icons.inventory_2_outlined),
              ),
              validator: (value) {
                final quantity = int.tryParse(value?.trim() ?? '');
                if (quantity == null || quantity <= 0) {
                  return l10n.invalidRestockQuantity;
                }
                return null;
              },
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.restockAddButton)),
      ],
    );
  }
}
