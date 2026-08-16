import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:vibration/vibration.dart';

abstract interface class ScanFeedback {
  void trigger();
}

typedef ScanFeedbackEffect = Future<void> Function();

/// Keeps the short scan sound preloaded and runs sound/haptics without ever
/// delaying barcode processing.
final class ScanFeedbackService implements ScanFeedback {
  ScanFeedbackService._({
    ScanFeedbackEffect? playSound,
    ScanFeedbackEffect? vibrate,
    ScanFeedbackEffect? disposeResources,
  })  : _playSound = playSound,
        _vibrate = vibrate,
        _disposeResources = disposeResources;

  final ScanFeedbackEffect? _playSound;
  final ScanFeedbackEffect? _vibrate;
  final ScanFeedbackEffect? _disposeResources;
  bool _disposed = false;

  static Future<ScanFeedbackService> create() async {
    AudioPool? pool;
    try {
      pool = await AudioPool.createFromAsset(
        path: 'audio/bip.mp3',
        minPlayers: 1,
        maxPlayers: 2,
      );
    } catch (_) {
      // Sound feedback is optional; scanning must still work without it.
    }

    var canVibrate = false;
    try {
      canVibrate = await Vibration.hasVibrator();
    } catch (_) {
      // Haptics are unavailable on several browsers and desktop platforms.
    }

    return ScanFeedbackService._(
      playSound: pool == null
          ? null
          : () async {
              await pool!.start();
            },
      vibrate: !canVibrate
          ? null
          : () async {
              await Vibration.vibrate(duration: 60);
            },
      disposeResources: pool?.dispose,
    );
  }

  @visibleForTesting
  factory ScanFeedbackService.forTest({
    ScanFeedbackEffect? playSound,
    ScanFeedbackEffect? vibrate,
    ScanFeedbackEffect? disposeResources,
  }) = ScanFeedbackService._;

  @override
  void trigger() {
    if (_disposed) return;
    unawaited(_guard(_playSound));
    unawaited(_guard(_vibrate));
  }

  Future<void> _guard(ScanFeedbackEffect? effect) async {
    try {
      await effect?.call();
    } catch (_) {
      // Feedback is best-effort and must never break a successful scan.
    }
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _guard(_disposeResources);
  }
}
