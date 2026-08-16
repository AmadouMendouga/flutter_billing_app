import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';

class GetShopUseCase implements UseCase<Shop, NoParams> {
  final ShopRepository repository;

  GetShopUseCase(this.repository);

  @override
  Future<Either<Failure, Shop>> call(NoParams params) {
    return repository.getShop();
  }
}

class UpdateShopUseCase implements UseCase<void, Shop> {
  final ShopRepository repository;

  UpdateShopUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Shop params) {
    return repository.updateShop(params);
  }
}

class EnsureShopParams {
  const EnsureShopParams({this.initialName = ''});

  final String initialName;
}

class EnsureShopUseCase implements UseCase<Shop, EnsureShopParams> {
  EnsureShopUseCase(this.repository);

  final ShopRepository repository;

  @override
  Future<Either<Failure, Shop>> call(EnsureShopParams params) {
    return repository.ensureShop(initialName: params.initialName);
  }
}

class WatchShopUseCase {
  WatchShopUseCase(this.repository);

  final ShopRepository repository;

  Stream<Either<Failure, Shop>> call() => repository.watchShop();
}
