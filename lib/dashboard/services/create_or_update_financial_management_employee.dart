import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_storage_storage.dart';

class FinancialManagementService {
  final FirebaseCloudStorage _firebaseStorage = FirebaseCloudStorage.instance;

  final CollectionReference financialManagement =
      FirebaseFirestore.instance.collection('financialManagement');

  Future<CloudFinancialManagement> createOrUpdateFinancialReport({
    required String creatorId,
    required String companyId,
    required String txnType,
    required String description,
    required String totalAmount,
    required String txnDate,
  }) async {
    final querySnapshot = await financialManagement
        .where('creatorId', isEqualTo: creatorId)
        .where('companyId', isEqualTo: companyId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Update existing financial report
      final docRef = querySnapshot.docs.first.reference;
      await docRef.update({
        'transactionType': txnType,
        'description': description,
        'totalAmount': totalAmount,
        'transactionDate': txnDate,
      });

      return CloudFinancialManagement(
        id: docRef.id,
        creatorId: creatorId,
        companyId: companyId,
        txnType: txnType,
        discription: description,
        totalAmount: totalAmount,
        txnDate: txnDate,
      );
    } else {
      // Create new financial report
      final docRef = await _firebaseStorage.addDocument(
        collectionPath: 'financialManagement',
        data: {
          'creatorId': creatorId,
          'companyId': companyId,
          'transactionType': txnType,
          'description': description,
          'totalAmount': totalAmount,
          'transactionDate': txnDate,
        },
      );

      return CloudFinancialManagement(
        id: docRef.id,
        creatorId: creatorId,
        companyId: companyId,
        txnType: txnType,
        discription: description,
        totalAmount: totalAmount,
        txnDate: txnDate,
      );
    }
  }
}
