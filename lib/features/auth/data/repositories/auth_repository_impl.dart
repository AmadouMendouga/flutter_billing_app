import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      email: user.email,
      emailVerified: user.emailVerified,
    );
  }

  @override
  Stream<AppUser?> get authStateChanges =>
      _firebaseAuth.authStateChanges().map(_toAppUser);

  @override
  AppUser? get currentUser => _toAppUser(_firebaseAuth.currentUser);

  @override
  Future<Either<Failure, AppUser>> signUp(
      String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return Right(_toAppUser(credential.user)!);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    }
  }

  @override
  Future<Either<Failure, AppUser>> logIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return Right(_toAppUser(credential.user)!);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    }
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    try {
      final credential =
          await _firebaseAuth.signInWithProvider(GoogleAuthProvider());
      return Right(_toAppUser(credential.user)!);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    }
  }

  @override
  Future<Either<Failure, void>> logOut() async {
    try {
      await _firebaseAuth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationCode() async {
    try {
      await _functions.httpsCallable('sendVerificationCode').call();
      return const Right(null);
    } on FirebaseFunctionsException catch (e) {
      return Left(AuthFailure(_messageForFunctionsError(e)));
    }
  }

  @override
  Future<Either<Failure, AppUser>> verifyEmailCode(String code) async {
    try {
      await _functions
          .httpsCallable('verifyEmailCode')
          .call({'code': code});
      await _firebaseAuth.currentUser?.reload();
      final refreshed = _toAppUser(_firebaseAuth.currentUser);
      if (refreshed == null) {
        return const Left(AuthFailure('Session expirée, reconnecte-toi.'));
      }
      return Right(refreshed);
    } on FirebaseFunctionsException catch (e) {
      return Left(AuthFailure(_messageForFunctionsError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> sendVerificationEmail() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Left(AuthFailure('Session expirée, reconnecte-toi.'));
      }
      await user.sendEmailVerification();
      return const Right(null);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    }
  }

  @override
  Future<Either<Failure, AppUser>> refreshEmailVerificationStatus() async {
    try {
      await _firebaseAuth.currentUser?.reload();
      final refreshed = _toAppUser(_firebaseAuth.currentUser);
      if (refreshed == null) {
        return const Left(AuthFailure('Session expirée, reconnecte-toi.'));
      }
      return Right(refreshed);
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(_messageFor(e)));
    }
  }

  String _messageForFunctionsError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'invalid-argument':
        return e.message ?? 'Code incorrect.';
      case 'deadline-exceeded':
        return 'Ce code a expiré, demande-en un nouveau.';
      case 'resource-exhausted':
        return e.message ?? 'Trop de tentatives, réessaie plus tard.';
      case 'failed-precondition':
        return e.message ?? "Aucun code n'a été demandé.";
      case 'unauthenticated':
        return 'Session expirée, reconnecte-toi.';
      default:
        return e.message ?? 'Une erreur est survenue.';
    }
  }

  String _messageFor(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet email.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ou mot de passe incorrect.';
      case 'operation-not-allowed':
        return 'Connexion par email/mot de passe non activée.';
      case 'network-request-failed':
        return 'Pas de connexion internet.';
      case 'too-many-requests':
        return 'Trop de tentatives, réessaie dans quelques minutes.';
      case 'popup-closed-by-user':
      case 'cancelled-popup-request':
        return 'Connexion annulée.';
      case 'account-exists-with-different-credential':
        return 'Un compte existe déjà avec cet email via un autre moyen de connexion.';
      default:
        return e.message ?? 'Une erreur est survenue.';
    }
  }
}
