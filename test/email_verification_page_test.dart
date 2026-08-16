import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/auth/domain/entities/app_user.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/pages/email_verification_page.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  testWidgets('a verified email shows the success motion before continuing', (
    tester,
  ) async {
    const pendingUser = AppUser(uid: 'user-1', email: 'shop@example.com');
    const verifiedUser = AppUser(
      uid: 'user-1',
      email: 'shop@example.com',
      emailVerified: true,
    );
    final repository = _VerificationRepository(verifiedUser);
    final bloc = AuthBloc(authRepository: repository);
    addTearDown(bloc.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: bloc,
        child: const MaterialApp(
          locale: Locale('fr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EmailVerificationPage(user: pendingUser),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('J’ai ouvert le lien'));
    await tester.pump();

    expect(find.text('E-mail vérifié !'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    expect(bloc.state, isA<AuthInitial>());

    await tester.pump(const Duration(milliseconds: 1201));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 501));
    await tester.pump();
    await tester.pump();

    expect(bloc.state, const AuthAuthenticated(verifiedUser));
  });
}

class _VerificationRepository implements AuthRepository {
  _VerificationRepository(this.verifiedUser);

  final AppUser verifiedUser;

  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  AppUser? get currentUser => verifiedUser;

  @override
  Future<Either<Failure, AppUser>> refreshEmailVerificationStatus() async {
    return Right(verifiedUser);
  }

  @override
  Future<Either<Failure, void>> sendVerificationEmail() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, AppUser>> logIn(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logOut() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> sendVerificationCode() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AppUser>> signInWithGoogle() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AppUser>> signUp(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AppUser>> verifyEmailCode(String code) {
    throw UnimplementedError();
  }
}
