import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/shop.dart';

class ShopAccessStatusPage extends StatelessWidget {
  const ShopAccessStatusPage({
    super.key,
    required this.shop,
    required this.onLogOut,
    this.onCompleteProfile,
    this.onRetry,
  });

  final Shop shop;
  final VoidCallback onLogOut;
  final VoidCallback? onCompleteProfile;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final presentation = _presentation(l10n, scheme);

    return Scaffold(
      key: ValueKey('shop-status-${shop.status.firestoreValue}'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: presentation.containerColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          presentation.icon,
                          size: 46,
                          color: presentation.foregroundColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        presentation.title,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        presentation.message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      if (shop.statusReason.trim().isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: scheme.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.statusReason,
                                style: Theme.of(context).textTheme.labelLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              Text(shop.statusReason.trim()),
                            ],
                          ),
                        ),
                      ],
                      if (shop.status == ShopStatus.pending) ...[
                        const SizedBox(height: 16),
                        Text(
                          l10n.shopPendingHelp,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                        if (onCompleteProfile != null) ...[
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            key: const ValueKey(
                              'complete-pending-shop-profile',
                            ),
                            onPressed: onCompleteProfile,
                            icon: const Icon(Icons.edit_outlined),
                            label: Text(l10n.completeShopProfile),
                          ),
                        ],
                      ],
                      if (onRetry != null) ...[
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.refreshStatus),
                        ),
                      ],
                      const SizedBox(height: 8),
                      TextButton.icon(
                        key: const ValueKey('shop-status-logout'),
                        onPressed: onLogOut,
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(l10n.logOut),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _StatusPresentation _presentation(AppLocalizations l10n, ColorScheme scheme) {
    return switch (shop.status) {
      ShopStatus.pending => _StatusPresentation(
        icon: Icons.hourglass_top_rounded,
        title: l10n.shopPendingTitle,
        message: l10n.shopPendingMessage,
        containerColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      ),
      ShopStatus.suspended => _StatusPresentation(
        icon: Icons.storefront_outlined,
        title: l10n.shopSuspendedTitle,
        message: l10n.shopSuspendedMessage,
        containerColor: scheme.errorContainer,
        foregroundColor: scheme.onErrorContainer,
      ),
      ShopStatus.rejected => _StatusPresentation(
        icon: Icons.cancel_outlined,
        title: l10n.shopRejectedTitle,
        message: l10n.shopRejectedMessage,
        containerColor: scheme.errorContainer,
        foregroundColor: scheme.onErrorContainer,
      ),
      ShopStatus.active => _StatusPresentation(
        icon: Icons.check_circle_outline_rounded,
        title: l10n.statusActive,
        message: '',
        containerColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
      ),
    };
  }
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.icon,
    required this.title,
    required this.message,
    required this.containerColor,
    required this.foregroundColor,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color containerColor;
  final Color foregroundColor;
}
