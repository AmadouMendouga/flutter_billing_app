import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<AppUser?>? _authSubscription;

  /// Shop name entered at sign-up, held here (rather than only on the
  /// emitted state) so it survives the email-verification gate: the
  /// Firebase authStateChanges stream can re-fire AuthUserChanged one or
  /// more times while verification is pending, each of which would
  /// otherwise reset it before EmailVerificationPage ever gets to consume
  /// it. Cleared once a verified user state is emitted, or on sign-out.
  String? _pendingShopName;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthSubscriptionRequested>(_onSubscriptionRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<SignUpRequested>(_onSignUpRequested);
    on<LogInRequested>(_onLogInRequested);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<LogOutRequested>(_onLogOutRequested);
  }

  void _onSubscriptionRequested(
      AuthSubscriptionRequested event, Emitter<AuthState> emit) {
    emit(AuthLoading());
    _authSubscription?.cancel();
    _authSubscription = authRepository.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    final user = event.user;
    if (user != null) {
      final shopName = _pendingShopName;
      if (user.emailVerified) {
        _pendingShopName = null;
      }
      emit(AuthAuthenticated(user, pendingShopName: shopName));
    } else {
      _pendingShopName = null;
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignUpRequested(
      SignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.signUp(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        _pendingShopName = event.shopName;
        emit(AuthAuthenticated(user, pendingShopName: event.shopName));
      },
    );
  }

  Future<void> _onLogInRequested(
      LogInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.logIn(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.signInWithGoogle();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogOutRequested(
      LogOutRequested event, Emitter<AuthState> emit) async {
    // AuthUnauthenticated is emitted via the authStateChanges subscription
    // once Firebase confirms the sign-out.
    await authRepository.logOut();
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
