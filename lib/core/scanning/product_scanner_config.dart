import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

const productBarcodeFormats = <BarcodeFormat>[
  BarcodeFormat.ean13,
  BarcodeFormat.ean8,
  BarcodeFormat.upcA,
  BarcodeFormat.upcE,
  BarcodeFormat.code128,
  BarcodeFormat.code39,
  BarcodeFormat.itf14,
  BarcodeFormat.qrCode,
];

MobileScannerController createProductScannerController() {
  return MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.normal,
    detectionTimeoutMs: 100,
    formats: productBarcodeFormats,
    cameraResolution: const Size(1280, 720),
    returnImage: false,
    autoZoom: true,
  );
}

Rect productScanWindow(Size size) {
  final width = math.min(size.width * 0.88, 480.0);
  final height = math.min(size.height * 0.55, 180.0);
  return Rect.fromCenter(
    center: size.center(Offset.zero),
    width: width,
    height: height,
  );
}
