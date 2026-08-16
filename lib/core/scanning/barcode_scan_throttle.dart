final class BarcodeScanThrottle {
  BarcodeScanThrottle({
    this.cooldown = const Duration(milliseconds: 800),
  });

  final Duration cooldown;
  final Map<String, DateTime> _lastScans = {};

  bool accept(String value, DateTime now) {
    final previous = _lastScans[value];
    if (previous != null && now.difference(previous) < cooldown) {
      return false;
    }

    _lastScans[value] = now;
    _lastScans.removeWhere(
      (_, scannedAt) => now.difference(scannedAt) > const Duration(seconds: 10),
    );
    return true;
  }
}
