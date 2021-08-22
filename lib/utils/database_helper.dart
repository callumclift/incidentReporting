// import 'dart:async';
// import 'dart:io';
//
// import 'package:sqflite/sqflite.dart';
// import 'package:encrypt/encrypt.dart';
// import 'package:random_string/random_string.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
//
// import '../shared/global_config.dart';
//
// class DatabaseHelper {
//   //Singleton DatabaseHelper - only one instance throughout the app
//   static DatabaseHelper _databaseHelper;
//   //Singleton Database object
//   static Database _database;
//
//   //Incidents Table
//   static String incidentsTable = 'incident_table';
//   static String id = 'id';
//   static String incidentId = 'incident_id';
//   static String incidentUserId = 'user_id';
//   static String incidentType = 'type';
//   static String incidentFullName = 'fullname';
//   static String incidentUsername = 'username';
//   static String incidentEmail = 'email';
//   static String incidentDate = 'incident_date';
//   static String incidentCreated = 'created';
//   static String incidentLatitude = 'latitude';
//   static String incidentLongitude = 'longitude';
//   static String incidentPostCode = 'postcode';
//   static String incidentProjectName = 'project_name';
//   static String incidentRoute = 'route';
//   static String incidentElr = 'elr';
//   static String incidentMileage = 'mileage';
//   static String incidentSummary = 'summary';
//   static String incidentImages = 'images';
//   static String incidentOrganisationId = 'organisation_id';
//   static String incidentOrganisationName = 'organisation_name';
//   static String incidentCustomFields = 'custom_fields';
//   static String incidentAnonymous = 'anonymous';
//   static String incidentServerUploaded = 'server_uploaded';
//
//   //Temporary Incident Table
//   static String temporaryIncidentsTable = 'temporary_incidents_table';
//   static String temporaryUserId = 'user_id';
//   static String temporaryIncidentType = 'type';
//   static String temporaryFullName = 'fullname';
//   static String temporaryUsername = 'username';
//   static String temporaryEmail = 'email';
//   static String temporaryDate = 'incident_date';
//   static String temporaryLocationDropValue = 'location_drop';
//   static String temporaryLatitude = 'latitude';
//   static String temporaryLongitude = 'longitude';
//   static String temporaryPostCode = 'postcode';
//   static String temporaryLocationMap = 'location_map';
//   static String temporaryPostcodeMap = 'postcode_map';
//   static String temporaryProjectName = 'project_name';
//   static String temporaryRoute = 'route';
//   static String temporaryElr = 'elr';
//   static String temporaryMileageTip = 'mileage_tip';
//   static String temporaryMileage = 'mileage';
//   static String temporarySummary = 'summary';
//   static String temporaryImages = 'images';
//   static String temporaryOrganisationId = 'organisation_id';
//   static String temporaryOrganisationName = 'organisation_name';
//   static String temporaryCustomFields = 'custom_fields';
//   static String temporaryCustomFieldValue1 = 'custom_value1';
//   static String temporaryCustomFieldValue2 = 'custom_value2';
//   static String temporaryCustomFieldValue3 = 'custom_value3';
//   static String temporaryAnonymous = 'anonymous';
//
//   //Users Table
//   static String usersTable = 'users_table';
//   static String userId = 'user_id';
//   static String userFirstName = 'first_name';
//   static String userLastName = 'last_name';
//   static String userUsername = 'username';
//   static String userPassword = 'password';
//   static String userSuspended = 'suspended';
//   static String userOrganisationId = 'organisation_id';
//   static String userOrganisationName = 'organisation_name';
//   static String userSession = 'session';
//   static String userDeleted = 'deleted';
//   static String userIsClientAdmin = 'is_client_admin';
//   static String userIsSuperAdmin = 'is_super_admin';
//   static String userTermsAccepted = 'terms_accepted';
//   static String userForcePasswordReset = 'force_password_reset';
//   static String userDarkMode = 'dark_mode';
//
//   //Incident Type Table
//   static String incidentTypesTable = 'incident_type_table';
//   static String incidentTypeId = 'incident_type_id';
//   static String incidentTypeUserId = 'user_id';
//   static String incidentTypeUsername = 'username';
//   static String incidentTypeOrganisationId = 'organisation_id';
//   static String incidentTypeOrganisationName = 'organisation_name';
//   static String incidentTypeName = 'name';
//   static String incidentTypeCustomLabel1 = 'custom_label1';
//   static String incidentTypeCustomLabel2 = 'custom_label2';
//   static String incidentTypeCustomLabel3 = 'custom_label3';
//   static String incidentTypeCustomPlaceholder1 = 'custom_placeholder1';
//   static String incidentTypeCustomPlaceholder2 = 'custom_placeholder2';
//   static String incidentTypeCustomPlaceholder3 = 'custom_placeholder3';
//   static String incidentTypeServerUploaded = 'server_uploaded';
//
//   //Route Table
//   static String routesTable = 'routes_table';
//   static String routeName = 'route_name';
//   static String routeCode = 'route_code';
//
//   //ELRs Table
//   static String elrsTable = 'elrs_table';
//   static String regionCode = 'region_code';
//   static String elr = 'elr';
//   static String elrDescription = 'description';
//   static String elrStartMiles = 'start_miles';
//   static String elrEndMiles = 'end_miles';
//
//   //Image Path Table
//   static String imagePathTable = 'image_path_table';
//   static String imagePath = 'image_path';
//
//   //Cached Image Path Table
//   static String cachedImagePathTable = 'cached_path_table';
//   static String cachedImagePath = 'cached_path';
//
//   //Camera Table
//   static String cameraTable = 'camera_table';
//   static String customCamera = 'custom_camera';
//   static String showToast = 'show_toast';
//
//   static String createUsersTableSql = 'CREATE TABLE IF NOT EXISTS $usersTable ($userId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $userFirstName VARCHAR(255), $userLastName VARCHAR(255), '
//       '$userUsername VARCHAR(255), $userPassword VARCHAR(255), $userSuspended TINYINT(1), $userOrganisationId INT(11), $userOrganisationName VARCHAR(255), $userSession VARCHAR(255), '
//       '$userDeleted TINYINT(1), $userIsClientAdmin TINYINT(1), $userIsSuperAdmin TINYINT(1), $userTermsAccepted VARCHAR(255), $userForcePasswordReset TINYINT(1), $userDarkMode TINYINT(1))';
//
//   static String createIncidentsTableSql = 'CREATE TABLE IF NOT EXISTS $incidentsTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $incidentId INT(11) default NULL, $userId INT(11) default NULL, $incidentType VARCHAR(255), $incidentFullName VARCHAR(255) default NULL, '
//       '$incidentUsername VARCHAR(255) default NULL, $incidentEmail VARCHAR(255) default NULL, $incidentDate VARCHAR(255), $incidentCreated VARCHAR(255), $incidentLatitude VARCHAR(255) default NULL, $incidentLongitude VARCHAR(255) default NULL, '
//       '$incidentPostCode VARCHAR(255) default NULL, $incidentProjectName VARCHAR(255) default NULL, $incidentRoute VARCHAR(255) default NULL, $incidentElr VARCHAR(255) default NULL, $incidentMileage VARCHAR(255) default NULL, $incidentSummary TEXT, $incidentImages JSON default NULL, '
//       '$incidentOrganisationId INT(11), $incidentOrganisationName VARCHAR(255), $incidentCustomFields JSON default NULL, $incidentAnonymous TINYINT(1) default NULL, $incidentServerUploaded TINYINT(1) default NULL)';
//
//   static String createTemporaryIncidentsTableSql = 'CREATE TABLE IF NOT EXISTS $temporaryIncidentsTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $temporaryUserId INT(11), $temporaryIncidentType VARCHAR(255) default NULL, $temporaryFullName VARCHAR(255) default NULL, '
//       '$temporaryUsername VARCHAR(255) default NULL, $temporaryEmail VARCHAR(255) default NULL, $temporaryDate VARCHAR(255) default NULL, $temporaryLocationDropValue VARCHAR(255) default NULL, $temporaryLatitude VARCHAR(255) default NULL, $temporaryLongitude VARCHAR(255) default NULL, '
//       '$temporaryPostCode VARCHAR(255) default NULL, $temporaryPostcodeMap TEXT default NULL, $temporaryLocationMap TEXT default NULL, $temporaryProjectName VARCHAR(255) default NULL, $temporaryRoute VARCHAR(255) default NULL, $temporaryElr VARCHAR(255) default NULL, $temporaryMileage VARCHAR(255) default NULL, $temporaryMileageTip VARCHAR(255) default NULL, $temporarySummary TEXT default NULL, $temporaryImages JSON default NULL, '
//       '$temporaryOrganisationId INT(11), $temporaryOrganisationName VARCHAR(255), $temporaryCustomFields JSON default NULL, $temporaryCustomFieldValue1 VARCHAR(255) default NULL, $temporaryCustomFieldValue2 VARCHAR(255) default NULL, $temporaryCustomFieldValue3 VARCHAR(255) default NULL, $temporaryAnonymous TINYINT(1) default NULL)';
//
//   static String createIncidentTypesTableSql = 'CREATE TABLE IF NOT EXISTS $incidentTypesTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $incidentTypeId INT(11) default NULL, $incidentTypeUserId INT(11), $incidentTypeUsername VARCHAR(255), $incidentTypeName VARCHAR(255), $incidentTypeCustomLabel1 VARCHAR(255) default NULL, $incidentTypeCustomLabel2 VARCHAR(255) default NULL, '
//       '$incidentTypeCustomLabel3 VARCHAR(255) default NULL, $incidentTypeOrganisationId INT(11), $incidentTypeOrganisationName VARCHAR(255),'
//       '$incidentTypeCustomPlaceholder1 VARCHAR(255) default NULL, $incidentTypeCustomPlaceholder2 VARCHAR(255) default NULL, $incidentTypeCustomPlaceholder3 VARCHAR(255) default NULL, $incidentTypeServerUploaded TINYINT(1) default NULL)';
//
//   static String createRoutesTableSql = 'CREATE TABLE IF NOT EXISTS $routesTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $routeName VARCHAR(255) default NULL, $routeCode VARCHAR(20) default NULL)';
//
//   static String createElrsTableSql = 'CREATE TABLE IF NOT EXISTS $elrsTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $regionCode VARCHAR(20) default NULL, $elr VARCHAR(20) default NULL, $elrDescription VARCHAR(255) default NULL, $elrStartMiles VARCHAR(20) default NULL, $elrEndMiles VARCHAR(20) default NULL)';
//
//   static String createImagePathTableSql = 'CREATE TABLE IF NOT EXISTS $imagePathTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $imagePath VARCHAR(255) default NULL)';
//
//   static String createCachedImagePathTable = 'CREATE TABLE IF NOT EXISTS $cachedImagePathTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $cachedImagePath VARCHAR(255) default NULL)';
//
//   static String createCameraTableSql = 'CREATE TABLE IF NOT EXISTS $cameraTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $customCamera TINYINT(1) default 0 NOT NULL, $showToast TINYINT(1) default 0 NOT NULL)';
//
//   List<String> createAllTables = [createUsersTableSql, createIncidentsTableSql, createTemporaryIncidentsTableSql, createIncidentTypesTableSql, createRoutesTableSql, createElrsTableSql, createImagePathTableSql, createCachedImagePathTable, createCameraTableSql];
//
//
//
//
//
//   //Named constructor to create instance of DatabaseHelper
//   DatabaseHelper._createInstance();
//
//   //factory keyword allows the constructor to return some value
//   factory DatabaseHelper() {
//     //initialize our object as well and add a null check so we will create the instance of the database helper only if it is null, this statement will
//     //only be executed once in the application
//
//     if (_databaseHelper == null) {
//       _databaseHelper = DatabaseHelper._createInstance();
//     }
//     return _databaseHelper;
//   }
//
//   //getter for our database
//   Future<Database> get database async {
//     //if it is null initialize it otherwise return the older instance
//     if (_database == null) {
//       _database = await initializeDatabase();
//     }
//     return _database;
//   }
//
//   //function to initialise our database
//   Future<Database> initializeDatabase() async {
//     Directory directory = await getApplicationDocumentsDirectory();
//     String path = join(directory.path, 'incidentReporting.db');
//
//     //open/create the database at this given path
//     var incidentReportingDatabase =
//         await openDatabase(path, version: 1, onCreate: _createDb, onUpgrade: _onUpgrade);
//     return incidentReportingDatabase;
//   }
//
//   //create a function to help us to execute a statement to create our database
//   void _createDb(Database db, int newVersion) async {
//
//     for(String table in createAllTables){
//       db.execute(table);
//     }
//
//
//     await db.rawInsert("INSERT INTO $routesTable ($routeName, $routeCode) VALUES "
//         "('Anglia', 'QT'),"
//         "('Southeast', 'QK'),"
//         "('London North East', 'QG'),"
//         "('London North West (North)','QR'),"
//         "('London North West (South)','QS'),"
//         "('East Midlands', 'QM'),"
//         "('Scotland', 'QL'),"
//         "('Wales', 'QC'),"
//         "('Wessex', 'QW'),"
//         "('Western (West)', 'QD'),"
//         "('Western (Thames Valley)', 'QV')");
//
//     await db.insert(cameraTable, {'custom_camera' : 0, 'show_toast' : 0});
//
//   }
//
//   void _onUpgrade(Database db, int oldVersion, int newVersion) async {
//
//     for(String table in createAllTables){
//       db.execute(table);
//     }
//
//   }
//
//   //Get all incidents from the database
//   Future<List<Map<String, dynamic>>> getIncidentMapList() async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $incidentsTable order by $id ASC');
//     return result;
//   }
//
//   //Insert Operation: Insert an incident object to the database
//   Future<int> addIncident(Map<String, dynamic> incidentData) async {
//     Database db = await this.database;
//
//     var result = await db.insert(incidentsTable, incidentData);
//
//     return result;
//   }
//
//   Future<int> addTemporaryIncident(Map<String, dynamic> incidentData) async {
//     Database db = await this.database;
//
//     var result = await db.insert(temporaryIncidentsTable, incidentData);
//
//     return result;
//   }
//
//   Future<int> addImagePath(Map<String, dynamic> imagePathData) async {
//     Database db = await this.database;
//
//     var result = await db.insert(imagePathTable, imagePathData);
//
//     return result;
//   }
//
//   //Update Operation: update an incident object and save it to the database
//   Future<int> updateIncident(Map<String, dynamic> incidentData) async {
//     Database db = await this.database;
//
//     var result = await db.update(incidentsTable, incidentData,
//         where: '$id = ?', whereArgs: [incidentData['incidentId']]);
//     return result;
//   }
//
//   Future<int> updateTemporaryIncident(Map<String, dynamic> incidentData) async {
//     Database db = await this.database;
//
//     var result = await db.update(temporaryIncidentsTable, incidentData,
//         where: '$id = ?', whereArgs: [incidentData['incidentId']]);
//     return result;
//   }
//
//   Future<int> resetTemporaryIncident(int userId) async {
//     Database db = await this.database;
//
//     var result = await db.update(temporaryIncidentsTable, {
//       '$temporaryIncidentType': null,
//       '$temporaryAnonymous' : false,
//       '$temporaryDate' : null,
//       '$temporaryLocationDropValue' : null,
//       '$temporaryLatitude' : null,
//       '$temporaryLongitude' : null,
//       '$temporaryPostCode' : null,
//       '$temporaryLocationMap': null,
//       '$temporaryPostcodeMap': null,
//       '$temporaryProjectName' : null,
//       '$temporaryRoute' : null,
//       '$temporaryElr' : null,
//       '$temporaryMileage' : null,
//       '$temporarySummary' : null,
//       '$temporaryImages' : null,
//       '$temporaryCustomFields': null,
//       '$temporaryCustomFieldValue1': null,
//       '$temporaryCustomFieldValue2': null,
//       '$temporaryCustomFieldValue3': null,
//     },
//         where: '$temporaryUserId = ?', whereArgs: ['$userId']);
//     return result;
//   }
//
//   Future<int> updateTemporaryIncidentField(String field, var value, int userId) async {
//     Database db = await this.database;
//
//     var result = await db.update(temporaryIncidentsTable, {field : value},
//         where: '$temporaryUserId = ?', whereArgs: [userId]);
//     return result;
//   }
//
//   Future<int> deleteIncident(int id) async {
//     Database db = await this.database;
//
//     var result =
//         await db.delete('DELETE FROM $incidentsTable WHERE $id = $id');
//     return result;
//   }
//
//   Future<int> getIncidentCount() async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//         await db.rawQuery('SELECT COUNT (*) from $incidentsTable');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> getImagePathCount() async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//     await db.rawQuery('SELECT COUNT (*) from $imagePathTable');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   //Insert Operation: Insert an incident object to the database
//   Future<int> addUser(Map<String, dynamic> incidentData) async {
//     Database db = await this.database;
//
//     var result = await db.insert(usersTable, incidentData);
//
//     return result;
//   }
//
//   Future<int> updateUser(Map<String, dynamic> userData) async {
//     Database db = await this.database;
//
//     var result = await db.update(usersTable, userData,
//         where: '$userId = ?', whereArgs: [userData['user_id']]);
//     return result;
//   }
//
//   //Insert Operation: Insert an incident object to the database
//   Future<int> addIncidentType(Map<String, dynamic> incidentTypeData) async {
//     Database db = await this.database;
//
//     var result = await db.insert(incidentTypesTable, incidentTypeData);
//
//     return result;
//   }
//
//   Future<int> updateIncidentType(Map<String, dynamic> incidentTypeData) async {
//     Database db = await this.database;
//
//     var result = await db.update(incidentTypesTable, incidentTypeData);
//
//     return result;
//   }
//
//   Future<int> addElr(Map<String, dynamic> elrData) async {
//     Database db = await this.database;
//
//     var result = await db.insert(elrsTable, elrData);
//     //db.close();
//
//     return result;
//   }
//
//   Future<int> updateElr(Map<String, dynamic> elrData, String inputElr, String inputRegion) async {
//     Database db = await this.database;
//
//     var result = await db.update(elrsTable, elrData, where: '$elr = ? AND $regionCode = ?', whereArgs: [inputElr, inputRegion]);
//
//     return result;
//   }
//
//   Future<int> updateUserDarkMode(int usersId, bool darkMode) async {
//     Database db = await this.database;
//
//     var result = await db.update(usersTable, {userDarkMode : darkMode},
//         where: '$userId = ?', whereArgs: [usersId]);
//     return result;
//   }
//
//   Future<int> updateIncidentId(int localId, int updatedIncidentId) async {
//     Database db = await this.database;
//
//     var result = await db.update(incidentsTable, {incidentId : updatedIncidentId},
//         where: '$id = ?', whereArgs: [localId]);
//     return result;
//   }
//
//   Future<int> updateServerUploaded(int localId, bool serverUploaded) async {
//     Database db = await this.database;
//
//     var result = await db.update(incidentsTable, {incidentServerUploaded : serverUploaded},
//         where: '$id = ?', whereArgs: [localId]);
//     return result;
//   }
//
//   Future<int> updateLocalIncidentImages(int serverId, var images) async {
//     Database db = await this.database;
//
//     var result = await db.update(incidentsTable, {incidentImages : images},
//         where: '$incidentId = ?', whereArgs: [serverId]);
//     return result;
//   }
//
//   Future<List<Map<String, dynamic>>> getUser(int id) async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $incidentsTable WHERE $id = $id');
//     return result;
//   }
//
//   Future<List<Map<String, dynamic>>> getLocalIncident(int serverId) async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentId = $serverId');
//     return result;
//   }
//
//   Future<Map<String, dynamic>> getTemporaryIncident(int userId) async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $temporaryIncidentsTable WHERE $temporaryUserId = $userId');
//     return result[0];
//   }
//
//   Future<int> checkUserExists(int id) async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x = await db.rawQuery(
//         'SELECT EXISTS(SELECT 1 FROM $usersTable WHERE $userId = $id)');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> checkElrExists(String inputElr, String inputRegion) async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x = await db.rawQuery(
//         "SELECT EXISTS(SELECT 1 FROM $elrsTable WHERE $elr = ? AND $regionCode = ?)", [inputElr, inputRegion]);
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> deleteElrs(int id) async {
//     Database db = await this.database;
//
//     var result =
//     await db.delete('DELETE FROM $elrsTable');
//     return result;
//   }
//
//   Future<int> checkIncidentExists(int id) async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x = await db.rawQuery(
//         'SELECT EXISTS(SELECT 1 FROM $incidentsTable WHERE $incidentId = $id)');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> checkTemporaryIncidentExists(int userId) async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x = await db.rawQuery(
//         'SELECT EXISTS(SELECT 1 FROM $temporaryIncidentsTable WHERE $temporaryUserId = $userId)');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> checkIncidentTypeExists(int id) async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x = await db.rawQuery(
//         'SELECT EXISTS(SELECT 1 FROM $incidentTypesTable WHERE $incidentTypeId = $id)');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> checkPendingIncidents(int userId) async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x = await db.rawQuery(
//         'SELECT EXISTS(SELECT 1 FROM $incidentsTable WHERE $incidentServerUploaded = 0 AND $incidentUserId = $userId)');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<List<Map<String, dynamic>>> getPendingIncidents(int id) async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentServerUploaded = 0 AND $incidentUserId = $userId');
//     return result;
//   }
//
//   Future<List<Map<String, dynamic>>> getRoutes() async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $routesTable');
//     return result;
//   }
//
//   Future<List<Map<String, dynamic>>> getIncidentTypes(int organisationId ) async {
//     Database db = await this.database;
//
//     var result = await db.query(incidentTypesTable,
//         where: '$incidentTypeOrganisationId = ?',
//         whereArgs: [organisationId]);
//     return result;
//   }
//
//   Future<List<Map<String, dynamic>>> getIncidents(int userId) async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentServerUploaded = 1 AND $incidentUserId = $userId ORDER BY $incidentId DESC');
//     return result;
//   }
//
//
//   Future<List<Map<String, dynamic>>> getIncidentsSuperAdmin() async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentServerUploaded = 1 ORDER BY $incidentId DESC');
//     return result;
//   }
//
//   Future<List<Map<String, dynamic>>> getIncidentsClientAdmin(int organisationId) async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentServerUploaded = 1 AND $incidentOrganisationId = $organisationId ORDER BY $incidentId DESC');
//     return result;
//   }
//
//   Future<int> checkElrCount() async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//     await db.rawQuery('SELECT COUNT (*) from $elrsTable');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> checkLocalIncidentCount(int userId) async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//     await db.rawQuery('SELECT COUNT (*) from $incidentsTable WHERE $incidentUserId = $userId');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> checkLocalIncidentCountClientAdmin(int organisationId) async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//     await db.rawQuery('SELECT COUNT (*) from $incidentsTable WHERE $incidentOrganisationId = $organisationId');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> checkLocalIncidentCountSuperAdmin() async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//     await db.rawQuery('SELECT COUNT (*) from $incidentsTable');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//
//   Future<List<Map<String, dynamic>>> getElrsFromRegion(String region) async {
//     Database db = await this.database;
//
//     var result = await db
//         .rawQuery("SELECT * FROM $elrsTable WHERE $regionCode = '$region'");
//     return result;
//   }
//
//   Future<String> getImagePath() async {
//     Database db = await this.database;
//     String imagePath;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $imagePathTable');
//
//     if(result != null){
//       imagePath = result[0]['image_path'];
//     }
//
//     return imagePath;
//   }
//
//   Future<int> getCachedImagePathCount() async {
//     Database db = await this.database;
//     List<Map<String, dynamic>> x =
//     await db.rawQuery('SELECT COUNT (*) from $cachedImagePathTable');
//     int result = Sqflite.firstIntValue(x);
//     return result;
//   }
//
//   Future<int> addCachedImagePath(Map<String, dynamic> cachedImagePathData) async {
//     Database db = await this.database;
//
//     var result = await db.insert(cachedImagePathTable, cachedImagePathData);
//
//     return result;
//   }
//
//   Future<String> getCachedImagePath() async {
//     Database db = await this.database;
//     String cachedPath;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $cachedImagePathTable');
//
//     if(result != null){
//       cachedPath = result[0]['cached_path'];
//     }
//
//     return cachedPath;
//   }
//
//   Future<Map<String, dynamic>> getCustomCamera() async {
//     Database db = await this.database;
//     Map<String, dynamic> customCameraVal;
//
//     var result = await db
//         .rawQuery('SELECT * FROM $cameraTable');
//
//     if(result != null){
//       customCameraVal = result[0];
//     }
//
//     return customCameraVal;
//   }
//
//   Future<int> updateCustomCamera(int customValue, int toastValue) async {
//     Database db = await this.database;
//
//     var result = await db.update(cameraTable, {'custom_camera' : customValue, 'show_toast' : toastValue});
//
//     return result;
//   }
//
//
//
// }
