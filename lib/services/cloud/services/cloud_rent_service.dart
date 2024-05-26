//cloud_rent_service.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_storage_exceptions.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_storage_storage.dart';

class RentService {
  final FirebaseCloudStorage _firebaseStorage = FirebaseCloudStorage.instance;

  final CollectionReference profiles =
      FirebaseFirestore.instance.collection('profiles');
  final CollectionReference rents =
      FirebaseFirestore.instance.collection('rents');
  final CollectionReference expenses =
      FirebaseFirestore.instance.collection('expenses');

  Future<CloudProfile> createProfile({
    required String creatorId,
    required String companyName,
    required String firstName,
    required String lastName,
    required String tin,
    required String email,
    required String phoneNumber,
    required String address,
    required String contractInfo,
  }) async {
    final docRef = await _firebaseStorage.addDocument(
      collectionPath: 'profiles',
      data: {
        'creatorId': creatorId,
        'companyName': companyName,
        'firstName': firstName,
        'lastName': lastName,
        'tin': tin,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'contractInfo': contractInfo,
      },
    );

    return CloudProfile(
      id: docRef.id,
      creatorId: creatorId,
      companyName: companyName,
      firstName: firstName,
      lastName: lastName,
      tin: tin,
      email: email,
      phoneNumber: phoneNumber,
      address: address,
      contractInfo: contractInfo,
    );
  }

  Future<List<CloudRent>> getRentsByProfileId(
      {required String profileId}) async {
    final querySnapshot =
        await rents.where('profileId', isEqualTo: profileId).get();
    return querySnapshot.docs
        .map((doc) => CloudRent.fromFirestore(doc))
        .toList();
  }

