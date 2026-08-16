import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/auth/domain/entities/app_user.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  const user = AppUser(
    uid: 'user-1',
    email: 'shop@example.com',
  );

  test('sign-up emits a submitting state then the Firebase user', () async {
    final repository = _FakeAuthRepository(signUpUser: user);
    final bloc = AuthBloc(authRepository: repository);
    addTearDown(bloc.close);

    final states = bloc.stream.take(2).toList();
    bloc.add(const SignUpRequested(
      'shop@example.com',
      'Password1!',
      'Ma boutique',
    ));

    expect(
      await states,
      [
        isA<AuthSubmitting>(),
        const AuthAuthenticated(user, pendingShopName: 'Ma boutique'),
      ],
    );
  });

  test('a late failure cannot overwrite an existing Firebase session',
      () async {
    final repository = _FakeAuthRepository(
      currentUserValue: user,
      signUpFailure: const AuthFailure('Pas de connexion internet.'),
    );
    final bloc = AuthBloc(authRepository: repository);
    addTearDown(bloc.close);

    final states = bloc.stream.take(2).toList();
    bloc.add(const SignUpRequested(
      'shop@example.com',
      'Password1!',
      'Ma boutique',
    ));

    expect(
      await states,
      [
        isA<AuthSubmitting>(),
        const AuthAuthenticated(user, pendingShopName: 'Ma boutique'),
      ],
    );
  });

  test('a queued null event cannot overwrite an existing Firebase session',
      () async {
    final repository = _FakeAuthRepository(currentUserValue: user);
    final bloc = AuthBloc(authRepository: repository);
    addTearDown(bloc.close);

    final state = bloc.stream.first;
    bloc.add(const AuthUserChanged(null));

    expect(await state, const AuthAuthenticated(user));
  });

  test('a real sign-up failure remains visible as AuthError', () async {
    final repository = _FakeAuthRepository(
      signUpFailure: const AuthFailure('Un compte existe déjà avec cet email.'),
    );
    final bloc = AuthBloc(authRepository: repository);
    addTearDown(bloc.close);

    final states = bloc.stream.take(2).toList();
    bloc.add(const SignUpRequested(
      'shop@example.com',
      'Password1!',
      'Ma boutique',
    ));

    expect(
      await states,
      [
        isA<AuthSubmitting>(),
        const AuthError('Un compte existe déjà avec cet email.'),
      ],
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.currentUserValue,
    this.signUpUser,
    this.signUpFailure,
  });

  AppUser? currentUserValue;
  final AppUser? signUpUser;
  final Failure? signUpFailure;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  AppUser? get currentUser => currentUserValue;

  @override
  Future<Either<Failure, AppUser>> signUp(String email, String password) async {
    if (signUpUser != null) {
      currentUserValue = signUpUser;
      return Right(signUpUser!);
    }
    return Left(signUpFailure ?? const AuthFailure('Échec de l’inscription.'));
  }

  @override
  Future<Either<Failure, AppUser>> logIn(String email, String password) async {
    return const Left(AuthFailure('Non utilisé dans ce test.'));
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() async {
    return const Left(AuthFailure('Non utilisé dans ce test.'));
  }

  @override
  Future<Either<Failure, void>> logOut() async => const Right(null);

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendVerificationCode() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, AppUser>> verifyEmailCode(String code) async {
    return const Left(AuthFailure('Non utilisé dans ce test.'));
  }

  @override
  Future<Either<Failure, void>> sendVerificationEmail() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, AppUser>> refreshEmailVerificationStatus() async {
    final currentUser = currentUserValue;
    if (currentUser == null) {
      return const Left(AuthFailure('Session expirée.'));
    }
    return Right(currentUser);
  }
}
