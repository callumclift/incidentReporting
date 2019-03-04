import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:connectivity/connectivity.dart';

import '../models/user.dart';
import '../models/authenticated_user.dart';
import '../scoped_models/incidents_model.dart';
import '../shared/global_functions.dart';
import '../shared/global_config.dart';
import '../utils/database_helper.dart';



class UsersModel extends Model {
  List<User> _users = [];
  AuthenticatedUser _authenticatedUser;
  int _selUserKey;
  bool _isLoading = false;
  Timer _authTimer;
  bool _loadingElrs = false;


  bool get isLoading {
    return _isLoading;
  }

  bool get loadingElrs {
    return _loadingElrs;
  }


  List<User> get allUsers {
    return List.from(_users);
  }

  int get selectedUserIndex {
    return _users.indexWhere((User user) {
      return user.userId == _selUserKey;
    });
  }

  int get selectedUserKey {
    return _selUserKey;
  }

  User get selectedUser {
    if (_selUserKey == null) {
      return null;
    }
    return _users.firstWhere((User user) {
      return user.userId == _selUserKey;
    });
  }

  void selectUser(int userKey) {
    _selUserKey = userKey;
    if (userKey != null) {
      notifyListeners();
    }
  }


  AuthenticatedUser get authenticatedUser {
    return _authenticatedUser;
  }

  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> login(String username, String password, bool rememberMe, BuildContext context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();



    _isLoading = true;
    notifyListeners();

    bool success = false;
    String message = 'Something went wrong!';


    final Map<String,dynamic> authData = {
      'loginData': {'username': username, 'password': password},
    };

    try {

      var connectivityResult = await (new Connectivity().checkConnectivity());

      if(connectivityResult == ConnectivityResult.none) {
        if (prefs.get('username') == null && prefs.get('password') == null) {
          message = 'No data connection, please try again later';
        } else {


        if (username == GlobalFunctions.decryptString(prefs.get('username')) &&
            password == GlobalFunctions.decryptString(prefs.get('password'))) {
          _authenticatedUser = AuthenticatedUser(
              userId: prefs.getInt('userId'),
              firstName: GlobalFunctions.decryptString(prefs.get('firstName')),
              lastName: GlobalFunctions.decryptString(prefs.get('lastName')),
              username: GlobalFunctions.decryptString(prefs.get('username')),
              password: GlobalFunctions.decryptString(prefs.get('password')),
              suspended: prefs.getBool('suspended'),
              organisationId: prefs.getInt('organisationId'),
              organisationName: prefs.get('organisationName'),
              session: GlobalFunctions.decryptString(prefs.get('session')),
              deleted: prefs.getBool('deleted'),
              isClientAdmin: prefs.getBool('isClientAdmin'),
              isSuperAdmin: prefs.getBool('isSuperAdmin'),
              termsAccepted: prefs.get('termsAccepted'),
              forcePasswordReset: prefs.getBool('forcePasswordReset'),
              darkMode: prefs.getBool('darkMode'));

          if (prefs.get('cookie') != null)
            cookie = GlobalFunctions.decryptString(prefs.get('cookie'));

          success = true;
          notifyListeners();
        } else {
          message = 'No data connection, please try again later';
        }
      }

      } else {

        //Make the POST request to the server
        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'login', authData, false).timeout(Duration(seconds: 90));

        if (serverResponse != null) {
          if (serverResponse['error'] != null &&
              serverResponse['error'] == 'incorrect_details') {
            message = 'Incorrect username or password given';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'terms_not_accepted') {
            message =
            'You need to accept the terms & conditions before using this app';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'change_password') {
            message = 'You are required to change your password';
          } else if (serverResponse['response']['session'] != null) {

            cookie = serverResponse['response']['session'];
            prefs.setString('cookie', GlobalFunctions.encryptString(cookie));

            final DateTime now = DateTime.now();

            final DateTime cookieExpiryTime =
            now.add(Duration(minutes: 28));


            _authenticatedUser = AuthenticatedUser(
                userId: int.parse(serverResponse['response']['id']),
                firstName: serverResponse['response']['first_name'],
                lastName: serverResponse['response']['last_name'],
                username: username,
                password: password,
                suspended: serverResponse['response']['suspended'],
                organisationId: int.parse(
                    serverResponse['response']['organisation_id']),
                organisationName: serverResponse['response']['organisation_name'],
                session: serverResponse['response']['session'],
                deleted: serverResponse['response']['deleted'],
                isClientAdmin: serverResponse['response']['is_client_admin'],
                isSuperAdmin: serverResponse['response']['is_super_admin'],
                termsAccepted: serverResponse['response']['terms_accepted'],
                forcePasswordReset: serverResponse['response']['force_password_reset']);




            DatabaseHelper databaseHelper = DatabaseHelper();

            final int existingUser = await databaseHelper.checkUserExists(_authenticatedUser.userId);


            //First Name
            String encryptedFirstName = GlobalFunctions.encryptString(
                authenticatedUser.firstName);
            //Last Name
            String encryptedLastName = GlobalFunctions.encryptString(
                authenticatedUser.lastName);
            //Username
            String encryptedUsername = GlobalFunctions.encryptString(
                authenticatedUser.username);
            //Password
            String encryptedPassword = GlobalFunctions.encryptString(
                authenticatedUser.password);
            //Session
            String encryptedSession = GlobalFunctions.encryptString(
                authenticatedUser.session);


            if (existingUser == 0) {

              authenticatedUser.darkMode = false;

              Map<String, dynamic> userData = {
                'user_id': _authenticatedUser.userId,
                'first_name': encryptedFirstName,
                'last_name': encryptedLastName,
                'username': encryptedUsername,
                'password': encryptedPassword,
                'suspended': _authenticatedUser.suspended,
                'organisation_id': _authenticatedUser.organisationId,
                'organisation_name': _authenticatedUser.organisationName,
                'session': encryptedSession,
                'deleted': _authenticatedUser.deleted,
                'is_client_admin': _authenticatedUser.isClientAdmin,
                'is_super_admin': _authenticatedUser.isSuperAdmin,
                'terms_accepted': _authenticatedUser.termsAccepted,
                'force_password_reset': _authenticatedUser.forcePasswordReset,
                'dark_mode': false,
              };

              int addedUser = await databaseHelper.addUser(userData);

              if (addedUser == 0) {
                message = 'Unable to add user locally to the device';
              } else {
                final SharedPreferences prefs = await SharedPreferences
                    .getInstance();

                prefs.setInt('userId', _authenticatedUser.userId);
                prefs.setString('firstName', encryptedFirstName);
                prefs.setString('lastName', encryptedLastName);
                prefs.setString('username', encryptedUsername);
                prefs.setString('password', encryptedPassword);
                prefs.setBool('suspended', _authenticatedUser.suspended);
                prefs.setInt(
                    'organisationId', _authenticatedUser.organisationId);
                prefs.setString('organisationName', _authenticatedUser.organisationName);
                prefs.setString('session', encryptedSession);
                prefs.setBool('deleted', _authenticatedUser.deleted);
                prefs.setBool('isClientAdmin', _authenticatedUser.isClientAdmin);
                prefs.setBool('isSuperAdmin', _authenticatedUser.isSuperAdmin);
                prefs.setString('termsAccepted', _authenticatedUser.termsAccepted);
                prefs.setBool('forcePasswordReset',
                    _authenticatedUser.forcePasswordReset);
                prefs.setBool('rememberMe', rememberMe);
                prefs.setBool('darkMode', false);
                prefs.setString('cookieExpiryTime', cookieExpiryTime.toIso8601String());
              }
            } else {

              Map<String, dynamic> userData = {


                'user_id': _authenticatedUser.userId,
                'first_name': encryptedFirstName,
                'last_name': encryptedLastName,
                'username': encryptedUsername,
                'password': encryptedPassword,
                'suspended': _authenticatedUser.suspended,
                'organisation_id': _authenticatedUser.organisationId,
                'organisation_name': _authenticatedUser.organisationName,
                'session': encryptedSession,
                'deleted': _authenticatedUser.deleted,
                'is_client_admin': _authenticatedUser.isClientAdmin,
                'is_super_admin': _authenticatedUser.isSuperAdmin,
                'terms_accepted': _authenticatedUser.termsAccepted,
                'force_password_reset': _authenticatedUser.forcePasswordReset,
              };

              int updatedUser = await databaseHelper.updateUser(userData);
              if (updatedUser == 0) {
                message = 'Unable to update user locally on the device';
              } else {
                Database database = await databaseHelper.database;

                List<Map<String, dynamic>> user = await database.rawQuery(
                    'SELECT dark_mode FROM users_table WHERE user_id = ${_authenticatedUser
                        .userId}');

                bool darkMode;

                if(user[0]['dark_mode'] is String){
                  darkMode = user[0]['dark_mode'] == 'true' ? true : false;

                } else if (user[0]['dark_mode'] is int){
                  darkMode = user[0]['dark_mode'] == 1 ? true : false;
                }

                authenticatedUser.darkMode = darkMode;

                final SharedPreferences prefs = await SharedPreferences
                    .getInstance();
                prefs.setInt('userId', _authenticatedUser.userId);
                prefs.setString('firstName', encryptedFirstName);
                prefs.setString('lastName', encryptedLastName);
                prefs.setString('username', encryptedUsername);
                prefs.setString('password', encryptedPassword);
                prefs.setBool('suspended', _authenticatedUser.suspended);
                prefs.setInt(
                    'organisationId', _authenticatedUser.organisationId);
                prefs.setString('organisationName', _authenticatedUser.organisationName);
                prefs.setString('session', encryptedSession);
                prefs.setBool('deleted', _authenticatedUser.deleted);
                prefs.setBool('isClientAdmin', _authenticatedUser.isClientAdmin);
                prefs.setBool('isSuperAdmin', _authenticatedUser.isSuperAdmin);
                prefs.setString('termsAccepted', _authenticatedUser.termsAccepted);
                prefs.setBool('forcePasswordReset',
                    _authenticatedUser.forcePasswordReset);
                prefs.setBool('rememberMe', rememberMe);
                prefs.setBool('darkMode', darkMode);
                prefs.setString('cookieExpiryTime', cookieExpiryTime.toIso8601String());

              }
            }

            final int existingTemporaryIncident = await databaseHelper.checkTemporaryIncidentExists(_authenticatedUser.userId);

            if(existingTemporaryIncident == 0){
              int result = await databaseHelper.addTemporaryIncident({
                'user_id' : _authenticatedUser.userId,
                'organisation_id' : _authenticatedUser.organisationId,
                'organisation_name' : _authenticatedUser.organisationName,
                'anonymous' : false

              });

              if(result == 1){
                print('successfully added a temporary incident');
              } else {
                print('unable to add temporary incident');
              }

            }


            final IncidentsModel _incidentsModel =
            ScopedModel.of<IncidentsModel>(context);

            final Map<String, dynamic> incidentTypes = await _incidentsModel.getCustomIncidents(_authenticatedUser);

            if(incidentTypes['success']) success = true;

            //Add the ELRs to the Database if the table count is 0
            int elrCount = await databaseHelper.checkElrCount();

            if(elrCount == 0){
              print('going to get ELRs');
              _loadingElrs = true;
              notifyListeners();
              final Map<String, dynamic> elrResult = await this.getElrs();

              if(elrResult['success']){
                success = true;
              }  else {
                success = false;
              }
              _loadingElrs = false;
              notifyListeners();
            }

          } else {
            message = 'no valid session found';
          }

        }
      }

    } on TimeoutException catch (_) {

      message = 'Request timeout, please try again later';
      // A timeout occurred.
    } catch(error){
      print(error);
      message = 'Something went wrong';
    }

