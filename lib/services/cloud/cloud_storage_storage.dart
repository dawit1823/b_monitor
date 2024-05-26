//firebase_cloud_storage.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseCloudStorage {
  FirebaseCloudStorage._privateConstructor();
  static final FirebaseCloudStorage _instance =
      FirebaseCloudStorage._privateConstructor();
  static FirebaseCloudStorage get instance => _instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference> addDocument({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    return await _firestore.collection(collectionPath).add(data);
  }

  Future<DocumentSnapshot> getDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    return await _firestore.collection(collectionPath).doc(documentId).get();
  }

  Future<void> updateDocument({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.collection(collectionPath).doc(documentId).update(data);
  }

  Future<void> deleteDocument({
    required String collectionPath,
    required String documentId,
  }) async {
    await _firestore.collection(collectionPath).doc(documentId).delete();
  }

  Stream<QuerySnapshot> getCollectionStream({required String collectionPath}) {
    return _firestore.collection(collectionPath).snapshots();
  }
}
