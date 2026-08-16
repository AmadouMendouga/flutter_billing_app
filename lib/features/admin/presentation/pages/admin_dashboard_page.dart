import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../domain/entities/admin_access.dart';
import '../../domain/entities/admin_shop.dart';
import '../../domain/repositories/admin_repository.dart';
import '../widgets/shop_status_badge.dart';

class AdminDashboardPage extends StatefulWidget {
  final AdminRepository repository;
  final String adminUid;
  final ValueChanged<AdminShop> onOpenShop;
  final VoidCallback? onSignOut;

  const AdminDashboardPage({
    super.key,
    required this.repository,
    required this.adminUid,
    required this.onOpenShop,
    this.onSignOut,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _searchController = TextEditingController();
  late final Stream<AdminAccess> _accessStream;
  late final Stream<List<AdminShop>> _shopsStream;
  ShopStatus? _filter;

  @override
  void initState() {
    super.initState();
    _accessStream = widget.repository.watchAdminAccess(widget.adminUid);
    _shopsStream = widget.repository.watchShops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<AdminAccess>(
      stream: _accessStream,
      builder: (context, accessSnapshot) {
        if (accessSnapshot.hasError) {
          return _AdminMessageScaffold(message: l10n.shopAccessLoadFailed);
        }
        if (!accessSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final access = accessSnapshot.requireData;
        if (!access.canOpenDashboard) {
          return _AdminMessageScaffold(
            key: const ValueKey('admin-access-denied'),
            message: l10n.adminAccessDenied,
            icon: Icons.admin_panel_settings_outlined,
            action: widget.onSignOut,
            actionLabel: l10n.logOut,
          );
        }
        return _buildDashboard(context, access);
      },
    );
  }

  Widget _buildDashboard(BuildContext context, AdminAccess access) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminDashboard),
        actions: [
          if (widget.onSignOut != null)
            IconButton(
              tooltip: l10n.logOut,
              onPressed: widget.onSignOut,
              icon: const Icon(Icons.logout),
            ),
        ],
      ),
      body: StreamBuilder<List<AdminShop>>(
        stream: _shopsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.shopAccessLoadFailed));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final shops = snapshot.requireData;
          final query = _searchController.text.trim().toLowerCase();
          final visibleShops = shops
              .where((shop) {
                final matchesStatus = _filter == null || shop.status == _filter;
                final searchable =
                    '${shop.name} ${shop.ownerEmail} '
                            '${shop.phoneNumber} ${shop.id}'
                        .toLowerCase();
                return matchesStatus &&
                    (query.isEmpty || searchable.contains(query));
              })
              .toList(growable: false);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(child: _StatusSummary(shops: shops)),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    key: const ValueKey('admin-shop-search'),
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: l10n.adminDashboardSubtitle,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.clear),
                              ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _filterChip(context, null, l10n.allShops),
                      const SizedBox(width: 8),
                      _filterChip(
                        context,
                        ShopStatus.pending,
                        l10n.pendingShops,
                      ),
                      const SizedBox(width: 8),
                      _filterChip(context, ShopStatus.active, l10n.activeShops),
                      const SizedBox(width: 8),
                      _filterChip(
                        context,
                        ShopStatus.suspended,
                        l10n.suspendedShops,
                      ),
                      const SizedBox(width: 8),
                      _filterChip(
                        context,
                        ShopStatus.rejected,
                        l10n.rejectedShops,
                      ),
                    ],
                  ),
                ),
              ),
              if (visibleShops.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(l10n.noShopsFound)),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList.separated(
                    itemCount: visibleShops.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final shop = visibleShops[index];
                      return _ShopCard(
                        shop: shop,
                        onTap: () => widget.onOpenShop(shop),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterChip(BuildContext context, ShopStatus? status, String label) {
    return FilterChip(
      key: ValueKey('shop-filter-${status?.name ?? 'all'}'),
      label: Text(label),
      selected: _filter == status,
      onSelected: (_) => setState(() => _filter = status),
    );
  }
}

class _StatusSummary extends StatelessWidget {
  final List<AdminShop> shops;

  const _StatusSummary({required this.shops});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    int count(ShopStatus status) =>
        shops.where((shop) => shop.status == status).length;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: l10n.pendingShops,
            value: count(ShopStatus.pending),
            icon: Icons.hourglass_top,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: l10n.activeShops,
            value: count(ShopStatus.active),
            icon: Icons.storefront,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryCard(
            label: l10n.suspendedShops,
            value: count(ShopStatus.suspended),
            icon: Icons.block,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final AdminShop shop;
  final VoidCallback onTap;

  const _ShopCard({required this.shop, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        key: ValueKey('admin-shop-${shop.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  shop.displayName.isEmpty
                      ? '?'
                      : shop.displayName[0].toUpperCase(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            shop.displayName,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        ShopStatusBadge(status: shop.status),
                      ],
                    ),
                    if (shop.ownerEmail.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        '${l10n.shopOwner} : ${shop.ownerEmail}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (shop.statusReason.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        shop.statusReason,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMessageScaffold extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? action;
  final String? actionLabel;

  const _AdminMessageScaffold({
    super.key,
    required this.message,
    this.icon = Icons.error_outline,
    this.action,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              if (action != null && actionLabel != null) ...[
                const SizedBox(height: 20),
                OutlinedButton(onPressed: action, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