  Stream<Iterable<CloudProfile>> allProfiles({required String creatorId}) {
    return profiles
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CloudProfile.fromFirestore(doc));
    });
  }

  Future<CloudProfile> getProfile({required String id}) async {
    final docSnapshot = await _firebaseStorage.getDocument(
      collectionPath: 'profiles',
      documentId: id,
    );
    if (!docSnapshot.exists) throw CouldNotFindProfileException();
    return CloudProfile.fromFirestore(docSnapshot);
  }

  Future<CloudProfile> updateProfile({
    required String id,
    required String companyName,
    required String firstName,
    required String lastName,
    required String tin,
    required String email,
    required String phoneNumber,
    required String address,
    required String contractInfo,
  }) async {
    await _firebaseStorage.updateDocument(
      collectionPath: 'profiles',
      documentId: id,
      data: {
        'companyName': companyName,
        'firstName': firstName,
        'lastName': lastName,
        'tin': tin,
        'email': email,
        'phoneNumber': phoneNumber,
        'address': address,
        'contractInfo': contractInfo,
      },
    );
    return await getProfile(id: id);
  }

  Future<void> deleteProfile({required String id}) async {
    await _firebaseStorage.deleteDocument(
      collectionPath: 'profiles',
      documentId: id,
    );
  }

  Future<CloudRent> createRent({
    required String creatorId,
    required String profileId,
    required String propertyId,
    required double rentAmount,
    required String contract,
    required String dueDate,
    required String endContract,
    required String paymentStatus,
  }) async {
    final docRef = await _firebaseStorage.addDocument(
      collectionPath: 'rents',
      data: {
        'creatorId': creatorId,
        'profileId': profileId,
        'propertyId': propertyId,
        'rentAmount': rentAmount,
        'contract': contract,
        'dueDate': dueDate,
        'endContract': endContract,
        'paymentStatus': paymentStatus,
      },
    );

    return CloudRent(
      id: docRef.id,
      creatorId: creatorId,
      profileId: profileId,
      propertyId: propertyId,
      rentAmount: rentAmount,
      contract: contract,
      dueDate: dueDate,
      endContract: endContract,
      paymentStatus: paymentStatus,
    );
  }

  Future<CloudRent> getRent({required String id}) async {
    final docSnapshot = await _firebaseStorage.getDocument(
      collectionPath: 'rents',
      documentId: id,
    );
    if (!docSnapshot.exists) throw CouldNotFindRentException();
    return CloudRent.fromFirestore(docSnapshot);
  }

  Future<void> endRentContract({required String id}) async {
    await _firebaseStorage.updateDocument(
      collectionPath: 'rents',
      documentId: id,
      data: {
        'endContract': 'Contract_Ended',
      },
    );
  }

  Future<CloudRent> updateRent({
    required String id,
    required double rentAmount,
    required String contract,
    required String dueDate,
    required String endContract,
    required String paymentStatus,
  }) async {
    await _firebaseStorage.updateDocument(
      collectionPath: 'rents',
      documentId: id,
      data: {
        'rentAmount': rentAmount,
        'contract': contract,
        'dueDate': dueDate,
        'endContract': endContract,
        'paymentStatus': paymentStatus,
      },
    );
    return await getRent(id: id);
  }

  Stream<Iterable<CloudRent>> allRents({required String creatorId}) {
    return rents
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CloudRent.fromFirestore(doc));
    });
  }

  Future<void> deleteRent({required String id}) async {
    await _firebaseStorage.deleteDocument(
      collectionPath: 'rents',
      documentId: id,
    );
  }

  Future<CloudExpenses> createExpense({
    required String creatorId,
    required String propertyId,
    required String rentId,
    required String profileId,
    required String expenceType,
    required String amount,
    required String discription,
    required String date,
  }) async {
    final docRef = await _firebaseStorage.addDocument(
      collectionPath: 'expenses',
      data: {
        'creatorId': creatorId,
        'propertyId': propertyId,
        'rentId': rentId,
        'profileId': profileId,
        'expenceType': expenceType,
        'amount': amount,
        'discription': discription,
        'date': date,
      },
    );

    return CloudExpenses(
      id: docRef.id,
      creatorId: creatorId,
      propertyId: propertyId,
      rentId: rentId,
      profileId: profileId,
      expenceType: expenceType,
      amount: amount,
      discription: discription,
      date: date,
    );
  }

  Future<CloudExpenses> getExpense({required String id}) async {
    final docSnapshot = await _firebaseStorage.getDocument(
      collectionPath: 'expenses',
      documentId: id,
    );
    if (!docSnapshot.exists) throw CouldNotFindExpenseException();
    return CloudExpenses.fromFirestore(docSnapshot);
  }

  Stream<Iterable<CloudExpenses>> getExpensesByRentIdStream(
      {required String rentId}) {
    return expenses
        .where('rentId', isEqualTo: rentId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CloudExpenses.fromFirestore(doc));
    });
  }

  Future<CloudExpenses> updateExpense({
    required String id,
    required String expenceType,
    required String amount,
    required String discription,
    required String date,
  }) async {
    await _firebaseStorage.updateDocument(
      collectionPath: 'expenses',
      documentId: id,
      data: {
        'expenceType': expenceType,
        'amount': amount,
        'discription': discription,
        'date': date,
      },
    );
    return await getExpense(id: id);
  }

  Future<void> deleteExpense({required String id}) async {
    await _firebaseStorage.deleteDocument(
      collectionPath: 'expenses',
      documentId: id,
    );
  }

  Stream<Iterable<CloudExpenses>> allExpenses({required String creatorId}) {
    return expenses
        .where('creatorId', isEqualTo: creatorId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => CloudExpenses.fromFirestore(doc));
    });
  }

  Future<List<CloudExpenses>> getExpensesByRentId(
      {required String rentId}) async {
    final querySnapshot =
        await expenses.where('rentId', isEqualTo: rentId).get();
    return querySnapshot.docs
        .map((doc) => CloudExpenses.fromFirestore(doc))
        .toList();
  }
}
