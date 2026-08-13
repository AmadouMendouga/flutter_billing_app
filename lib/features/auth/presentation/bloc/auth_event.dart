part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

/// Starts listening to Firebase's authStateChanges stream.
class AuthSubscriptionRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final AppUser? user;
  const AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user];
}

class SignUpRequested extends AuthEvent {
  final String email;
  final String password;
  const SignUpRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class LogInRequested extends AuthEvent {
  final String email;
  final String password;
  const LogInRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class LogOutRequested extends AuthEvent {}
