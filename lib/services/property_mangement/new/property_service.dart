// //property_service.dart
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:r_and_e_monitor/extensions/list/filter.dart';
// import 'package:r_and_e_monitor/services/helper/db_exceptions.dart';
// import 'package:r_and_e_monitor/services/helper/db_helper.dart';
// import 'package:r_and_e_monitor/services/property_mangement/CRUD/crud_exception.dart';
// import 'package:sqflite/sqflite.dart';

// class PropertyService {
//   Database? _db;
//   List<DatabaseProperty> _properties = [];

//   DatabaseUser? _user;

//   static final PropertyService _shared = PropertyService._sharedInstance();
//   PropertyService._sharedInstance() {
//     _propertyStreamController =
//         StreamController<List<DatabaseProperty>>.broadcast(
//       onListen: () {
//         _propertyStreamController.sink.add(_properties);
//       },
//     );
//   }

//   factory PropertyService() => _shared;

//   late final StreamController<List<DatabaseProperty>> _propertyStreamController;
//   Stream<List<DatabaseProperty>> get propertyStream =>
//       _propertyStreamController.stream.filter((property) {
//         final currentUser = _user;
//         if (currentUser != null) {
//           return property.creatorId == currentUser.id;
//         } else {
//           throw UserShouldBeSetBeforeReadingAllNotes();
//         }
//       });

//   Future<void> open() async {
//     try {
//       if (_db != null) return;
//       final docsPath = await getApplicationDocumentsDirectory();
//       final dbPath = join(docsPath.path, 'Bmonitor.db');
//       final db = await openDatabase(dbPath);
//       _db = db;
//       await db.execute(createUserTable);
//       await db.execute(createPropertyTable);
//       await db.execute(createProfileTable);
//       await db.execute(createRentTable);
//       await _catchProperty();
//     } catch (e) {
//       throw DatabaseOpenException('Error opening database: $e');
//     }
//   }

//   Database getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     try {
//       if (db != null) await db.close();
//     } catch (e) {
//       throw DatabaseCloseException('Error closing database: $e');
//     }
//   }

//   Future<void> _catchProperty() async {
//     try {
//       final propertyStream = await getAllProperties();
//       _properties = propertyStream.toList();
//       _propertyStreamController.add(_properties);
//     } catch (e) {
//       // Handle error
//       print('Error updating property list: $e');
//     }
//   }

//   Future<void> ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyExistException {}
//   }

