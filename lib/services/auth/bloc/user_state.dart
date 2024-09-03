// user_state.dart
import 'package:flutter/foundation.dart' show immutable;
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

@immutable
abstract class UserState {
  final bool isLoading;
  final String? loadingText;

  const UserState({this.isLoading = false, this.loadingText});

  UserState copyWith({bool? isLoading, String? loadingText});
}

class UserStateInitial extends UserState {
  const UserStateInitial({super.isLoading, super.loadingText});

  @override
  UserStateInitial copyWith({bool? isLoading, String? loadingText}) {
    return UserStateInitial(
      isLoading: isLoading ?? this.isLoading,
      loadingText: loadingText ?? this.loadingText,
    );
  }
}

class UserStateChecking extends UserState {
  const UserStateChecking({super.isLoading = true, super.loadingText});

  @override
  UserStateChecking copyWith({bool? isLoading, String? loadingText}) {
    return UserStateChecking(
      isLoading: isLoading ?? this.isLoading,
      loadingText: loadingText ?? this.loadingText,
    );
  }
}

class UserStateFound extends UserState {
  final CloudEmployee employee;

  const UserStateFound(this.employee,
      {super.isLoading, super.loadingText});

  @override
  UserStateFound copyWith({bool? isLoading, String? loadingText}) {
    return UserStateFound(
      employee,
      isLoading: isLoading ?? this.isLoading,
      loadingText: loadingText ?? this.loadingText,
    );
  }
}

class UserStateNotFound extends UserState {
  const UserStateNotFound({super.isLoading, super.loadingText});

  @override
  UserStateNotFound copyWith({bool? isLoading, String? loadingText}) {
    return UserStateNotFound(
      isLoading: isLoading ?? this.isLoading,
      loadingText: loadingText ?? this.loadingText,
    );
  }
}

class UserStateFailure extends UserState {
  final Exception exception;

  const UserStateFailure(this.exception,
      {super.isLoading, super.loadingText});

  @override
  UserStateFailure copyWith({bool? isLoading, String? loadingText}) {
    return UserStateFailure(
      exception,
      isLoading: isLoading ?? this.isLoading,
      loadingText: loadingText ?? this.loadingText,
    );
  }
}

class UserStateRegistering extends UserState {
  const UserStateRegistering({super.isLoading = true, super.loadingText});

  @override
  UserStateRegistering copyWith({bool? isLoading, String? loadingText}) {
    return UserStateRegistering(
      isLoading: isLoading ?? this.isLoading,
      loadingText: loadingText ?? this.loadingText,
    );
  }
}

class UserStateRegistered extends UserState {
  const UserStateRegistered({super.isLoading, super.loadingText});

  @override
  UserStateRegistered copyWith({bool? isLoading, String? loadingText}) {
    return UserStateRegistered(
      isLoading: isLoading ?? this.isLoading,
      loadingText: loadingText ?? this.loadingText,
    );
  }
}
