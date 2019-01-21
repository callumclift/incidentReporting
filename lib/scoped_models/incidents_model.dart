import 'dart:convert';
import 'dart:async';
import 'dart:io';

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


import '../models/authenticated_user.dart';
import '../models/incident.dart';
import '../models/incident_type.dart';
import '../models/location_data.dart';
import '../utils/database_helper.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';


class IncidentsModel extends Model {

  List<Incident> _incidents = [];
  List<Incident> _myIncidents = [];
  List<IncidentType> _incidentTypes = [
    IncidentType(id: 1, name: 'Incident', custom1: 'test1', custom2: 'test2', custom3: 'test3', organisation: 'Ontrac'),
    IncidentType(id: 2, name: 'Close Call', custom1: 'test11', custom2: 'test22', custom3: 'test33', organisation:  'Ontrac')
  ];
  int _selIncidentKey;
  int _selMyIncidentId;
  int _selIncidentTypeId;
  bool _isLoading = false;

  bool get isLoading {
    return _isLoading;
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
      return incident.id == _selMyIncidentId;
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

  Future<Map<String, dynamic>> getIncidents() async{

    _isLoading = true;
    notifyListeners();

    bool success = false;
    String message = 'Something went wrong';

    List<Incident> _incidentList = [];



    try {

      var connectivityResult = await (new Connectivity().checkConnectivity());

      if(connectivityResult == ConnectivityResult.none){

        message = 'No data connection, please try again later';


      } else {

        //Make the POST request to the server
        final Map<String,dynamic> requestData = {'incidentData': {},};

        Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
            serverUrl + 'getIncidents', requestData);

        print(serverResponse);

        if (serverResponse != null) {
          if (serverResponse['error'] != null &&
              serverResponse['error'] == 'incorrect_details') {
            message = 'Incorrect username or password given';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Token missing or invalid') {
            message =
            'token missing or invalied';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'Access Denied') {
            message =
            'server says access denied';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'terms_not_accepted') {
            message =
            'You need to accept the terms & conditions before using this app';
          } else if (serverResponse['error'] != null &&
              serverResponse['error'] == 'change_password') {
            message = 'You are required to change your password';
          } else if (serverResponse['response']['incidents'] != null) {


            List<dynamic> incidents = serverResponse['response']['incidents'];
            print('ok herrrreeee');
            print(incidents);

            DatabaseHelper databaseHelper = DatabaseHelper();

            for(Map<String, dynamic> incidentData in incidents){
              print('the start of the for' + incidentData['Incidents']['id']);

              int count = await databaseHelper.getIncidentCount();
              int id;

              if (count == 0) {
                id = 1;
              } else {
                id = count + 1;
              }


              final Incident incident = Incident(
                id: id,
                incidentId: int.parse(incidentData['Incidents']['id']),
                userId: int.parse(incidentData['Incidents']['user_id']),
                type: incidentData['Incidents']['type'],
                fullName: incidentData['0']['fullname'],
                username: incidentData['User']['email'],
                email: null,
                incidentDate: incidentData['Incidents']['incident_date'],
                created: incidentData['Incidents']['created'],
                latitude: double.parse(incidentData['Incidents']['latitude']),
                longitude: double.parse(incidentData['Incidents']['longitude']),
                projectName: incidentData['Incidents']['project_name'],
                route: incidentData['Incidents']['route'],
                elr: incidentData['Incidents']['elr'],
                mileage: incidentData['Incidents']['mileage'],
                summary: incidentData['Incidents']['summary'],
                images: incidentData['Incidents']['images'],
                organisationId: int.parse(incidentData['Incidents']['organisation_id']),
                organisationName: incidentData['Organisation']['name'],
                customFields: incidentData['Incidents']['custom_fields'],
                anonymous: incidentData['Incidents']['anonymous']
              );
              print('ok about to add');
              _incidentList.add(incident);


              int incidentExists = await databaseHelper.checkIncidentExists(int.parse(incidentData['Incidents']['user_id']));

              if(incidentExists == 0){

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
                  'fullname': incident.fullName == null? incident.fullName : GlobalFunctions.encryptString(incident.fullName),
                  'username': incident.username == null? incident.username : GlobalFunctions.encryptString(incident.username),
                  'email': incident.email == null ? incident.email : GlobalFunctions.encryptString(incident.email),
                  'incident_date': incident.incidentDate,
                  'created': incident.created,
                  'latitude': incident.latitude,
                  'longitude': incident.longitude,
                  'project_name': incident.projectName,
                  'route': incident.route,
                  'elr': incident.elr,
                  'mileage': incident.mileage,
                  'summary': GlobalFunctions.encryptString(incident.summary),
                  'images': incident.images,
                  'organisation_id': incident.organisationId,
                  'organisation_name': incident.organisationName,
                  'custom_fields': incident.customFields,
                  'anonymous': incident.anonymous
                };

                int result = await databaseHelper.addIncident(databaseData);

                if (result != 0){

                  message = 'Incident not added to local database';
                }

              }

            }
            success = true;
            message = 'waheyyyyy';
            }


          } else {
            message = 'no valid session found';
          }

        }
      } catch(error){
      print(error);
      message = 'Something went wrong';
    }

