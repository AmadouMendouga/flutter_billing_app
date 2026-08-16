import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';
import '../product_barcode_index.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductBarcodeIndex _barcodeIndex = ProductBarcodeIndex();

  CollectionReference<Map<String, dynamic>> _productsCollection(String uid) =>
      FirebaseFirestore.instance
          .collection('shops')
          .doc(uid)
          .collection('products');

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    final uid = _uid;
    _barcodeIndex.bind(uid);
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      final snapshot = await _productsCollection(uid).get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
          .toList();
      if (_uid != uid) {
        return const Left(AuthFailure('Authenticated user changed'));
      }
      _barcodeIndex.replace(uid, products);
      return Right(products);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    final uid = _uid;
    _barcodeIndex.bind(uid);
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    final indexedProduct = _barcodeIndex.find(barcode);
    if (indexedProduct != null) return Right(indexedProduct);
    try {
      var querySnapshot = await _productsCollection(uid)
          .where('barcode', isEqualTo: barcode.trim())
          .get(const GetOptions(source: Source.cache));
      if (querySnapshot.docs.isEmpty) {
        querySnapshot = await _productsCollection(uid)
            .where('barcode', isEqualTo: barcode.trim())
            .get();
      }
      if (querySnapshot.docs.isEmpty) {
        return const Left(CacheFailure('Product not found'));
      }
      final doc = querySnapshot.docs.first;
      final product = ProductModel.fromMap(doc.id, doc.data());
      if (_uid != uid) {
        return const Left(AuthFailure('Authenticated user changed'));
      }
      _barcodeIndex.upsert(uid, product);
      return Right(product);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    final uid = _uid;
    _barcodeIndex.bind(uid);
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      final model = ProductModel.fromEntity(product);
      await _productsCollection(uid).doc(model.id).set(model.toMap());
      if (_uid == uid) _barcodeIndex.upsert(uid, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    final uid = _uid;
    _barcodeIndex.bind(uid);
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      final model = ProductModel.fromEntity(product);
      await _productsCollection(uid).doc(model.id).set(model.toMap());
      if (_uid == uid) _barcodeIndex.upsert(uid, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    final uid = _uid;
    _barcodeIndex.bind(uid);
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      await _productsCollection(uid).doc(id).delete();
      if (_uid == uid) _barcodeIndex.remove(uid, id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
