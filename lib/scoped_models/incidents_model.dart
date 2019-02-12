import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:random_string/random_string.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:mailer/smtp_server/hotmail.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:connectivity/connectivity.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../models/authenticated_user.dart';
import '../models/incident.dart';
import '../models/incident_type.dart';
import '../models/location_data.dart';
import '../utils/database_helper.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../scoped_models/users_model.dart';

class IncidentsModel extends Model {
  final UsersModel _usersModel = UsersModel();
  List<Incident> _incidents = [];
  List<Incident> _myIncidents = [];
  List<IncidentType> _incidentTypes = [];
  int _selIncidentKey;
  int _selMyIncidentId;
  int _selIncidentTypeId;
  bool _isLoading = false;
  bool _pendingIncidents = false;

  bool get isLoading {
    return _isLoading;
  }

  bool get pendingIncidents {
    return _pendingIncidents;
  }

  List<Incident> get allIncidents {
    return List.from(_incidents);
  }

  List<Incident> get allMyIncidents {
    return List.from(_myIncidents);
  }

  List<IncidentType> get allIncidentTypes {
    return List.from(_incidentTypes);
  }

  int get selectedIncidentIndex {
    return _incidents.indexWhere((Incident incident) {
      return incident.id == _selIncidentKey;
    });
  }

  int get selectedMyIncidentIndex {
    return _myIncidents.indexWhere((Incident incident) {
      return incident.id == _selMyIncidentId;
    });
  }

  int get selectedIncidentTypeIndex {
    return _incidentTypes.indexWhere((IncidentType incidentType) {
      return incidentType.id == _selIncidentTypeId;
    });
  }

  int get selectedIncidentKey {
    return _selIncidentKey;
  }

  int get selectedMyIncidentId {
    return _selMyIncidentId;
  }

  int get selectedIncidentTypeId {
    return _selIncidentTypeId;
  }

  Incident get selectedIncident {
    if (_selIncidentKey == null) {
      return null;
    }
    return _incidents.firstWhere((Incident incident) {
      return incident.id == _selIncidentKey;
    });
  }

  Incident get selectedMyIncident {
    if (_selMyIncidentId == null) {
      return null;
    }
    return _myIncidents.firstWhere((Incident incident) {
      return incident.incidentId == _selMyIncidentId;
    });
  }

  IncidentType get selectedIncidentType {
    if (_selIncidentTypeId == null) {
      return null;
    }
    return _incidentTypes.firstWhere((IncidentType incidentType) {
      return incidentType.id == _selIncidentTypeId;
    });
  }

  void selectIncident(int incidentKey) {
    _selIncidentKey = incidentKey;
    if (incidentKey != null) {
      notifyListeners();
    }
  }

  void selectMyIncident(int incidentId) {
    _selMyIncidentId = incidentId;
    if (incidentId != null) {
      notifyListeners();
    }
  }

  void selectIncidentType(int incidentTypeId) {
    _selIncidentTypeId = incidentTypeId;
    if (incidentTypeId != null) {
      notifyListeners();
    }
  }

  Future<void> testing() async {
    final Map<String, dynamic> requestData = {
      'incidentData': {},
    };

    Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
        serverUrl + 'getCustomIncidents', requestData)
        .timeout(Duration(seconds: 90));