    _userSubject.add(true);
    _isLoading = false;
    notifyListeners();

    return {'success': success, 'message': message};
  }

  Future<Map<String, dynamic>> loginTest(bool rememberMe, BuildContext context) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();

    String username = 'callum.planner';
    String password = 'Ontrac99';



    _isLoading = true;
    notifyListeners();

    bool success = false;
    String message = 'Something went wrong!';


    final Map<String,dynamic> authData = {
      'loginData': {'username': username, 'password': password},
    };

    try {

      var connectivityResult = await (new Connectivity().checkConnectivity());

      if(connectivityResult == ConnectivityResult.none) {
        if (prefs.get('username') == null && prefs.get('password') == null) {
          message = 'No data connection, please try again later';
        } else {


          if (username == GlobalFunctions.decryptString(prefs.get('username')) &&
              password == GlobalFunctions.decryptString(prefs.get('password'))) {
            _authenticatedUser = AuthenticatedUser(
                userId: prefs.getInt('userId'),
                firstName: GlobalFunctions.decryptString(prefs.get('firstName')),
                lastName: GlobalFunctions.decryptString(prefs.get('lastName')),
                username: GlobalFunctions.decryptString(prefs.get('username')),
                password: GlobalFunctions.decryptString(prefs.get('password')),
                suspended: prefs.getBool('suspended'),
                organisationId: prefs.getInt('organisationId'),
                organisationName: prefs.get('organisationName'),
                session: GlobalFunctions.decryptString(prefs.get('session')),
                deleted: prefs.getBool('deleted'),
                isClientAdmin: prefs.getBool('isClientAdmin'),
                isSuperAdmin: prefs.getBool('isSuperAdmin'),
                termsAccepted: prefs.get('termsAccepted'),
                forcePasswordReset: prefs.getBool('forcePasswordReset'),
                darkMode: prefs.getBool('darkMode'));

            if (prefs.get('cookie') != null)
              cookie = GlobalFunctions.decryptString(prefs.get('cookie'));

            success = true;
            notifyListeners();
          } else {
            message = 'No data connection, please try again later';
          }
        }

      } else {

        //Make the POST request to the server
        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'login', authData, false).timeout(Duration(seconds: 90));

        if (serverResponse != null) {
          if (serverResponse['error'] != null &&
              serverResponse['error'] == 'incorrect_details') {
            message = 'Incorrect username or password given';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'terms_not_accepted') {
            message =
            'You need to accept the terms & conditions before using this app';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'change_password') {
            message = 'You are required to change your password';
          } else if (serverResponse['response']['session'] != null) {

            cookie = serverResponse['response']['session'];
            prefs.setString('cookie', GlobalFunctions.encryptString(cookie));

            final DateTime now = DateTime.now();

            final DateTime cookieExpiryTime =
            now.add(Duration(minutes: 28));


            _authenticatedUser = AuthenticatedUser(
                userId: int.parse(serverResponse['response']['id']),
                firstName: serverResponse['response']['first_name'],
                lastName: serverResponse['response']['last_name'],
                username: username,
                password: password,
                suspended: serverResponse['response']['suspended'],
                organisationId: int.parse(
                    serverResponse['response']['organisation_id']),
                organisationName: serverResponse['response']['organisation_name'],
                session: serverResponse['response']['session'],
                deleted: serverResponse['response']['deleted'],
                isClientAdmin: serverResponse['response']['is_client_admin'],
                isSuperAdmin: serverResponse['response']['is_super_admin'],
                termsAccepted: serverResponse['response']['terms_accepted'],
                forcePasswordReset: serverResponse['response']['force_password_reset']);




            DatabaseHelper databaseHelper = DatabaseHelper();

            final int existingUser = await databaseHelper.checkUserExists(_authenticatedUser.userId);


            //First Name
            String encryptedFirstName = GlobalFunctions.encryptString(
                authenticatedUser.firstName);
            //Last Name
            String encryptedLastName = GlobalFunctions.encryptString(
                authenticatedUser.lastName);
            //Username
            String encryptedUsername = GlobalFunctions.encryptString(
                authenticatedUser.username);
            //Password
            String encryptedPassword = GlobalFunctions.encryptString(
                authenticatedUser.password);
            //Session
            String encryptedSession = GlobalFunctions.encryptString(
                authenticatedUser.session);


            if (existingUser == 0) {

              authenticatedUser.darkMode = false;

              Map<String, dynamic> userData = {
                'user_id': _authenticatedUser.userId,
                'first_name': encryptedFirstName,
                'last_name': encryptedLastName,
                'username': encryptedUsername,
                'password': encryptedPassword,
                'suspended': _authenticatedUser.suspended,
                'organisation_id': _authenticatedUser.organisationId,
                'organisation_name': _authenticatedUser.organisationName,
                'session': encryptedSession,
                'deleted': _authenticatedUser.deleted,
                'is_client_admin': _authenticatedUser.isClientAdmin,
                'is_super_admin': _authenticatedUser.isSuperAdmin,
                'terms_accepted': _authenticatedUser.termsAccepted,
                'force_password_reset': _authenticatedUser.forcePasswordReset,
                'dark_mode': false,
              };

              int addedUser = await databaseHelper.addUser(userData);

              if (addedUser == 0) {
                message = 'Unable to add user locally to the device';
              } else {
                final SharedPreferences prefs = await SharedPreferences
                    .getInstance();

                prefs.setInt('userId', _authenticatedUser.userId);
                prefs.setString('firstName', encryptedFirstName);
                prefs.setString('lastName', encryptedLastName);
                prefs.setString('username', encryptedUsername);
                prefs.setString('password', encryptedPassword);
                prefs.setBool('suspended', _authenticatedUser.suspended);
                prefs.setInt(
                    'organisationId', _authenticatedUser.organisationId);
                prefs.setString('organisationName', _authenticatedUser.organisationName);
                prefs.setString('session', encryptedSession);
                prefs.setBool('deleted', _authenticatedUser.deleted);
                prefs.setBool('isClientAdmin', _authenticatedUser.isClientAdmin);
                prefs.setBool('isSuperAdmin', _authenticatedUser.isSuperAdmin);
                prefs.setString('termsAccepted', _authenticatedUser.termsAccepted);
                prefs.setBool('forcePasswordReset',
                    _authenticatedUser.forcePasswordReset);
                prefs.setBool('rememberMe', rememberMe);
                prefs.setBool('darkMode', false);
                prefs.setString('cookieExpiryTime', cookieExpiryTime.toIso8601String());
              }
            } else {

              Map<String, dynamic> userData = {


                'user_id': _authenticatedUser.userId,
                'first_name': encryptedFirstName,
                'last_name': encryptedLastName,
                'username': encryptedUsername,
                'password': encryptedPassword,
                'suspended': _authenticatedUser.suspended,
                'organisation_id': _authenticatedUser.organisationId,
                'organisation_name': _authenticatedUser.organisationName,
                'session': encryptedSession,
                'deleted': _authenticatedUser.deleted,
                'is_client_admin': _authenticatedUser.isClientAdmin,
                'is_super_admin': _authenticatedUser.isSuperAdmin,
                'terms_accepted': _authenticatedUser.termsAccepted,
                'force_password_reset': _authenticatedUser.forcePasswordReset,
              };

              int updatedUser = await databaseHelper.updateUser(userData);
              if (updatedUser == 0) {
                message = 'Unable to update user locally on the device';
              } else {
                Database database = await databaseHelper.database;

                List<Map<String, dynamic>> user = await database.rawQuery(
                    'SELECT dark_mode FROM users_table WHERE user_id = ${_authenticatedUser
                        .userId}');

                bool darkMode;

                if(user[0]['dark_mode'] is String){
                  darkMode = user[0]['dark_mode'] == 'true' ? true : false;

                } else if (user[0]['dark_mode'] is int){
                  darkMode = user[0]['dark_mode'] == 1 ? true : false;
                }

                authenticatedUser.darkMode = darkMode;

                final SharedPreferences prefs = await SharedPreferences
                    .getInstance();
                prefs.setInt('userId', _authenticatedUser.userId);
                prefs.setString('firstName', encryptedFirstName);
                prefs.setString('lastName', encryptedLastName);
                prefs.setString('username', encryptedUsername);
                prefs.setString('password', encryptedPassword);
                prefs.setBool('suspended', _authenticatedUser.suspended);
                prefs.setInt(
                    'organisationId', _authenticatedUser.organisationId);
                prefs.setString('organisationName', _authenticatedUser.organisationName);
                prefs.setString('session', encryptedSession);
                prefs.setBool('deleted', _authenticatedUser.deleted);
                prefs.setBool('isClientAdmin', _authenticatedUser.isClientAdmin);
                prefs.setBool('isSuperAdmin', _authenticatedUser.isSuperAdmin);
                prefs.setString('termsAccepted', _authenticatedUser.termsAccepted);
                prefs.setBool('forcePasswordReset',
                    _authenticatedUser.forcePasswordReset);
                prefs.setBool('rememberMe', rememberMe);
                prefs.setBool('darkMode', darkMode);
                prefs.setString('cookieExpiryTime', cookieExpiryTime.toIso8601String());

              }
            }

            final int existingTemporaryIncident = await databaseHelper.checkTemporaryIncidentExists(_authenticatedUser.userId);

            if(existingTemporaryIncident == 0){
              int result = await databaseHelper.addTemporaryIncident({
                'user_id' : _authenticatedUser.userId,
                'organisation_id' : _authenticatedUser.organisationId,
                'organisation_name' : _authenticatedUser.organisationName,
                'anonymous' : false

              });

              if(result == 1){
                print('successfully added a temporary incident');
              } else {
                print('unable to add temporary incident');
              }

            }


            final IncidentsModel _incidentsModel =
            ScopedModel.of<IncidentsModel>(context);

            final Map<String, dynamic> incidentTypes = await _incidentsModel.getCustomIncidents(_authenticatedUser);

            if(incidentTypes['success']) success = true;

            //Add the ELRs to the Database if the table count is 0
            int elrCount = await databaseHelper.checkElrCount();

            if(elrCount == 0){
              print('going to get ELRs');
              _loadingElrs = true;
              notifyListeners();
              final Map<String, dynamic> elrResult = await this.getElrs();

              if(elrResult['success']){
                success = true;
              }  else {
                success = false;
              }
              _loadingElrs = false;
              notifyListeners();
            }

          } else {
            message = 'no valid session found';
          }

        }
      }

    } on TimeoutException catch (_) {

      message = 'Request timeout, please try again later';
      // A timeout occurred.
    } catch(error){
      print(error);
      message = 'Something went wrong';
    }

    _userSubject.add(true);
    _isLoading = false;
    notifyListeners();

    return {'success': success, 'message': message};
  }


  Future<Map<String, dynamic>> getElrs() async {

    bool success = false;
    String message = 'Something went wrong';

    try {
      var connectivityResult = await (new Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        message = 'No data connection, unable to fetch Elr Data';
      } else {

        final Map<String, dynamic> requestData = {
          'incidentData': {},
        };

        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        Map<String, dynamic> renewSession = {};

        if (isCookieExpired) {
          renewSession = await this.renewSession(
              authenticatedUser.username,
              authenticatedUser.password);
          message = renewSession['message'];
        }

        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'getElrs', requestData)
            .timeout(Duration(seconds: 90));

        if (serverResponse != null) {

          if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Token missing or invalid') {
            message = 'token missing or invalied';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Access Denied.') {

            Map<String, dynamic> renewSession = await this.renewSession(
                authenticatedUser.username,
                authenticatedUser.password);

            message = renewSession['message'];
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'terms_not_accepted') {
            message =
            'You need to accept the terms & conditions before using this app';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'change_password') {
            message = 'You are required to change your password';
          } else if (serverResponse['response']['elrs'] != null) {
            List<dynamic> elrList = serverResponse['response']['elrs'];

            DatabaseHelper databaseHelper = DatabaseHelper();

            for (Map<String, dynamic> elrData in elrList) {

                Map<String, dynamic> databaseData = {
                  'region_code': elrData['HdElrLookup']['region'],
                  'elr': elrData['HdElrLookup']['elr'],
                  'description': elrData['HdElrLookup']['description'],
                  'start_miles': elrData['HdElrLookup']['start_miles'],
                  'end_miles': elrData['HdElrLookup']['end_miles'],
                };

                int result = await databaseHelper.addElr(databaseData);

                if (result != 0) {
                  message = 'Elr not added to the database';
                }
            }

            int count = await databaseHelper.checkElrCount();
            print('this is the count of the elrs: ' + count.toString());
            success = true;
            message = 'waheyyyyy';
          }
        } else {
          message = 'no valid session found';
        }
      }
    } on TimeoutException catch (_) {
      message = 'Request timeout, unable to fetch Elr data';
      // A timeout occurred.
    } catch (error) {
      print(error);
      message = 'Unable to fetch Elr data';
    }

    return {'success': success, 'message': message};
  }

  Future<Map<String, dynamic>> updateElrs() async {

    bool success = false;
    String message = 'Something went wrong';

    try {
      var connectivityResult = await (new Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        message = 'No data connection, unable to fetch Elr Data';
      } else {

        final Map<String, dynamic> requestData = {
          'incidentData': {},
        };

        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        Map<String, dynamic> renewSession = {};

        if (isCookieExpired) {
          renewSession = await this.renewSession(
              authenticatedUser.username,
              authenticatedUser.password);
          message = renewSession['message'];
        }

        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'getElrs', requestData)
            .timeout(Duration(seconds: 90));

        if (serverResponse != null) {

          if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Token missing or invalid') {
            message = 'token missing or invalied';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Access Denied.') {
            print('its in access denied, trying to renew the session');

            Map<String, dynamic> renewSession = await this.renewSession(
                authenticatedUser.username,
                authenticatedUser.password);

            message = renewSession['message'];
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'terms_not_accepted') {
            message =
            'You need to accept the terms & conditions before using this app';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'change_password') {
            message = 'You are required to change your password';
          } else if (serverResponse['response']['elrs'] != null) {
            List<dynamic> elrList = serverResponse['response']['elrs'];

            DatabaseHelper databaseHelper = DatabaseHelper();

            for (Map<String, dynamic> elrData in elrList) {

              Map<String, dynamic> databaseData = {
                'region_code': elrData['HdElrLookup']['region'],
                'elr': elrData['HdElrLookup']['elr'],
                'description': elrData['HdElrLookup']['description'],
                'start_miles': elrData['HdElrLookup']['start_miles'],
                'end_miles': elrData['HdElrLookup']['end_miles'],
              };

              int alreadyExists = await databaseHelper.checkElrExists(databaseData['elr'], databaseData['region_code']);

              if(alreadyExists == 0){

                int result = await databaseHelper.addElr(databaseData);

                if (result != 0) {
                  message = 'Elr not added to the database';
                }
              } else {

                int result = await databaseHelper.updateElr(databaseData);

                if (result != 0) {
                  message = 'Elr not updated';
                }

              }

            }

            int count = await databaseHelper.checkElrCount();
            print('this is the count of the elrs: ' + count.toString());
            success = true;
            message = 'waheyyyyy';
          }
        } else {
          message = 'no valid session found';
        }
      }
    } on TimeoutException catch (_) {
      message = 'Request timeout, unable to fetch Elr data';
      // A timeout occurred.
    } catch (error) {
      print(error);
      message = 'Unable to fetch Elr data';
    }

    return {'success': success, 'message': message};
  }


  Future<Map<String, dynamic>> renewSession(String username, String password) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool rememberMe = prefs.getBool('rememberMe');


    _isLoading = true;
    notifyListeners();

    bool success = false;
    String message = 'Something went wrong!';


    final Map<String,dynamic> authData = {
      'loginData': {'username': username, 'password': password},
    };

    try {

      var connectivityResult = await (new Connectivity().checkConnectivity());

      if(connectivityResult == ConnectivityResult.none){

        message = 'No data connection, please try again later';

      } else {

        //Make the POST request to the server
        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'login', authData, false).timeout(Duration(seconds: 90));

        if (serverResponse != null) {
          if (serverResponse['error'] != null &&
              serverResponse['error'] == 'incorrect_details') {
            message = 'Your Username/Email and or Password have been changed';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'terms_not_accepted') {
            message =
            'You need to accept the terms & conditions before continuing to use this app';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'change_password') {
            message = 'You are required to change your password, unable to process this request';
          } else if (serverResponse['response']['session'] != null) {

            cookie = serverResponse['response']['session'];
            prefs.setString('cookie', GlobalFunctions.encryptString(cookie));

            final DateTime now = DateTime.now();

            final DateTime cookieExpiryTime =
            now.add(Duration(minutes: 28));


            _authenticatedUser = AuthenticatedUser(
                userId: int.parse(serverResponse['response']['id']),
                firstName: serverResponse['response']['first_name'],
                lastName: serverResponse['response']['last_name'],
                username: username,
                password: password,
                suspended: serverResponse['response']['suspended'],
                organisationId: int.parse(
                    serverResponse['response']['organisation_id']),
                organisationName: serverResponse['response']['organisation_name'],
                session: serverResponse['response']['session'],
                deleted: serverResponse['response']['deleted'],
                isClientAdmin: serverResponse['response']['is_client_admin'],
                isSuperAdmin: serverResponse['response']['is_super_admin'],
                termsAccepted: serverResponse['response']['terms_accepted'],
                forcePasswordReset: serverResponse['response']['force_password_reset'],
            darkMode: prefs.getBool('darkMode'));



            //Encrypt details of the incident
            DatabaseHelper databaseHelper = DatabaseHelper();

            final int existingUser = await databaseHelper.checkUserExists(_authenticatedUser.userId);


            //First Name
            String encryptedFirstName = GlobalFunctions.encryptString(
                authenticatedUser.firstName);
            //Last Name
            String encryptedLastName = GlobalFunctions.encryptString(
                authenticatedUser.lastName);
            //Username
            String encryptedUsername = GlobalFunctions.encryptString(
                authenticatedUser.username);
            //Password
            String encryptedPassword = GlobalFunctions.encryptString(
                authenticatedUser.password);
            //Session
            String encryptedSession = GlobalFunctions.encryptString(
                authenticatedUser.session);

            if (existingUser == 0) {
              Map<String, dynamic> userData = {
                'user_id': _authenticatedUser.userId,
                'first_name': encryptedFirstName,
                'last_name': encryptedLastName,
                'username': encryptedUsername,
                'password': encryptedPassword,
                'suspended': _authenticatedUser.suspended,
                'organisation_id': _authenticatedUser.organisationId,
                'organisation_name': _authenticatedUser.organisationName,
                'session': encryptedSession,
                'deleted': _authenticatedUser.deleted,
                'is_client_admin': _authenticatedUser.isClientAdmin,
                'is_super_admin': _authenticatedUser.isSuperAdmin,
                'terms_accepted': _authenticatedUser.termsAccepted,
                'force_password_reset': _authenticatedUser.forcePasswordReset,
                'dark_mode': false,
              };

              int addedUser = await databaseHelper.addUser(userData);

              if (addedUser == 0) {
                message = 'Unable to add user locally to the device';
              } else {
                final SharedPreferences prefs = await SharedPreferences
                    .getInstance();
                prefs.setInt('userId', _authenticatedUser.userId);
                prefs.setString('firstName', encryptedFirstName);
                prefs.setString('lastName', encryptedLastName);
                prefs.setString('username', encryptedUsername);
                prefs.setString('password', encryptedPassword);
                prefs.setBool('suspended', _authenticatedUser.suspended);
                prefs.setInt(
                    'organisationId', _authenticatedUser.organisationId);
                prefs.setString('organisationName', _authenticatedUser.organisationName);
                prefs.setString('session', encryptedSession);
                prefs.setBool('deleted', _authenticatedUser.deleted);
                prefs.setBool('isClientAdmin', _authenticatedUser.isClientAdmin);
                prefs.setBool('isSuperAdmin', _authenticatedUser.isSuperAdmin);
                prefs.setString('termsAccepted', _authenticatedUser.termsAccepted);
                prefs.setBool('forcePasswordReset',
                    _authenticatedUser.forcePasswordReset);
                prefs.setBool('rememberMe', rememberMe);
                prefs.setBool('darkMode', false);
                prefs.setString('cookieExpiryTime', cookieExpiryTime.toIso8601String());
              }
            } else {
              Map<String, dynamic> userData = {
                'user_id': _authenticatedUser.userId,
                'first_name': encryptedFirstName,
                'last_name': encryptedLastName,
                'username': encryptedUsername,
                'password': encryptedPassword,
                'suspended': _authenticatedUser.suspended,
                'organisation_id': _authenticatedUser.organisationId,
                'organisation_name': _authenticatedUser.organisationName,
                'session': encryptedSession,
                'deleted': _authenticatedUser.deleted,
                'is_client_admin': _authenticatedUser.isClientAdmin,
                'is_super_admin': _authenticatedUser.isSuperAdmin,
                'terms_accepted': _authenticatedUser.termsAccepted,
                'force_password_reset': _authenticatedUser.forcePasswordReset,
              };

              int updatedUser = await databaseHelper.updateUser(userData);
              if (updatedUser == 0) {
                message = 'Unable to update user locally on the device';
              } else {
                Database database = await databaseHelper.database;

                List<Map<String, dynamic>> user = await database.rawQuery(
                    'SELECT dark_mode FROM users_table WHERE user_id = ${_authenticatedUser
                        .userId}');

                bool darkMode;

                if(user[0]['dark_mode'] is String){
                  darkMode = user[0]['dark_mode'] == 'true' ? true : false;

                } else if (user[0]['dark_mode'] is int){
                  darkMode = user[0]['dark_mode'] == 1 ? true : false;
                }

                final SharedPreferences prefs = await SharedPreferences
                    .getInstance();
                prefs.setInt('userId', _authenticatedUser.userId);
                prefs.setString('firstName', encryptedFirstName);
                prefs.setString('lastName', encryptedLastName);
                prefs.setString('username', encryptedUsername);
                prefs.setString('password', encryptedPassword);
                prefs.setBool('suspended', _authenticatedUser.suspended);
                prefs.setInt(
                    'organisationId', _authenticatedUser.organisationId);
                prefs.setString('organisationName', _authenticatedUser.organisationName);
                prefs.setString('session', encryptedSession);
                prefs.setBool('deleted', _authenticatedUser.deleted);
                prefs.setBool('isClientAdmin', _authenticatedUser.isClientAdmin);
                prefs.setBool('isSuperAdmin', _authenticatedUser.isSuperAdmin);
                prefs.setString('termsAccepted', _authenticatedUser.termsAccepted);
                prefs.setBool('forcePasswordReset',
                    _authenticatedUser.forcePasswordReset);
                prefs.setBool('rememberMe', rememberMe);
                prefs.setBool('darkMode', darkMode);
                prefs.setString('cookieExpiryTime', cookieExpiryTime.toIso8601String());

              }
            }
            message = 'successfully renewed the session, please try again';
            success = true;
          } else {
            message = 'no valid session found';
          }

        }
      }

    } on TimeoutException catch (_) {
      message = 'Request timeout, unable renew session';
    } catch(error){
      print(error);
      message = 'Something went wrong';
    }

    _userSubject.add(true);
    _isLoading = false;
    notifyListeners();

    return {'success': success, 'message': message};
  }


    autoLogin(SharedPreferences prefs){
    final bool rememberMe = prefs.getBool('rememberMe');

    if(rememberMe != null && rememberMe == true){

      _authenticatedUser = AuthenticatedUser(
          userId: prefs.getInt('userId'),
          firstName: GlobalFunctions.decryptString(prefs.get('firstName')),
          lastName: GlobalFunctions.decryptString(prefs.get('lastName')),
          username: GlobalFunctions.decryptString(prefs.get('username')),
          password: GlobalFunctions.decryptString(prefs.get('password')),
          suspended: prefs.getBool('suspended'),
          organisationId: prefs.getInt('organisationId'),
          organisationName: prefs.get('organisationName'),
          session: GlobalFunctions.decryptString(prefs.get('session')),
          deleted: prefs.getBool('deleted'),
          isClientAdmin: prefs.getBool('isClientAdmin'),
          isSuperAdmin: prefs.getBool('isSuperAdmin'),
          termsAccepted: prefs.get('termsAccepted'),
          forcePasswordReset: prefs.getBool('forcePasswordReset'),
      darkMode: prefs.getBool('darkMode'));

      if(prefs.get('cookie') != null) cookie = GlobalFunctions.decryptString(prefs.get('cookie'));

      notifyListeners();

    }

//    else {
//      prefs.remove('userId');
//      prefs.remove('firstName');
//      prefs.remove('lastName');
//      prefs.remove('username');
//      prefs.remove('password');
//      prefs.remove('suspended');
//      prefs.remove('organisationId');
//      prefs.remove('organisationName');
//      prefs.remove('session');
//      prefs.remove('deleted');
//      prefs.remove('isClientAdmin');
//      prefs.remove('isSuperAdmin');
//      prefs.remove('termsAccepted');
//      prefs.remove('forcePasswordReset');
//      prefs.remove('cookie');
//      prefs.remove('cookieExpiryTime');
//    }
  }


   void logout() async {
    print('logout happened');
    _selUserKey = null;
    _authenticatedUser = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('rememberMe');
//    prefs.remove('userId');
//    prefs.remove('firstName');
//    prefs.remove('lastName');
//    prefs.remove('username');
//    prefs.remove('password');
//    prefs.remove('suspended');
//    prefs.remove('organisationId');
//    prefs.remove('organisationName');
//    prefs.remove('session');
//    prefs.remove('deleted');
//    prefs.remove('isAdmin');
//    prefs.remove('termsAccepted');
//    prefs.remove('forcePasswordReset');
//    prefs.remove('darkMode');

//    prefs.remove('cookie');
//    prefs.remove('cookieExpiryTime');
  }

  void setAuthTimeout(int time) {
    print('this is the timer left in seconds: ' + time.toString());
    _authTimer = Timer(Duration(seconds: time), logout);
  }



}
