import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    final user = _auth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user.uid));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );
      emit(AuthAuthenticated(_auth.currentUser!.uid));
    } on FirebaseAuthException catch (e) {
      
      String message = 'Login failed';
      if (e.code == 'user-not-found') {
        message = 'No user found with this email.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = 'Incorrect password. Please try again.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else if (e.code == 'user-disabled') {
        message = 'This user account has been disabled.';
      }
      emit(AuthError(message));
    } catch (_) {
      emit(AuthError('Something went wrong. Try again.'));
    }
  }

  Future<void> _onSignupRequested(
      AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password.trim(),
      );

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': cred.user!.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      emit(AuthAuthenticated(cred.user!.uid));
    } on FirebaseAuthException catch (e) {
      
      String message = 'Signup failed';
      if (e.code == 'email-already-in-use') {
        message = 'The email address is already in use by another account.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is badly formatted.';
      } else if (e.code == 'operation-not-allowed') {
        message = 'Email/password accounts are not enabled.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      }
      emit(AuthError(message));
    } catch (_) {
      emit(AuthError('Something went wrong. Try again.'));
    }
  }
  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }
}