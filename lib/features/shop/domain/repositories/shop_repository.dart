import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shop.dart';

abstract class ShopRepository {
  Future<Either<Failure, Shop>> getShop();
  Future<Either<Failure, Shop>> ensureShop({String initialName = ''});
  Stream<Either<Failure, Shop>> watchShop();
  Future<Either<Failure, void>> updateShop(Shop shop);
}
