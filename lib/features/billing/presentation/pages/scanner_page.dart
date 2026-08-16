import 'dart:async';

import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/scanning/product_scanner_config.dart';
import '../../../../core/services/scan_feedback_service.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key, required this.scanFeedback});

  final ScanFeedback scanFeedback;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> with WidgetsBindingObserver {
  final MobileScannerController controller = createProductScannerController();
  bool _isScanned = false;
  Future<void> _cameraOperation = Future<void>.value();
  bool _isDisposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isScanned) unawaited(_setScannerRunning(true));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.hasCameraPermission) return;

    switch (state) {
      case AppLifecycleState.resumed:
        if (!_isScanned) unawaited(_setScannerRunning(true));
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
          if (!controller.value.isRunning) await controller.start();
        } else if (controller.value.isRunning) {
          await controller.stop();
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
      await controller.dispose();
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
    if (_isScanned) return;

    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue?.trim();
      if (rawValue == null || rawValue.isEmpty) continue;

      _isScanned = true;
      widget.scanFeedback.trigger();
      if (mounted) context.pop(rawValue);
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            size: 28,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context).scannerTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final scanWindow = productScanWindow(constraints.biggest);
          return Stack(
            fit: StackFit.expand,
            children: [
              MobileScanner(
                controller: controller,
                onDetect: _onDetect,
                scanWindow: scanWindow,
                scanWindowUpdateThreshold: 8,
                tapToFocus: true,
              ),
              Positioned.fromRect(
                rect: scanWindow,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [_corner(0), _corner(1)],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [_corner(3), _corner(2)],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Text(
                  AppLocalizations.of(context).alignBarcode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _corner(int index) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
