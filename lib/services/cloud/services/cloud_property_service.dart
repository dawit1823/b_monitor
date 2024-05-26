import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:r_and_e_monitor/services/cloud/cloud_data_models.dart';

class PropertyService {
  final CollectionReference properties =
      FirebaseFirestore.instance.collection('properties');

  Future<DatabaseProperty> createProperty({
    required String creator,
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
      'propertyType': propertyType,
      'floorNumber': floorNumber,
      'propertyNumber': propertyNumber,
      'sizeInSquareMeters': sizeInSquareMeters,
      'pricePerMonth': pricePerMonth,
      'description': description,
      'isRented': isRented,
    });

    return DatabaseProperty(
      id: docRef.id,
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

  Stream<Iterable<DatabaseProperty>> allProperties(
          {required String creatorId}) =>
      properties.snapshots().map((event) => event.docs
          .map((doc) => DatabaseProperty.fromSnapshot(doc))
          .where((property) => property.creatorId == creatorId));

  Future<DatabaseProperty> getProperty({required String id}) async {
    final doc = await properties.doc(id).get();
    if (!doc.exists) {
      throw Exception('Property not found');
    }
    return DatabaseProperty.fromSnapshot(doc);
  }

  Future<DatabaseProperty> updateProperty({
    required String id,
    required String propertyType,
    required int floorNumber,
    required String propertyNumber,
    required double sizeInSquareMeters,
    required double pricePerMonth,
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
