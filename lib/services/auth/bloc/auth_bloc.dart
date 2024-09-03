//auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_and_e_monitor/services/auth/auth_provider.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_event.dart';
import 'package:r_and_e_monitor/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthProvider provider;

  AuthBloc(this.provider)
      : super(const AuthStateUnInitialized(isLoading: true)) {
    on<AuthEventInitialize>(_onInitialize);
    on<AuthEventSendEmailVerification>(_onSendEmailVerification);
    on<AuthEventRegister>(_onRegister);
    on<AuthEventLogIn>(_onLogIn);
    on<AuthEventLogOut>(_onLogOut);
  }

  Future<void> _onInitialize(
      AuthEventInitialize event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isLoading: true));
    await provider.initialize();
    final user = provider.currentUser;
    if (user == null) {
      emit(const AuthStateLoggedOut(exception: null, isLoading: false));
    } else if (!user.isEmailVerified) {
      emit(const AuthStateNeedsVerification(isLoading: false));
    } else {
      emit(AuthStateLoggedIn(user: user, isLoading: false));
    }
  }

  Future<void> _onSendEmailVerification(
      AuthEventSendEmailVerification event, Emitter<AuthState> emit) async {
    await provider.sendEmailVerification();
    emit(state);
  }

  Future<void> _onRegister(
      AuthEventRegister event, Emitter<AuthState> emit) async {
    final email = event.email;
    final password = event.password;
    try {
      await provider.createUser(email: email, password: password);
      await provider.sendEmailVerification();
      emit(const AuthStateNeedsVerification(isLoading: false));
    } on Exception catch (e) {
      emit(AuthStateRegistering(exception: e, isLoading: false));
    }
  }

  Future<void> _onLogIn(AuthEventLogIn event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoggingIn(
        isLoading: true, loadingText: 'Logging in...'));
    final email = event.email;
    final password = event.password;
    try {
      final user = await provider.logIn(email: email, password: password);
      if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification(isLoading: false));
      } else {
        emit(AuthStateLoggedIn(user: user, isLoading: false));
      }
    } on Exception catch (e) {
      emit(AuthStateLoggedOut(exception: e, isLoading: false));
    }
  }

  Future<void> _onLogOut(AuthEventLogOut event, Emitter<AuthState> emit) async {
    emit(const AuthStateLoggedOut(
        exception: null, isLoading: false, loadingText: 'Please wait...'));
    try {
      await provider.signOut();
      emit(const AuthStateLoggedOut(exception: null, isLoading: false));
    } on Exception catch (e) {
      emit(AuthStateLoggedOut(exception: e, isLoading: false));
    }
  }
}
