import 'package:billing_app/core/scanning/product_scanner_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  test('uses the fast product scanner configuration', () async {
    final controller = createProductScannerController();
    addTearDown(controller.dispose);

    expect(controller.detectionSpeed, DetectionSpeed.normal);
    expect(controller.autoStart, isFalse);
    expect(controller.detectionTimeoutMs, 100);
    expect(controller.formats, productBarcodeFormats);
    expect(controller.cameraResolution, const Size(1280, 720));
    expect(controller.returnImage, isFalse);
    expect(controller.autoZoom, isTrue);
  });

  test('scan window stays centered, bounded, and wider than it is tall', () {
    const size = Size(390, 340);
    final window = productScanWindow(size);

    final expectedCenter = size.center(Offset.zero);
    expect(window.center.dx, closeTo(expectedCenter.dx, 0.001));
    expect(window.center.dy, closeTo(expectedCenter.dy, 0.001));
    expect(window.left, greaterThanOrEqualTo(0));
    expect(window.top, greaterThanOrEqualTo(0));
    expect(window.right, lessThanOrEqualTo(size.width));
    expect(window.bottom, lessThanOrEqualTo(size.height));
    expect(window.width, greaterThan(window.height));
  });
}
