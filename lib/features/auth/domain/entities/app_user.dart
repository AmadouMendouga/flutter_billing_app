import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String? email;

  const AppUser({required this.uid, this.email});

  @override
  List<Object?> get props => [uid, email];
}
