import 'package:equatable/equatable.dart';

import '../../../shop/domain/entities/shop.dart';

class AdminShop extends Equatable {
  final String id;
  final String ownerUid;
  final String ownerEmail;
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final ShopStatus status;
  final String statusReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? statusUpdatedAt;
  final String statusUpdatedBy;

  const AdminShop({
    required this.id,
    required this.ownerUid,
    required this.ownerEmail,
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.status,
    this.statusReason = '',
    this.createdAt,
    this.updatedAt,
    this.statusUpdatedAt,
    this.statusUpdatedBy = '',
  });

  String get displayName {
    if (name.trim().isNotEmpty) return name.trim();
    if (ownerEmail.trim().isNotEmpty) return ownerEmail.trim();
    return id;
  }

  @override
  List<Object?> get props => [
    id,
    ownerUid,
    ownerEmail,
    name,
    addressLine1,
    addressLine2,
    phoneNumber,
    status,
    statusReason,
    createdAt,
    updatedAt,
    statusUpdatedAt,
    statusUpdatedBy,
  ];
}
