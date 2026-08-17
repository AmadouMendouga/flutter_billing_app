import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/stock_sale_line.dart';
import '../../domain/failures/stock_failure.dart';
import '../../domain/repositories/product_repository.dart';
import '../models/product_model.dart';
import '../product_barcode_index.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
    ProductBarcodeIndex? barcodeIndex,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _barcodeIndex = barcodeIndex ?? ProductBarcodeIndex();

  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;
  final ProductBarcodeIndex _barcodeIndex;

  CollectionReference<Map<String, dynamic>> _productsCollection(String uid) =>
      _firestore.collection('shops').doc(uid).collection('products');

  String? get _uid => _firebaseAuth.currentUser?.uid;

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    final uid = _uid;
    _barcodeIndex.bind(uid);
    if (uid == null) return const Left(AuthFailure('No authenticated user'));
    try {
      final snapshot = await _productsCollection(uid).get();
      final products =
          snapshot.docs
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
        querySnapshot =
            await _productsCollection(
              uid,
            ).where('barcode', isEqualTo: barcode.trim()).get();
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

  @override
  Future<Either<Failure, List<Product>>> completeSale(
    List<StockSaleLine> lines,
  ) async {
    final uid = _uid;
    _barcodeIndex.bind(uid);
    if (uid == null) return const Left(AuthFailure('No authenticated user'));

    for (final line in lines) {
      if (line.quantity <= 0) {
        return Left(
          InvalidStockQuantityFailure(
            productId: line.productId.trim(),
            productName: line.productName.trim(),
            requestedQuantity: line.quantity,
          ),
        );
      }
    }

    final consolidatedLines = consolidateStockSaleLines(lines);
    if (consolidatedLines.isEmpty) return const Right([]);

    for (final line in consolidatedLines) {
      if (line.productId.isEmpty) {
        return Left(
          ProductDeletedFailure(
            productId: line.productId,
            productName: line.productName,
            requestedQuantity: line.quantity,
          ),
        );
      }
    }

    try {
      final result = await _firestore
          .runTransaction<Either<Failure, List<Product>>>((transaction) async {
            final entries = <_StockTransactionEntry>[];

            // Firestore transactions require all reads to happen before the
            // first write. Read every product first, then validate the whole
            // sale, and only then enqueue stock updates.
            for (final line in consolidatedLines) {
              final reference = _productsCollection(uid).doc(line.productId);
              final snapshot = await transaction.get(reference);
              entries.add(
                _StockTransactionEntry(
                  line: line,
                  reference: reference,
                  snapshot: snapshot,
                ),
              );
            }

            for (final entry in entries) {
              if (!entry.snapshot.exists) {
                return Left(
                  ProductDeletedFailure(
                    productId: entry.line.productId,
                    productName: entry.line.productName,
                    requestedQuantity: entry.line.quantity,
                  ),
                );
              }
            }

            final updatedProducts = <Product>[];
            for (final entry in entries) {
              final current = ProductModel.fromMap(
                entry.snapshot.id,
                entry.snapshot.data()!,
              );
              if (current.stock < entry.line.quantity) {
                return Left(
                  InsufficientStockFailure(
                    productId: current.id,
                    productName:
                        current.name.trim().isEmpty
                            ? entry.line.productName
                            : current.name,
                    availableQuantity: current.stock,
                    requestedQuantity: entry.line.quantity,
                  ),
                );
              }

              updatedProducts.add(
                ProductModel(
                  id: current.id,
                  name: current.name,
                  barcode: current.barcode,
                  price: current.price,
                  stock: current.stock - entry.line.quantity,
                ),
              );
            }

            for (var index = 0; index < entries.length; index++) {
              transaction.update(entries[index].reference, {
                'stock': updatedProducts[index].stock,
              });
            }

            return Right(List<Product>.unmodifiable(updatedProducts));
          });

      return result.fold(
        (failure) {
          // A failed transaction exposes authoritative server state. Remove
          // the matching cached item so a later scan cannot reuse stale stock
          // or a product that has been deleted remotely.
          if (_uid == uid && failure is StockFailure) {
            _barcodeIndex.remove(uid, failure.productId);
          }
          return Left(failure);
        },
        (products) {
          if (_uid == uid) _barcodeIndex.upsertAll(uid, products);
          return Right(products);
        },
      );
    } on FirebaseException catch (error) {
      return Left(CacheFailure(error.message ?? error.code));
    } catch (error) {
      return Left(CacheFailure(error.toString()));
    }
  }
}

final class _StockTransactionEntry {
  const _StockTransactionEntry({
    required this.line,
    required this.reference,
    required this.snapshot,
  });

  final StockSaleLine line;
  final DocumentReference<Map<String, dynamic>> reference;
  final DocumentSnapshot<Map<String, dynamic>> snapshot;
}