//   Future<DatabaseUser> getOrCreateUser({
//     required String email,
//     // String? role,
//     // int? creatorId,
//     bool setAsCurrentUser = true,
//   }) async {
//     // await _ensureDbIsOpen();
//     try {
//       final user = await getUser(email: email);
//       if (setAsCurrentUser) {
//         _user = user;
//       }
//       return user;
//     } on UserNotFoundException {
//       final createdUser = await createUser(
//         email: email,
//       ); // role: role, creatorId: creatorId);
//       if (setAsCurrentUser) {
//         _user = createdUser;
//       }
//       return createdUser;
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<DatabaseUser> createUser({
//     required String email,
//     // String? role,
//     // int? creatorId,
//   }) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final results = await db.query(
//         userTable,
//         limit: 1,
//         where: 'email = ?',
//         whereArgs: [email.toLowerCase()],
//       );
//       if (results.isNotEmpty) {
//         final dbPropertyUser = await getUser(email: email);
//         return dbPropertyUser;
//         // throw UserAlreadyExists();
//       }

//       final id = await db.insert(
//         userTable,
//         {
//           'email': email.toLowerCase(),
//           // 'role': '',
//           // 'creator_user_id': creatorId
//         },
//       );
//       return DatabaseUser(
//         id: id,
//         email: email,
//         // role: role,
//         // creatorUserId: creatorId,
//       );
//     } catch (e) {
//       throw DatabaseInsertException('Error creating user: $e');
//     }
//   }

//   // @override
//   // Future<DatabaseUser> getUserById({required int userId}) async {
//   //   await _ensureDbIsOpen();
//   //   final db = _getDatabaseOrThrow();
//   //   try {
//   //     final results = await db.query(
//   //       userTable,
//   //       limit: 1,
//   //       where: 'id = ?',
//   //       whereArgs: [userId],
//   //     );
//   //     if (results.isEmpty) {
//   //       throw DatabaseQueryException('User not found');
//   //     } else {
//   //       return DatabaseUser.fromRow(results.first);
//   //     }
//   //   } catch (e) {
//   //     throw DatabaseQueryException('Error getting user: $e');
//   //   }
//   // }

//   Future<DatabaseUser> getUser({required String email}) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     final results = await db.query(
//       userTable,
//       limit: 1,
//       where: 'email = ?',
//       whereArgs: [email.toLowerCase()],
//     );

//     if (results.isEmpty) {
//       throw CouldNotFindUser();
//     } else {
//       return DatabaseUser.fromRow(results.first);
//     }
//   }

//   Future<void> deleteUser({required String email}) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'email=?',
//       whereArgs: [email.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//   Future<DatabaseProperty> createProperty({
//     required DatabaseUser creator,
//     required String propertyType,
//     required int floorNumber,
//     required String propertyNumber,
//     required double sizeInSquareMeters,
//     required double pricePerMonth,
//     required String description,
//     required bool isRented,
//   }) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final dbPropertyUser = await getUser(email: creator.email);
//       print(dbPropertyUser);
//       if (dbPropertyUser != creator) {
//         throw UserNotFoundException();
//       }

//       final propertyId = await db.insert(propertyTable, {
//         creatorIdColumn: creator.id,
//         propertyTypeColumn: propertyType,
//         floorNumberColumn: floorNumber,
//         propertyNumberColumn: propertyNumber,
//         sizeInSquareMetersColumn: sizeInSquareMeters,
//         pricePerMonthColumn: pricePerMonth,
//         descriptionColumn: description,
//         isRentedColumn: isRented == true ? 1 : 0,
//       });

//       final property = DatabaseProperty(
//         id: propertyId,
//         creatorId: creator.id,
//         propertyType: propertyType,
//         floorNumber: floorNumber,
//         propertyNumber: propertyNumber,
//         sizeInSquareMeters: sizeInSquareMeters,
//         pricePerMonth: pricePerMonth,
//         description: description,
//         isRented: isRented,
//       );

//       _properties.add(property);
//       _propertyStreamController.add(_properties);
//       return property;
//     } catch (e) {
//       throw DatabaseInsertException('Error inserting property: $e');
//     }
//   }

//   Future<Iterable<DatabaseProperty>> getAllProperties() async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final properties = await db.query(propertyTable);

//       return properties
//           .map((propertyRow) => DatabaseProperty.fromRow(propertyRow));
//     } catch (e) {
//       throw DatabaseQueryException('Error getting properties: $e');
//     }
//   }

//   Future<DatabaseProperty> getProperty({required int id}) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     final properties = await db.query(
//       propertyTable,
//       limit: 1,
//       where: 'p_id = ?',
//       whereArgs: [id],
//     );
//     if (properties.isEmpty) {
//       throw CouldNotFindProperty();
//     } else {
//       final property = DatabaseProperty.fromRow(properties.first);
//       _properties.removeWhere((property) => property.id == id);
//       _properties.add(property);
//       _propertyStreamController.add(_properties);

//       return property;
//     }
//   }

//   Future<DatabaseProperty> updateProperty({
//     required DatabaseProperty property,
//     required String propertyType,
//     required int floorNumber,
//     required String propertyNumber,
//     required double sizeInSquareMeters,
//     required double pricePerMonth,
//     required String description,
//     required bool isRented,
//   }) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       // Remove the old property from the list

//       await getProperty(id: property.id);
//       final updatedCount = await db.update(
//         propertyTable,
//         {
//           propertyTypeColumn: propertyType,
//           floorNumberColumn: floorNumber,
//           propertyNumberColumn: propertyNumber,
//           sizeInSquareMetersColumn: sizeInSquareMeters,
//           pricePerMonthColumn: pricePerMonth,
//           descriptionColumn: description,
//           isRentedColumn: isRented,
//         },
//         where: 'p_id=?',
//         whereArgs: [property.id],
//       );
//       if (updatedCount == 0) {
//         throw CouldNotUpdateProperty();
//       } else {
//         final updatedProperty = await getProperty(id: property.id);
//         _properties
//             .removeWhere((property) => property.id == updatedProperty.id);

//         // Add the updated property to the list
//         _properties.add(updatedProperty);
//         _propertyStreamController.add(_properties);
//         return updatedProperty;
//       }
//     } catch (e) {
//       throw DatabaseUpdateException('Error updating property: $e');
//     }
//   }

//   Future<void> deleteProperty({required int id}) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final deletedCounted = await db.delete(
//         propertyTable,
//         where: 'p_id = ?',
//         whereArgs: [id],
//       );
//       if (deletedCounted == 0) {
//         throw CouldNotDeleteProperty();
//       } else {
//         _properties.removeWhere((property) => property.id == id);
//         _propertyStreamController.add(_properties);
//       }
//     } catch (e) {
//       throw DatabaseDeleteException('Error deleting property: $e');
//     }
//   }
// }

// @immutable
// class DatabaseUser {
//   final int id;
//   final String email;
//   // final String role = '';
//   // final int creatorUserId = null;

//   const DatabaseUser({
//     required this.id,
//     required this.email,

//     // required this.creatorUserId,
//   });

//   DatabaseUser.fromRow(Map<String, Object?> map)
//       : id = map[idColumn] as int,
//         email = map[emailColumn] as String;
//   // role = map[roleColumn] as String,
//   // creatorUserId = map[creatorIdColumn] as int;

//   @override
//   String toString() =>
//       'person, ID=$id, email=$email,'; //role=$role,creator_user_id=$creatorUserId';
//   @override
//   bool operator ==(covariant DatabaseUser other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }

// class DatabaseProperty {
//   final int id;
//   final int creatorId;
//   final String propertyType;
//   final int floorNumber;
//   final String propertyNumber;
//   final double sizeInSquareMeters;
//   final double pricePerMonth;
//   final String description;
//   final bool isRented;

//   const DatabaseProperty({
//     required this.id,
//     required this.creatorId,
//     required this.propertyType,
//     required this.floorNumber,
//     required this.propertyNumber,
//     required this.sizeInSquareMeters,
//     required this.pricePerMonth,
//     this.description = '',
//     this.isRented = false,
//   });

//   DatabaseProperty.fromRow(Map<String, Object?> map)
//       : id = map[pIdColumn] as int,
//         creatorId = map[creatorIdColumn] as int,
//         propertyType = map[propertyTypeColumn] as String,
//         floorNumber = map[floorNumberColumn] as int,
//         propertyNumber = map[propertyNumberColumn] as String,
//         sizeInSquareMeters = map[sizeInSquareMetersColumn] as double,
//         pricePerMonth = map[pricePerMonthColumn] as double,
//         description = map[descriptionColumn] as String,
//         isRented = map[isRentedColumn] == 0 ? false : true;

//   @override
//   String toString() =>
//       'property, id=$id, creatorId=$creatorId, propertyType=$propertyType, floorNumber=$floorNumber, propertyNumber=$propertyNumber,isRented=$isRented';

//   @override
//   bool operator ==(covariant DatabaseProperty other) => id == other.id;

//   @override
//   int get hashCode => id.hashCode;
// }
