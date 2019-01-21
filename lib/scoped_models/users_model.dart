import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:random_string/random_string.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:http_parser/http_parser.dart';
import 'package:encrypt/encrypt.dart';
import 'package:connectivity/connectivity.dart';

import '../models/user.dart';
import '../models/authenticated_user.dart';
import '../models/auth.dart';
import '../shared/global_functions.dart';
import '../shared/global_config.dart';
import '../utils/database_helper.dart';



class UsersModel extends Model {
  List<User> _users = [];
  AuthenticatedUser _authenticatedUser;
  int _selUserKey;
  bool _isLoading = false;
  Timer _authTimer;


  bool get isLoading {
    return _isLoading;
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

//  Future<Null> fetchUsers(String role, {onlyForUser: false, clearExisting = false}) async{
//
//    _isLoading = true;
//
//    if (clearExisting) {
//      _users = [];
//    }
//
//    final List<User> fetchedUserList = [];
//
//    Map<String, dynamic> userData = {};
//
//
//    try {
//
//      DataSnapshot snapshot;
//
//      snapshot = await FirebaseDatabase.instance
//          .reference().child('users').orderByChild('firstName')
//          .once();
//
//      userData = new Map.from(snapshot.value);
//
//      userData.forEach((String userKey, dynamic userData) {
//        final User user = User(
//            id: userKey,
//            authenticationId: userData['authenticationId'],
//            email: userData['email'],
//            firstName: userData['firstName'],
//            surname: userData['surname'],
//            organisation: userData['organisation'],
//            role: userData['role'],
//            hasTemporaryPassword: userData['hasTemporaryPassword'],
//            acceptedTerms: userData['acceptedTerms'],
//            suspended: userData['suspended']);
//        fetchedUserList.add(user);
//      });
//
//      fetchedUserList.sort((User a, User b) => a.firstName.compareTo(b.firstName));
//
//      fetchedUserList.forEach((User user){
//
//        print(user.firstName);
//
//      });
//
//      _users = fetchedUserList;
//      _isLoading = false;
//      notifyListeners();
//      //_selUserKey = null;
//
//    } catch(e){
//      _isLoading = false;
//      notifyListeners();
//      return;
//    }
//  }



  AuthenticatedUser get authenticatedUser {
    return _authenticatedUser;
  }

  PublishSubject<bool> _userSubject = PublishSubject();

  PublishSubject<bool> get userSubject {
    return _userSubject;
  }

  Future<Map<String, dynamic>> addUser() async{
    _isLoading = true;
    notifyListeners();

    String message = 'Something went wrong!';
    bool success = false;

    _isLoading = false;
    notifyListeners();

    return {'success': success, 'message': message};

  }

//  Future<Map<String, dynamic>> addUser(String firstName, String surname, String email, String organisation, String role) async {
//    _isLoading = true;
//    notifyListeners();
//
//    if(firstName.length == 1){
//      firstName = firstName.toUpperCase();
//    } else {
//      firstName = '${firstName[0].toUpperCase()}${firstName.substring(1)}';
//    }
//
//    if(surname.length == 1){
//      surname = surname.toUpperCase();
//    } else {
//      surname = '${surname[0].toUpperCase()}${surname.substring(1)}';
//    }
//
//    final String temporaryPassword = randomAlphaNumeric(10);
//
//    final Map<String, dynamic> authData = {
//      'email': email,
//      'password': temporaryPassword,
//      'returnSecureToken': false
//    };
//
//    String message = 'Something went wrong!';
//    bool hasError = true;
//
//    http.Response response;
//
//    try {
//      response = await http.post(
//        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
//        body: json.encode(authData),
//        headers: {'Content-Type': 'application/json'},
//      );
//
//
//      Map<String, dynamic> responseData = json.decode(response.body);
//
//
//
//
//      if (responseData.containsKey('idToken')) {
//        hasError = false;
//        message = 'authentication succeeded';
//
//        final Map<String, dynamic> userData = {
//          'authenticationId': responseData['localId'],
//          'firstName': firstName,
//          'surname': surname,
//          'organisation': organisation,
//          'role': role,
//          'email': email,
//          'hasTemporaryPassword' : true,
//          'acceptedTerms' : false,
//          'suspended' : false
//        };
//
//
//        final http.Response response = await http.post(
//            'https://incident-reporting-a5394.firebaseio.com/users.json?auth=${_authenticatedUser
//                .token}',
//            body: json.encode(userData));
//
//        if (response.statusCode != 200 && response.statusCode != 201) {
//
//          await http.post(
//            'https://www.googleapis.com/identitytoolkit/v3/relyingparty/deleteAccount?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
//            body: json.encode({'idToken' : responseData['localId']}),
//            headers: {'Content-Type': 'application/json'},
//          );
//          _isLoading = false;
//          notifyListeners();
//          hasError = true;
//          message = 'something went wrong';
//        }
//
//        final User newUser = User(
//            authenticationId: responseData['id'],
//            id: responseData['name'],
//            firstName: firstName,
//            surname: surname,
//            email: email,
//            organisation: organisation,
//            role: role,
//            hasTemporaryPassword: true,
//            acceptedTerms: false,
//            suspended: false
//        );
//        _users.add(newUser);
//        await signUpEmail(temporaryPassword, email, firstName);
//        hasError = false;
//        message = 'user added successfully';
//
//      } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
//        message = 'Email not found';
//      } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
//        message = 'Incorrect password';
//      } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
//        message = 'This email already exists';
//      }
//    } catch(e){
//      _isLoading = false;
//      notifyListeners();
//      return {'success': !hasError, 'message': message};
//
//    }
//
//    print('this is the selected user key');
//
//    print(_selUserKey);
//
//
//    _isLoading = false;
//    notifyListeners();
//    return {'success': !hasError, 'message': message};
//
//  }

//  Future<Map<String, dynamic>> newPassword(String newPassword) async {
//    _isLoading = true;
//    notifyListeners();
//
//    String idToken = _authenticatedUser.session;
//
//    print(idToken);
//
//
//
//    final Map<String, dynamic> authData = {
//      'idToken': idToken,
//      'password': newPassword,
//      'returnSecureToken': true
//    };
//
//    String message = 'Something went wrong!';
//    bool hasError = true;
//
//    http.Response response;
//
//    try {
//      response = await http.post(
//        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/setAccountInfo?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
//        body: json.encode(authData),
//        headers: {'Content-Type': 'application/json'},
//      );
//
//
//      Map<String, dynamic> responseData = json.decode(response.body);
//
//      print(responseData);
//
//
//
//
//      if (responseData.containsKey('passwordHash')) {
//        hasError = false;
//        message = 'your password has been changed';
//
//        _authenticatedUser = AuthenticatedUser(
//            id: _authenticatedUser.id,
//            email: _authenticatedUser.email,
//            token: responseData['idToken'],
//            suspended: _authenticatedUser.suspended,
//            acceptedTerms: _authenticatedUser.acceptedTerms,
//            hasTemporaryPassword: false,
//            organisationId: 1,
//            organisationName: _authenticatedUser.organisationName,
//            surname: _authenticatedUser.surname,
//            firstName: _authenticatedUser.firstName,
//            role: _authenticatedUser.role,
//            authenticationId: _authenticatedUser.authenticationId);
//
//
//
//
//
//        setAuthTimeout(int.parse(responseData['expiresIn']));
//        //_userSubject.add(true);
//
//        final DateTime now = DateTime.now();
//        print('this is the time currently now' + now.toIso8601String());
//
//        final DateTime expiryTime =
//        now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
//        print('this is the expiry time at the point of logging in' +
//            expiryTime.toIso8601String());
//
//        final SharedPreferences prefs = await SharedPreferences
//            .getInstance();
//        prefs.setString('id', _authenticatedUser.id);
//        prefs.setString('email', _authenticatedUser.email);
//        prefs.setString('token', _authenticatedUser.token);
//        prefs.setBool('suspended', _authenticatedUser.suspended);
//        prefs.setBool('acceptedTerms', _authenticatedUser.acceptedTerms);
//        prefs.setBool('hasTemporaryPassword', _authenticatedUser.hasTemporaryPassword);
//        prefs.setString('organisation', _authenticatedUser.organisationName);
//        prefs.setString('surname', _authenticatedUser.firstName);
//        prefs.setString('firstName', _authenticatedUser.surname);
//        prefs.setString('role', _authenticatedUser.role);
//        prefs.setString('authenticationId', _authenticatedUser.authenticationId);
//        prefs.setString('expiryTime', expiryTime.toIso8601String());
//
//
//
//      } else if (responseData['error']['message'] == 'CREDENTIAL_TOO_OLD_LOGIN_AGAIN') {
//        message = 'Your session has expired please login again with your temporary password';
//      }
//    } catch(e){
//
//      print(e);
//
//    }
//
//    print('this is the selected user key');
//
//    print(_selUserKey);
//
//
//    _isLoading = false;
//    notifyListeners();
//
//    final Map<String, dynamic> updateData = {
//      'authenticationId': _authenticatedUser.authenticationId,
//      'firstName': _authenticatedUser.firstName,
//      'surname': _authenticatedUser.surname,
//      'organisation': _authenticatedUser.organisationName,
//      'role': _authenticatedUser.role,
//      'email': _authenticatedUser.email,
//      'hasTemporaryPassword' : false,
//      'acceptedTerms' : _authenticatedUser.acceptedTerms,
//      'suspended' : _authenticatedUser.suspended
//    };
//    try {
//      await FirebaseDatabase.instance.reference().child('users').child(_authenticatedUser.id).update(updateData);
//    } catch(e) {
//      print(e);
//    }
//    return {'success': !hasError, 'message': message};
//
//  }

//  Future<bool> acceptTerms() async {
//    _isLoading = true;
//    notifyListeners();
//
//    bool successful = false;
//
//    final Map<String, dynamic> updateData = {
//      'authenticationId': _authenticatedUser.authenticationId,
//      'firstName': _authenticatedUser.firstName,
//      'surname': _authenticatedUser.surname,
//      'organisation': _authenticatedUser.organisationName,
//      'role': _authenticatedUser.role,
//      'email': _authenticatedUser.email,
//      'hasTemporaryPassword' : _authenticatedUser.hasTemporaryPassword,
//      'acceptedTerms' : true,
//      'suspended' : _authenticatedUser.suspended
//    };
//
//    try {
//      await FirebaseDatabase.instance.reference().child('users').child(_authenticatedUser.id).update(updateData);
//      successful = true;
//      _authenticatedUser.acceptedTerms = true;
//      final SharedPreferences prefs = await SharedPreferences
//          .getInstance();
//      prefs.setBool('acceptedTerms', true);
//
//    } catch(e) {
//      successful = false;
//      print(e);
//    }
//
//
//    _isLoading = false;
//    notifyListeners();
//    return successful;
//
//  }

//  Future<Map<String, dynamic>>suspendResumeUser(String userKey, bool suspended) async {
//
//    bool hasError = true;
//    String message = 'Something went wrong';
//
//    try {
//      await FirebaseDatabase.instance.reference().child('users').child(userKey).update({'suspended': !suspended});
//    } catch(e) {
//      print(e);
//      return {'success' : hasError, 'message' : message};
//    }
//
//    if(!suspended == true) {
//      message = 'User has been suspended';
//    } else {
//      message = 'User has been resumed';
//    }
//
//    return {'success' : !hasError, 'message' : message};
//  }

//  Future<Map<String, dynamic>>voidUnvoidIncident(String incidentKey, bool voided) async {
//
//    bool hasError = true;
//    String message = 'Something went wrong';
//
//    try {
//      await FirebaseDatabase.instance.reference().child('incidents').child(incidentKey).update({'voided': !voided});
//    } catch(e) {
//      print(e);
//      return {'success' : hasError, 'message' : message};
//    }
//
//    if(!voided == true) {
//      message = 'Incident has been voided';
//    } else {
//      message = 'Incident has been unvoided';
//    }
//
//    return {'success' : !hasError, 'message' : message};
//  }

//  Future<Map<String, dynamic>>editUser(User user, String firstName, String surname, String email, String organisation, String role) async {
//
//    _isLoading = true;
//    notifyListeners();
//
//    bool hasError = true;
//    String message = 'Something went wrong';
//
//    final Map<String, dynamic> updateData = {
//      'authenticationId': user.authenticationId,
//      'firstName': firstName,
//      'surname': surname,
//      'organisation': organisation,
//      'role': role,
//      'email': email,
//      'hasTemporaryPassword' : user.hasTemporaryPassword,
//      'acceptedTerms' : user.acceptedTerms,
//      'suspended' : user.suspended
//    };
//
//    print('its got here before the fail');
//
//
//    try {
//      await FirebaseDatabase.instance.reference().child('users').child(user.id).update(updateData);
//      message = 'User has been edited';
//      hasError = false;
//    } catch(e) {
//      print(e);
//    }
//
//
//
//    _isLoading = false;
//    notifyListeners();
//    return {'success' : !hasError, 'message' : message};
//  }

  Future signUpEmail(String temporaryPassword String email, String firstName) async {


  final smtpServer = hotmail('callum.clift@on-trac.co.uk', 'jhjhjhj');

  final message = new Message()
  ..from = new Address('callum.clift@on-trac.co.uk', 'Accounts')
  ..recipients.add(email)
  ..subject = 'You have been registered as a user on Callums app'
  ..text = 'This is the plain text.\nThis is line 2 of the text part.'
  ..html = "<p>Dear "+ firstName +",</p>\n<p>You have been registered as a user on Callums app.</p>\n"
  "<p>Please login using your email and temporary password below, please be sure to change the temporary password after you have logged in for the first time</p>\n"
  "<p>Temporary password: "+ temporaryPassword +"</p>";

  await send(message, smtpServer);

  }

  Future<Map<String, dynamic>> login(String username, String password, bool rememberMe) async {

    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('before shared prefs');
    String test = prefs.get('firstName');
    print(test);
    print('ok after test');


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
            serverUrl + 'login', authData, false);

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
            print(serverResponse);

            cookie = serverResponse['response']['session'];


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
            //Organisation Name
            String encryptedOrganisationName = GlobalFunctions.encryptString(
                authenticatedUser.organisationName);
            //Session
            String encryptedSession = GlobalFunctions.encryptString(
                authenticatedUser.session);
            //Date terms accepted
            String encryptedTermsAccepted = GlobalFunctions.encryptString(
                authenticatedUser.termsAccepted);


            if (existingUser == 0) {
              Map<String, dynamic> userData = {
                'user_id': _authenticatedUser.userId,
                'first_name': encryptedFirstName,
                'last_name': encryptedLastName,
                'username': encryptedUsername,
                'password': encryptedPassword,
                'suspended': _authenticatedUser.suspended,
                'organisation_id': _authenticatedUser.organisationId,
                'organisation_name': encryptedOrganisationName,
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
                prefs.setString('organisationName', encryptedOrganisationName);
                prefs.setString('session', encryptedSession);
                prefs.setBool('deleted', _authenticatedUser.deleted);
                prefs.setBool('isClientAdmin', _authenticatedUser.isClientAdmin);
                prefs.setBool('isSuperAdmin', _authenticatedUser.isSuperAdmin);
                prefs.setString('termsAccepted', encryptedTermsAccepted);
                prefs.setBool('forcePasswordReset',
                    _authenticatedUser.forcePasswordReset);
                prefs.setBool('rememberMe', rememberMe);
                prefs.setBool('darkMode', false);
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
                'organisation_name': encryptedOrganisationName,
                'session': encryptedSession,
                'deleted': _authenticatedUser.deleted,
                'is_client_admin': _authenticatedUser.isClientAdmin,
                'is_super_admin': _authenticatedUser.isSuperAdmin,
                'terms_accepted': _authenticatedUser.termsAccepted,
                'force_password_reset': _authenticatedUser.forcePasswordReset,
              };

              int updatedUser = await databaseHelper.updateUser1(userData);
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
                prefs.setString('organisationName', encryptedOrganisationName);
                prefs.setString('session', encryptedSession);
                prefs.setBool('deleted', _authenticatedUser.deleted);
                prefs.setBool('isClientAdmin', _authenticatedUser.isClientAdmin);
                prefs.setBool('isSuperAdmin', _authenticatedUser.isSuperAdmin);
                prefs.setString('termsAccepted', encryptedTermsAccepted);
                prefs.setBool('forcePasswordReset',
                    _authenticatedUser.forcePasswordReset);
                prefs.setBool('rememberMe', rememberMe);
                prefs.setBool('darkMode', darkMode);
              }
            }

