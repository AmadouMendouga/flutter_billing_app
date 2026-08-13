import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  CollectionReference<Map<String, dynamic>> _productsCollection(String uid) =>
      FirebaseFirestore.instance
          .collection('shops')
          .doc(uid)
          .collection('products');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    final uid = _uid;
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      final snapshot = await _productsCollection(uid).get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
          .toList();
      return Right(products);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    final uid = _uid;
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      // Products are already fully loaded into Firestore's local cache by
      // getProducts() at app start, so this stays local/instant instead of
      // hitting the network on every barcode scan.
      var querySnapshot = await _productsCollection(uid)
          .where('barcode', isEqualTo: barcode)
          .get(const GetOptions(source: Source.cache));
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await _productsCollection(uid)
            .where('barcode', isEqualTo: barcode)
            .get();
      }
      if (querySnapshot.docs.isEmpty) {
        return const Left(CacheFailure('Product not found'));
      }
      final doc = querySnapshot.docs.first;
      return Right(ProductModel.fromMap(doc.id, doc.data()));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    final uid = _uid;
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      final model = ProductModel.fromEntity(product);
      await _productsCollection(uid).doc(model.id).set(model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    final uid = _uid;
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      final model = ProductModel.fromEntity(product);
      await _productsCollection(uid).doc(model.id).set(model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    final uid = _uid;
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      await _productsCollection(uid).doc(id).delete();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
