import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../domain/entities/app_preferences.dart';
import '../bloc/app_preferences_cubit.dart';
import '../bloc/printer_bloc.dart';
import '../bloc/printer_event.dart';
import '../bloc/printer_state.dart';
import '../widgets/profile_avatar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    context.read<PrinterBloc>().add(InitPrinterEvent());
  }

  String _languageLabel(AppLocalizations l10n, AppLanguage language) {
    return switch (language) {
      AppLanguage.system => l10n.deviceDefault,
      AppLanguage.english => l10n.english,
      AppLanguage.french => l10n.french,
    };
  }

  Future<void> _showLanguagePicker() async {
    final pageContext = context;
    await showModalBottomSheet<void>(
      context: pageContext,
      showDragHandle: true,
      useSafeArea: true,
      builder: (sheetContext) {
        return BlocBuilder<AppPreferencesCubit, AppPreferences>(
          builder: (context, preferences) {
            final l10n = AppLocalizations.of(context);
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.language,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RadioGroup<AppLanguage>(
                    groupValue: preferences.language,
                    onChanged: (value) async {
                      if (value == null) return;
                      final success = await pageContext
                          .read<AppPreferencesCubit>()
                          .setLanguage(value);
                      if (!sheetContext.mounted) return;
                      Navigator.of(sheetContext).pop();
                      if (!success && pageContext.mounted) {
                        _showPreferenceError(pageContext);
                      }
                    },
                    child: Column(
                      children: [
                        for (final language in AppLanguage.values)
                          RadioListTile<AppLanguage>(
                            value: language,
                            title: Text(_languageLabel(l10n, language)),
                            secondary: Icon(switch (language) {
                              AppLanguage.system => Icons.phone_android,
                              AppLanguage.english => Icons.language,
                              AppLanguage.french => Icons.translate,
                            }),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPreferenceError(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).preferenceSaveFailed),
        backgroundColor: scheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.settings,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, size: 28),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 48),
        child: Column(
          children: [
            _buildProfileSection(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, l10n.preferences),
            _buildPreferencesGroup(context),
            const SizedBox(height: 24),
            _buildSectionHeader(context, l10n.management),
            _buildListGroup(
              context,
              children: [
                _buildListItem(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: l10n.products,
                  subtitle: l10n.manageStockAndBarcodes,
                  onTap: () => context.push('/products'),
                ),
                _buildDivider(context),
                _buildListItem(
                  context,
                  icon: Icons.storefront,
                  title: l10n.shopDetails,
                  subtitle: l10n.editBusinessInfoAndAddress,
                  onTap: () => context.push('/shop'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, l10n.hardware),
            _buildPrinterGroup(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                l10n.bluetoothPairingInstructions,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader(context, l10n.account),
            _buildListGroup(
              context,
              children: [
                _buildListItem(
                  context,
                  icon: Icons.logout,
                  title: l10n.logOut,
                  subtitle: l10n.signOutAccount,
                  trailingIcon: null,
                  onTap: () => context.read<AuthBloc>().add(LogOutRequested()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLow,
      child: InkWell(
        onTap: () => context.push('/profile'),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: BlocBuilder<ShopBloc, ShopState>(
              builder: (context, state) {
                final shop = state is ShopLoaded ? state.shop : null;
                final shopName =
                    shop?.name.trim().isNotEmpty == true
                        ? shop!.name.trim()
                        : l10n.shopNameHint;
                return Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ProfileAvatar(
                          name: shopName,
                          imageBytes: shop?.profileImageBytes,
                        ),
                        Positioned(
                          right: -4,
                          bottom: -4,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: scheme.surfaceContainerLow,
                                width: 3,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.edit_outlined,
                                color: scheme.onPrimary,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      shopName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.editProfile,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesGroup(BuildContext context) {
    return BlocBuilder<AppPreferencesCubit, AppPreferences>(
      builder: (context, preferences) {
        final l10n = AppLocalizations.of(context);
        final isDark = preferences.themeMode == ThemeMode.dark;
        return _buildListGroup(
          context,
          children: [
            _buildListItem(
              context,
              icon: Icons.language,
              title: l10n.language,
              subtitle: _languageLabel(l10n, preferences.language),
              onTap: _showLanguagePicker,
            ),
            _buildDivider(context),
            _buildListItem(
              context,
              icon: isDark ? Icons.dark_mode : Icons.light_mode,
              title: l10n.appearance,
              subtitle: isDark ? l10n.darkMode : l10n.lightMode,
              trailingWidget: Switch.adaptive(
                key: const ValueKey('dark-mode-switch'),
                value: isDark,
                onChanged: (value) async {
                  final success = await context
                      .read<AppPreferencesCubit>()
                      .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                  if (!success && context.mounted) {
                    _showPreferenceError(context);
                  }
                },
              ),
              onTap: () async {
                final success = await context
                    .read<AppPreferencesCubit>()
                    .setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
                if (!success && context.mounted) {
                  _showPreferenceError(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPrinterGroup(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return BlocConsumer<PrinterBloc, PrinterState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: scheme.error,
            ),
          );
        } else if (state.status == PrinterStatus.connected) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.connectedToPrinter)));
        }
      },
      builder: (context, state) {
        return _buildListGroup(
          context,
          children: [
            _buildListItem(
              context,
              icon: Icons.print,
              title: l10n.printDevice,
              subtitleWidget: Row(
                children: [
                  Flexible(
                    child: Text(
                      state.connectedMac != null
                          ? (state.connectedName ?? l10n.printerConnected)
                          : l10n.noPrinterConnected,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (state.connectedMac != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        l10n.connected.toUpperCase(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              trailingWidget: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (state.status == PrinterStatus.scanning ||
                      state.status == PrinterStatus.connecting)
                    const SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed:
                          () => context.read<PrinterBloc>().add(
                            RefreshPrinterEvent(),
                          ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    tooltip: l10n.settings,
                    onPressed:
                        () => AppSettings.openAppSettings(
                          type: AppSettingsType.bluetooth,
                        ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: scheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildListGroup(
    BuildContext context, {
    required List<Widget> children,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
      indent: 72,
    );
  }

  Widget _buildListItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? subtitleWidget,
    Widget? trailingWidget,
    IconData? trailingIcon = Icons.chevron_right,
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: scheme.onPrimaryContainer, size: 21),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (subtitleWidget != null) ...[
                    const SizedBox(height: 4),
                    subtitleWidget,
                  ],
                ],
              ),
            ),
            if (trailingWidget != null)
              trailingWidget
            else if (trailingIcon != null)
              Icon(trailingIcon, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
