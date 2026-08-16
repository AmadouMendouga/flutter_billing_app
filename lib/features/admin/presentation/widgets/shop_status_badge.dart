import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../shop/domain/entities/shop.dart';

class ShopStatusBadge extends StatelessWidget {
  final ShopStatus status;

  const ShopStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (label, background, foreground) = switch (status) {
      ShopStatus.pending => (
        l10n.statusPending,
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
      ),
      ShopStatus.active => (
        l10n.statusActive,
        const Color(0xFFD7F5E1),
        const Color(0xFF075E36),
      ),
      ShopStatus.suspended => (
        l10n.statusSuspended,
        scheme.errorContainer,
        scheme.onErrorContainer,
      ),
      ShopStatus.rejected => (
        l10n.statusRejected,
        scheme.surfaceContainerHighest,
        scheme.onSurfaceVariant,
      ),
    };
    return Semantics(
      label: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
