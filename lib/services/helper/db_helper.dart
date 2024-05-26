// const dbName = 'Bmonitor.db';
// const propertyTable = 'property';
// const profileTable = 'profile';
// const userTable = 'user';
// const rentTable = 'rent';
// const idColumn = 'id';
// const emailColumn = 'email';
// // const roleColumn = 'role';
// const pIdColumn = 'p_id';
// const creatorIdColumn = 'c_id';
// const propertyTypeColumn = 'property_type';
// const floorNumberColumn = 'floor_number';
// const propertyNumberColumn = 'property_number';
// const sizeInSquareMetersColumn = 'size_in_square_meters';
// const pricePerMonthColumn = 'price_per_month';
// const descriptionColumn = 'description';
// const isRentedColumn = 'is_rented';

// //rent mangement

// const profileIdColumn = 'profile_id';
// //const propertyIdColumn = 'property_id';
// //const emailColumn = 'profile_id';
// const companyNameColumn = 'companyName';
// const firstNameColumn = 'firstName';
// const lastNameColumn = 'lastName';
// const phoneNumberColumn = 'phoneNumber';
// const tinColumn = 'tin';
// const contractInfoColumn = 'contractInfo';
// const contractColumn = 'contract';
// const endContractColumn = 'end_contract';
// const rentAmountColumn = 'rent_amount';
// const dueDateColumn = 'due_date';
// const paymentStatusColumn = 'payment_status';
// const rentIdColumn = 'rent_id';

// const createUserTable = '''CREATE TABLE IF NOT EXISTS "user" (
//   "id" INTEGER PRIMARY KEY AUTOINCREMENT,
//   "email" TEXT NOT NULL UNIQUE
  
  
  
// );''';

// const createPropertyTable = '''CREATE TABLE IF NOT EXISTS "property" (
//   "p_id" INTEGER PRIMARY KEY AUTOINCREMENT,
//   "c_id" INTEGER NOT NULL,
//   "property_type" TEXT NOT NULL,
//   "floor_number" INTEGER NOT NULL,
//   "property_number" TEXT,
//   "size_in_square_meters" REAL NOT NULL,
//   "price_per_month" REAL NOT NULL,
//   "description" TEXT,
//   "is_rented" INTEGER NOT NULL,
//   FOREIGN KEY("c_id") REFERENCES "user"("id")
// );''';

// const createProfileTable = '''CREATE TABLE IF NOT EXISTS "profile" (
//     "profile_id"	INTEGER NOT NULL,
     
//     "companyName"	TEXT,
//     "firstName"	TEXT,
//     "lastName"	TEXT,
//     "tin"	INTEGER,
//     "phoneNumber"	INTEGER NOT NULL,
//     "email"	TEXT NOT NULL,
//     "contractInfo"	TEXT,
    
//     PRIMARY KEY("profile_id" AUTOINCREMENT)
//   );''';

// const createRentTable = '''CREATE TABLE IF NOT EXISTS "rent" (
//   "rent_id" INTEGER PRIMARY KEY AUTOINCREMENT,
//   "profile_id" INTEGER NOT NULL,
//   "p_id" INTEGER NOT NULL,
//   "contract" TEXT NOT NULL,
//   "rent_amount" REAL NOT NULL,
//   "due_date" TEXT NOT NULL,
//   "end_contract" TEXT NOT NULL,
//   "payment_status" String NOT NULL,
  
//   FOREIGN KEY("profile_id") REFERENCES "profile"("profile_id"),
//   FOREIGN KEY("p_id") REFERENCES "property"("p_id")
// );''';

// //"rent_status" INTEGER NOT NULL,