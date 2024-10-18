//cloud_storage_exceptions.dart
class CloudStorageException implements Exception {
  const CloudStorageException();
}

class CouldNotCreatePropertyException extends CloudStorageException {}

class CouldNotGetAllPropertyException extends CloudStorageException {}

class CouldNotUpdatePropertyException extends CloudStorageException {}

class CouldNotDeletePropertyException extends CloudStorageException {}

class CouldNotFindProfileException extends CloudStorageException {}

class CouldNotFindRentException extends CloudStorageException {}

class DatabaseAlreadyExistException implements Exception {}

class UnableToGetApplicationDocumentsDirectory implements Exception {}

class CouldNotDeleteUser implements Exception {}

class CouldNotDeleteProperty implements Exception {}

class UserAlreadyExists implements Exception {}

class UserNotFoundException implements Exception {}

class DatabaseIsNotOpen implements Exception {}

class CouldNotFindUser implements Exception {}

class CouldNotFindProperty implements Exception {}

class CouldNotUpdateProperty implements Exception {}

class UserNotLoggedInException implements Exception {}

class UserShouldBeSetBeforeReadingAllNotes implements Exception {}

class CouldNotFindExpenseException implements Exception {}

class CouldNotFindReportException implements Exception {}

class CouldNotFindCompanyException implements Exception {}

class CouldNotFindFinancialReportException implements Exception {}

class CouldNotFindEmployeeException implements Exception {}
