import 'dart:async';
import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:encrypt/encrypt.dart';
import 'package:random_string/random_string.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../shared/global_config.dart';

class DatabaseHelper {
  //Singleton DatabaseHelper - only one instance throughout the app
  static DatabaseHelper _databaseHelper;
  //Singleton Database object
  static Database _database;

  //Incidents Table
  String incidentsTable = 'incident_table';
  String id = 'id';
  String incidentId = 'incident_id';
  String incidentUserId = 'user_id';
  String incidentType = 'type';
  String incidentFullName = 'fullname';
  String incidentUsername = 'username';
  String incidentEmail = 'email';
  String incidentDate = 'incident_date';
  String incidentCreated = 'created';
  String incidentLatitude = 'latitude';
  String incidentLongitude = 'longitude';
  String incidentPostCode = 'postcode';
  String incidentProjectName = 'project_name';
  String incidentRoute = 'route';
  String incidentElr = 'elr';
  String incidentMileage = 'mileage';
  String incidentSummary = 'summary';
  String incidentImages = 'images';
  String incidentOrganisationId = 'organisation_id';
  String incidentOrganisationName = 'organisation_name';
  String incidentCustomFields = 'custom_fields';
  String incidentAnonymous = 'anonymous';
  String incidentServerUploaded = 'server_uploaded';

  //Temporary Incident Table
  String temporaryIncidentsTable = 'temporary_incidents_table';
  String temporaryUserId = 'user_id';
  String temporaryIncidentType = 'type';
  String temporaryFullName = 'fullname';
  String temporaryUsername = 'username';
  String temporaryEmail = 'email';
  String temporaryDate = 'incident_date';
  String temporaryLocationDropValue = 'location_drop';
  String temporaryLatitude = 'latitude';
  String temporaryLongitude = 'longitude';
  String temporaryPostCode = 'postcode';
  String temporaryLocationMap = 'location_map';
  String temporaryPostcodeMap = 'postcode_map';
  String temporaryProjectName = 'project_name';
  String temporaryRoute = 'route';
  String temporaryElr = 'elr';
  String temporaryMileageTip = 'mileage_tip';
  String temporaryMileage = 'mileage';
  String temporarySummary = 'summary';
  String temporaryImages = 'images';
  String temporaryOrganisationId = 'organisation_id';
  String temporaryOrganisationName = 'organisation_name';
  String temporaryCustomFields = 'custom_fields';
  String temporaryCustomFieldValue1 = 'custom_value1';
  String temporaryCustomFieldValue2 = 'custom_value2';
  String temporaryCustomFieldValue3 = 'custom_value3';
  String temporaryAnonymous = 'anonymous';

  //Users Table
  String usersTable = 'users_table';
  String userId = 'user_id';
  String userFirstName = 'first_name';
  String userLastName = 'last_name';
  String userUsername = 'username';
  String userPassword = 'password';
  String userSuspended = 'suspended';
  String userOrganisationId = 'organisation_id';
  String userOrganisationName = 'organisation_name';
  String userSession = 'session';
  String userDeleted = 'deleted';
  String userIsClientAdmin = 'is_client_admin';
  String userIsSuperAdmin = 'is_super_admin';
  String userTermsAccepted = 'terms_accepted';
  String userForcePasswordReset = 'force_password_reset';
  String userDarkMode = 'dark_mode';

  //Incident Type Table
  String incidentTypesTable = 'incident_type_table';
  String incidentTypeId = 'incident_type_id';
  String incidentTypeUserId = 'user_id';
  String incidentTypeUsername = 'username';
  String incidentTypeOrganisationId = 'organisation_id';
  String incidentTypeOrganisationName = 'organisation_name';
  String incidentTypeName = 'name';
  String incidentTypeCustomLabel1 = 'custom_label1';
  String incidentTypeCustomLabel2 = 'custom_label2';
  String incidentTypeCustomLabel3 = 'custom_label3';
  String incidentTypeCustomPlaceholder1 = 'custom_placeholder1';
  String incidentTypeCustomPlaceholder2 = 'custom_placeholder2';
  String incidentTypeCustomPlaceholder3 = 'custom_placeholder3';
  String incidentTypeServerUploaded = 'server_uploaded';