            success = true;
          } else {
            message = 'no valid session found';
          }

        }
      }


    } catch(error){
      print(error);
      message = 'Something went wrong';
    }

    //final List<IncidentType> fetchedIncidentTypeList = [];

//      Map<String, dynamic> serverResponse1 = await GlobalFunctions.apiRequest(
//          serverUrl + 'getTestCustomFields', authData);
//
//    print(serverResponse1);
//
//    _isLoading = false;
//    notifyListeners();
//
//      print('testing custom fields');
//      List<Map<String, dynamic>> testList = (serverResponse1['fields']);
//      testList.forEach((Map<String, dynamic> map){
//        print(map['label']);
//      });
//      print('ok im done');

//    Map<String, dynamic> testing = {
//      'incidentData': {'type': 'Incident', 'incident_date': '2019-01-01 12:00:00', 'latitude' : '54.9517560000000000',
//        'longitude' : '-1.5937100000000000', 'project_name' : 'Test Project 2', 'route': 'London North East', 'elr': 'ECM1',
//        'mileage' : '1-10 miles', 'summary' : 'this is a test of the summary 222', 'custom_fields' : null, 'anonymous': false, 'images': null},
//    };
//
//    Map<String, dynamic> serverResponse1 = await GlobalFunctions.apiRequest(
//        serverUrl + 'saveIncident', testing);
//
//    print(serverResponse1);



    _userSubject.add(true);
    _isLoading = false;
    notifyListeners();

    return {'success': success, 'message': message};
  }


    autoLogin(SharedPreferences prefs){
    print('entring auto login');
    final bool rememberMe = prefs.getBool('rememberMe');
    print('this is remember me');
    print(rememberMe);

    if(rememberMe != null){

      _authenticatedUser = AuthenticatedUser(
          userId: prefs.getInt('userId'),
          firstName: GlobalFunctions.decryptString(prefs.get('firstName')),
          lastName: GlobalFunctions.decryptString(prefs.get('lastName')),
          username: GlobalFunctions.decryptString(prefs.get('username')),
          password: GlobalFunctions.decryptString(prefs.get('password')),
          suspended: prefs.getBool('suspended'),
          organisationId: prefs.getInt('organisationId'),
          organisationName: GlobalFunctions.decryptString(prefs.get('organisationName')),
          session: GlobalFunctions.decryptString(prefs.get('session')),
          deleted: prefs.getBool('deleted'),
          isClientAdmin: prefs.getBool('isClientAdmin'),
          isSuperAdmin: prefs.getBool('isSuperAdmin'),
          termsAccepted: GlobalFunctions.decryptString(prefs.get('termsAccepted')),
          forcePasswordReset: prefs.getBool('forcePasswordReset'));

      notifyListeners();

    }
  }




