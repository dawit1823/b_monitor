import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

class PropertyService {
  final CollectionReference properties =
      FirebaseFirestore.instance.collection('properties');

  Future<CloudProperty> createProperty({
    required String creator,
    required String companyId,
    required String propertyType,
    required String floorNumber,
    required String propertyNumber,
    required String sizeInSquareMeters,
    required String pricePerMonth,
    required String description,
    required bool isRented,
  }) async {
    final docRef = await properties.add({
      'creatorId': creator,
      'companyId': companyId,
      'propertyType': propertyType,
      'floorNumber': floorNumber,
      'propertyNumber': propertyNumber,
      'sizeInSquareMeters': sizeInSquareMeters,
      'pricePerMonth': pricePerMonth,
      'description': description,
      'isRented': isRented,
    });

    return CloudProperty(
      id: docRef.id,
      companyId: companyId,
      creatorId: creator,
      propertyType: propertyType,
      floorNumber: floorNumber,
      propertyNumber: propertyNumber,
      sizeInSquareMeters: sizeInSquareMeters,
      pricePerMonth: pricePerMonth,
      description: description,
      isRented: isRented,
    );
  }

  Stream<Iterable<CloudProperty>> allProperties({required String creatorId}) =>
      properties.snapshots().map((event) => event.docs
          .map((doc) => CloudProperty.fromSnapshot(doc))
          .where((property) => property.creatorId == creatorId));

  Future<CloudProperty> getProperty({required String id}) async {
    final doc = await properties.doc(id).get();
    if (!doc.exists) {
      throw Exception('Property not found');
    }
    return CloudProperty.fromSnapshot(doc);
  }

  Future<CloudProperty> updateProperty({
    required String id,
    required String propertyType,
    required String floorNumber,
    required String propertyNumber,
    required String sizeInSquareMeters,
    required String pricePerMonth,
    required String description,
    required bool isRented,
  }) async {
    await properties.doc(id).update({
      'propertyType': propertyType,
      'floorNumber': floorNumber,
      'propertyNumber': propertyNumber,
      'sizeInSquareMeters': sizeInSquareMeters,
      'pricePerMonth': pricePerMonth,
      'description': description,
      'isRented': isRented,
    });
    return getProperty(id: id);
  }

  Future<void> deleteProperty({required String id}) async {
    await properties.doc(id).delete();
  }
}
