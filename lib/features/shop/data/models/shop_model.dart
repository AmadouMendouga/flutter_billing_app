import '../../domain/entities/shop.dart';

class ShopModel extends Shop {
  const ShopModel({
    required super.name,
    required super.addressLine1,
    required super.addressLine2,
    required super.phoneNumber,
    required super.upiId,
    required super.footerText,
  });

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      upiId: shop.upiId,
      footerText: shop.footerText,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'phoneNumber': phoneNumber,
      'upiId': upiId,
      'footerText': footerText,
    };
  }

  Shop toEntity() => this;
}
