import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/auth/domain/entities/app_user.dart';
import 'package:billing_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:billing_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:billing_app/features/auth/presentation/pages/auth_page.dart';
import 'package:billing_app/core/widgets/google_sign_in_button.dart';
import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

void main() {
  testWidgets('the authentication form stays responsive', (tester) async {
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpWidget(_buildAuthPage());

    final emailField = find.byType(TextFormField).first;
    var fieldRect = tester.getRect(emailField);

    expect(fieldRect.width, 520);
    expect(fieldRect.center.dx, 720);

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpAndSettle();
    fieldRect = tester.getRect(emailField);

    expect(fieldRect.width, 342);
    expect(fieldRect.center.dx, 195);
  });

  testWidgets('an unexpected Google error is visible and unlocks the button', (
    tester,
  ) async {
    await tester.pumpWidget(_buildAuthPage());

    await tester.tap(find.text('Continuer avec Google'));
    await tester.pumpAndSettle();

    expect(
      find.text('Connexion Google impossible. Réessaie ou utilise ton email.'),
      findsOneWidget,
    );
    final button = tester.widget<GoogleSignInButton>(
      find.byType(GoogleSignInButton),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
    'the password can be shown, hidden, and is remasked on mode change',
    (tester) async {
      await tester.pumpWidget(_buildAuthPage());

      final passwordField = find.byKey(const ValueKey('password-field'));
      final visibilityToggle = find.byKey(
        const ValueKey('password-visibility-toggle'),
      );
      EditableText editablePassword() => tester.widget<EditableText>(
        find.descendant(of: passwordField, matching: find.byType(EditableText)),
      );

      expect(editablePassword().obscureText, isTrue);
      expect(find.byTooltip('Afficher le mot de passe'), findsOneWidget);

      await tester.tap(visibilityToggle);
      await tester.pump();

      expect(editablePassword().obscureText, isFalse);
      expect(find.byTooltip('Masquer le mot de passe'), findsOneWidget);

      await tester.tap(find.text('Pas encore de compte ? En créer un'));
      await tester.pump();

      expect(editablePassword().obscureText, isTrue);
    },
  );
}

Widget _buildAuthPage() {
  return BlocProvider(
    create: (_) => AuthBloc(authRepository: _FakeAuthRepository()),
    child: const MaterialApp(
      locale: Locale('fr'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AuthPage(),
    ),
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> get authStateChanges => const Stream.empty();

  @override
  AppUser? get currentUser => null;

  @override
  Future<Either<Failure, AppUser>> logIn(String email, String password) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, void>> logOut() {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AppUser>> refreshEmailVerificationStatus() {
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
  Future<Either<Failure, void>> sendVerificationEmail() {
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
