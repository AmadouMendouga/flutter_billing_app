import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// Reusable delivery hint for every flow that sends an email to the user.
class EmailDeliveryHint extends StatelessWidget {
  const EmailDeliveryHint({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      child: Container(
        key: const ValueKey('email-spam-folder-hint'),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline_rounded, size: 20, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.checkSpamFolder,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
