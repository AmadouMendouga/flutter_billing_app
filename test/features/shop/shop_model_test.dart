import 'dart:typed_data';

import 'package:billing_app/features/shop/data/models/shop_model.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads legacy shop documents without a profile image', () {
    final model = ShopModel.fromMap(const {'name': 'Amad'});

    expect(model.name, 'Amad');
    expect(model.profileImageBytes, isNull);
  });

  test('stores and restores profile image bytes with Firestore Blob', () {
    final image = Uint8List.fromList([1, 2, 3, 4]);
    final model = ShopModel.fromEntity(
      Shop(name: 'Amad', profileImageBytes: image),
    );

    final map = model.toMap();
    final restored = ShopModel.fromMap(map);

    expect(map['profileImage'], isA<Blob>());
    expect(restored.profileImageBytes, orderedEquals(image));
  });

  test('copyWith preserves or explicitly clears a profile image', () {
    final image = Uint8List.fromList([9, 8, 7]);
    final shop = Shop(name: 'Old', profileImageBytes: image);

    final renamed = shop.copyWith(name: 'New');
    final cleared = renamed.copyWith(clearProfileImage: true);

    expect(renamed.profileImageBytes, orderedEquals(image));
    expect(cleared.profileImageBytes, isNull);
  });
}