//  Future<Map<String, dynamic>> login(String email, String password) async {
//    _isLoading = true;
//    notifyListeners();
//    final Map<String, dynamic> authData = {
//      'email': email,
//      'password': password,
//      'returnSecureToken': true
//    };
//
//    http.Response response;
//    response = await http.post(
//      'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
//      body: json.encode(authData),
//      headers: {'Content-Type': 'application/json'},);
//
//    Map<String, dynamic> responseData = json.decode(response.body);
//
//    bool hasError = true;
//    String message = 'Something went wrong!';
//
//    Map<String, dynamic> userData;
//    if (responseData.containsKey('idToken')) {
//      message = 'authentication succeeded';
//
//      DataSnapshot snapshot;
//
//      snapshot = await FirebaseDatabase.instance
//          .reference().child('users').orderByChild('email')
//          .equalTo(email)
//          .once();
//
//      print('this is the snapshot');
//      print(snapshot);
//
//
//      userData = new Map.from(snapshot.value);
//
//      userData.forEach((String key, dynamic value) {
//        print(key);
//        print(value['firstName']);
//        _authenticatedUser = AuthenticatedUser(
//            id: key,
//            email: email,
//            token: responseData['idToken'],
//            suspended: value['suspended'],
//            acceptedTerms: value['acceptedTerms'],
//            hasTemporaryPassword: value['hasTemporaryPassword'],
//            organisationId: 1,
//            organisationName: value['organisation'],
//            surname: value['surname'],
//            firstName: value['firstName'],
//            role: value['role'],
//            authenticationId: value['authenticationId']);
//
//        print('should not print this till after snapshot');
//      });
//      //this will trigger the listener in the main.dart for isAuthenticated
//      if (_authenticatedUser.suspended == true) {
//        print('at least it got here');
//        message = 'your account has been suspended please contact your system admin';
//      } else {
//        hasError = false;
//        setAuthTimeout(int.parse(responseData['expiresIn']));
//        _userSubject.add(true);
//
//        final DateTime now = DateTime.now();
//        print('this is the time currently now' + now.toIso8601String());
//
//        final DateTime expiryTime =
//        now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
//        print('this is the expiry time at the point of logging in' +
//            expiryTime.toIso8601String());
//
//        final SharedPreferences prefs = await SharedPreferences
//            .getInstance();
//        prefs.setString('id', _authenticatedUser.id);
//        prefs.setString('email', _authenticatedUser.email);
//        prefs.setString('token', _authenticatedUser.token);
//        prefs.setBool('suspended', _authenticatedUser.suspended);
//        prefs.setBool('acceptedTerms', _authenticatedUser.acceptedTerms);
//        prefs.setBool('hasTemporaryPassword', _authenticatedUser.hasTemporaryPassword);
//        prefs.setString('organisation', _authenticatedUser.organisationName);
//        prefs.setString('surname', _authenticatedUser.surname);
//        prefs.setString('firstName', _authenticatedUser.firstName);
//        prefs.setString('role', _authenticatedUser.role);
//        prefs.setString('authenticationId', _authenticatedUser.authenticationId);
//        prefs.setString('expiryTime', expiryTime.toIso8601String());
//      }
//    }
//
//    else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
//      message = 'Email not found';
//      //_authenticatedUser = User(id: '1234', email: email, password: password);
//      //print('this is the email:' + currentUser.email);
//
//
//    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
//      message = 'Incorrect password';
//
//    }
//
//    _isLoading = false;
//    notifyListeners();
//    print('ok so its here aswekk');
//    print(message);
//    return {'success': !hasError, 'message': message};
////_authenticatedUser = User(id: '1234', email: email, password: password);
////print('this is the email:' + currentUser.email);
//
//
//
//
//
//
//
//
//
//  }

