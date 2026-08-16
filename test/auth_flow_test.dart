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

  test('Google sign-in emits submitting then the authenticated user', () async {
    const googleUser = AppUser(
      uid: 'google-user',
      email: 'google@example.com',
      emailVerified: true,
    );
    final repository = _FakeAuthRepository(googleUser: googleUser);
    final bloc = AuthBloc(authRepository: repository);
    addTearDown(bloc.close);

    final states = bloc.stream.take(2).toList();
    bloc.add(GoogleSignInRequested());

    expect(
      await states,
      [isA<AuthSubmitting>(), const AuthAuthenticated(googleUser)],
    );
  });

  test('a Google cancellation is exposed instead of leaving the form loading',
      () async {
    final repository = _FakeAuthRepository(
      googleFailure: const AuthFailure('Connexion Google annulée.'),
    );
    final bloc = AuthBloc(authRepository: repository);
    addTearDown(bloc.close);

    final states = bloc.stream.take(2).toList();
    bloc.add(GoogleSignInRequested());

    expect(
      await states,
      [
        isA<AuthSubmitting>(),
        const AuthError('Connexion Google annulée.'),
      ],
    );
  });

  test('an unexpected Google error cannot leave the form loading', () async {
    final repository = _FakeAuthRepository(
      googleException: UnsupportedError('not supported'),
    );
    final bloc = AuthBloc(authRepository: repository);
    addTearDown(bloc.close);

    final states = bloc.stream.take(2).toList();
    bloc.add(GoogleSignInRequested());

    expect(
      await states,
      [
        isA<AuthSubmitting>(),
        const AuthError(
          'Connexion Google impossible. Réessaie ou utilise ton email.',
        ),
      ],
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.currentUserValue,
    this.signUpUser,
    this.signUpFailure,
    this.googleUser,
    this.googleFailure,
    this.googleException,
  });

  AppUser? currentUserValue;
  final AppUser? signUpUser;
  final Failure? signUpFailure;
  final AppUser? googleUser;
  final Failure? googleFailure;
  final Object? googleException;

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
    final exception = googleException;
    if (exception != null) throw exception;
    final user = googleUser;
    if (user != null) {
      currentUserValue = user;
      return Right(user);
    }
    return Left(
      googleFailure ?? const AuthFailure('Connexion Google impossible.'),
    );
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
