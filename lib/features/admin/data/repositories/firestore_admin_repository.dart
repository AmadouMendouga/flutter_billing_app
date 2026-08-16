import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../product/data/models/product_model.dart';
import '../../../product/domain/entities/product.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../domain/entities/admin_access.dart';
import '../../domain/entities/admin_shop.dart';
import '../../domain/entities/product_copy_report.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/services/product_copy_planner.dart';
import '../models/admin_access_model.dart';
import '../models/admin_shop_model.dart';

class AdminOperationException implements Exception {
  final String message;

  const AdminOperationException(this.message);

  @override
  String toString() => message;
}

class FirestoreAdminRepository implements AdminRepository {
  static const _copyBatchSize = 450;

  final FirebaseFirestore _firestore;

  const FirestoreAdminRepository({required FirebaseFirestore firestore})
    : _firestore = firestore;

  CollectionReference<Map<String, dynamic>> get _shops =>
      _firestore.collection('shops');

  CollectionReference<Map<String, dynamic>> get _auditLogs =>
      _firestore.collection('adminAuditLogs');

  CollectionReference<Map<String, dynamic>> _products(String shopId) =>
      _shops.doc(shopId).collection('products');

  @override
  Stream<AdminAccess> watchAdminAccess(String uid) {
    if (uid.trim().isEmpty) {
      return Stream.value(const AdminAccess.denied(''));
    }
    return _firestore
        .collection('admins')
        .doc(uid)
        .snapshots()
        .map((snapshot) => AdminAccessModel.fromMap(uid, snapshot.data()));
  }

  @override
  Stream<List<AdminShop>> watchShops() {
    return _shops.snapshots().map((snapshot) {
      final shops =
          snapshot.docs
              .map((doc) => AdminShopModel.fromMap(doc.id, doc.data()))
              .toList();
      shops.sort(_compareShops);
      return List.unmodifiable(shops);
    });
  }

  @override
  Stream<List<Product>> watchProducts(String shopId) {
    return _products(shopId).snapshots().map((snapshot) {
      final products =
          snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.id, doc.data()).toEntity())
              .toList();
      products.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      return List.unmodifiable(products);
    });
  }

  @override
  Future<void> setShopStatus({
    required String shopId,
    required ShopStatus status,
    required String adminUid,
    String reason = '',
  }) async {
    _requireId(shopId, 'shopId');
    _requireId(adminUid, 'adminUid');
    final normalizedReason = reason.trim();
    if ((status == ShopStatus.suspended || status == ShopStatus.rejected) &&
        normalizedReason.isEmpty) {
      throw const AdminOperationException(
        'A reason is required to suspend or reject a shop.',
      );
    }

    final shopReference = _shops.doc(shopId);
    final snapshot = await shopReference.get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) {
      throw const AdminOperationException('Shop not found.');
    }
    final previousStatus = ShopStatus.fromFirestore(data['status']);
    if (previousStatus == status &&
        (data['statusReason'] as String? ?? '') == normalizedReason) {
      return;
    }

    final batch = _firestore.batch();
    batch.update(shopReference, {
      'status': status.firestoreValue,
      'statusReason': normalizedReason,
      'updatedAt': FieldValue.serverTimestamp(),
      'statusUpdatedAt': FieldValue.serverTimestamp(),
      'statusUpdatedBy': adminUid,
    });
    batch.set(_auditLogs.doc(), {
      'action': 'shop_status_changed',
      'actorUid': adminUid,
      'shopId': shopId,
      'previousStatus': previousStatus.firestoreValue,
      'newStatus': status.firestoreValue,
      'reason': normalizedReason,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  @override
  Future<ProductCopyReport> copyMissingProducts({
    required String sourceShopId,
    required String targetShopId,
    required String adminUid,
  }) async {
    _requireId(sourceShopId, 'sourceShopId');
    _requireId(targetShopId, 'targetShopId');
    _requireId(adminUid, 'adminUid');
    if (sourceShopId == targetShopId) {
      throw const AdminOperationException(
        'Source and target shops must be different.',
      );
    }

    final shopSnapshots = await Future.wait([
      _shops.doc(sourceShopId).get(),
      _shops.doc(targetShopId).get(),
    ]);
    if (!shopSnapshots[0].exists || !shopSnapshots[1].exists) {
      throw const AdminOperationException('Source or target shop not found.');
    }
    final targetStatus = ShopStatus.fromFirestore(
      shopSnapshots[1].data()?['status'],
    );
    if (targetStatus != ShopStatus.active) {
      throw const AdminOperationException('The target shop must be active.');
    }

    final snapshots = await Future.wait([
      _products(sourceShopId).get(),
      _products(targetShopId).get(),
    ]);
    final sourceProducts = snapshots[0].docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()).toEntity())
        .toList(growable: false);
    final targetProducts = snapshots[1].docs
        .map((doc) => ProductModel.fromMap(doc.id, doc.data()).toEntity())
        .toList(growable: false);
    final plan = planMissingProductCopies(
      sourceProducts: sourceProducts,
      targetProducts: targetProducts,
    );

    for (
      var offset = 0;
      offset < plan.products.length;
      offset += _copyBatchSize
    ) {
      final end = (offset + _copyBatchSize).clamp(0, plan.products.length);
      final batch = _firestore.batch();
      for (final product in plan.products.sublist(offset, end)) {
        final reference = _products(targetShopId).doc();
        batch.set(reference, {
          'name': product.name,
          'barcode': product.barcode,
          'price': product.price,
          'stock': 0,
        });
      }
      await batch.commit();
    }

    final report = plan.report;
    await _auditLogs.add({
      'action': 'products_copied',
      'actorUid': adminUid,
      'sourceShopId': sourceShopId,
      'targetShopId': targetShopId,
      'sourceCount': report.sourceCount,
      'copiedCount': report.copiedCount,
      'skippedCount': report.skippedCount,
      // Samples keep the audit document bounded for large catalogues while
      // the complete report is still returned to the administrator.
      'existingBarcodeSample': report.existingBarcodes.take(100).toList(),
      'duplicateSourceBarcodeSample':
          report.duplicateSourceBarcodes.take(100).toList(),
      'missingBarcodeCount': report.missingBarcodeCount,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return report;
  }

  static int _compareShops(AdminShop a, AdminShop b) {
    final statusComparison = _statusWeight(
      a.status,
    ).compareTo(_statusWeight(b.status));
    if (statusComparison != 0) return statusComparison;
    final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final dateComparison = bDate.compareTo(aDate);
    if (dateComparison != 0) return dateComparison;
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  }

  static int _statusWeight(ShopStatus status) => switch (status) {
    ShopStatus.pending => 0,
    ShopStatus.active => 1,
    ShopStatus.suspended => 2,
    ShopStatus.rejected => 3,
  };

  static void _requireId(String value, String fieldName) {
    if (value.trim().isEmpty) {
      throw AdminOperationException('$fieldName cannot be empty.');
    }
  }
}