//  void autoLogin() async {
//    print('entring auto login');
//    final SharedPreferences prefs = await SharedPreferences.getInstance();
//
//    final String token = await prefs.get('token');
//    final String expiryTimeString = prefs.get('expiryTime');
//
//    if (token != null) {
//      final DateTime now = DateTime.now();
//      print('this is the current time: ' + now.toIso8601String());
//      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
//      print('this is the expiry time: ' + parsedExpiryTime.toIso8601String());
//
//      if (parsedExpiryTime.isBefore(now)) {
//        print('yes its passed its expiry timeeeee');
//        _authenticatedUser = null;
//        notifyListeners();
//        return;
//      }
//      print('no it has not passed its expiry timeeeee');
//      final String id = await prefs.get('id');
//      final String email = await prefs.get('email');
//      final bool suspended = await prefs.get('suspended');
//      final bool acceptedTerms = await prefs.get('acceptedTerms');
//      final bool hasTemporaryPassword = await prefs.get('hasTemporaryPassword');
//      final String organisation = await prefs.get('organisation');
//      final String surname = await prefs.get('surname');
//      final String firstName = await prefs.get('firstName');
//      final String role = await prefs.get('role');
//      final String authenticationId = await prefs.get('authenticationId');
//
//
//      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
//      setAuthTimeout(tokenLifespan);
//      print('this is the new lifespan:' + tokenLifespan.toString());
//
//      _authenticatedUser = _authenticatedUser = AuthenticatedUser(
//          id: id,
//          email: email,
//          token: token,
//          suspended: suspended,
//          acceptedTerms: acceptedTerms,
//          hasTemporaryPassword: hasTemporaryPassword,
//          organisationId: 1,
//          organisationName: organisation,
//          surname: surname,
//          firstName: firstName,
//          role: role,
//          authenticationId: authenticationId);
//      _userSubject.add(true);
//      notifyListeners();
//    }
//  }

