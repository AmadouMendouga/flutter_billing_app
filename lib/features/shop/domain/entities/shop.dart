import 'dart:typed_data';

import 'package:equatable/equatable.dart';

enum ShopStatus {
  pending('pending'),
  active('active'),
  suspended('suspended'),
  rejected('rejected');

  const ShopStatus(this.firestoreValue);

  final String firestoreValue;

  bool get allowsAccess => this == ShopStatus.active;

  /// Documents created before shop approval existed have no `status` field.
  /// They remain active so the migration does not lock out existing shops.
  static ShopStatus fromFirestore(Object? value) {
    if (value == null) return ShopStatus.active;

    switch (value.toString().trim().toLowerCase()) {
      case 'active':
      case 'approved':
        return ShopStatus.active;
      case 'suspended':
      case 'disabled':
        return ShopStatus.suspended;
      case 'rejected':
        return ShopStatus.rejected;
      case 'pending':
        return ShopStatus.pending;
      default:
        // An unknown explicit value must never accidentally grant access.
        return ShopStatus.pending;
    }
  }
}

class Shop extends Equatable {
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final String upiId;
  final String footerText;
  final Uint8List? profileImageBytes;
  final String ownerUid;
  final String ownerEmail;
  final ShopStatus status;
  final String statusReason;
  final DateTime? statusUpdatedAt;
  final String statusUpdatedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Shop({
    this.name = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phoneNumber = '',
    this.upiId = '',
    this.footerText = '',
    this.profileImageBytes,
    this.ownerUid = '',
    this.ownerEmail = '',
    this.status = ShopStatus.active,
    this.statusReason = '',
    this.statusUpdatedAt,
    this.statusUpdatedBy = '',
    this.createdAt,
    this.updatedAt,
  });

  bool get isActive => status.allowsAccess;

  Shop copyWith({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? phoneNumber,
    String? upiId,
    String? footerText,
    Uint8List? profileImageBytes,
    bool clearProfileImage = false,
    String? ownerUid,
    String? ownerEmail,
    ShopStatus? status,
    String? statusReason,
    DateTime? statusUpdatedAt,
    String? statusUpdatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Shop(
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      upiId: upiId ?? this.upiId,
      footerText: footerText ?? this.footerText,
      profileImageBytes:
          clearProfileImage
              ? null
              : profileImageBytes ?? this.profileImageBytes,
      ownerUid: ownerUid ?? this.ownerUid,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      status: status ?? this.status,
      statusReason: statusReason ?? this.statusReason,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      statusUpdatedBy: statusUpdatedBy ?? this.statusUpdatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    name,
    addressLine1,
    addressLine2,
    phoneNumber,
    upiId,
    footerText,
    profileImageBytes,
    ownerUid,
    ownerEmail,
    status,
    statusReason,
    statusUpdatedAt,
    statusUpdatedBy,
    createdAt,
    updatedAt,
  ];
}
