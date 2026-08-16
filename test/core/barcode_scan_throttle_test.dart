import 'package:billing_app/core/scanning/barcode_scan_throttle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts a first scan and throttles only quick identical scans', () {
    final throttle = BarcodeScanThrottle();
    final start = DateTime(2026, 8, 16);

    expect(throttle.accept('123', start), isTrue);
    expect(
      throttle.accept('123', start.add(const Duration(milliseconds: 500))),
      isFalse,
    );
    expect(
      throttle.accept('456', start.add(const Duration(milliseconds: 500))),
      isTrue,
    );
    expect(
      throttle.accept('123', start.add(const Duration(milliseconds: 800))),
      isTrue,
    );
  });
}
