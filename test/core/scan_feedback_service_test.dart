import 'dart:async';

import 'package:billing_app/core/services/scan_feedback_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts sound and vibration without waiting for them', () async {
    final sound = Completer<void>();
    final vibration = Completer<void>();
    var soundCalls = 0;
    var vibrationCalls = 0;
    final feedback = ScanFeedbackService.forTest(
      playSound: () {
        soundCalls++;
        return sound.future;
      },
      vibrate: () {
        vibrationCalls++;
        return vibration.future;
      },
    );

    feedback.trigger();

    expect(soundCalls, 1);
    expect(vibrationCalls, 1);
    expect(sound.isCompleted, isFalse);
    expect(vibration.isCompleted, isFalse);

    sound.complete();
    vibration.complete();
    await Future<void>.delayed(Duration.zero);
  });

  test('feedback failures never escape', () async {
    final feedback = ScanFeedbackService.forTest(
      playSound: () async => throw StateError('audio unavailable'),
      vibrate: () async => throw StateError('vibration unavailable'),
    );

    feedback.trigger();
    await Future<void>.delayed(Duration.zero);
  });

  test('dispose releases resources once and disables later feedback', () async {
    var playCalls = 0;
    var disposeCalls = 0;
    final feedback = ScanFeedbackService.forTest(
      playSound: () async => playCalls++,
      disposeResources: () async => disposeCalls++,
    );

    await feedback.dispose();
    await feedback.dispose();
    feedback.trigger();

    expect(disposeCalls, 1);
    expect(playCalls, 0);
  });
}
