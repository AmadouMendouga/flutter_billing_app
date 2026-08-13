part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

/// Nothing has happened yet (before AuthSubscriptionRequested is added).
class AuthInitial extends AuthState {}

/// Auth state is unknown: either resolving the persisted session at cold
/// start, or a sign-up/log-in request is in flight.
class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final AppUser user;
  /// Shop name entered on the sign-up form, to be saved once. Null for
  /// logins/session restores, where there's nothing new to save.
  final String? pendingShopName;
  const AuthAuthenticated(this.user, {this.pendingShopName});
  @override
  List<Object?> get props => [user, pendingShopName];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
