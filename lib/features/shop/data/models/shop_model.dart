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
    );
  }

  factory ShopModel.fromMap(Map<String, dynamic> map) {
    return ShopModel(
      name: map['name'] as String? ?? '',
      addressLine1: map['addressLine1'] as String? ?? '',
      addressLine2: map['addressLine2'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      upiId: map['upiId'] as String? ?? '',
      footerText: map['footerText'] as String? ?? '',
      profileImageBytes: _profileImageFromMap(map['profileImage']),
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
    };
    final imageBytes = profileImageBytes;
    if (imageBytes != null && imageBytes.isNotEmpty) {
      map['profileImage'] = Blob(imageBytes);
    }
    return map;
  }

  Shop toEntity() => this;

  static Uint8List? _profileImageFromMap(Object? value) {
    if (value case final Blob blob) return blob.bytes;
    if (value case final Uint8List bytes) return bytes;
    if (value case final List<int> bytes) return Uint8List.fromList(bytes);
    return null;
  }
}
