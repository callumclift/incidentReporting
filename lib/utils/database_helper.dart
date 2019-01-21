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
  String incidentTypeTable = 'incident_type_table';
  String incidentTypeId = 'id';
  String incidentTypeName = 'name';
  String incidentTypeCustom1 = 'custom_field_1';
  String incidentTypeCustom2 = 'custom_field_2';
  String incidentTypeCustom3 = 'custom_field_3';
  String incidentTypeOrganisationId = 'organisation_id';
  String incidentTypeOrganisationName = 'organisation_name';

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
        'CREATE TABLE $usersTable ($userId INT(11) PRIMARY KEY, $userFirstName VARCHAR(255), $userLastName VARCHAR(255), '
        '$userUsername VARCHAR(255), $userPassword VARCHAR(255), $userSuspended TINYINT(1), $userOrganisationId INT(11), $userOrganisationName VARCHAR(255), $userSession VARCHAR(255), '
        '$userDeleted TINYINT(1), $userIsClientAdmin TINYINT(1), $userIsSuperAdmin TINYINT(1), $userTermsAccepted VARCHAR(255), $userForcePasswordReset TINYINT(1), $userDarkMode TINYINT(1))');

    await db.execute(
        'CREATE TABLE $incidentsTable($id INT(11) PRIMARY KEY, $incidentId INT(11) default NULL, $userId INT(11) default NULL, $incidentType VARCHAR(255), $incidentFullName VARCHAR(255) default NULL, '
        '$incidentUsername VARCHAR(255) default NULL, $incidentEmail VARCHAR(255) default NULL, $incidentDate VARCHAR(255), $incidentCreated VARCHAR(255), $incidentLatitude VARCHAR(255) default NULL, $incidentLongitude VARCHAR(255) default NULL, '
            '$incidentProjectName VARCHAR(255) default NULL, $incidentRoute VARCHAR(255) default NULL, $incidentElr VARCHAR(255) default NULL, $incidentMileage VARCHAR(255) default NULL, $incidentSummary TEXT, $incidentImages JSON default NULL, '
            '$incidentOrganisationId INT(11), $incidentOrganisationName VARCHAR(255), $incidentCustomFields TEXT default NULL, $incidentAnonymous TINYINT(1) default NULL)');

    await db.execute(
        'CREATE TABLE $incidentTypeTable($incidentTypeId INT(11) PRIMARY KEY, $incidentTypeName VARCHAR(255), $incidentTypeCustom1 VARCHAR(255), $incidentTypeCustom2 VARCHAR(255), '
            '$incidentTypeCustom3 VARCHAR(255), $incidentTypeOrganisationId INT(11), $incidentTypeOrganisationName VARCHAR(255))');
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

  //Update Operation: update an incident object and save it to the database
  Future<int> updateIncident(Map<String, dynamic> incidentData) async {
    Database db = await this.database;

    var result = await db.update(incidentsTable, incidentData,
        where: '$id = ?', whereArgs: [incidentData['incidentId']]);
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

  //Insert Operation: Insert an incident object to the database
  Future<int> addUser(Map<String, dynamic> incidentData) async {
    Database db = await this.database;

    var result = await db.insert(usersTable, incidentData);

    return result;
  }

  Future<int> updateUser1(Map<String, dynamic> userData) async {
    Database db = await this.database;

    var result = await db.update(usersTable, userData,
        where: '$userId = ?', whereArgs: [userData['user_id']]);
    return result;
  }

  Future<int> updateUser(Map<String, dynamic> userData) async {
    Database db = await this.database;

    var result = await db.rawUpdate(
        'UPDATE $usersTable SET $userId = ?, $userFirstName = ? , $userLastName = ?, $userUsername = ?, $userPassword = ?, '
            '$userSuspended = ?, $userOrganisationId = ?, $userOrganisationName = ?, $userSession = ?, $userDeleted = ?, '
            '$userIsClientAdmin = ?, $userIsSuperAdmin = ?, $userTermsAccepted = ?, $userForcePasswordReset = ? WHERE $userId = ?',
        [
          '${userData['user_id']}',
          '${userData['first_name']}',
          '${userData['last_name']}',
          '${userData['username']}',
          '${userData['password']}',
          '${userData['suspended']}',
          '${userData['organisation_id']}',
          '${userData['organisation_name']}',
          '${userData['session']}',
          '${userData['deleted']}',
          '${userData['is_client_admin']}',
          '${userData['is_super_admin']}',
          '${userData['terms_accepted']}',
          '${userData['force_password_reset']}',
          '${userData['user_id']}'
        ]);
    return result;
  }

  //Insert Operation: Insert an incident object to the database
  Future<int> addIncidentType(Map<String, dynamic> incidentTypeData) async {
    Database db = await this.database;

    var result = await db.insert(incidentTypeTable, incidentTypeData);

    return result;
  }

  Future<int> updateUserDarkMode(int userId, bool darkMode) async {
    Database db = await this.database;

    var result = await db.rawUpdate(
        'UPDATE $usersTable SET $userDarkMode = ? WHERE $userId = ?',
        [
          '$darkMode',
          '$userId'
        ]);
    return result;
  }

  Future<int> updateIncidentId(int localId, int updatedincidentId) async {
    Database db = await this.database;

    var result = await db.rawUpdate(
        'UPDATE $incidentsTable SET $incidentId = ? WHERE $localId = ?',
        [
          '$updatedincidentId',
          '$localId'
        ]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getUser(int id) async {
    Database db = await this.database;

    var result = await db
        .rawQuery('SELECT * FROM $incidentsTable WHERE $id = $id');
    return result;
  }

  Future<int> checkUserExists(int id) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM $usersTable WHERE $userId = $id)');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  Future<int> checkIncidentExists(int id) async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery(
        'SELECT EXISTS(SELECT 1 FROM $incidentsTable WHERE $incidentId = $id)');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
}
