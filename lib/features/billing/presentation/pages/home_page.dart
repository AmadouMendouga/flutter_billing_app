import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/data/hive_database.dart';
import '../../../../core/scanning/barcode_scan_throttle.dart';
import '../../../../core/scanning/product_scanner_config.dart';
import '../../../../core/services/scan_feedback_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../billing/presentation/bloc/billing_bloc.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../../domain/entities/cart_item.dart';

const _shopReminderDismissedKey = 'shop_reminder_dismissed';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.scanFeedback});

  final ScanFeedback scanFeedback;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final MobileScannerController _scannerController =
      createProductScannerController();

  bool _isCameraOn = true;
  bool _isFlashOn = false;
  bool _shopReminderDismissed = HiveDatabase.settingsBox.get(
    _shopReminderDismissedKey,
    defaultValue: false,
  );

  // Vertical position (from the top) of the draggable bottom panel.
  // Lazily initialized to the default position on first build, then
  // updated as the user drags the handle up/down.
  double? _panelTop;

  final BarcodeScanThrottle _scanThrottle = BarcodeScanThrottle();
  Future<void> _cameraOperation = Future<void>.value();
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isCameraOn) {
        unawaited(_setScannerRunning(true));
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scannerController.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (_isCameraOn) unawaited(_setScannerRunning(true));
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(_setScannerRunning(false));
    }
  }

  Future<void> _setScannerRunning(bool shouldRun) {
    final nextOperation = _cameraOperation.then((_) async {
      if (_isDisposing) return;
      try {
        if (shouldRun) {
          if (!_scannerController.value.isRunning) {
            await _scannerController.start();
          }
        } else if (_scannerController.value.isRunning) {
          await _scannerController.stop();
        }
      } catch (error) {
        debugPrint('Scanner lifecycle operation failed: $error');
      }
    });
    _cameraOperation = nextOperation;
    return nextOperation;
  }

  Future<void> _disposeScanner() async {
    await _cameraOperation;
    try {
      await _scannerController.dispose();
    } catch (error) {
      debugPrint('Scanner disposal failed: $error');
    }
  }

  @override
  void dispose() {
    _isDisposing = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_disposeScanner());
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final now = DateTime.now();

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue?.trim();
      if (rawValue == null || rawValue.isEmpty) continue;
      if (!_scanThrottle.accept(rawValue, now)) continue;

      if (mounted) {
        context.read<BillingBloc>().add(ScanBarcodeEvent(rawValue));
      }
      widget.scanFeedback.trigger();
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final topPadding = MediaQuery.of(context).padding.top;
    final defaultPanelTop = (screenHeight * 0.4) - 24;
    // How far the panel can be dragged: almost full screen when expanded,
    // down to just the handle + header when collapsed.
    final minPanelTop = topPadding + 80;
    final maxPanelTop = screenHeight - 200;
    _panelTop = (_panelTop ?? defaultPanelTop).clamp(minPanelTop, maxPanelTop);

    return Scaffold(
      body: BlocListener<BillingBloc, BillingState>(
        listenWhen:
            (previous, current) =>
                previous.error != current.error && current.error != null,
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Stack(
          children: [
            // SCANNER VIEW (TOP 50%)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height * 0.4,
              child: _buildScannerSection(),
            ),

            // BOTTOM PANEL (draggable up/down via its handle)
            Positioned(
              top: _panelTop!,
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomPanel(minPanelTop, maxPanelTop),
            ),
          ],
        ),
      ),
      bottomSheet: BlocBuilder<BillingBloc, BillingState>(
        builder: (context, state) {
          return PrimaryButton(
            onPressed:
                state.cartItems.isEmpty
                    ? null
                    : () async {
                      await _setScannerRunning(false);
                      if (!context.mounted) return;
                      await context.push('/checkout');
                      if (_isCameraOn && mounted) {
                        await _setScannerRunning(true);
                      }
                    },
            icon: Icons.payment,
            label: 'Review Order',
          );
        },
      ),
    );
  }

  Widget _buildScannerSection() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanWindow = productScanWindow(constraints.biggest);
        return ColoredBox(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: _scannerController,
                onDetect: _onDetect,
                scanWindow: scanWindow,
                scanWindowUpdateThreshold: 8,
                tapToFocus: true,
              ),
              if (!_isCameraOn) _buildCameraOffState(),

              // Overlay Actions (Top Right)
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Column(
                  children: [
                    _buildOverlayButton(
                      icon: Icons.settings,
                      onPressed: () async {
                        await _setScannerRunning(false);
                        if (!context.mounted) return;
                        await context.push('/settings');
                        if (_isCameraOn && mounted) {
                          await _setScannerRunning(true);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_isCameraOn)
                      _buildOverlayButton(
                        icon:
                            _isFlashOn
                                ? Icons.flashlight_off
                                : Icons.flashlight_on,
                        onPressed: () {
                          setState(() => _isFlashOn = !_isFlashOn);
                          _scannerController.toggleTorch();
                        },
                      ),
                    if (_isCameraOn) const SizedBox(height: 16),
                    _buildOverlayButton(
                      icon: _isCameraOn ? Icons.videocam : Icons.videocam_off,
                      onPressed: () async {
                        final shouldRun = !_isCameraOn;
                        setState(() => _isCameraOn = shouldRun);
                        await _setScannerRunning(shouldRun);
                      },
                    ),
                  ],
                ),
              ),

              if (_isCameraOn)
                Positioned.fromRect(
                  rect: scanWindow,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Stack(
                        children: [
                          _buildCorner(Alignment.topLeft),
                          _buildCorner(Alignment.topRight),
                          _buildCorner(Alignment.bottomLeft),
                          _buildCorner(Alignment.bottomRight),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraOffState() {
    return Container(
      color: const Color(0xFF1E293B), // slate-800
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: Color(0xFF334155), // slate-700
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.videocam_off,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Camera is turned off',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Turn on your camera to start scanning barcodes and items automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.videocam),
            label: const Text(
              'Turn on Camera',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              setState(() => _isCameraOn = true);
              await _setScannerRunning(true);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Container(
      width: 44,
      height: 44,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color ?? Colors.black45,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildCorner(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top:
                (alignment == Alignment.topLeft ||
                        alignment == Alignment.topRight)
                    ? const BorderSide(color: Colors.greenAccent, width: 4)
                    : BorderSide.none,
            bottom:
                (alignment == Alignment.bottomLeft ||
                        alignment == Alignment.bottomRight)
                    ? const BorderSide(color: Colors.greenAccent, width: 4)
                    : BorderSide.none,
            left:
                (alignment == Alignment.topLeft ||
                        alignment == Alignment.bottomLeft)
                    ? const BorderSide(color: Colors.greenAccent, width: 4)
                    : BorderSide.none,
            right:
                (alignment == Alignment.topRight ||
                        alignment == Alignment.bottomRight)
                    ? const BorderSide(color: Colors.greenAccent, width: 4)
                    : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildShopReminderBanner() {
    return BlocBuilder<ShopBloc, ShopState>(
      builder: (context, state) {
        if (state is! ShopLoaded || state.shop.addressLine1.isNotEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.storefront, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Personnalise ta boutique !',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "Ajoute l'adresse et le téléphone de ta boutique pour qu'ils apparaissent sur tes reçus.",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        HiveDatabase.settingsBox.put(
                          _shopReminderDismissedKey,
                          true,
                        );
                        setState(() => _shopReminderDismissed = true);
                      },
                      child: const Text('Ne plus afficher'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        await _setScannerRunning(false);
                        if (!context.mounted) return;
                        await context.push('/shop');
                        if (_isCameraOn && mounted) {
                          await _setScannerRunning(true);
                        }
                      },
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      label: const Text('Modifier'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomPanel(double minPanelTop, double maxPanelTop) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle: pulls the whole panel up/down.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              setState(() {
                _panelTop = (_panelTop! + details.delta.dy).clamp(
                  minPanelTop,
                  maxPanelTop,
                );
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.transparent,
              child: Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          if (!_shopReminderDismissed) _buildShopReminderBanner(),

          // Header
          BlocBuilder<BillingBloc, BillingState>(
            builder: (context, state) {
              final totalItems = state.cartItems.fold<int>(
                0,
                (sum, i) => sum + i.quantity,
              );
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scanned Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '$totalItems items total',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'TOTAL PRICE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          '${state.totalAmount.toStringAsFixed(0)} FCFA',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(height: 1),

          // List View
          Expanded(
            child: Stack(
              children: [
                BlocBuilder<BillingBloc, BillingState>(
                  builder: (context, state) {
                    if (state.cartItems.isEmpty) {
                      return _buildEmptyCart();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(
                        left: 15,
                        right: 15,
                        top: 16,
                        bottom: 100,
                      ),
                      itemCount: state.cartItems.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = state.cartItems[index];
                        return _buildCartItemCard(context, item);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.shopping_basket,
              size: 40,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'List is empty',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Scanned items will appear here as you scan them with the camera above.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 1,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.product.price.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _circularIconButton(
                  icon: Icons.remove,
                  onPressed: () {
                    if (item.quantity > 1) {
                      context.read<BillingBloc>().add(
                        UpdateQuantityEvent(item.product.id, item.quantity - 1),
                      );
                    } else {
                      context.read<BillingBloc>().add(
                        RemoveProductFromCartEvent(item.product.id),
                      );
                    }
                  },
                ),
                SizedBox(
                  width: 32,
                  child: Text(
                    '${item.quantity}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                _circularIconButton(
                  icon: Icons.add,
                  onPressed: () {
                    context.read<BillingBloc>().add(
                      UpdateQuantityEvent(item.product.id, item.quantity + 1),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circularIconButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: Colors.grey[600]),
      ),
    );
  }

  // A floating Details/Checkout Button at the very bottom
  // Added a Stack wrapper below to overlay this button
}
