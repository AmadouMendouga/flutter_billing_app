import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../shop/domain/entities/shop.dart';
import '../../domain/entities/admin_shop.dart';

class AdminShopModel {
  const AdminShopModel._();

  static AdminShop fromMap(String id, Map<String, dynamic> map) {
    return AdminShop(
      id: id,
      ownerUid: _string(map['ownerUid'], fallback: id),
      ownerEmail: _string(map['ownerEmail']),
      name: _string(map['name']),
      addressLine1: _string(map['addressLine1']),
      addressLine2: _string(map['addressLine2']),
      phoneNumber: _string(map['phoneNumber']),
      status: ShopStatus.fromFirestore(map['status']),
      statusReason: _string(map['statusReason']),
      createdAt: _dateTime(map['createdAt']),
      updatedAt: _dateTime(map['updatedAt']),
      statusUpdatedAt: _dateTime(map['statusUpdatedAt']),
      statusUpdatedBy: _string(map['statusUpdatedBy']),
    );
  }

  static String _string(Object? value, {String fallback = ''}) =>
      value is String ? value : fallback;

  static DateTime? _dateTime(Object? value) {
    if (value case final Timestamp timestamp) return timestamp.toDate();
    if (value case final DateTime dateTime) return dateTime;
    return null;
  }
}
