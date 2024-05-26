// //rent_service.dart
// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:r_and_e_monitor/services/helper/db_exceptions.dart';
// import 'package:r_and_e_monitor/services/helper/db_helper.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart';

// import '../../../property_mangement/CRUD/crud_exception.dart';

// class RentService {
//   Database? _db;
//   final List<DatabaseProfile> _profiles = [];
//   final List<DatabaseRent> _rents = [];

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

//   Future<void> ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyExistException {}
//   }

//   Future<void> close() async {
//     final db = _db;
//     try {
//       if (db != null) await db.close();
//     } catch (e) {
//       throw DatabaseCloseException('Error closing database: $e');
//     }
//   }

//   Future<DatabaseProfile> createProfile({
//     final String? companyName,
//     final String? firstName,
//     final String? lastName,
//     final int? tin,
//     required int phoneNumber,
//     required String email,
//     required String contractInfo,
//   }) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final profileId = await db.insert(profileTable, {
//         companyNameColumn: companyName,
//         firstNameColumn: firstName,
//         lastNameColumn: lastName,
//         phoneNumberColumn: phoneNumber,
//         contractInfoColumn: contractInfo,
//         emailColumn: email,
//         tinColumn: tin,
//       });

//       final profile = DatabaseProfile(
//         profileId: profileId,
//         companyName: companyName,
//         firstName: firstName,
//         lastName: lastName,
//         phoneNumber: phoneNumber,
//         contractInfo: contractInfo,
//         email: email,
//         tin: tin,
//       );

//       _profiles.add(profile);
//       //_propertyStreamController.add(_properties);
//       return profile;
//     } catch (e) {
//       throw DatabaseInsertException('Error inserting property: $e');
//     }
//   }

//   Future<DatabaseProfile> getProfile({required int profileId}) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     final profiles = await db.query(
//       profileTable,
//       limit: 1,
//       where: 'profile_id = ?',
//       whereArgs: [profileId],
//     );

//     if (profiles.isEmpty) {
//       throw Exception('ID $profileId not found');
//     } else {
//       final profile = DatabaseProfile.fromRow(profiles.first);
//       _profiles.removeWhere((profile) => profile.profileId == profileId);
//       _profiles.add(profile);
//       //_propertyStreamController.add(_properties);

//       return profile;
//     }
//   }

//   Future<Iterable<DatabaseProfile>> readAllProfiles() async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final profiles = await db.query(profileTable);

//       return profiles.map((profileRow) => DatabaseProfile.fromRow(profileRow));
//     } catch (e) {
//       throw DatabaseQueryException('Error getting profiles: $e');
//     }
//   }

//   Future<DatabaseProfile> updateProfile({
//     required DatabaseProfile profile,
//     final String? companyName,
//     String? firstName,
//     String? lastName,
//     int? tin,
//     required int phoneNumber,
//     required String email,
//     required String contractInfo,
//   }) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       await getProfile(profileId: profile.profileId);
//       final updatedCount = await db.update(
//         profileTable,
//         {
//           companyNameColumn: companyName,
//           firstNameColumn: firstName,
//           lastNameColumn: lastName,
//           phoneNumberColumn: phoneNumber,
//           contractInfoColumn: contractInfo,
//           emailColumn: email,
//           tinColumn: tin,
//         },
//         where: 'profile_id=?',
//         whereArgs: [profile.profileId],
//       );
//       if (updatedCount == 0) {
//         throw CouldNotUpdateProperty();
//       } else {
//         final updatedProfile = await getProfile(profileId: profile.profileId);
//         _profiles.removeWhere(
//             (profile) => profile.profileId == updatedProfile.profileId);

//         // Add the updated property to the list
//         _profiles.add(updatedProfile);
//         // _propertyStreamController.add(_properties);
//         return updatedProfile;
//       }
//     } catch (e) {
//       throw DatabaseUpdateException('Error updating property: $e');
//     }
//   }

//   Future<void> deleteProfile({required int profileId}) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final deletedCounted = await db.delete(
//         profileTable,
//         where: 'profile_id = ?',
//         whereArgs: [profileId],
//       );
//       if (deletedCounted == 0) {
//         throw CouldNotDeleteProperty();
//       } else {
//         _profiles.removeWhere((profile) => profile.profileId == profileId);
//         // _propertyStreamController.add(_properties);
//       }
//     } catch (e) {
//       throw DatabaseDeleteException('Error deleting profile: $e');
//     }
//   }

//   Future<DatabaseRent> createRent({
//     required int profileId,
//     required int pId,
//     required String contract,
//     required double rentAmount,
//     required String dueDate,
//     required String endContract,
//     required String paymentStatus,
//   }) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final rentId = await db.insert(rentTable, {
//         profileIdColumn: profileId,
//         pIdColumn: pId,
//         contractColumn: contract,
//         rentAmountColumn: rentAmount,
//         dueDateColumn: dueDate,
//         endContractColumn: endContract,
//         paymentStatusColumn: paymentStatus,
//       });

//       final rent = DatabaseRent(
//         rentId: rentId,
//         profileId: profileId,
//         id: pId,
//         contract: contract,
//         rentAmount: rentAmount,
//         dueDate: dueDate,
//         endContract: endContract,
//         paymentStatus: paymentStatus,
//       );

