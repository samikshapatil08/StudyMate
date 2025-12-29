part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
}

class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  AuthSignupRequested(this.email, this.password);
}

class AuthLogoutRequested extends AuthEvent {}