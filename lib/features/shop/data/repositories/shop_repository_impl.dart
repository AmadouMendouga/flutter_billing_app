import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  DocumentReference<Map<String, dynamic>> _shopDoc(String uid) =>
      FirebaseFirestore.instance.collection('shops').doc(uid);

  @override
  Future<Either<Failure, Shop>> getShop() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Left(AuthFailure('No authenticated user'));
    }
    try {
      final snapshot = await _shopDoc(uid).get();
      if (!snapshot.exists) {
        // New account: no shop details yet, let the user fill their own in.
        return const Right(Shop());
      }
      return Right(ShopModel.fromMap(snapshot.data()!));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Left(AuthFailure('No authenticated user'));
    }
    try {
      final model = ShopModel.fromEntity(shop);
      await _shopDoc(uid).set(model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
