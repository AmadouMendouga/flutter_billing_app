import 'dart:typed_data';

import 'package:billing_app/features/settings/domain/services/profile_image_processor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image_lib;

void main() {
  test('normalizes a valid image to a bounded square JPEG', () {
    final source = image_lib.Image(width: 1200, height: 800)
      ..clear(image_lib.ColorRgb8(108, 99, 255));
    final pngBytes = image_lib.encodePng(source);

    final result = processProfileImageSync(pngBytes);
    final decoded = image_lib.decodeJpg(result);

    expect(result.lengthInBytes, lessThanOrEqualTo(maxProfileImageBytes));
    expect(decoded, isNotNull);
    expect(decoded!.width, profileImageDimension);
    expect(decoded.height, profileImageDimension);
  });

  test('rejects content that is not an image', () {
    expect(
      () => processProfileImageSync(Uint8List.fromList([1, 2, 3, 4])),
      throwsA(
        isA<ProfileImageException>().having(
          (error) => error.error,
          'error',
          ProfileImageError.invalidImage,
        ),
      ),
    );
  });
}
