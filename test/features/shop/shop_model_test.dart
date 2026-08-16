import 'dart:typed_data';

import 'package:billing_app/features/shop/data/models/shop_model.dart';
import 'package:billing_app/features/shop/domain/entities/shop.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads legacy shop documents without a profile image', () {
    final model = ShopModel.fromMap(
      const {'name': 'Amad'},
      fallbackOwnerUid: 'legacy-owner',
      fallbackOwnerEmail: 'legacy@example.com',
    );

    expect(model.name, 'Amad');
    expect(model.profileImageBytes, isNull);
    expect(model.status, ShopStatus.active);
    expect(model.isActive, isTrue);
    expect(model.ownerUid, 'legacy-owner');
    expect(model.ownerEmail, 'legacy@example.com');
  });

  test('an unknown explicit status never grants shop access', () {
    final model = ShopModel.fromMap(const {
      'name': 'Unexpected',
      'status': 'future-status',
    });

    expect(model.status, ShopStatus.pending);
    expect(model.isActive, isFalse);
  });

  test('reads lifecycle metadata and Firestore timestamps', () {
    final createdAt = DateTime.utc(2026, 8, 16, 10);
    final updatedAt = DateTime.utc(2026, 8, 17, 11);
    final statusUpdatedAt = DateTime.utc(2026, 8, 18, 12);

    final model = ShopModel.fromMap({
      'name': 'Amad',
      'ownerUid': 'owner-1',
      'ownerEmail': 'owner@example.com',
      'status': 'suspended',
      'statusReason': 'Documents incomplets',
      'statusUpdatedAt': Timestamp.fromDate(statusUpdatedAt),
      'statusUpdatedBy': 'admin-1',
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    });

    expect(model.status, ShopStatus.suspended);
    expect(model.statusReason, 'Documents incomplets');
    expect(model.statusUpdatedAt, statusUpdatedAt);
    expect(model.statusUpdatedBy, 'admin-1');
    expect(model.createdAt, createdAt);
    expect(model.updatedAt, updatedAt);
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

  test('copyWith preserves lifecycle metadata during profile edits', () {
    final createdAt = DateTime.utc(2026, 8, 16);
    final shop = Shop(
      name: 'Old',
      ownerUid: 'owner-1',
      ownerEmail: 'owner@example.com',
      status: ShopStatus.pending,
      statusReason: 'Reviewing',
      statusUpdatedBy: 'admin-1',
      createdAt: createdAt,
    );

    final renamed = shop.copyWith(name: 'New');

    expect(renamed.ownerUid, shop.ownerUid);
    expect(renamed.ownerEmail, shop.ownerEmail);
    expect(renamed.status, shop.status);
    expect(renamed.statusReason, shop.statusReason);
    expect(renamed.statusUpdatedBy, shop.statusUpdatedBy);
    expect(renamed.createdAt, createdAt);
  });

  test('profile update map excludes lifecycle and ownership fields', () {
    final map =
        ShopModel.fromEntity(
          const Shop(
            name: 'Amad',
            ownerUid: 'owner-1',
            ownerEmail: 'owner@example.com',
            status: ShopStatus.suspended,
            statusReason: 'Reason',
            statusUpdatedBy: 'admin-1',
          ),
        ).toProfileMap();

    expect(map['name'], 'Amad');
    for (final systemField in <String>[
      'ownerUid',
      'ownerEmail',
      'status',
      'statusReason',
      'statusUpdatedAt',
      'statusUpdatedBy',
      'createdAt',
      'updatedAt',
    ]) {
      expect(map, isNot(contains(systemField)));
    }
  });

  test('new shop map is pending and carries immutable owner metadata', () {
    final timestamp = DateTime.utc(2026, 8, 16, 13);

    final map = ShopModel.pendingCreationMap(
      name: 'Nouvelle boutique',
      ownerUid: 'owner-1',
      ownerEmail: 'owner@example.com',
      timestamp: timestamp,
    );

    expect(map['status'], 'pending');
    expect(map['ownerUid'], 'owner-1');
    expect(map['ownerEmail'], 'owner@example.com');
    expect(map['createdAt'], same(timestamp));
    expect(map['updatedAt'], same(timestamp));
    expect(map['statusUpdatedAt'], same(timestamp));
    expect(map['statusUpdatedBy'], 'owner-1');
  });
}
