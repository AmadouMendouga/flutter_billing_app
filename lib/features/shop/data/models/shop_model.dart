import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/shop.dart';

class ShopModel extends Shop {
  const ShopModel({
    required super.name,
    required super.addressLine1,
    required super.addressLine2,
    required super.phoneNumber,
    required super.upiId,
    required super.footerText,
    super.profileImageBytes,
    super.ownerUid,
    super.ownerEmail,
    super.status,
    super.statusReason,
    super.statusUpdatedAt,
    super.statusUpdatedBy,
    super.createdAt,
    super.updatedAt,
  });

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      upiId: shop.upiId,
      footerText: shop.footerText,
      profileImageBytes: shop.profileImageBytes,
      ownerUid: shop.ownerUid,
      ownerEmail: shop.ownerEmail,
      status: shop.status,
      statusReason: shop.statusReason,
      statusUpdatedAt: shop.statusUpdatedAt,
      statusUpdatedBy: shop.statusUpdatedBy,
      createdAt: shop.createdAt,
      updatedAt: shop.updatedAt,
    );
  }

  factory ShopModel.fromMap(
    Map<String, dynamic> map, {
    String fallbackOwnerUid = '',
    String fallbackOwnerEmail = '',
  }) {
    return ShopModel(
      name: map['name'] as String? ?? '',
      addressLine1: map['addressLine1'] as String? ?? '',
      addressLine2: map['addressLine2'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      upiId: map['upiId'] as String? ?? '',
      footerText: map['footerText'] as String? ?? '',
      profileImageBytes: _profileImageFromMap(map['profileImage']),
      ownerUid: map['ownerUid'] as String? ?? fallbackOwnerUid,
      ownerEmail: map['ownerEmail'] as String? ?? fallbackOwnerEmail,
      status: ShopStatus.fromFirestore(map['status']),
      statusReason: map['statusReason'] as String? ?? '',
      statusUpdatedAt: _dateTimeFromMap(map['statusUpdatedAt']),
      statusUpdatedBy: map['statusUpdatedBy'] as String? ?? '',
      createdAt: _dateTimeFromMap(map['createdAt']),
      updatedAt: _dateTimeFromMap(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'phoneNumber': phoneNumber,
      'upiId': upiId,
      'footerText': footerText,
      'ownerUid': ownerUid,
      'ownerEmail': ownerEmail,
      'status': status.firestoreValue,
      'statusReason': statusReason,
      'statusUpdatedBy': statusUpdatedBy,
    };
    if (createdAt != null) map['createdAt'] = Timestamp.fromDate(createdAt!);
    if (updatedAt != null) map['updatedAt'] = Timestamp.fromDate(updatedAt!);
    if (statusUpdatedAt != null) {
      map['statusUpdatedAt'] = Timestamp.fromDate(statusUpdatedAt!);
    }
    final imageBytes = profileImageBytes;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      map['profileImage'] = Blob(imageBytes);
    }
    return map;
  }

  /// Only user-editable profile fields. Lifecycle and ownership fields are
  /// deliberately excluded so profile edits cannot change approval state.
  Map<String, dynamic> toProfileMap({bool deleteMissingProfileImage = false}) {
    final map = <String, dynamic>{
      'name': name,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'phoneNumber': phoneNumber,
      'upiId': upiId,
      'footerText': footerText,
    };
    final imageBytes = profileImageBytes;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      map['profileImage'] = Blob(imageBytes);
    } else if (deleteMissingProfileImage) {
      map['profileImage'] = FieldValue.delete();
    }
    return map;
  }

  /// Data for the first write of a shop document. Server timestamps are
  /// injectable to keep this serialization independently testable.
  static Map<String, dynamic> pendingCreationMap({
    required String name,
    required String ownerUid,
    required String ownerEmail,
    Object? timestamp,
  }) {
    final timestampValue = timestamp ?? FieldValue.serverTimestamp();
    return <String, dynamic>{
      'name': name,
      'addressLine1': '',
      'addressLine2': '',
      'phoneNumber': '',
      'upiId': '',
      'footerText': '',
      'ownerUid': ownerUid,
      'ownerEmail': ownerEmail,
      'status': ShopStatus.pending.firestoreValue,
      'statusReason': '',
      'statusUpdatedAt': timestampValue,
      'statusUpdatedBy': ownerUid,
      'createdAt': timestampValue,
      'updatedAt': timestampValue,
    };
  }

  Shop toEntity() => this;

  static Uint8List? _profileImageFromMap(Object? value) {
    if (value case final Blob blob) return blob.bytes;
    if (value case final Uint8List bytes) return bytes;
    if (value case final List<int> bytes) return Uint8List.fromList(bytes);
    return null;
  }

  static DateTime? _dateTimeFromMap(Object? value) {
    if (value case final Timestamp timestamp) return timestamp.toDate().toUtc();
    if (value case final DateTime dateTime) return dateTime.toUtc();
    if (value case final int millisecondsSinceEpoch) {
      return DateTime.fromMillisecondsSinceEpoch(
        millisecondsSinceEpoch,
        isUtc: true,
      );
    }
    if (value case final String iso8601) {
      return DateTime.tryParse(iso8601)?.toUtc();
    }
    return null;
  }
}
