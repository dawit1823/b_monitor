// user_event.dart
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class UserEvent {
  const UserEvent();
}

class UserEventCheck extends UserEvent {
  final String email;

  const UserEventCheck(this.email);
}

class UserEventRegister extends UserEvent {
  final String email;
  final String password;
  final String role;

  const UserEventRegister(this.email, this.password, this.role);
}
