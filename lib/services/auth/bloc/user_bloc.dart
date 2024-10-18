// user_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserBloc() : super(const UserStateInitial()) {
    on<UserEventCheck>(_onCheckUser);
    on<UserEventRegister>(_onRegisterUser);
  }

  Future<void> _onCheckUser(
      UserEventCheck event, Emitter<UserState> emit) async {
    emit(const UserStateChecking(
        isLoading: false, loadingText: 'Checking user...'));
    try {
      final querySnapshot = await _firestore
          .collection('employees')
          .where('email', isEqualTo: event.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final employee = CloudEmployee.fromFirestore(doc);
        emit(UserStateFound(employee, isLoading: false));
      } else {
        emit(const UserStateNotFound(isLoading: false));
      }
    } on Exception catch (e) {
      emit(UserStateFailure(e, isLoading: false));
    }
  }

  Future<void> _onRegisterUser(
      UserEventRegister event, Emitter<UserState> emit) async {
    emit(const UserStateRegistering(
        isLoading: true, loadingText: 'Registering user...'));
    try {
      final UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      await userCredential.user!.sendEmailVerification();
      await _firestore
          .collection('employees')
          .doc(userCredential.user!.uid)
          .set({
        'email': event.email,
        'role': event.role, // Include the role
      });

      emit(const UserStateRegistered(isLoading: false));
    } catch (e) {
      emit(UserStateFailure(e as Exception, isLoading: false));
    }
  }
}