//  Future<Map<String, dynamic>> authenticate(String email, String password,
//      [AuthMode mode = AuthMode.Login]) async {
//    _isLoading = true;
//    notifyListeners();
//    final Map<String, dynamic> authData = {
//      'email': email,
//      'password': password,
//      'returnSecureToken': true
//    };
//
//    http.Response response;
//
//    if (mode == AuthMode.Login) {
//      response = await http.post(
//        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/verifyPassword?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
//        body: json.encode(authData),
//        headers: {'Content-Type': 'application/json'},
//      );
//      //else signUp
//    } else {
//      response = await http.post(
//        'https://www.googleapis.com/identitytoolkit/v3/relyingparty/signupNewUser?key=AIzaSyDGEgZURSQc5zJEv0MbraTJjCY-Nom7MoA',
//        body: json.encode(authData),
//        headers: {'Content-Type': 'application/json'},
//      );
//    }
//
//    Map<String, dynamic> responseData = json.decode(response.body);
//
//    bool hasError = true;
//    String message = 'Something went wrong!';
//
//    if (responseData.containsKey('idToken')) {
//      hasError = false;
//      message = 'authentication succeeded';
//      _authenticatedUser = AuthenticatedUser(
//          id: responseData['localId'],
//          email: email,
//          token: responseData['idToken']);
//      setAuthTimeout(int.parse(responseData['expiresIn']));
//      //this will trigger the listener in the main.dart for isAuthenticated
//      _userSubject.add(true);
//
//      final DateTime now = DateTime.now();
//      print('this is the time currently now' + now.toIso8601String());
//
//      final DateTime expiryTime =
//      now.add(Duration(seconds: int.parse(responseData['expiresIn'])));
//      print('this is the expiry time at the point of logging in' +
//          expiryTime.toIso8601String());
//
//      final SharedPreferences prefs = await SharedPreferences.getInstance();
//      prefs.setString('token', responseData['idToken']);
//      prefs.setString('userEmail', email);
//      prefs.setString('userId', responseData['localId']);
//      prefs.setString('expiryTime', expiryTime.toIso8601String());
//    } else if (responseData['error']['message'] == 'EMAIL_NOT_FOUND') {
//      message = 'Email not found';
//    } else if (responseData['error']['message'] == 'INVALID_PASSWORD') {
//      message = 'Incorrect password';
//    } else if (responseData['error']['message'] == 'EMAIL_EXISTS') {
//      message = 'This email already exists';
//    }
//    _isLoading = false;
//    notifyListeners();
//    return {'success': !hasError, 'message': message};
//    //_authenticatedUser = User(id: '1234', email: email, password: password);
//    //print('this is the email:' + currentUser.email);
//  }

