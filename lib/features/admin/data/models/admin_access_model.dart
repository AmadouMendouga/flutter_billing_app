import '../../domain/entities/admin_access.dart';

class AdminAccessModel {
  const AdminAccessModel._();

  static AdminAccess fromMap(String uid, Map<String, dynamic>? map) {
    if (map == null) return AdminAccess.denied(uid);
    return AdminAccess(
      uid: uid,
      role: _roleFromFirestore(map['role']),
      isActive: map['enabled'] == true,
    );
  }

  static AdminRole _roleFromFirestore(Object? value) {
    return switch (value) {
      'super_admin' || 'superAdmin' => AdminRole.superAdmin,
      'reviewer' => AdminRole.reviewer,
      'support' => AdminRole.support,
      'catalog_manager' || 'catalogManager' => AdminRole.catalogManager,
      _ => AdminRole.unknown,
    };
  }
}
