import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  ShopRepositoryImpl({FirebaseFirestore? firestore, FirebaseAuth? firebaseAuth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  DocumentReference<Map<String, dynamic>> _shopDoc(String uid) =>
      _firestore.collection('shops').doc(uid);

  @override
  Future<Either<Failure, Shop>> getShop() => ensureShop();

  @override
  Future<Either<Failure, Shop>> ensureShop({String initialName = ''}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const Left(AuthFailure('No authenticated user'));
    }

    final uid = user.uid;
    final email = user.email?.trim() ?? '';
    try {
      final shop = await _firestore.runTransaction<Shop>((transaction) async {
        final reference = _shopDoc(uid);
        final snapshot = await transaction.get(reference);
        final data = snapshot.data();
        if (snapshot.exists && data != null) {
          return ShopModel.fromMap(
            data,
            fallbackOwnerUid: uid,
            fallbackOwnerEmail: email,
          );
        }

        final name = initialName.trim();
        transaction.set(
          reference,
          ShopModel.pendingCreationMap(
            name: name,
            ownerUid: uid,
            ownerEmail: email,
          ),
        );
        return Shop(
          name: name,
          ownerUid: uid,
          ownerEmail: email,
          status: ShopStatus.pending,
          statusUpdatedBy: uid,
        );
      });
      return Right(shop);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, Shop>> watchShop() async* {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      yield const Left(AuthFailure('No authenticated user'));
      return;
    }

    final ensured = await ensureShop();
    final ensureFailure = ensured.fold<Failure?>(
      (failure) => failure,
      (_) => null,
    );
    if (ensureFailure != null) {
      yield Left(ensureFailure);
      return;
    }

    final uid = user.uid;
    final email = user.email?.trim() ?? '';
    try {
      await for (final snapshot in _shopDoc(uid).snapshots()) {
        final data = snapshot.data();
        if (!snapshot.exists || data == null) {
          yield Right(
            Shop(ownerUid: uid, ownerEmail: email, status: ShopStatus.pending),
          );
          continue;
        }
        yield Right(
          ShopModel.fromMap(
            data,
            fallbackOwnerUid: uid,
            fallbackOwnerEmail: email,
          ),
        );
      }
    } catch (e) {
      yield Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const Left(AuthFailure('No authenticated user'));
    }

    final uid = user.uid;
    final email = user.email?.trim() ?? '';
    try {
      final model = ShopModel.fromEntity(shop);
      await _firestore.runTransaction<void>((transaction) async {
        final reference = _shopDoc(uid);
        final snapshot = await transaction.get(reference);
        final profile = model.toProfileMap(
          deleteMissingProfileImage: snapshot.exists,
        );
        final timestamp = FieldValue.serverTimestamp();

        if (!snapshot.exists) {
          final newShop = ShopModel.pendingCreationMap(
            name: shop.name.trim(),
            ownerUid: uid,
            ownerEmail: email,
            timestamp: timestamp,
          )..addAll(profile);
          transaction.set(reference, newShop, SetOptions(merge: true));
          return;
        }

        transaction.set(reference, <String, dynamic>{
          ...profile,
          'updatedAt': timestamp,
        }, SetOptions(merge: true));
      });
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