//  void autoAuthenticate() async {
//    print('entering auto authenticate');
//    final SharedPreferences prefs = await SharedPreferences.getInstance();
//
//    final String token = await prefs.get('token');
//    final String expiryTimeString = prefs.get('expiryTime');
//
//    if (token != null) {
//      final DateTime now = DateTime.now();
//      print('this is the current time: ' + now.toIso8601String());
//      final DateTime parsedExpiryTime = DateTime.parse(expiryTimeString);
//      print('this is the expiry time: ' + parsedExpiryTime.toIso8601String());
//
//      if (parsedExpiryTime.isBefore(now)) {
//        print('yes its passed its expiry timeeeee');
//        _authenticatedUser = null;
//        notifyListeners();
//        return;
//      }
//      print('no it has not passed its expiry timeeeee');
//      final String userEmail = await prefs.get('userEmail');
//      final String userId = await prefs.get('userId');
//
//      final int tokenLifespan = parsedExpiryTime.difference(now).inSeconds;
//      setAuthTimeout(tokenLifespan);
//      print('this is the new lifespan:' + tokenLifespan.toString());
//
//      _authenticatedUser = AuthenticatedUser(id: userId, email: userEmail, token: token);
//      _userSubject.add(true);
//      notifyListeners();
//    }
//  }

   void logout() async {
    print('logout happened');
    _selUserKey = null;

    _authenticatedUser = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('userId');
    prefs.remove('firstName');
    prefs.remove('lastName');
    prefs.remove('username');
    prefs.remove('password');
    prefs.remove('suspended');
    prefs.remove('organisationId');
    prefs.remove('organisationName');
    prefs.remove('session');
    prefs.remove('deleted');
    prefs.remove('isAdmin');
    prefs.remove('termsAccepted');
    prefs.remove('forcePasswordReset');
    prefs.remove('darkMode');
    prefs.remove('rememberMe');
  }

  void setAuthTimeout(int time) {
    print('this is the timer left in seconds: ' + time.toString());
    _authTimer = Timer(Duration(seconds: time), logout);
  }



}
