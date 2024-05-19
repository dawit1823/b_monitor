class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}

class DatabaseOpenException extends DatabaseException {
  DatabaseOpenException(String message) : super(message);
}

class DatabaseCloseException extends DatabaseException {
  DatabaseCloseException(String message) : super(message);
}

class DatabaseInsertException extends DatabaseException {
  DatabaseInsertException(String message) : super(message);
}

class DatabaseQueryException extends DatabaseException {
  DatabaseQueryException(String message) : super(message);
}

class DatabaseUpdateException extends DatabaseException {
  DatabaseUpdateException(String message) : super(message);
}

class DatabaseDeleteException extends DatabaseException {
  DatabaseDeleteException(String message) : super(message);
}