    _myIncidents = _incidentList;
    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};

  }


  Future<Map<String, dynamic>>voidUnvoidIncident(String incidentKey, bool voided) async {

    bool hasError = true;
    String message = 'Something went wrong';

    try {
      await FirebaseDatabase.instance.reference().child('incidents').child(incidentKey).update({'voided': !voided});
    } catch(e) {
      print(e);
      return {'success' : hasError, 'message' : message};
    }

    if(!voided == true) {
      message = 'Incident has been voided';
    } else {
      message = 'Incident has been unvoided';
    }

    return {'success' : !hasError, 'message' : message};
  }

  Future<Null> fetchMyIncidents() async{

    _isLoading = true;
    notifyListeners();

    final List<Incident> fetchedIncidentList = [];

    try {

      DatabaseHelper databaseHelper = DatabaseHelper();

      List<Map<String, dynamic>> incidentsList = await databaseHelper.getIncidentMapList();

      if (incidentsList.length == 0){
        print('there are no incidents');
      } else {
        print('we have some incidents');
      }

      print('this is the size of the incident list locally');
      print(incidentsList.length);

      incidentsList.forEach((Map<String, dynamic> incidentMap) {
        print('the start of the for each');

        final Incident incident = Incident.myIncident(
          incidentId: incidentMap['id'],
          incidentType: incidentMap['incidentType'],
          reporterFirstName: incidentMap['reporterFirstName'],
          reporterLastName: incidentMap['reporterLastName'],
          dateTime: incidentMap['dateTime'],
          location: LocationData(longitude: incidentMap['locLng'], latitude: incidentMap['locLat']),
          projectName: incidentMap['projectName'],
          route: incidentMap['route'],
          elr: incidentMap['elr'],
          mileage: incidentMap['mileage'],
          summary: incidentMap['summary'],
          organisation: incidentMap['organisation'],
          reporterEmail: incidentMap['reporterEmail'],
        );
        print('ok about to add');
        fetchedIncidentList.add(incident);

        //Incident incident = Incident(id: null, incidentType: null, reporter: null, dateTime: null, location: null, projectName: null, route: null, elr: null, mileage: null, summary: null, imagePaths: null, images: null, organisation: null, reporterEmail: null, voided: null)
      });

      //return incidentsList;

    } catch (error) {
      print(error);
    }

    _myIncidents = fetchedIncidentList;
    _isLoading = false;
    notifyListeners();

  }

  Future<Null> fetchIncidents(String role, {onlyForUser: false, clearExisting = false}) async{

    _isLoading = true;

    if (clearExisting) {
      _incidents = [];
    }

    final List<Incident> fetchedIncidentList = [];

    Map<String, dynamic> incidentData = {};


    try {

      print('its getting into the try');

      DataSnapshot snapshot;

      snapshot = await FirebaseDatabase.instance
          .reference().child('incidents').orderByChild('dateTime')
          .once();

      incidentData = new Map.from(snapshot.value);


      incidentData.forEach((String incidentKey, dynamic incidentData) {
        print(incidentKey);
        print(incidentData);


        List<String> images = [];
        List<String> imagePaths = [];



        for (var value in incidentData['imageUrls']) {
          print('inside the for looppp');
          images.add(value);
        }

        for (var value in incidentData['imagePaths']) {
          print('inside the for looppp');
          imagePaths.add(value);
        }

        final Incident incident = Incident(
            id: incidentKey,
            incidentType: incidentData['incidentType'],
            reporterFirstName: incidentData['reporterFirstName'],
            reporterLastName: incidentData['reporterLastName'],
            dateTime: incidentData['dateTime'],
            location: LocationData(longitude: incidentData['loc_lng'], latitude: incidentData['loc_lat']),
            projectName: incidentData['projectName'],
            route: incidentData['route'],
            elr: incidentData['elr'],
            mileage: incidentData['mileage'],
            summary: incidentData['summary'],
            imagePaths: imagePaths,
            images: images,
            organisation: incidentData['organisation'],
            reporterEmail: incidentData['reporterEmail'],
            voided: incidentData['voided']
        );
        print('ok about to add');
        fetchedIncidentList.add(incident);
      });

      fetchedIncidentList.sort((Incident a, Incident b) => a.dateTime.compareTo(b.dateTime));

      print('its sorted the list');



      fetchedIncidentList.forEach((Incident incident){

        print(incident.dateTime);

      });

      _incidents = fetchedIncidentList;
      _isLoading = false;
      notifyListeners();
      _selIncidentKey = null;

    } catch(e){
      _isLoading = false;
      notifyListeners();
      return;
    }
  }

  Future<String> test() async{

    Map<String, dynamic> requestData = {
      'incidentData': {}
    };

    Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
        serverUrl + 'getIncidents', requestData);

    print('testing custom fields');
    print(serverResponse);


    return 'hi';
  }

  Future<Null> getIncidentTypes() async{

    _isLoading = true;
    notifyListeners();

    final List<IncidentType> fetchedIncidentTypeList = [];

    Map<String, dynamic> requestData = {
      'authToken': 'test'
    };

    try {

      Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
          serverUrl + 'getTestCustomFields', requestData, false);

      print('testing custom fields');
      print(serverResponse);
      List<Map<String, dynamic>> testList = (serverResponse['fields']);
      testList.forEach((Map<String, dynamic> map){
        print(map['label']);
      });
      print('ok im done');

      DatabaseHelper databaseHelper = DatabaseHelper();

      List<Map<String, dynamic>> incidentsList = await databaseHelper.getIncidentMapList();

      if (incidentsList.length == 0){
        print('there are no incidents');
      } else {
        print('we have some incidents');
      }

      print('this is the size of the incident list locally');
      print(incidentsList.length);

      incidentsList.forEach((Map<String, dynamic> incidentMap) {
        print('the start of the for each');

        final Incident incident = Incident.myIncident(
          incidentId: incidentMap['id'],
          incidentType: incidentMap['incidentType'],
          reporterFirstName: incidentMap['reporterFirstName'],
          reporterLastName: incidentMap['reporterLastName'],
          dateTime: incidentMap['dateTime'],
          location: LocationData(longitude: incidentMap['locLng'], latitude: incidentMap['locLat']),
          projectName: incidentMap['projectName'],
          route: incidentMap['route'],
          elr: incidentMap['elr'],
          mileage: incidentMap['mileage'],
          summary: incidentMap['summary'],
          organisation: incidentMap['organisation'],
          reporterEmail: incidentMap['reporterEmail'],
        );
        print('ok about to add');
        fetchedIncidentList.add(incident);

        //Incident incident = Incident(id: null, incidentType: null, reporter: null, dateTime: null, location: null, projectName: null, route: null, elr: null, mileage: null, summary: null, imagePaths: null, images: null, organisation: null, reporterEmail: null, voided: null)
      });

      //return incidentsList;

    } catch (error) {
      print(error);
    }

    _myIncidents = fetchedIncidentList;
    _isLoading = false;
    notifyListeners();

  }

  //this gets called from within add and update product
  Future<Map<String, dynamic>> uploadImage(AuthenticatedUser authenticatedUser, File image,
      {String imagePath}) async {
    final mimeTypeData = lookupMimeType(image.path).split('/');
    final imageUploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://us-central1-incident-reporting-a5394.cloudfunctions.net/storeImage'));

    final file = await http.MultipartFile.fromPath(
      'image',
      image.path,
      contentType: MediaType(
        mimeTypeData[0],
        mimeTypeData[1],
      ),
    );
    imageUploadRequest.files.add(file);
    if (imagePath != null) {
      imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
    }

    imageUploadRequest.headers['Authorization'] =
    'Bearer ${authenticatedUser.token}';

    try {
      final http.StreamedResponse streamedResponse =
      await imageUploadRequest.send();
      final http.Response response =
      await http.Response.fromStream(streamedResponse);
      if (response.statusCode != 200 && response.statusCode != 201) {
        print(json.decode(response.body));
        return null;
      }
      final responseData = json.decode(response.body);
      return responseData;
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> uploadImages(AuthenticatedUser authenticatedUser, List<File> images,
      {String imagePath}) async {
    List<Map<String, dynamic>> uploadedImages = [];

    print('these are the images');
    print(images);

    for (File image in images) {
      if (image == null) {
        continue;
      }

      print('it got inside the for each ofr the images');
      print(image);
      print('image path');
      print(image.path);

      final mimeTypeData = lookupMimeType(image.path).split('/');
      final imageUploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://us-central1-incident-reporting-a5394.cloudfunctions.net/storeImage'));

      final file = await http.MultipartFile.fromPath(
        'image',
        image.path,
        contentType: MediaType(
          mimeTypeData[0],
          mimeTypeData[1],
        ),
      );
      imageUploadRequest.files.add(file);
      if (imagePath != null) {
        imageUploadRequest.fields['imagePath'] = Uri.encodeComponent(imagePath);
      }

      imageUploadRequest.headers['Authorization'] =
      'Bearer ${authenticatedUser.token}';

      try {
        print('it got inside the try');
        final http.StreamedResponse streamedResponse =
        await imageUploadRequest.send();
        final http.Response response =
        await http.Response.fromStream(streamedResponse);
        if (response.statusCode != 200 && response.statusCode != 201) {
          print(json.decode(response.body));
          return null;
        }
        final responseData = json.decode(response.body);
        print('this is the response data');
        print(responseData);
        uploadedImages.add(responseData);
        print('this is the uploaded images inside the loop');
        print(uploadedImages);
      } catch (error) {
        print(error);
        return null;
      }
    }

    print('this the uploaded images after the for each');
    print(uploadedImages);

    return uploadedImages;
  }


  Future<Map<String, dynamic>> addIncidentLocally(bool anonymous, AuthenticatedUser authenticatedUser, String type, String incidentDate, LocationData locationData,
      String projectName, String route, String elr, String mileage, String summary, List<File> images) async {

    _isLoading = true;
    notifyListeners();

    String message = 'Something went wrong!';
    bool success = true;

    try{


      if(images !=null) {

        //JSON Encode the base 64 images

        List<String> base64Images = [];
        List<String> encryptedBase64Images = [];

        for (File image in images) {
          if (image == null) {
            continue;
          }
          //Convert each image to Base64
          List<int> imageBytes = image.readAsBytesSync();
          String base64Image = base64Encode(imageBytes);
          base64Images.add(base64Image);

          //Encrypt for the local database
          String encryptedBase64 = GlobalFunctions.encryptString(base64Image);
          encryptedBase64Images.add(encryptedBase64);
        }

        //JSON Encode the list of images for storing in the local database
        var encodedEncryptedImages = jsonEncode(encryptedBase64Images);
        var encodedImages = jsonEncode(base64Images);
      }

      //create an instance of the database class

      DatabaseHelper databaseHelper = DatabaseHelper();

      int count = await databaseHelper.getIncidentCount();
      int id;

      if (count == 0) {
        id = 1;
      } else {
        id = count + 1;
      }

      Map<String, dynamic> incidentData = {
        'incidentData': {
          'type': type,
          'incident_date': incidentDate,
          'latitude' : locationData.latitude,
          'longitude' : locationData.longitude,
          'project_name' : projectName,
          'route': route,
          'elr': elr,
          'mileage' : mileage,
          'summary' : summary,
          'custom_fields' : null,
          'anonymous': anonymous,
          'images': null}
      };

          Map<String, dynamic> databaseData = {
            'id': id,
            'incident_id': null,
            'user_id': authenticatedUser.userId,
            'type': type,
            'fullname': anonymous == true? null : GlobalFunctions.encryptString(authenticatedUser.firstName + ' ' + authenticatedUser.lastName),
            'username': anonymous == true? null : GlobalFunctions.encryptString(authenticatedUser.username),
            'email': null,
            'incident_date': incidentDate,
            'created': null,
            'latitude': locationData.latitude,
            'longitude': locationData.longitude,
            'project_name': projectName,
            'route': route,
            'elr': elr,
            'mileage': mileage,
            'summary': GlobalFunctions.encryptString(summary),
            'images': images,
            'organisation_id': authenticatedUser.organisationId,
            'organisation_name': authenticatedUser.organisationName,
            'custom_fields': null,
            'anonymous': anonymous
          };

      int result = await databaseHelper.addIncident(databaseData);

      if (result != 0){
        print('Incident has successfully been added to local database');
      }

  //Make the POST request to the server
  Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
  serverUrl + 'saveIncident', incidentData);
      print('here is the server response');
      print(serverResponse);

  if (serverResponse != null) {
    print(serverResponse);

  if (serverResponse['error'] != null &&
  serverResponse['error'] == 'incorrect_details') {
  message = 'Incorrect username or password given';
  } else if (serverResponse['error'] != null &&
  serverResponse['error'] == 'terms_not_accepted') {
  message = 'You need to accept the terms & conditions before using this app';
  } else if (serverResponse['error'] != null &&
  serverResponse['error'] == 'change_password') {
  message = 'You are required to change your password';
  } else if (serverResponse['response']['incident_id'] != null){

    //update the local DB incident with the right id and add the created.

    int updateId = await databaseHelper.updateIncidentId(id, int.parse(serverResponse['response']['incident_id']));

    if(updateId == 1){
      print('local database successfully updated');
    }
    message = 'everything has worked woo';
    success = true;
  } else {
  message = 'no valid session found';
  }

  }
    } catch (error) {
      print(error);
    }

    _isLoading = false;
    notifyListeners();
    return {'success': success, 'message': message};

  }

  Future<Map<String, dynamic>> addIncident(AuthenticatedUser authenticatedUser, String incidentType, String reporterFirstName, String reporterLastName, String dateTime, LocationData locationData,
      String projectName, String route, String elr, double mileage, String summary, List<File> images) async {


    _isLoading = true;
    notifyListeners();

    String message = 'Something went wrong!';
    bool hasError = true;

    try {
      print('ok its in the try');
      List<Map<String, dynamic>> uploadData = await uploadImages(authenticatedUser, images);

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

  Future<Map<String, dynamic>> addIncidentType(String name, String customField1, String customField2, String customField3, int organisationId, String organisationName) async {

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


    Map<String, dynamic> incidentTypeData = new Map<String,dynamic>();
    Map<String, dynamic> localIncidentTypeData = new Map<String,dynamic>();



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

    try{

    //Make the POST request to the server
    Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
    serverUrl + 'addIncidentType', incidentTypeData);

    if (serverResponse != null) {

    if (serverResponse['error'] != null &&
    serverResponse['error'] == 'incorrect_details') {
    message = 'Incorrect username or password given';
    } else if (serverResponse['error'] != null &&
    serverResponse['error'] == 'terms_not_accepted') {
    message = 'You need to accept the terms & conditions before using this app';
    } else if (serverResponse['error'] != null &&
    serverResponse['error'] == 'change_password') {
    message = 'You are required to change your password';
    } else if (serverResponse['response']['session'] != null){

      success = true;


    } else {
    message = 'no valid session found';

    }

    print(serverResponse);

    }

    int result = await databaseHelper.addIncident(incidentData);

    if (result != 0){
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
}