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
}