//       _rents.add(rent);
//       return rent;
//     } catch (e) {
//       throw DatabaseInsertException('Error inserting rent: $e');
//     }
//   }

//   Future<List<DatabaseRent>> readAllRents() async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final rents = await db.query(rentTable);
//       return rents.map((rentRow) => DatabaseRent.fromRow(rentRow)).toList();
//     } catch (e) {
//       throw DatabaseQueryException('Error getting rents: $e');
//     }
//   }

//   Future<DatabaseRent> getRent({required int rentId}) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     final rents = await db.query(
//       rentTable,
//       limit: 1,
//       where: 'rent_Id = ?',
//       whereArgs: [rentId],
//     );

//     if (rents.isEmpty) {
//       throw Exception('Rent ID $rentId not found');
//     } else {
//       return DatabaseRent.fromRow(rents.first);
//     }
//   }

//   Future<DatabaseRent> updateRent({
//     required int rentId,
//     required int profileId,
//     required int pId,
//     required String contract,
//     required double rentAmount,
//     required String dueDate,
//     required String endContarct,
//     required String paymentStatus,
//   }) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final updatedCount = await db.update(
//         rentTable,
//         {
//           profileIdColumn: profileId,
//           pIdColumn: pId,
//           contractColumn: contract,
//           rentAmountColumn: rentAmount,
//           dueDateColumn: dueDate,
//           endContractColumn: endContarct,
//           paymentStatusColumn: paymentStatus,
//         },
//         where: 'rent_Id = ?',
//         whereArgs: [rentId],
//       );
//       if (updatedCount == 0) {
//         throw CouldNotUpdateProperty();
//       } else {
//         final updatedRent = await getRent(rentId: rentId);
//         return updatedRent;
//       }
//     } catch (e) {
//       throw DatabaseUpdateException('Error updating rent: $e');
//     }
//   }

//   Future<void> deleteRent({required int rentId}) async {
//     await ensureDbIsOpen();
//     final db = getDatabaseOrThrow();
//     try {
//       final deletedCount = await db.delete(
//         rentTable,
//         where: 'rent_Id = ?',
//         whereArgs: [rentId],
//       );
//       if (deletedCount == 0) {
//         throw CouldNotDeleteProperty();
//       }
//     } catch (e) {
//       throw DatabaseDeleteException('Error deleting rent: $e');
//     }
//   }
// }

// class DatabaseProfile {
//   final int profileId;
//   final String? companyName;
//   final String? firstName;
//   final String? lastName;
//   final int? tin;
//   final int phoneNumber;
//   final String email;
//   final String contractInfo;

//   DatabaseProfile({
//     required this.profileId,
//     this.companyName,
//     this.firstName,
//     this.lastName,
//     this.tin,
//     required this.phoneNumber,
//     required this.email,
//     required this.contractInfo,
//   });

//   DatabaseProfile.fromRow(Map<String, Object?> map)
//       : profileId = map[profileIdColumn] as int,
//         companyName = map[companyNameColumn] as String?,
//         firstName = map[firstNameColumn] as String?,
//         lastName = map[lastNameColumn] as String?,
//         tin = map[tinColumn] as int?,
//         phoneNumber = map[phoneNumberColumn] as int,
//         email = map[emailColumn] as String,
//         contractInfo = map[contractInfoColumn] as String;

//   @override
//   String toString() =>
//       'Profile, profile_id= $profileId, Company Name= $companyName, First Name= $firstName, Last Name= $lastName, Phone Number= $phoneNumber, Contract Info= $contractInfo, Email= $email';

//   @override
//   bool operator ==(covariant DatabaseProfile other) =>
//       profileId == other.profileId;

//   @override
//   int get hashCode => profileId.hashCode;
// }

// class DatabaseRent {
//   final int rentId;
//   final int profileId;
//   final int id;
//   final String contract;
//   final double rentAmount;
//   final String dueDate;
//   final String endContract;
//   final String paymentStatus;

//   DatabaseRent({
//     required this.rentId,
//     required this.profileId,
//     required this.id,
//     required this.contract,
//     required this.rentAmount,
//     required this.dueDate,
//     required this.endContract,
//     required this.paymentStatus,
//   });

//   DatabaseRent.fromRow(Map<String, Object?> map)
//       : rentId = map[rentIdColumn] as int,
//         profileId = map[profileIdColumn] as int,
//         id = map[pIdColumn] as int,
//         contract = map[contractColumn] as String? ?? '', // Handle null
//         rentAmount = map[rentAmountColumn] as double? ?? 0.0, // Handle null
//         dueDate = map[dueDateColumn] as String? ?? '', // Handle null
//         endContract = map[endContractColumn] as String? ?? '', // Handle null
//         paymentStatus =
//             map[paymentStatusColumn] as String? ?? ''; // Handle null

//   @override
//   String toString() =>
//       'Rent, rent_Id= $rentId, profile_id= $profileId, id= $id, contract= $contract, rent_amount= $rentAmount, due_date= $dueDate, end_contract= $endContract,  payment_status= $paymentStatus';

//   @override
//   bool operator ==(covariant DatabaseRent other) => rentId == other.rentId;

//   @override
//   int get hashCode => rentId.hashCode;
// }
