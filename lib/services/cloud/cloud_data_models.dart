import 'package:cloud_firestore/cloud_firestore.dart';

class CloudProfile {
  final String id;
  final String creatorId;
  final String companyName;
  final String firstName;
  final String lastName;
  final String tin;
  final String email;
  final String phoneNumber;
  final String address;
  final String contractInfo;

  const CloudProfile({
    required this.id,
    required this.creatorId,
    required this.companyName,
    required this.firstName,
    required this.lastName,
    required this.tin,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.contractInfo,
  });

  CloudProfile.fromFirestore(DocumentSnapshot doc)
      : id = doc.id,
        creatorId = doc['creatorId'],
        companyName = doc['companyName'],
        firstName = doc['firstName'],
        lastName = doc['lastName'],
        tin = doc['tin'],
        email = doc['email'],
        phoneNumber = doc['phoneNumber'],
        address = doc['address'],
        contractInfo = doc['contractInfo'];
}

class CloudRent {
  final String id;
  final String creatorId;
  final String profileId;
  final String propertyId;
  final double rentAmount;
  final String contract;
  final String dueDate;
  final String endContract;
  final String paymentStatus;

  const CloudRent({
    required this.id,
    required this.creatorId,
    required this.profileId,
    required this.propertyId,
    required this.rentAmount,
    required this.contract,
    required this.dueDate,
    required this.endContract,
    required this.paymentStatus,
  });

  CloudRent.fromFirestore(DocumentSnapshot doc)
      : id = doc.id,
        creatorId = doc['creatorId'],
        profileId = doc['profileId'],
        propertyId = doc['propertyId'],
        rentAmount = doc['rentAmount'],
        contract = doc['contract'],
        dueDate = doc['dueDate'],
        endContract = doc['endContract'],
        paymentStatus = doc['paymentStatus'];
}

class DatabaseProperty {
  final String id;
  final String creatorId;
  final String propertyType;
  final String floorNumber;
  final String propertyNumber;
  final String sizeInSquareMeters;
  final String pricePerMonth;
  final String description;
  final bool isRented;

  const DatabaseProperty({
    required this.id,
    required this.creatorId,
    required this.propertyType,
    required this.floorNumber,
    required this.propertyNumber,
    required this.sizeInSquareMeters,
    required this.pricePerMonth,
    required this.description,
    required this.isRented,
  });

  DatabaseProperty.fromSnapshot(DocumentSnapshot snapshot)
      : id = snapshot.id,
        creatorId = snapshot['creatorId'],
        propertyType = snapshot['propertyType'],
        floorNumber = snapshot['floorNumber'],
        propertyNumber = snapshot['propertyNumber'],
        sizeInSquareMeters = snapshot['sizeInSquareMeters'],
        pricePerMonth = snapshot['pricePerMonth'],
        description = snapshot['description'],
        isRented = snapshot['isRented'];
}

class CloudExpenses {
  final String id;
  final String creatorId;
  final String propertyId;
  final String rentId;
  final String profileId;
  final String expenceType;
  final String amount;
  final String discription;
  final String date;

  const CloudExpenses({
    required this.id,
    required this.creatorId,
    required this.propertyId,
    required this.rentId,
    required this.profileId,
    required this.expenceType,
    required this.amount,
    required this.discription,
    required this.date,
  });

  CloudExpenses.fromFirestore(DocumentSnapshot doc)
      : id = doc.id,
        creatorId = doc['creatorId'],
        rentId = doc['rentId'],
        propertyId = doc['propertyId'],
        profileId = doc['profileId'],
        expenceType = doc['expenceType'],
        amount = doc['amount'],
        discription = doc['discription'],
        date = doc['date'];
}

class CloudReports {
  final String reportId;
  final String rentId;
  final String reportTitle;
  final String reportContent;
  final String carbonCopy;
  final String reportDate;

  const CloudReports({
    required this.reportId,
    required this.rentId,
    required this.reportTitle,
    required this.reportContent,
    required this.carbonCopy,
    required this.reportDate,
  });

  CloudReports.fromFirestore(DocumentSnapshot doc)
      : reportId = doc.id,
        rentId = doc['rentId'],
        reportTitle = doc['report_title'],
        reportContent = doc['report_content'],
        carbonCopy = doc['carbonCopy'],
        reportDate = doc['report_date'];
}

class CloudCompany {
  final String id;
  final String creatorId;
  final String companyName;
  final String companyOwner;
  final String emailAddress;
  final String phone;
  final String address;

  const CloudCompany({
    required this.id,
    required this.creatorId,
    required this.companyName,
    required this.companyOwner,
    required this.emailAddress,
    required this.phone,
    required this.address,
  });

  CloudCompany.fromFirestore(DocumentSnapshot doc)
      : id = doc.id,
        creatorId = doc['creatorId'],
        companyName = doc['companyName'],
        companyOwner = doc['companyOwner'],
        emailAddress = doc['emailAddress'],
        phone = doc['phone'],
        address = doc['address'];
}
