// auth_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:r_and_e_monitor/services/auth/auth_user.dart';

@immutable
abstract class AuthState extends Equatable {
  final bool isLoading;
  final String? loadingText;

  const AuthState(
      {required this.isLoading, this.loadingText = 'wait a moment...'});

  AuthState copyWith({bool? isLoading, String? loadingText});

  @override
  List<Object?> get props => [isLoading, loadingText];
}

class AuthStateUnInitialized extends AuthState {
  const AuthStateUnInitialized({required super.isLoading});

  @override
  AuthStateUnInitialized copyWith({bool? isLoading, String? loadingText}) {
    return AuthStateUnInitialized(isLoading: isLoading ?? this.isLoading);
  }
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;

  const AuthStateRegistering(
      {required this.exception, required super.isLoading});

  @override
  AuthStateRegistering copyWith({bool? isLoading, String? loadingText}) {
    return AuthStateRegistering(
      exception: exception,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser user;

  const AuthStateLoggedIn({required this.user, required super.isLoading});

  @override
  AuthStateLoggedIn copyWith({bool? isLoading, String? loadingText}) {
    return AuthStateLoggedIn(
      user: user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification({required super.isLoading});

  @override
  AuthStateNeedsVerification copyWith({bool? isLoading, String? loadingText}) {
    return AuthStateNeedsVerification(isLoading: isLoading ?? this.isLoading);
  }
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;

  const AuthStateLoggedOut(
      {required this.exception,
      required super.isLoading,
      super.loadingText = null});

  @override
  AuthStateLoggedOut copyWith(
      {bool? isLoading, String? loadingText, Exception? exception}) {
    return AuthStateLoggedOut(
      exception: exception ?? this.exception,
      isLoading: isLoading ?? this.isLoading,
      loadingText: loadingText ?? this.loadingText,
    );
  }

  @override
  List<Object?> get props => [exception, isLoading, loadingText];
}

class AuthStateLoggingIn extends AuthState {
  const AuthStateLoggingIn(
      {required super.isLoading, super.loadingText = null});

  @override
  AuthStateLoggingIn copyWith({bool? isLoading, String? loadingText}) {
    return AuthStateLoggingIn(
      isLoading: isLoading ?? this.isLoading,
      loadingText: loadingText ?? this.loadingText,
    );
  }
}