  //Route Table
  String routesTable = 'routes_table';
  String routeName = 'route_name';
  String routeCode = 'route_code';

  //ELRs Table
  String elrsTable = 'elrs_table';
  String regionCode = 'region_code';
  String elr = 'elr';
  String elrDescription = 'description';
  String elrStartMiles = 'start_miles';
  String elrEndMiles = 'end_miles';

  //Image Path Table
  String imagePathTable = 'image_path_table';
  String imagePath = 'image_path';



  //Named constructor to create instance of DatabaseHelper
  DatabaseHelper._createInstance();

  //factory keyword allows the constructor to return some value
  factory DatabaseHelper() {
    //initialize our object as well and add a null check so we will create the instance of the database helper only if it is null, this statement will
    //only be executed once in the application

    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    return _databaseHelper;
  }

  //getter for our database
  Future<Database> get database async {
    //if it is null initialize it otherwise return the older instance
    if (_database == null) {
      _database = await initializeDatabase();
    }
    return _database;
  }

  //function to initialise our database
  Future<Database> initializeDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'incidentReporting.db');

    //open/create the database at this given path
    var incidentReportingDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return incidentReportingDatabase;
  }

  //create a function to help us to execute a statement to create our database
  void _createDb(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $usersTable ($userId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $userFirstName VARCHAR(255), $userLastName VARCHAR(255), '
        '$userUsername VARCHAR(255), $userPassword VARCHAR(255), $userSuspended TINYINT(1), $userOrganisationId INT(11), $userOrganisationName VARCHAR(255), $userSession VARCHAR(255), '
        '$userDeleted TINYINT(1), $userIsClientAdmin TINYINT(1), $userIsSuperAdmin TINYINT(1), $userTermsAccepted VARCHAR(255), $userForcePasswordReset TINYINT(1), $userDarkMode TINYINT(1))');

    await db.execute(
        'CREATE TABLE $incidentsTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $incidentId INT(11) default NULL, $userId INT(11) default NULL, $incidentType VARCHAR(255), $incidentFullName VARCHAR(255) default NULL, '
        '$incidentUsername VARCHAR(255) default NULL, $incidentEmail VARCHAR(255) default NULL, $incidentDate VARCHAR(255), $incidentCreated VARCHAR(255), $incidentLatitude VARCHAR(255) default NULL, $incidentLongitude VARCHAR(255) default NULL, '
            '$incidentPostCode VARCHAR(255) default NULL, $incidentProjectName VARCHAR(255) default NULL, $incidentRoute VARCHAR(255) default NULL, $incidentElr VARCHAR(255) default NULL, $incidentMileage VARCHAR(255) default NULL, $incidentSummary TEXT, $incidentImages JSON default NULL, '
            '$incidentOrganisationId INT(11), $incidentOrganisationName VARCHAR(255), $incidentCustomFields JSON default NULL, $incidentAnonymous TINYINT(1) default NULL, $incidentServerUploaded TINYINT(1) default NULL)');

    await db.execute(
        'CREATE TABLE $temporaryIncidentsTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $temporaryUserId INT(11), $temporaryIncidentType VARCHAR(255) default NULL, $temporaryFullName VARCHAR(255) default NULL, '
            '$temporaryUsername VARCHAR(255) default NULL, $temporaryEmail VARCHAR(255) default NULL, $temporaryDate VARCHAR(255) default NULL, $temporaryLocationDropValue VARCHAR(255) default NULL, $temporaryLatitude VARCHAR(255) default NULL, $temporaryLongitude VARCHAR(255) default NULL, '
            '$temporaryPostCode VARCHAR(255) default NULL, $temporaryPostcodeMap TEXT default NULL, $temporaryLocationMap TEXT default NULL, $temporaryProjectName VARCHAR(255) default NULL, $temporaryRoute VARCHAR(255) default NULL, $temporaryElr VARCHAR(255) default NULL, $temporaryMileage VARCHAR(255) default NULL, $temporaryMileageTip VARCHAR(255) default NULL, $temporarySummary TEXT default NULL, $temporaryImages JSON default NULL, '
            '$temporaryOrganisationId INT(11), $temporaryOrganisationName VARCHAR(255), $temporaryCustomFields JSON default NULL, $temporaryCustomFieldValue1 VARCHAR(255) default NULL, $temporaryCustomFieldValue2 VARCHAR(255) default NULL, $temporaryCustomFieldValue3 VARCHAR(255) default NULL, $temporaryAnonymous TINYINT(1) default NULL)');

    await db.execute(
        'CREATE TABLE $incidentTypesTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $incidentTypeId INT(11) default NULL, $incidentTypeUserId INT(11), $incidentTypeUsername VARCHAR(255), $incidentTypeName VARCHAR(255), $incidentTypeCustomLabel1 VARCHAR(255) default NULL, $incidentTypeCustomLabel2 VARCHAR(255) default NULL, '
            '$incidentTypeCustomLabel3 VARCHAR(255) default NULL, $incidentTypeOrganisationId INT(11), $incidentTypeOrganisationName VARCHAR(255),'
            '$incidentTypeCustomPlaceholder1 VARCHAR(255) default NULL, $incidentTypeCustomPlaceholder2 VARCHAR(255) default NULL, $incidentTypeCustomPlaceholder3 VARCHAR(255) default NULL, $incidentTypeServerUploaded TINYINT(1) default NULL)');

    await db.execute(
        'CREATE TABLE $routesTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $routeName VARCHAR(255) default NULL, $routeCode VARCHAR(20) default NULL)');

    await db.execute(
        'CREATE TABLE $elrsTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $regionCode VARCHAR(20) default NULL, $elr VARCHAR(20) default NULL, $elrDescription VARCHAR(255) default NULL, $elrStartMiles VARCHAR(20) default NULL, $elrEndMiles VARCHAR(20) default NULL)');

    await db.execute(
        'CREATE TABLE $imagePathTable($id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, $imagePath VARCHAR(255) default NULL)');
    
    await db.rawInsert("INSERT INTO $routesTable ($routeName, $routeCode) VALUES "
        "('Anglia', 'QT'),"
        "('Southeast', 'QK'),"
        "('London North East', 'QG'),"
        "('London North West (North)','QR'),"
        "('London North West (South)','QS'),"
        "('East Midlands', 'QM'),"
        "('Scotland', 'QL'),"
        "('Wales', 'QC'),"
        "('Wessex', 'QW'),"
        "('Western (West)', 'QD'),"
        "('Western (Thames Valley)', 'QV')");
  }

  //Get all incidents from the database
  Future<List<Map<String, dynamic>>> getIncidentMapList() async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $incidentsTable order by $id ASC');
    return result;
  }

  //Insert Operation: Insert an incident object to the database
  Future<int> addIncident(Map<String, dynamic> incidentData) async {
    Database db = await this.database;

    var result = await db.insert(incidentsTable, incidentData);

    return result;
  }

  Future<int> addTemporaryIncident(Map<String, dynamic> incidentData) async {
    Database db = await this.database;

    var result = await db.insert(temporaryIncidentsTable, incidentData);

    return result;
  }

  Future<int> addImagePath(Map<String, dynamic> imagePathData) async {
    Database db = await this.database;

    var result = await db.insert(imagePathTable, imagePathData);

    return result;
  }

  //Update Operation: update an incident object and save it to the database
  Future<int> updateIncident(Map<String, dynamic> incidentData) async {
    Database db = await this.database;

    var result = await db.update(incidentsTable, incidentData,
        where: '$id = ?', whereArgs: [incidentData['incidentId']]);
    return result;
  }

  Future<int> updateTemporaryIncident(Map<String, dynamic> incidentData) async {
    Database db = await this.database;

    var result = await db.update(temporaryIncidentsTable, incidentData,
        where: '$id = ?', whereArgs: [incidentData['incidentId']]);
    return result;
  }

  Future<int> resetTemporaryIncident(int userId) async {
    Database db = await this.database;

    var result = await db.update(temporaryIncidentsTable, {
      '$temporaryIncidentType': null,
      '$temporaryAnonymous' : false,
      '$temporaryDate' : null,
      '$temporaryLocationDropValue' : null,
      '$temporaryLatitude' : null,
      '$temporaryLongitude' : null,
      '$temporaryPostCode' : null,
      '$temporaryLocationMap': null,
      '$temporaryPostcodeMap': null,
      '$temporaryProjectName' : null,
      '$temporaryRoute' : null,
      '$temporaryElr' : null,
      '$temporaryMileage' : null,
      '$temporarySummary' : null,
      '$temporaryImages' : null,
      '$temporaryCustomFields': null,
      '$temporaryCustomFieldValue1': null,
      '$temporaryCustomFieldValue2': null,
      '$temporaryCustomFieldValue3': null,
    },
        where: '$temporaryUserId = ?', whereArgs: ['$userId']);
    return result;
  }

  Future<int> updateTemporaryIncidentField(String field, var value, int userId) async {
    Database db = await this.database;

    var result = await db.update(temporaryIncidentsTable, {field : value},
        where: '$temporaryUserId = ?', whereArgs: [userId]);
    return result;
  }

  Future<int> deleteIncident(int id) async {
    Database db = await this.database;

    var result =
        await db.delete('DELETE FROM $incidentsTable WHERE $id = $id');
    return result;
  }

  Future<int> getIncidentCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
        await db.rawQuery('SELECT COUNT (*) from $incidentsTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> getImagePathCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $imagePathTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  //Insert Operation: Insert an incident object to the database
  Future<int> addUser(Map<String, dynamic> incidentData) async {
    Database db = await this.database;

    var result = await db.insert(usersTable, incidentData);

    return result;
  }

  Future<int> updateUser(Map<String, dynamic> userData) async {
    Database db = await this.database;

    var result = await db.update(usersTable, userData,
        where: '$userId = ?', whereArgs: [userData['user_id']]);
    return result;
  }

  //Insert Operation: Insert an incident object to the database
  Future<int> addIncidentType(Map<String, dynamic> incidentTypeData) async {
    Database db = await this.database;

    var result = await db.insert(incidentTypesTable, incidentTypeData);

    return result;
  }

  Future<int> updateIncidentType(Map<String, dynamic> incidentTypeData) async {
    Database db = await this.database;

    var result = await db.update(incidentTypesTable, incidentTypeData);

    return result;
  }

  Future<int> addElr(Map<String, dynamic> elrData) async {
    Database db = await this.database;

    var result = await db.insert(elrsTable, elrData);
    //db.close();

    return result;
  }

  Future<int> updateElr(Map<String, dynamic> elrData) async {
    Database db = await this.database;

    var result = await db.update(elrsTable, elrData);

    return result;
  }

  Future<int> updateUserDarkMode(int usersId, bool darkMode) async {
    Database db = await this.database;

    var result = await db.update(usersTable, {userDarkMode : darkMode},
        where: '$userId = ?', whereArgs: [usersId]);
    return result;
  }

  Future<int> updateIncidentId(int localId, int updatedIncidentId) async {
    Database db = await this.database;

    var result = await db.update(incidentsTable, {incidentId : updatedIncidentId},
        where: '$id = ?', whereArgs: [localId]);
    return result;
  }

  Future<int> updateServerUploaded(int localId, bool serverUploaded) async {
    Database db = await this.database;

    var result = await db.update(incidentsTable, {incidentServerUploaded : serverUploaded},
        where: '$id = ?', whereArgs: [localId]);
    return result;
  }

  Future<int> updateLocalIncidentImages(int serverId, var images) async {
    Database db = await this.database;

    var result = await db.update(incidentsTable, {incidentImages : images},
        where: '$incidentId = ?', whereArgs: [serverId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getUser(int id) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $incidentsTable WHERE $id = $id');
    return result;
  }

  Future<List<Map<String, dynamic>>> getLocalIncident(int serverId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentId = $serverId');
    return result;
  }

  Future<Map<String, dynamic>> getTemporaryIncident(int userId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $temporaryIncidentsTable WHERE $temporaryUserId = $userId');
    return result[0];
  }

  Future<int> checkUserExists(int id) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM $usersTable WHERE $userId = $id)');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkElrExists(String inputElr, String inputRegion) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        "SELECT EXISTS(SELECT 1 FROM $elrsTable WHERE $elr = '$inputElr' AND $regionCode = '$inputRegion')");
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> deleteElrs(int id) async {
    Database db = await this.database;

    var result =
    await db.delete('DELETE FROM $elrsTable');
    return result;
  }

  Future<int> checkIncidentExists(int id) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM $incidentsTable WHERE $incidentId = $id)');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkTemporaryIncidentExists(int userId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM $temporaryIncidentsTable WHERE $temporaryUserId = $userId)');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkIncidentTypeExists(int id) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM $incidentTypesTable WHERE $incidentTypeId = $id)');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkPendingIncidents(int userId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM $incidentsTable WHERE $incidentServerUploaded = 0 AND $incidentUserId = $userId)');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<List<Map<String, dynamic>>> getPendingIncidents(int id) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentServerUploaded = 0 AND $incidentUserId = $userId');
    return result;
  }

  Future<List<Map<String, dynamic>>> getRoutes() async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $routesTable');
    return result;
  }

  Future<List<Map<String, dynamic>>> getIncidentTypes(int organisationId ) async {
    Database db = await this.database;

    var result = await db.query(incidentTypesTable,
        where: '$incidentTypeOrganisationId = ?',
        whereArgs: [organisationId]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getIncidents(int userId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentServerUploaded = 1 AND $incidentUserId = $userId ORDER BY $incidentId DESC');
    return result;
  }


  Future<List<Map<String, dynamic>>> getIncidentsSuperAdmin() async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentServerUploaded = 1 ORDER BY $incidentId DESC');
    return result;
  }

  Future<List<Map<String, dynamic>>> getIncidentsClientAdmin(int organisationId) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $incidentsTable WHERE $incidentServerUploaded = 1 AND $incidentOrganisationId = $organisationId ORDER BY $incidentId DESC');
    return result;
  }

  Future<int> checkElrCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $elrsTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkLocalIncidentCount(int userId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $incidentsTable WHERE $incidentUserId = $userId');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkLocalIncidentCountClientAdmin(int organisationId) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $incidentsTable WHERE $incidentOrganisationId = $organisationId');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkLocalIncidentCountSuperAdmin() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x =
    await db.rawQuery('SELECT COUNT (*) from $incidentsTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }


  Future<List<Map<String, dynamic>>> getElrsFromRegion(String region) async {
    Database db = await this.database;

    var result = await db
        .rawQuery("SELECT * FROM $elrsTable WHERE $regionCode = '$region'");
    return result;
  }

  Future<String> getImagePath() async {
    Database db = await this.database;
    String imagePath;

    var result = await db
        .rawQuery('SELECT * FROM $imagePathTable');

    if(result != null){
      imagePath = result[0]['image_path'];
    }

    return imagePath;
  }


}