    print(serverResponse);
  }

  Future<Map<String, dynamic>> getCustomIncidents(AuthenticatedUser authenticatedUser) async {
    _isLoading = true;
    notifyListeners();

    bool success = false;
    String message = 'Something went wrong';

    List<IncidentType> _incidentTypeList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();


    try {


      var connectivityResult = await (new Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {

        List<Map<String, dynamic>> _databaseIncidentTypes = await databaseHelper.getIncidentTypes(authenticatedUser.organisationId);

        for(Map<String, dynamic> databaseIncidentType in _databaseIncidentTypes){

          final IncidentType incidentType = IncidentType(
            id: databaseIncidentType['incident_type_id'],
            localId: databaseIncidentType['id'],
            userId: databaseIncidentType['user_id'],
            username: databaseIncidentType['username'],
            organisationId: databaseIncidentType['organisation_id'],
            organisationName: databaseIncidentType['organisation_name'],
            name: databaseIncidentType['name'],
            customLabel1: databaseIncidentType['custom_label1'] == null || databaseIncidentType['custom_label1'] == 'null' ? null : databaseIncidentType['custom_label1'],
            customLabel2: databaseIncidentType['custom_label2'] == null || databaseIncidentType['custom_label2'] == 'null' ? null : databaseIncidentType['custom_label2'],
            customLabel3: databaseIncidentType['custom_label3'] == null || databaseIncidentType['custom_label3'] == 'null' ? null : databaseIncidentType['custom_label3'],
            customPlaceholder1: databaseIncidentType['custom_placeholder1'] == null || databaseIncidentType['custom_placeholder1'] == 'null' ? null : databaseIncidentType['custom_placeholder1'],
            customPlaceholder2: databaseIncidentType['custom_placeholder2'] == null || databaseIncidentType['custom_placeholder2'] == 'null' ? null : databaseIncidentType['custom_placeholder2'],
            customPlaceholder3: databaseIncidentType['custom_placeholder3'] == null || databaseIncidentType['custom_placeholder3'] == 'null' ? null : databaseIncidentType['custom_placeholder3'],
          );
          print('ok about to add');
          _incidentTypeList.add(incidentType);




        }

        _incidentTypes = _incidentTypeList;


        message = 'No data connection, unable to fetch latest Incidents';
      } else {
        print('this is the cookie');
        print(cookie);

        //Make the POST request to the server
        final Map<String, dynamic> requestData = {
          'incidentData': {},
        };

        //Check the expiry time on the cookie before making the request
        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        Map<String, dynamic> renewSession = {};

        if (isCookieExpired) {
          renewSession = await _usersModel.renewSession(
              authenticatedUser.username,
              authenticatedUser.password);
          print('this is the renew session message');
          print(renewSession['message']);
          message = renewSession['message'];
        }

        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'getCustomIncidents', requestData)
            .timeout(Duration(seconds: 90));
        print('this is the cookie');
        print(cookie);
        print('server response:');
        print(serverResponse);
        print('done with server response');

        if (serverResponse != null) {
          print('its inside the server response');
          if (serverResponse['error'] != null &&
              serverResponse['error'] == 'incorrect_details') {
            message = 'Incorrect username or password given';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Token missing or invalid') {
            message = 'token missing or invalied';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Access Denied.') {
            print('its in access denied, trying to renew the session');

            Map<String, dynamic> renewSession = await _usersModel.renewSession(
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
          } else if (serverResponse['response']['custom_incidents'] != null) {
            List<
                dynamic> incidentTypes = serverResponse['response']['custom_incidents'];
            print('ok herrrreeee');
            print(incidentTypes);



            for (Map<String, dynamic> incidentTypeData in incidentTypes) {
              print('the start of the for' +
                  incidentTypeData['CustomIncidents']['id']);

              int count = await databaseHelper.getIncidentCount();
              int id;

              if (count == 0) {
                id = 1;
              } else {
                id = count + 1;
              }

              int customFieldCount = incidentTypeData['CustomIncidents']['custom_fields']
                  .length;


              final IncidentType incidentType = IncidentType(
                id: int.parse(incidentTypeData['CustomIncidents']['id']),
                localId: id,
                userId: int.parse(
                    incidentTypeData['CustomIncidents']['user_id']),
                username: incidentTypeData['User']['email'],
                organisationId: int.parse(
                    incidentTypeData['CustomIncidents']['organisation_id']),
                organisationName: incidentTypeData['Organisation']['name'],
                name: incidentTypeData['CustomIncidents']['name'],
                customLabel1: customFieldCount == 0
                    ? null
                    : incidentTypeData['CustomIncidents']['custom_fields'][0]['label'],
                customLabel2: customFieldCount < 2
                    ? null
                    : incidentTypeData['CustomIncidents']['custom_fields'][1]['label'],
                customLabel3: customFieldCount < 3
                    ? null
                    : incidentTypeData['CustomIncidents']['custom_fields'][2]['label'],
                customPlaceholder1: customFieldCount == 0
                    ? null
                    : incidentTypeData['CustomIncidents']['custom_fields'][0]['placeholder'],
                customPlaceholder2: customFieldCount < 2
                    ? null
                    : incidentTypeData['CustomIncidents']['custom_fields'][1]['placeholder'],
                customPlaceholder3: customFieldCount < 3
                    ? null
                    : incidentTypeData['CustomIncidents']['custom_fields'][2]['placeholder'],
              );
              print('ok about to add');
              _incidentTypeList.add(incidentType);

              int incidentExists = await databaseHelper.checkIncidentTypeExists(
                  int.parse(incidentTypeData['CustomIncidents']['id']));

              if (incidentExists == 0) {
                print('hi');
                print(incidentType.customLabel1);
                print(incidentType.customLabel2);
                print(incidentType.customLabel3);
                Map<String, dynamic> databaseData = {
                  'incident_type_id': incidentType.id,
                  'user_id': incidentType.userId,
                  'username': incidentType.username,
                  'organisation_id': incidentType.organisationId,
                  'organisation_name': incidentType.organisationName,
                  'name': incidentType.name,
                  'custom_label1': incidentType.customLabel1,
                  'custom_label2': incidentType.customLabel2,
                  'custom_label3': incidentType.customLabel3,
                  'custom_placeholder1': incidentType.customPlaceholder1,
                  'custom_placeholder2': incidentType.customPlaceholder2,
                  'custom_placeholder3': incidentType.customPlaceholder3,
                  'server_uploaded': true,
                };

                int result = await databaseHelper.addIncidentType(databaseData);

                if (result != 0) {
                  message = 'Incident Type not added to local database';
                }
              }

              if (incidentExists == 1) {
                print('hi');
                print(incidentType.customLabel1);
                print(incidentType.customLabel2);
                print(incidentType.customLabel3);
                Map<String, dynamic> databaseData = {
                  'incident_type_id': incidentType.id,
                  'user_id': incidentType.userId,
                  'username': incidentType.username,
                  'organisation_id': incidentType.organisationId,
                  'organisation_name': incidentType.organisationName,
                  'name': incidentType.name,
                  'custom_label1': incidentType.customLabel1,
                  'custom_label2': incidentType.customLabel2,
                  'custom_label3': incidentType.customLabel3,
                  'custom_placeholder1': incidentType.customPlaceholder1,
                  'custom_placeholder2': incidentType.customPlaceholder2,
                  'custom_placeholder3': incidentType.customPlaceholder3,
                  'server_uploaded': true,
                };

                int result = await databaseHelper.updateIncidentType(databaseData);

                if (result != 0) {
                  message = 'Incident Type not added to local database';
                }
              }
            }
            success = true;
            message = 'waheyyyyy';
            _incidentTypes = _incidentTypeList;
          }
        } else {
          message = 'no valid session found';
        }
      }
    } on TimeoutException catch (_) {
      List<Map<String, dynamic>> _databaseIncidentTypes = await databaseHelper.getIncidentTypes(authenticatedUser.organisationId);

      for(Map<String, dynamic> databaseIncidentType in _databaseIncidentTypes){

        final IncidentType incidentType = IncidentType(
          id: databaseIncidentType['incident_type_id'],
          localId: databaseIncidentType['id'],
          userId: databaseIncidentType['user_id'],
          username: databaseIncidentType['username'],
          organisationId: databaseIncidentType['organisation_id'],
          organisationName: databaseIncidentType['organisation_name'],
          name: databaseIncidentType['name'],
          customLabel1: databaseIncidentType['custom_label1'] == null || databaseIncidentType['custom_label1'] == 'null' ? null : databaseIncidentType['custom_label1'],
          customLabel2: databaseIncidentType['custom_label2'] == null || databaseIncidentType['custom_label2'] == 'null' ? null : databaseIncidentType['custom_label2'],
          customLabel3: databaseIncidentType['custom_label3'] == null || databaseIncidentType['custom_label3'] == 'null' ? null : databaseIncidentType['custom_label3'],
          customPlaceholder1: databaseIncidentType['custom_placeholder1'] == null || databaseIncidentType['custom_placeholder1'] == 'null' ? null : databaseIncidentType['custom_placeholder1'],
          customPlaceholder2: databaseIncidentType['custom_placeholder2'] == null || databaseIncidentType['custom_placeholder2'] == 'null' ? null : databaseIncidentType['custom_placeholder2'],
          customPlaceholder3: databaseIncidentType['custom_placeholder3'] == null || databaseIncidentType['custom_placeholder3'] == 'null' ? null : databaseIncidentType['custom_placeholder3'],
        );
        print('ok about to add');
        _incidentTypeList.add(incidentType);




      }

      _incidentTypes = _incidentTypeList;
      message = 'Request timeout, unable to fetch latest incident Types';
      // A timeout occurred.
    } catch (error) {
      print(error);
      message = 'Unable to fetch latest incident types';
    }

    print(_myIncidents);
    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

  Future<Map<String, dynamic>> getIncidents(AuthenticatedUser authenticatedUser) async {
    _isLoading = true;
    notifyListeners();

    bool success = false;
    String message = 'Something went wrong';

    List<Incident> _incidentList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();


    try {
      var connectivityResult = await (new Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {

        int localIncidentCount;

        if(authenticatedUser.isClientAdmin){

          localIncidentCount = await databaseHelper.checkLocalIncidentCountClientAdmin(authenticatedUser.organisationId);
        } else if(authenticatedUser.isSuperAdmin){
          localIncidentCount = await databaseHelper.checkLocalIncidentCountSuperAdmin();
        } else {
          localIncidentCount = await databaseHelper.checkLocalIncidentCount(authenticatedUser.userId);
        }


        if (localIncidentCount > 0) {

          List<Map<String, dynamic>> localIncidents = [];

          if(authenticatedUser.isClientAdmin){

            localIncidents = await databaseHelper.getIncidentsClientAdmin(authenticatedUser.organisationId);
          } else if(authenticatedUser.isSuperAdmin){
            localIncidents = await databaseHelper.getIncidentsSuperAdmin();
          } else {
            localIncidents = await databaseHelper.getIncidents(authenticatedUser.userId);
          }


          if(localIncidents.length >0){

            for (Map<String, dynamic> localIncident in localIncidents) {
              print('its inside the locals');
              print('printing value');
              print(localIncident['anonymous']);

              bool anonymousLocal = false;

              if (localIncident['anonymous'] != null &&
                  localIncident['anonymous'] != 'null') {
                if (localIncident['anonymous'] == 1) {
                  anonymousLocal = true;
                }
              }

              List<dynamic> decodedCustomFields = [];
              List<Map<String, dynamic>> customFields = [];

              if (localIncident['custom_fields'] != null) {
                print('before decoding');
                print(localIncident['custom_fields']);
                decodedCustomFields = jsonDecode(localIncident['custom_fields']);
                print('after decoding');

                for (dynamic custom in decodedCustomFields) {
                  print('inside the custom loop');

                  customFields.add(custom);
                }
              }

              final Incident incident = Incident(
                  id: localIncident['id'],
                  incidentId: localIncident['incident_id'] == null ||
                      localIncident['incident_id'] == 'null'
                      ? null
                      : localIncident['incident_id'],
                  userId: localIncident['user_id'] == null ||
                      localIncident['user_id'] == 'null'
                      ? null
                      : localIncident['user_id'],
                  type: localIncident['type'],
                  fullName: localIncident['fullname'] == null ||
                      localIncident['fullname'] == 'null' ? null : GlobalFunctions
                      .decryptString(localIncident['fullname']),
                  username: localIncident['username'] == null ||
                      localIncident['username'] == 'null' ? null : GlobalFunctions
                      .decryptString(localIncident['username']),
                  email: null,
                  incidentDate: localIncident['incident_date'] == null ||
                      localIncident['incident_date'] == 'null'
                      ? null
                      : localIncident['incident_date'],
                  created: localIncident['created'] == null ||
                      localIncident['created'] == 'null'
                      ? null
                      : localIncident['created'],
                  latitude: localIncident['latitude'] == null ||
                      localIncident['latitude'] == 'null' ? null : double.parse(
                      localIncident['latitude']),
                  longitude: localIncident['longitude'] == null ||
                      localIncident['longitude'] == 'null' ? null : double.parse(
                      localIncident['longitude']),
                  postcode: localIncident['postcode'] == null ||
                      localIncident['postcode'] == 'null'
                      ? null
                      : localIncident['postcode'],
                  projectName: localIncident['project_name'] == null ||
                      localIncident['project_name'] == 'null'
                      ? null
                      : localIncident['project_name'],
                  route: localIncident['route'] == null ||
                      localIncident['route'] == 'null'
                      ? null
                      : localIncident['route'],
                  elr: localIncident['elr'] == null ||
                      localIncident['elr'] == 'null' ? null : localIncident['elr'],
                  mileage: localIncident['mileage'] == null ||
                      localIncident['mileage'] == 'null'
                      ? null
                      : localIncident['mileage'],
                  summary: localIncident['summary'] == null ||
                      localIncident['summary'] == 'null' ? null : GlobalFunctions
                      .decryptString(localIncident['summary']),
                  images: null,
                  organisationId: localIncident['organisation_id'] == null ||
                      localIncident['organisation_id'] == 'null'
                      ? null
                      : localIncident['organisation_id'],
                  organisationName: localIncident['organisation_name'] == null ||
                      localIncident['organisation_name'] == 'null'
                      ? null
                      : localIncident['organisation_name'],
                  customFields: localIncident['custom_fields'] == null ||
                      localIncident['custom_fields'] == 'null'
                      ? null
                      : customFields,
                  anonymous: localIncident['anonymous'] == null ||
                      localIncident['anonymous'] == 'null' ? null : anonymousLocal);
              print('ok about to add');
              _incidentList.add(incident);
            }
            _myIncidents = _incidentList;

            message = 'No data connection, unable to fetch latest Incidents';
            success = true;

          }

      } else {
          message = 'No incidents available';
          success = true;
        }
      } else {
        print('this is the cookie');
        print(cookie);

        //Make the POST request to the server
        final Map<String, dynamic> requestData = {
          'incidentData': {},
        };

        //Check the expiry time on the cookie before making the request
        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        Map<String, dynamic> renewSession = {};

        if (isCookieExpired) {
          renewSession = await _usersModel.renewSession(
              authenticatedUser.username,
              authenticatedUser.password);
          print('this is the renew session message');
          print(renewSession['message']);
          message = renewSession['message'];
        }

        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'getIncidents', requestData)
            .timeout(Duration(seconds: 90));
        print('this is the cookie');
        print(cookie);
        print('server response:');
        print(serverResponse);
        print('done with server response');

        if (serverResponse != null) {
          print('its inside the server response');
          if (serverResponse['error'] != null &&
              serverResponse['error'] == 'incorrect_details') {
            message = 'Incorrect username or password given';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Token missing or invalid') {
            message = 'token missing or invalied';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Access Denied.') {
            print('its in access denied, trying to renew the session');

            Map<String, dynamic> renewSession = await _usersModel.renewSession(
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
          } else if (serverResponse['response']['incidents'] != null) {
            print('its here when it shouldnt be');

            List<dynamic> incidents = serverResponse['response']['incidents'];
            print('ok herrrreeee');
            print(incidents);

            if(incidents.length > 0){
              for (Map<String, dynamic> incidentData in incidents) {
                print('the start of the for' + incidentData['Incidents']['id']);

                List<dynamic> decodedCustomFields = [];
                List<Map<String, dynamic>> customFields = [];

                if(incidentData['Incidents']['custom_fields'] != null){
                  decodedCustomFields = jsonDecode(incidentData['Incidents']['custom_fields']);

                  for(dynamic custom in decodedCustomFields){

                    customFields.add(custom);
                  }
                }

                int count = await databaseHelper.getIncidentCount();
                int id;


                if (count == 0) {
                  id = 1;
                } else {
                  id = count + 1;
                }

                final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
                DateTime dateTime =
                DateTime.parse(incidentData['Incidents']['incident_date']);

                final Incident incident = Incident(
                    id: id,
                    incidentId: int.parse(incidentData['Incidents']['id']),
                    userId: incidentData['Incidents']['user_id'] == null
                        ? null
                        : int.parse(incidentData['Incidents']['user_id']),
                    type: incidentData['Incidents']['type'],
                    fullName: incidentData['0']['fullname'],
                    username: incidentData['User']['email'],
                    email: null,
                    incidentDate: dateFormat.format(dateTime),
                    created: incidentData['Incidents']['created'],
                    latitude: incidentData['Incidents']['latitude'] == null
                        ? null
                        : double.parse(incidentData['Incidents']['latitude']),
                    longitude: incidentData['Incidents']['longitude'] == null
                        ? null
                        :
                    double.parse(incidentData['Incidents']['longitude']),
                    postcode: incidentData['Incidents']['postcode'] == null
                        ? null
                        : incidentData['Incidents']['postcode'],
                    projectName: incidentData['Incidents']['project_name'],
                    route: incidentData['Incidents']['route'],
                    elr: incidentData['Incidents']['elr'],
                    mileage: incidentData['Incidents']['mileage'],
                    summary: incidentData['Incidents']['summary'],
                    images: null,
                    organisationId:
                    int.parse(incidentData['Incidents']['organisation_id']),
                    organisationName: incidentData['Organisation']['name'],
                    customFields: incidentData['Incidents']['custom_fields'] == null? null : customFields,
                    anonymous: incidentData['Incidents']['anonymous']);
                print('ok about to add');
                _incidentList.add(incident);

                int incidentExists = await databaseHelper.checkIncidentExists(
                    int.parse(incidentData['Incidents']['id']));

                if (incidentExists == 0) {
                  //JSON Encode the base 64 images
//
//                List<String> base64Images = [];
//                List<String> encryptedBase64Images = [];
//
//                for (File image in incidentData['Incidents']['images']) {
//                  if (image == null) {
//                    continue;
//                  }
//                  //Convert each image to Base64
//                  List<int> imageBytes =image.readAsBytesSync();
//                  String base64Image = base64Encode(imageBytes);
//                  base64Images.add(base64Image);
//
//                  //Encrypt for the local database
//                  String encryptedBase64 = GlobalFunctions.encryptString(base64Image);
//                  encryptedBase64Images.add(encryptedBase64);
//                }
//
//                //JSON Encode the list of images for storing in the local database
//                var encodedEncryptedImages = jsonEncode(encryptedBase64Images);
//                var encodedImages = jsonEncode(base64Images);

                  Map<String, dynamic> databaseData = {
                    'id': incident.id,
                    'incident_id': incident.incidentId,
                    'user_id': incident.userId,
                    'type': incident.type,
                    'fullname': incident.fullName == null
                        ? incident.fullName
                        : GlobalFunctions.encryptString(incident.fullName),
                    'username': incident.username == null
                        ? incident.username
                        : GlobalFunctions.encryptString(incident.username),
                    'email': incident.email == null
                        ? incident.email
                        : GlobalFunctions.encryptString(incident.email),
                    'incident_date': incident.incidentDate,
                    'created': incident.created,
                    'latitude': incident.latitude,
                    'longitude': incident.longitude,
                    'postcode': incident.postcode,
                    'project_name': incident.projectName,
                    'route': incident.route,
                    'elr': incident.elr,
                    'mileage': incident.mileage,
                    'summary': GlobalFunctions.encryptString(incident.summary),
                    'images': incident.images,
                    'organisation_id': incident.organisationId,
                    'organisation_name': incident.organisationName,
                    'custom_fields': incident.customFields == null? null : incidentData['Incidents']['custom_fields'],
                    'anonymous': incident.anonymous,
                    'server_uploaded': true,
                  };

                  int result = await databaseHelper.addIncident(databaseData);

                  if (result != 0) {
                    message = 'Incident not added to local database';
                  }
                }
              }
              success = true;
              message = 'waheyyyyy';
              _myIncidents = _incidentList;
            } else {
              _myIncidents = [];
              success = true;
              message = 'No incidents available';
            }



          }
        } else {
          message = 'no valid session found';
        }
      }
    } on TimeoutException catch (_) {

      int localIncidentCount;

      if(authenticatedUser.isClientAdmin){

        localIncidentCount = await databaseHelper.checkLocalIncidentCountClientAdmin(authenticatedUser.organisationId);
      } else if(authenticatedUser.isSuperAdmin){
        localIncidentCount = await databaseHelper.checkLocalIncidentCountSuperAdmin();
      } else {
        localIncidentCount = await databaseHelper.checkLocalIncidentCount(authenticatedUser.userId);
      }


      if (localIncidentCount > 0) {

        List<Map<String, dynamic>> localIncidents = [];

        if(authenticatedUser.isClientAdmin){

          localIncidents = await databaseHelper.getIncidentsClientAdmin(authenticatedUser.organisationId);
        } else if(authenticatedUser.isSuperAdmin){
          localIncidents = await databaseHelper.getIncidentsSuperAdmin();
        } else {
          localIncidents = await databaseHelper.getIncidents(authenticatedUser.userId);
        }


        if(localIncidents.length >0){

          for (Map<String, dynamic> localIncident in localIncidents) {
            print('its inside the locals');
            print('printing value');
            print(localIncident['anonymous']);

            bool anonymousLocal = false;

            if (localIncident['anonymous'] != null &&
                localIncident['anonymous'] != 'null') {
              if (localIncident['anonymous'] == 1) {
                anonymousLocal = true;
              }
            }

            List<dynamic> decodedCustomFields = [];
            List<Map<String, dynamic>> customFields = [];

            if (localIncident['custom_fields'] != null) {
              print('before decoding');
              print(localIncident['custom_fields']);
              decodedCustomFields = jsonDecode(localIncident['custom_fields']);
              print('after decoding');

              for (dynamic custom in decodedCustomFields) {
                print('inside the custom loop');

                customFields.add(custom);
              }
            }

            final Incident incident = Incident(
                id: localIncident['id'],
                incidentId: localIncident['incident_id'] == null ||
                    localIncident['incident_id'] == 'null'
                    ? null
                    : localIncident['incident_id'],
                userId: localIncident['user_id'] == null ||
                    localIncident['user_id'] == 'null'
                    ? null
                    : localIncident['user_id'],
                type: localIncident['type'],
                fullName: localIncident['fullname'] == null ||
                    localIncident['fullname'] == 'null' ? null : GlobalFunctions
                    .decryptString(localIncident['fullname']),
                username: localIncident['username'] == null ||
                    localIncident['username'] == 'null' ? null : GlobalFunctions
                    .decryptString(localIncident['username']),
                email: null,
                incidentDate: localIncident['incident_date'] == null ||
                    localIncident['incident_date'] == 'null'
                    ? null
                    : localIncident['incident_date'],
                created: localIncident['created'] == null ||
                    localIncident['created'] == 'null'
                    ? null
                    : localIncident['created'],
                latitude: localIncident['latitude'] == null ||
                    localIncident['latitude'] == 'null' ? null : double.parse(
                    localIncident['latitude']),
                longitude: localIncident['longitude'] == null ||
                    localIncident['longitude'] == 'null' ? null : double.parse(
                    localIncident['longitude']),
                postcode: localIncident['postcode'] == null ||
                    localIncident['postcode'] == 'null'
                    ? null
                    : localIncident['postcode'],
                projectName: localIncident['project_name'] == null ||
                    localIncident['project_name'] == 'null'
                    ? null
                    : localIncident['project_name'],
                route: localIncident['route'] == null ||
                    localIncident['route'] == 'null'
                    ? null
                    : localIncident['route'],
                elr: localIncident['elr'] == null ||
                    localIncident['elr'] == 'null' ? null : localIncident['elr'],
                mileage: localIncident['mileage'] == null ||
                    localIncident['mileage'] == 'null'
                    ? null
                    : localIncident['mileage'],
                summary: localIncident['summary'] == null ||
                    localIncident['summary'] == 'null' ? null : GlobalFunctions
                    .decryptString(localIncident['summary']),
                images: null,
                organisationId: localIncident['organisation_id'] == null ||
                    localIncident['organisation_id'] == 'null'
                    ? null
                    : localIncident['organisation_id'],
                organisationName: localIncident['organisation_name'] == null ||
                    localIncident['organisation_name'] == 'null'
                    ? null
                    : localIncident['organisation_name'],
                customFields: localIncident['custom_fields'] == null ||
                    localIncident['custom_fields'] == 'null'
                    ? null
                    : customFields,
                anonymous: localIncident['anonymous'] == null ||
                    localIncident['anonymous'] == 'null' ? null : anonymousLocal);
            print('ok about to add');
            _incidentList.add(incident);
          }
          _myIncidents = _incidentList;

          message = 'Request timeout, unable to fetch latest Incidents';
          success = true;

        }

      } else {
        message = 'No incidents available';
        success = true;
      }

      // A timeout occurred.
    } catch (error) {
      print(error);
      message = 'Something went wrong';
    }

    print(_myIncidents);
    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

  Future<Map<String, dynamic>> getIncidentImages(AuthenticatedUser authenticatedUser) async {
    _isLoading = true;
    notifyListeners();

    bool success = false;
    String message = 'Something went wrong';

    List<Uint8List> _imagesList = [];
    DatabaseHelper databaseHelper = DatabaseHelper();

    print('inside get incident images');


    try {

      var connectivityResult = await (new Connectivity().checkConnectivity());
      List<Map<String, dynamic>> localIncident = await databaseHelper.getLocalIncident(selectedMyIncident.incidentId);

      if(localIncident.length > 0 && localIncident[0]['images'] != null){
        print('there is a local incident with images');

            List<dynamic> localImages = jsonDecode(localIncident[0]['images']);
            print(localImages);

            if(localImages.length > 0){
              print('its in here');

              for(String localImage in localImages){

                File imageFile = File(localImage);
                List<int> imageBytes = imageFile.readAsBytesSync();
                Uint8List bytes = imageBytes;
                _imagesList.add(bytes);
              }

              if(_imagesList.length > 0){
                selectedMyIncident.images = _imagesList;
                success = true;
              }

            } else {
              print('its in here where it should be');
              message = 'There are no images attached to this incident';
              selectedMyIncident.images = _imagesList;
              success = true;
            }

      }
      else if (connectivityResult == ConnectivityResult.none) {
        print('no connection');

          message = 'No data connection, please try again later';

      } else {
        print('this is the cookie');
        print(cookie);

        //Make the POST request to the server
        final Map<String, dynamic> requestData = {
          'incidentData': {
            'incident_id': selectedMyIncident.incidentId.toString()
          },
        };

        //Check the expiry time on the cookie before making the request
        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        Map<String, dynamic> renewSession = {};

        if (isCookieExpired) {
          renewSession = await _usersModel.renewSession(
              authenticatedUser.username,
              authenticatedUser.password);
          print('this is the renew session message');
          print(renewSession['message']);
          message = renewSession['message'];
        }

        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'getIncidentImages', requestData)
            .timeout(const Duration(seconds: 90));
        print('this is the cookie');
        print(cookie);
        print('server response:');
        print(serverResponse);
        print('done with server response');

        if (serverResponse != null) {
          if (serverResponse['error'] != null &&
              serverResponse['error'] == 'incorrect_details') {
            message = 'Incorrect username or password given';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Token missing or invalid') {
            message = 'token missing or invalied';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Access Denied.') {
            print('its in access denied, trying to renew the session');

            Map<String, dynamic> renewSession = await _usersModel.renewSession(
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
          } else if (serverResponse['response']['incident_images'] != null) {
            List<dynamic> imagesList =
            serverResponse['response']['incident_images'];

            if (imagesList.length != 0) {

              for (Map<String, dynamic> imageData in imagesList) {
                print('its inside the foor loop');

                Uint8List bytes =
                base64Decode(imageData['IncidentImages']['image_data']);

                _imagesList.add(bytes);
              }

              message = 'success';
            } else {
              message = 'There are no images attached to this incident';
            }

            selectedMyIncident.images = _imagesList;
            success = true;

//            success = true;
//            message = 'waheyyyyy';
          }
//
//
        } else {
          message = 'no valid session found';
        }
      }
    } on TimeoutException catch (_) {
      // A timeout occurred.
      message =
      'Network Timeout communicating with the server, unable to load images';
    } catch (error) {
      print(error);
      message = 'Something went wrong';
    }

    //_myIncidents = _incidentList;
    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }


  Future<Map<String, dynamic>> saveIncident({@required bool anonymous,
      @required AuthenticatedUser authenticatedUser,
    @required String type,
    @required String incidentDate,
    @required double latitude,
    @required double longitude,
    @required String postcode,
    @required String projectName,
    @required String route,
    @required String elr,
    @required String mileage,
    @required String summary,
  @required List<File> images,
  @required List<Map<String, dynamic>> customFields,
    @required BuildContext context}) async {
    _isLoading = true;
    _pendingIncidents = true;
    notifyListeners();
    print('listeners notified');

    String message = 'Something went wrong!';
    bool success = false;

    try {
      List<Map<String, dynamic>> base64Images = [];
      var encodedImagePaths;
      var connectivityResult = await (new Connectivity().checkConnectivity());

      DatabaseHelper databaseHelper = DatabaseHelper();

      int count = await databaseHelper.getIncidentCount();
      int id;

      if (count == 0) {
        id = 1;
      } else {
        id = count + 1;
      }

      if (images != null) {

        final Directory extDir = await getApplicationDocumentsDirectory();
        int imageIndex = 0;
        List<String> _imagePaths = [];
        final String dirPath = '${extDir.path}/incidentImages/incident' + id.toString();


        for (File image in images) {

          if (image == null) {
            continue;
          }

          if(connectivityResult != ConnectivityResult.none){

            bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
            String base64Image;
            if(isAndroid){
              base64Image =
              await compute(GlobalFunctions.getBase64Image, image);
              base64Images.add({'image_type': 'jpg', 'image_data': base64Image});
            } else {

              List<int> imageBytes = await GlobalFunctions.compressImageIos(image);
              base64Image =
              await compute(GlobalFunctions.getBase64ImageIos, imageBytes);
              base64Images.add({'image_type': 'jpg', 'image_data': base64Image});

            }
          }

          if(imageIndex == 0) new Directory(dirPath).createSync(recursive: true);


          String path = '$dirPath/image' + imageIndex.toString() + '.jpg';

          File savedImage = image.copySync(path);

          _imagePaths.add(savedImage.path);

          imageIndex ++;
        }

        encodedImagePaths = jsonEncode(_imagePaths);
        print('this is the encoded image paths right herrrreeeeeeeeeeee');
        print(encodedImagePaths);

      }

      Map<String, dynamic> databaseData = {
        'id': id,
        'incident_id': null,
        'user_id': authenticatedUser.userId,
        'type': type,
        'fullname': anonymous == true
            ? null
            : GlobalFunctions.encryptString(
            authenticatedUser.firstName + ' ' + authenticatedUser.lastName),
        'username': anonymous == true
            ? null
            : GlobalFunctions.encryptString(authenticatedUser.username),
        'email': null,
        'incident_date': incidentDate,
        'created': null,
        'latitude': latitude,
        'longitude': longitude,
        'postcode': postcode,
        'project_name': projectName,
        'route': route,
        'elr': elr,
        'mileage': mileage,
        'summary': GlobalFunctions.encryptString(summary),
        'images': images == null ? null : encodedImagePaths,
        'organisation_id': authenticatedUser.organisationId,
        'organisation_name': authenticatedUser.organisationName,
        'custom_fields': null,
        'anonymous': anonymous,
        'server_uploaded': false
      };

      int result = await databaseHelper.addIncident(databaseData);
      print('its added to local');

      if (result != 0) {
        print('Incident has successfully been added to local database');
      }

      if (connectivityResult == ConnectivityResult.none) {
        message = 'No data connection, Incident has been stored locally';
      } else {
        //Check the expiry time on the cookie before making the request
        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        Map<String, dynamic> renewSession = {};

        if (isCookieExpired) {
          renewSession = await _usersModel.renewSession(
              authenticatedUser.username, authenticatedUser.password);
          print('this is the renew session message');
          print(renewSession['message']);
          message = renewSession['message'];
        }

        Map<String, dynamic> incidentData = {
          'incidentData': {
            'type': type,
            'incident_date': incidentDate,
            'latitude': latitude,
            'longitude': longitude,
            'postcode': postcode,
            'project_name': projectName,
            'route': route,
            'elr': elr,
            'mileage': mileage,
            'summary': summary,
            'custom_fields': customFields == null ? null : customFields,
            'anonymous': anonymous,
            'images': base64Images
          }
        };

        //Make the POST request to the server
        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'saveIncident', incidentData)
            .timeout(Duration(seconds: 90));
        print('here is the server response');
        print(serverResponse);

        if (serverResponse != null) {
          print(serverResponse);

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
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Access Denied.') {
            print('its in access denied, trying to renew the session');

            Map<String, dynamic> renewSession = await _usersModel.renewSession(
                authenticatedUser.username,
                authenticatedUser.password);

            message = renewSession['message'];
          } else if (serverResponse['response']['incident_id'] != null) {
            //update the local DB incident with the right id and add the created.

            int updateId = await databaseHelper.updateIncidentId(
                id, int.parse(serverResponse['response']['incident_id']));
            int updatedServerFlag =
            await databaseHelper.updateServerUploaded(id, true);

            if (updateId == 1 && updatedServerFlag == 1) {
              print('local database successfully updated');
            }
            message = 'everything has worked woo';
            success = true;

            //Check for pending Incidents in the local database
            int pendingIncidentsCheck = await databaseHelper
                .checkPendingIncidents(authenticatedUser.userId);
            if (pendingIncidentsCheck == 0) {
              print('ok this check has worked no more pending');
              _pendingIncidents = false;
            }
          } else {
            message = 'no valid session found';
          }
        }
      }
    } on TimeoutException catch (_) {
      message =
      'Unable to save incident on the server, please try again later from pending items';
      // A timeout occurred.
    } catch (error) {
      print(error);
    }

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

  Future<Map<String, dynamic>> addIncidentLocally({@required bool anonymous,
    @required AuthenticatedUser authenticatedUser,
    @required String type,
    @required String incidentDate,
    @required double latitude,
    @required double longitude,
    @required String postcode,
    @required String projectName,
    @required String route,
    @required String elr,
    @required String mileage,
    @required String summary,
    @required List<File> images,
    @required List<Map<String, dynamic>> customFields}) async {
    _isLoading = true;
    _pendingIncidents = true;
    notifyListeners();
    print('listeners notified');

    String message = 'Something went wrong!';
    bool success = false;

    try {
      List<Map<String, dynamic>> base64Images = [];
      List<String> encryptedBase64Images = [];
      var encodedEncryptedImages;
      var encodedImages;
      var connectivityResult = await (new Connectivity().checkConnectivity());

      DatabaseHelper databaseHelper = DatabaseHelper();

      int count = await databaseHelper.getIncidentCount();
      int id;

      if (count == 0) {
        id = 1;
      } else {
        id = count + 1;
      }

      if (images != null) {
        print(images);

        //JSON Encode the base 64 images

        for (File image in images) {
          print('here is image: ');
          print(image);

          print('ok thats the image');
          if (image == null) {
            continue;
          }
          //Convert each image to Base64

          String base64Image =
          await compute(GlobalFunctions.getBase64Image, image);

          base64Images.add({'image_type': 'jpg', 'image_data': base64Image});

          print('its created the map');
          print(base64Images);

          //Encrypt for the local database
//          String encryptedBase64 = await compute(GlobalFunctions.encryptBase64, base64Image);
//          print('here is the encypted base64 image');
//          print(encryptedBase64);
//          encryptedBase64Images.add(encryptedBase64);
//          print('here is the list of the encrypted base64s');
//          print(encryptedBase64Images);
        }

        //JSON Encode the list of images for storing in the local database
        //encodedEncryptedImages = jsonEncode(encryptedBase64Images);
        encodedImages = jsonEncode(base64Images);
        print('here is the json');
        print(encodedImages);
        //var encodedImages = jsonEncode(base64Images);
      }

      //create an instance of the database class
      print('here is anonymoussssssssssssssssssss');
      print(anonymous);


      Map<String, dynamic> incidentData = {
        'incidentData': {
          'type': type,
          'incident_date': incidentDate,
          'latitude': latitude,
          'longitude': longitude,
          'postcode': postcode,
          'project_name': projectName,
          'route': route,
          'elr': elr,
          'mileage': mileage,
          'summary': summary,
          'custom_fields': customFields == null ? null : customFields,
          'anonymous': anonymous,
          'images': base64Images
        }
      };

      Map<String, dynamic> databaseData = {
        'id': id,
        'incident_id': null,
        'user_id': authenticatedUser.userId,
        'type': type,
        'fullname': anonymous == true
            ? null
            : GlobalFunctions.encryptString(
            authenticatedUser.firstName + ' ' + authenticatedUser.lastName),
        'username': anonymous == true
            ? null
            : GlobalFunctions.encryptString(authenticatedUser.username),
        'email': null,
        'incident_date': incidentDate,
        'created': null,
        'latitude': latitude,
        'longitude': longitude,
        'postcode': postcode,
        'project_name': projectName,
        'route': route,
        'elr': elr,
        'mileage': mileage,
        'summary': GlobalFunctions.encryptString(summary),
        'images': images == null ? null : encodedImages,
        'organisation_id': authenticatedUser.organisationId,
        'organisation_name': authenticatedUser.organisationName,
        'custom_fields': null,
        'anonymous': anonymous,
        'server_uploaded': false
      };

      int result = await databaseHelper.addIncident(databaseData);
      print('its added to local');

      if (result != 0) {
        print('Incident has successfully been added to local database');
      }

      if (connectivityResult == ConnectivityResult.none) {
        message = 'No data connection, Incident has been stored locally';
      } else {
        //Check the expiry time on the cookie before making the request
        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        Map<String, dynamic> renewSession = {};

        if (isCookieExpired) {
          renewSession = await _usersModel.renewSession(
              authenticatedUser.username, authenticatedUser.password);
          print('this is the renew session message');
          print(renewSession['message']);
          message = renewSession['message'];
        }

        //Make the POST request to the server
        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'saveIncident', incidentData)
            .timeout(Duration(seconds: 90));
        print('here is the server response');
        print(serverResponse);

        if (serverResponse != null) {
          print(serverResponse);

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
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Access Denied.') {
            print('its in access denied, trying to renew the session');

            Map<String, dynamic> renewSession = await _usersModel.renewSession(
                authenticatedUser.username,
                authenticatedUser.password);

            message = renewSession['message'];
          } else if (serverResponse['response']['incident_id'] != null) {
            //update the local DB incident with the right id and add the created.

            int updateId = await databaseHelper.updateIncidentId(
                id, int.parse(serverResponse['response']['incident_id']));
            int updatedServerFlag =
            await databaseHelper.updateServerUploaded(id, true);

            if (updateId == 1 && updatedServerFlag == 1) {

              databaseHelper.updateLocalIncidentImages(int.parse(serverResponse['response']['incident_id']), null);

              final Directory extDir = await getApplicationDocumentsDirectory();
              int imageIndex = 0;

              List<String> _imagePaths = [];

              for (File image in images) {
                print('inside the images');

                if (image == null) {
                  continue;
                }

                final String dirPath = '${extDir.path}/incidentImages/incident' + serverResponse['response']['incident_id'].toString();

                if(imageIndex == 0) new Directory(dirPath).createSync(recursive: true);


                String path = '$dirPath/image' + imageIndex.toString() + '.jpg';

                File savedImage = image.copySync(path);

                _imagePaths.add(savedImage.path);

                imageIndex ++;
              }

              if(_imagePaths.length > 0){

                var jsonImagePaths = jsonEncode(_imagePaths);
                databaseHelper.updateLocalIncidentImages(int.parse(serverResponse['response']['incident_id']), jsonImagePaths);

                List<Map<String, dynamic>> test = await databaseHelper.getLocalIncident(int.parse(serverResponse['response']['incident_id']));
                print('ok so everything should have workeddddddddd');
                print(test[0]['images']);
              }


              print('local database successfully updated');
            }
            message = 'everything has worked woo';
            success = true;

            //Check for pending Incidents in the local database
            int pendingIncidentsCheck = await databaseHelper
                .checkPendingIncidents(authenticatedUser.userId);
            if (pendingIncidentsCheck == 0) {
              print('ok this check has worked no more pending');
              _pendingIncidents = false;
            }
          } else {
            message = 'no valid session found';
          }
        }
      }
    } on TimeoutException catch (_) {
      message =
      'Unable to save incident on the server, please try again later from pending items';
      // A timeout occurred.
    } catch (error) {
      print(error);
    }

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

  Future<Map<String, dynamic>> uploadPendingIncidents(
      AuthenticatedUser authenticatedUser) async {
    print('this should print second');

    _isLoading = true;
    _pendingIncidents = true;
    notifyListeners();
    print('listeners notified');

    String message = 'Something went wrong!';
    bool success = false;

    var connectivityResult = await (new Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      message = 'No data connection, unable to upload incidents';
    } else {
      try {
        DatabaseHelper databaseHelper = DatabaseHelper();

        List<Map<String, dynamic>> incidents =
        await databaseHelper.getPendingIncidents(authenticatedUser.userId);

        print(incidents);

        for (Map<String, dynamic> incident in incidents) {
          success = false;

          List<Map<String, dynamic>> base64Images = [];
          List<dynamic> decodedDatabaseImages = [];

          if (incident['images'] != null) {
            decodedDatabaseImages = jsonDecode(incident['images']);

            for (Map<String, dynamic> imageData in decodedDatabaseImages) {
              print('its actually in the for loop');

//                String base64Image = await compute(
//                    GlobalFunctions.decryptBase64, image);
              base64Images.add({
                'image_type': imageData['image_type'],
                'image_data': imageData['image_data']
              });
            }

            print('here is the base64 again');
            print(base64Images);
          }

          Map<String, dynamic> incidentData = {
            'incidentData': {
              'type': incident['type'],
              'incident_date': incident['incident_date'],
              'latitude': incident['latitude'],
              'longitude': incident['longitude'],
              'postcode': incident['postcode'],
              'project_name': incident['project_name'],
              'route': incident['route'],
              'elr': incident['elr'],
              'mileage': incident['mileage'],
              'summary': GlobalFunctions.decryptString(incident['summary']),
              'custom_fields': incident['custom_fields'],
              'anonymous': incident['anonymous'],
              'images': base64Images
            }
          };

          //Check the expiry time on the cookie before making the request
          bool isCookieExpired = await GlobalFunctions.isCookieExpired();
          Map<String, dynamic> renewSession = {};

          if (isCookieExpired) {
            renewSession = await _usersModel.renewSession(
                authenticatedUser.username, authenticatedUser.password);
            print('this is the renew session message');
            print(renewSession['message']);
            message = renewSession['message'];
          }

          //Make the POST request to the server
          Map<String, dynamic> serverResponse =
          await GlobalFunctions.apiRequest(
              serverUrl + 'saveIncident', incidentData)
              .timeout(Duration(seconds: 90));
          print('here is the server response');
          print(serverResponse);

          if (serverResponse != null) {
            print(serverResponse);

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
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Access Denied.') {
              print('its in access denied, trying to renew the session');

              Map<String, dynamic> renewSession =
              await _usersModel.renewSession(
                  authenticatedUser.username,
                  authenticatedUser.password);

              message = renewSession['message'];
            } else if (serverResponse['response']['incident_id'] != null) {
              //update the local DB incident with the right id and add the created.

              int updateId = await databaseHelper.updateIncidentId(
                  incident['id'],
                  int.parse(serverResponse['response']['incident_id']));
              int updatedServerFlag = await databaseHelper.updateServerUploaded(
                  incident['id'], true);

              if (updateId == 1 && updatedServerFlag == 1) {
                print('local database successfully updated');
              }
              message = 'everything has worked woo';
              success = true;

              //Check for pending Incidents in the local database
              int pendingIncidentsCheck = await databaseHelper
                  .checkPendingIncidents(authenticatedUser.userId);
              if (pendingIncidentsCheck == 0) {
                print('ok this check has worked no more pending');
                _pendingIncidents = false;
              }
            } else {
              message = 'no valid session found';
            }
          }
        }
      } on TimeoutException catch (_) {
        message =
        'Unable to save incident on the server, please try again later';
        // A timeout occurred.
      } catch (error) {
        print(error);
      }
    }

    if (success) message = 'Incidents Successfully uploaded';

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

  Future<Map<String, dynamic>> uploadPendingIncidents1(
      AuthenticatedUser authenticatedUser, BuildContext context) async {
    print('this should print second');

    _isLoading = true;
    _pendingIncidents = true;
    notifyListeners();
    print('listeners notified');

    String message = 'Something went wrong!';
    bool success = false;

    var connectivityResult = await (new Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      message = 'No data connection, unable to upload incidents';
    } else {
      try {
        DatabaseHelper databaseHelper = DatabaseHelper();

        List<Map<String, dynamic>> incidents =
        await databaseHelper.getPendingIncidents(authenticatedUser.userId);

        print(incidents);

        for (Map<String, dynamic> incident in incidents) {
          success = false;

          List<Map<String, dynamic>> base64Images = [];
          List<dynamic> decodedDatabaseImages = [];

          if (incident['images'] != null) {

            decodedDatabaseImages = jsonDecode(incident['images']);

            for (String imagePath in decodedDatabaseImages) {

              File image = File(imagePath);

              bool isAndroid = Theme.of(context).platform == TargetPlatform.android;
              String base64Image;
              if(isAndroid){
                base64Image =
                await compute(GlobalFunctions.getBase64Image, image);
              } else {

                List<int> imageBytes = await GlobalFunctions.compressImageIos(image);
                base64Image =
                await compute(GlobalFunctions.getBase64ImageIos, imageBytes);

              }

              base64Images.add({
                'image_type': 'jpg',
                'image_data': base64Image
              });
            }
          }

          Map<String, dynamic> incidentData = {
            'incidentData': {
              'type': incident['type'],
              'incident_date': incident['incident_date'],
              'latitude': incident['latitude'],
              'longitude': incident['longitude'],
              'postcode': incident['postcode'],
              'project_name': incident['project_name'],
              'route': incident['route'],
              'elr': incident['elr'],
              'mileage': incident['mileage'],
              'summary': GlobalFunctions.decryptString(incident['summary']),
              'custom_fields': incident['custom_fields'],
              'anonymous': incident['anonymous'],
              'images': incident['images'] == null ? null : base64Images
            }
          };

          //Check the expiry time on the cookie before making the request
          bool isCookieExpired = await GlobalFunctions.isCookieExpired();
          Map<String, dynamic> renewSession = {};

          if (isCookieExpired) {
            renewSession = await _usersModel.renewSession(
                authenticatedUser.username, authenticatedUser.password);
            print('this is the renew session message');
            print(renewSession['message']);
            message = renewSession['message'];
          }

          //Make the POST request to the server
          Map<String, dynamic> serverResponse =
          await GlobalFunctions.apiRequest(
              serverUrl + 'saveIncident', incidentData)
              .timeout(Duration(seconds: 90));
          print('here is the server response');
          print(serverResponse);

          if (serverResponse != null) {
            print(serverResponse);

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
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Access Denied.') {
              print('its in access denied, trying to renew the session');

              Map<String, dynamic> renewSession =
              await _usersModel.renewSession(
                  authenticatedUser.username,
                  authenticatedUser.password);

              message = renewSession['message'];
            } else if (serverResponse['response']['incident_id'] != null) {
              //update the local DB incident with the right id and add the created.

              int updateId = await databaseHelper.updateIncidentId(
                  incident['id'],
                  int.parse(serverResponse['response']['incident_id']));
              int updatedServerFlag = await databaseHelper.updateServerUploaded(
                  incident['id'], true);

              if (updateId == 1 && updatedServerFlag == 1) {
                print('local database successfully updated');
              }
              message = 'everything has worked woo';
              success = true;

              //Check for pending Incidents in the local database
              int pendingIncidentsCheck = await databaseHelper
                  .checkPendingIncidents(authenticatedUser.userId);
              if (pendingIncidentsCheck == 0) {
                print('ok this check has worked no more pending');
                _pendingIncidents = false;
              }
            } else {
              message = 'no valid session found';
            }
          }
        }
      } on TimeoutException catch (_) {
        message =
        'Unable to save incident on the server, please try again later';
        // A timeout occurred.
      } catch (error) {
        print(error);
      }
    }

    if (success) message = 'Incidents Successfully uploaded';

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

  Future<Map<String, dynamic>> addIncident(AuthenticatedUser authenticatedUser,
      String incidentType,
      String reporterFirstName,
      String reporterLastName,
      String dateTime,
      LocationData locationData,
      String projectName,
      String route,
      String elr,
      double mileage,
      String summary,
      List<File> images) async {
    _isLoading = true;
    notifyListeners();

    String message = 'Something went wrong!';
    bool hasError = true;

    try {
      print('ok its in the try');
      List<Map<String, dynamic>> uploadData =
      await uploadImages(authenticatedUser, images);

      print('upload data inside add product');
      print(uploadData);

      //because we return null in all error cases

      uploadData.forEach((upload) {
        if (upload == null) {
          print('Upload Failed');
        }
      });

      List<String> imagePaths = [];
      List<String> imageUrls = [];

      uploadData.forEach((upload) {
        imagePaths.add(upload['imagePath']);
        imageUrls.add(upload['imageUrl']);
      });

      print('the image paths inside the addproduct1');
      print(imagePaths);

      final Map<String, dynamic> incidentData = {
        'incidentType': incidentType,
        'reporterFirstName': reporterFirstName,
        'reporterLastName': reporterLastName,
        'dateTime': dateTime,
        'loc_lat': locationData.latitude,
        'loc_lng': locationData.longitude,
        'projectName': projectName,
        'route': route,
        'elr': elr,
        'mileage': mileage,
        'summary': summary,
        'imagePaths': imagePaths,
        'imageUrls': imageUrls,
        'organisation': authenticatedUser.organisationName,
        'reporterEmail': authenticatedUser.email,
        'voided': false
      };

      final http.Response response = await http.post(
          'https://incident-reporting-a5394.firebaseio.com/incidents.json?auth=${authenticatedUser
              .token}',
          body: json.encode(incidentData));

      if (response.statusCode == 200 || response.statusCode == 201) {
        hasError = false;
        message = 'Incident has been successfully uploaded';
      }
    } catch (error) {
      print(error);
    }

    _isLoading = false;
    notifyListeners();
    return {'success': !hasError, 'message': message};
  }

  Future<Map<String, dynamic>> addIncidentType(String name,
      String customField1,
      String customField2,
      String customField3,
      int organisationId,
      String organisationName) async {
    _isLoading = true;
    notifyListeners();

    String message = 'Something went wrong!';
    bool success = true;

    //create an instance of the database class

    DatabaseHelper databaseHelper = DatabaseHelper();

    int count = await databaseHelper.getCount();
    int id;

    if (count == 0) {
      id = 1;
    } else {
      id = count + 1;
    }

    Map<String, dynamic> incidentTypeData = new Map<String, dynamic>();
    Map<String, dynamic> localIncidentTypeData = new Map<String, dynamic>();

    incidentTypeData = {
      'name': name,
      'customField1': customField1,
      'customField2': customField2,
      'customField3': customField3,
      'organisationId': organisationId,
      'organisationName': organisationName,
    };

    localIncidentTypeData = {
      'name': name,
      'customField1': customField1,
      'customField2': customField2,
      'customField3': customField3,
      'organisationId': organisationId,
      'organisationName': GlobalFunctions.encryptString(organisationName)
    };

    try {
      //Make the POST request to the server
      Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
          serverUrl + 'addIncidentType', incidentTypeData);

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
          success = true;
        } else {
          message = 'no valid session found';
        }

        print(serverResponse);
      }

      int result = await databaseHelper.addIncident(incidentData);

      if (result != 0) {
        print('Incident has successfully been added to local database');
        success = false;
        message = 'Incident has been successfully uploaded';
      }
    } catch (error) {
      print(error);
    }

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};
  }

  Future<int> checkPendingIncidents(AuthenticatedUser authenticatedUser) async {
    DatabaseHelper databaseHelper = DatabaseHelper();

    int pendingIncidentsCheck =
    await databaseHelper.checkPendingIncidents(authenticatedUser.userId);

    return pendingIncidentsCheck;
  }

  Future<int> checkTemporaryIncidentExists(AuthenticatedUser authenticatedUser) async {
    DatabaseHelper databaseHelper = DatabaseHelper();

    int temporaryIncidentsCheck =
    await databaseHelper.checkTemporaryIncidentExists(authenticatedUser.userId);

    return temporaryIncidentsCheck;
  }

  Future<int> updateTemporaryIncidentField(String field, var value,
      int userId) async {
    DatabaseHelper databaseHelper = DatabaseHelper();

    int updateCheck =
    await databaseHelper.updateTemporaryIncidentField(field, value, userId);
    return updateCheck;
  }

  Future<Map<String, dynamic>> getTemporaryIncident(int userId) async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    Map<String, dynamic> temporaryIncident = await databaseHelper
        .getTemporaryIncident(userId);
    return temporaryIncident;
  }

  Future<int> resetTemporaryIncident(int userId) async {
    DatabaseHelper databaseHelper = DatabaseHelper();

    int resetCheck =
    await databaseHelper.resetTemporaryIncident(userId);
    return resetCheck;
  }

  Future <List<Map<String, dynamic>>> getRoutes() async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map<String, dynamic>> routes = await databaseHelper.getRoutes();
    return routes;
  }

  Future <List<Map<String, dynamic>>> getElrsFromRegion(String region) async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map<String, dynamic>> elrs = await databaseHelper.getElrsFromRegion(region);
    return elrs;
  }

  Future <List<Map<String, dynamic>>> getIncidentTypes(int organisationId) async {
    DatabaseHelper databaseHelper = DatabaseHelper();
    List<Map<String, dynamic>> incidentTypes = await databaseHelper.getIncidentTypes(organisationId);
    return incidentTypes;
  }
}
