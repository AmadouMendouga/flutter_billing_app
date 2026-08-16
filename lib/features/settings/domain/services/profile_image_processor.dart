import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image_lib;

const int maxProfileImageBytes = 300 * 1024;
const int maxProfileImageInputBytes = 20 * 1024 * 1024;
const int profileImageDimension = 512;

enum ProfileImageError { invalidImage, inputTooLarge, outputTooLarge }

final class ProfileImageException implements Exception {
  const ProfileImageException(this.error);

  final ProfileImageError error;
}

Future<Uint8List> processProfileImage(Uint8List bytes) async {
  if (bytes.lengthInBytes > maxProfileImageInputBytes) {
    throw const ProfileImageException(ProfileImageError.inputTooLarge);
  }
  return compute(_processProfileImageInBackground, bytes);
}

@visibleForTesting
Uint8List processProfileImageSync(Uint8List bytes) {
  if (bytes.lengthInBytes > maxProfileImageInputBytes) {
    throw const ProfileImageException(ProfileImageError.inputTooLarge);
  }
  return _processProfileImageInBackground(bytes);
}

Uint8List _processProfileImageInBackground(Uint8List bytes) {
  image_lib.Image? decoded;
  try {
    decoded = image_lib.decodeImage(bytes);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null) {
    throw const ProfileImageException(ProfileImageError.invalidImage);
  }

  final oriented = image_lib.bakeOrientation(decoded);
  var size = profileImageDimension;
  for (final quality in const [82, 72, 62, 52, 42]) {
    final square = image_lib.copyResizeCropSquare(
      oriented,
      size: size,
      interpolation: image_lib.Interpolation.linear,
    );
    final encoded = image_lib.encodeJpg(square, quality: quality);
    if (encoded.lengthInBytes <= maxProfileImageBytes) return encoded;
    size = 384;
  }

  throw const ProfileImageException(ProfileImageError.outputTooLarge);
}
