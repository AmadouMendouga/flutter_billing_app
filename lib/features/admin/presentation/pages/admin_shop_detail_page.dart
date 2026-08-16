import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../product/domain/entities/product.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../domain/entities/admin_access.dart';
import '../../domain/entities/admin_shop.dart';
import '../../domain/repositories/admin_repository.dart';
import '../widgets/shop_status_badge.dart';

class AdminShopDetailPage extends StatefulWidget {
  final AdminRepository repository;
  final String adminUid;
  final AdminShop shop;

  const AdminShopDetailPage({
    super.key,
    required this.repository,
    required this.adminUid,
    required this.shop,
  });

  @override
  State<AdminShopDetailPage> createState() => _AdminShopDetailPageState();
}

class _AdminShopDetailPageState extends State<AdminShopDetailPage> {
  late final Stream<AdminAccess> _accessStream;
  late final Stream<List<AdminShop>> _shopsStream;
  late final Stream<List<Product>> _productsStream;
  bool _isWorking = false;

  @override
  void initState() {
    super.initState();
    _accessStream = widget.repository.watchAdminAccess(widget.adminUid);
    _shopsStream = widget.repository.watchShops();
    _productsStream = widget.repository.watchProducts(widget.shop.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<AdminAccess>(
      stream: _accessStream,
      builder: (context, accessSnapshot) {
        if (accessSnapshot.hasError) {
          return Scaffold(body: Center(child: Text(l10n.adminAccessDenied)));
        }
        if (!accessSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final access = accessSnapshot.requireData;
        if (!access.canOpenDashboard) {
          return Scaffold(body: Center(child: Text(l10n.shopAccessLoadFailed)));
        }
        return StreamBuilder<List<AdminShop>>(
          stream: _shopsStream,
          initialData: [widget.shop],
          builder: (context, shopsSnapshot) {
            final shops = shopsSnapshot.data ?? [widget.shop];
            final shop =
                shops.cast<AdminShop?>().firstWhere(
                  (candidate) => candidate?.id == widget.shop.id,
                  orElse: () => widget.shop,
                )!;
            return _buildPage(context, access, shop, shops);
          },
        );
      },
    );
  }

  Widget _buildPage(
    BuildContext context,
    AdminAccess access,
    AdminShop shop,
    List<AdminShop> allShops,
  ) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(shop.displayName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _ShopOverview(shop: shop),
          if (shop.status == ShopStatus.suspended) ...[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.shopSuspendedMessage),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (access.canReviewShops)
                PopupMenuButton<ShopStatus>(
                  key: const ValueKey('change-shop-status'),
                  enabled: !_isWorking,
                  onSelected: (status) => _changeStatus(shop, status),
                  itemBuilder:
                      (context) => [
                        if (shop.status != ShopStatus.active)
                          PopupMenuItem(
                            value: ShopStatus.active,
                            child: Text(l10n.approveShop),
                          ),
                        if (shop.status != ShopStatus.pending)
                          PopupMenuItem(
                            value: ShopStatus.pending,
                            child: Text(l10n.statusPending),
                          ),
                        if (shop.status != ShopStatus.suspended)
                          PopupMenuItem(
                            value: ShopStatus.suspended,
                            child: Text(l10n.suspendShop),
                          ),
                        if (shop.status != ShopStatus.rejected)
                          PopupMenuItem(
                            value: ShopStatus.rejected,
                            child: Text(l10n.rejectShop),
                          ),
                      ],
                  child: _ActionChip(
                    icon: Icons.admin_panel_settings,
                    label: l10n.shopStatus,
                    busy: _isWorking,
                  ),
                ),
              if (access.canCopyProducts)
                InkWell(
                  key: const ValueKey('copy-shop-products'),
                  onTap:
                      _isWorking ? null : () => _copyProducts(shop, allShops),
                  borderRadius: BorderRadius.circular(10),
                  child: _ActionChip(
                    icon: Icons.copy_all_outlined,
                    label: l10n.copyProducts,
                    busy: _isWorking,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            l10n.registeredProducts,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          StreamBuilder<List<Product>>(
            stream: _productsStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l10n.shopAccessLoadFailed),
                );
              }
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final products = snapshot.requireData;
              if (products.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(child: Text(l10n.noProducts)),
                );
              }
              return Card(
                margin: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var index = 0; index < products.length; index++) ...[
                      _ProductTile(product: products[index]),
                      if (index < products.length - 1) const Divider(height: 1),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(AdminShop shop, ShopStatus status) async {
    final request = await showDialog<_StatusChangeRequest>(
      context: context,
      builder: (context) => _StatusChangeDialog(status: status),
    );
    if (request == null || !mounted) return;
    setState(() => _isWorking = true);
    try {
      await widget.repository.setShopStatus(
        shopId: shop.id,
        status: status,
        adminUid: widget.adminUid,
        reason: request.reason,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).shopStatusUpdated)),
      );
    } catch (_) {
      if (mounted) _showError();
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  Future<void> _copyProducts(
    AdminShop sourceShop,
    List<AdminShop> allShops,
  ) async {
    final targets = allShops
        .where(
          (shop) =>
              shop.id != sourceShop.id && shop.status == ShopStatus.active,
        )
        .toList(growable: false);
    final targetId = await showDialog<String>(
      context: context,
      builder: (context) => _CopyProductsDialog(targets: targets),
    );
    if (targetId == null || !mounted) return;
    setState(() => _isWorking = true);
    try {
      final report = await widget.repository.copyMissingProducts(
        sourceShopId: sourceShop.id,
        targetShopId: targetId,
        adminUid: widget.adminUid,
      );
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.productCopyCompleted(report.copiedCount, report.skippedCount),
          ),
        ),
      );
    } catch (_) {
      if (mounted) _showError();
    } finally {
      if (mounted) setState(() => _isWorking = false);
    }
  }

  void _showError() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.adminActionFailed),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _ShopOverview extends StatelessWidget {
  final AdminShop shop;

  const _ShopOverview({required this.shop});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    shop.displayName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ShopStatusBadge(status: shop.status),
              ],
            ),
            const SizedBox(height: 16),
            _DetailLine(
              icon: Icons.person_outline,
              label: l10n.shopOwner,
              value: shop.ownerEmail,
            ),
            _DetailLine(
              icon: Icons.location_on_outlined,
              label: l10n.addressLine1,
              value: [
                shop.addressLine1,
                shop.addressLine2,
              ].where((part) => part.trim().isNotEmpty).join(', '),
            ),
            _DetailLine(
              icon: Icons.phone_outlined,
              label: l10n.phoneNumber,
              value: shop.phoneNumber,
            ),
            if (shop.statusReason.isNotEmpty)
              _DetailLine(
                icon: Icons.info_outline,
                label: l10n.statusReason,
                value: shop.statusReason,
              ),
          ],
        ),
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '$label : ${value.trim().isEmpty ? '—' : value.trim()}',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListTile(
      leading: const Icon(Icons.inventory_2_outlined),
      title: Text(product.name),
      subtitle: Text(
        '${l10n.barcode} : ${product.barcode}\n'
        '${l10n.stock} : ${product.stock}',
      ),
      isThreeLine: true,
      trailing: Text(
        product.price.toStringAsFixed(0),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool busy;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.busy,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (busy)
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _StatusChangeRequest {
  final String reason;

  const _StatusChangeRequest(this.reason);
}

class _StatusChangeDialog extends StatefulWidget {
  final ShopStatus status;

  const _StatusChangeDialog({required this.status});

  @override
  State<_StatusChangeDialog> createState() => _StatusChangeDialogState();
}

class _StatusChangeDialogState extends State<_StatusChangeDialog> {
  final _reasonController = TextEditingController();
  String? _error;

  bool get _requiresReason =>
      widget.status == ShopStatus.suspended ||
      widget.status == ShopStatus.rejected;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.shopStatus),
      content: TextField(
        key: const ValueKey('shop-status-reason'),
        controller: _reasonController,
        maxLines: 3,
        autofocus: _requiresReason,
        decoration: InputDecoration(
          labelText: l10n.administrativeReason,
          hintText: l10n.administrativeReasonHint,
          errorText: _error,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('confirm-shop-status'),
          onPressed: () {
            final reason = _reasonController.text.trim();
            if (_requiresReason && reason.isEmpty) {
              setState(() => _error = l10n.reasonRequired);
              return;
            }
            Navigator.of(context).pop(_StatusChangeRequest(reason));
          },
          child: Text(l10n.confirmAction),
        ),
      ],
    );
  }
}

class _CopyProductsDialog extends StatefulWidget {
  final List<AdminShop> targets;

  const _CopyProductsDialog({required this.targets});

  @override
  State<_CopyProductsDialog> createState() => _CopyProductsDialogState();
}

class _CopyProductsDialogState extends State<_CopyProductsDialog> {
  String? _targetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.copyProducts),
      content:
          widget.targets.isEmpty
              ? Text(l10n.noOtherShopAvailable)
              : DropdownButtonFormField<String>(
                key: const ValueKey('copy-products-target'),
                initialValue: _targetId,
                isExpanded: true,
                decoration: InputDecoration(labelText: l10n.destinationShop),
                hint: Text(l10n.destinationShop),
                items: [
                  for (final shop in widget.targets)
                    DropdownMenuItem(
                      value: shop.id,
                      child: Text(
                        shop.displayName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _targetId = value),
              ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('confirm-copy-products'),
          onPressed:
              _targetId == null
                  ? null
                  : () => Navigator.of(context).pop(_targetId),
          child: Text(l10n.copyProducts),
        ),
      ],
    );
  }
}
