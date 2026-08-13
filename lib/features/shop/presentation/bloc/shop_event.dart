part of 'shop_bloc.dart';

abstract class ShopEvent extends Equatable {
  const ShopEvent();
  @override
  List<Object> get props => [];
}

class LoadShopEvent extends ShopEvent {}

/// Resets state to initial, e.g. right after logout so the next account
/// doesn't briefly see the previous account's shop details.
class ClearShopEvent extends ShopEvent {}

class UpdateShopEvent extends ShopEvent {
  final Shop shop;
  const UpdateShopEvent(this.shop);
  @override
  List<Object> get props => [shop];
}
