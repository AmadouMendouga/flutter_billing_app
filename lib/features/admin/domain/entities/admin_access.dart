import 'package:equatable/equatable.dart';

enum AdminRole { superAdmin, reviewer, support, catalogManager, unknown }

class AdminAccess extends Equatable {
  final String uid;
  final AdminRole role;
  final bool isActive;

  const AdminAccess({
    required this.uid,
    required this.role,
    required this.isActive,
  });

  const AdminAccess.denied(String uid)
    : this(uid: uid, role: AdminRole.unknown, isActive: false);

  bool get canOpenDashboard => isActive && role != AdminRole.unknown;

  bool get canReviewShops =>
      isActive && (role == AdminRole.superAdmin || role == AdminRole.reviewer);

  bool get canCopyProducts =>
      isActive &&
      (role == AdminRole.superAdmin || role == AdminRole.catalogManager);

  @override
  List<Object?> get props => [uid, role, isActive];
}
