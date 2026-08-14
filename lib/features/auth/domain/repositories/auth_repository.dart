import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> get authStateChanges;
  AppUser? get currentUser;
  Future<Either<Failure, AppUser>> signUp(String email, String password);
  Future<Either<Failure, AppUser>> logIn(String email, String password);
  Future<Either<Failure, AppUser>> signInWithGoogle();
  Future<Either<Failure, void>> logOut();
  Future<Either<Failure, void>> sendPasswordResetEmail(String email);
  Future<Either<Failure, void>> sendVerificationCode();
  Future<Either<Failure, AppUser>> verifyEmailCode(String code);

  /// Native Firebase email verification (a clickable link, sent by Firebase
  /// itself) — no backend required. Used instead of the 6-digit code flow
  /// above until Cloud Functions can be deployed (needs the Blaze plan).
  Future<Either<Failure, void>> sendVerificationEmail();
  Future<Either<Failure, AppUser>> refreshEmailVerificationStatus();
}
