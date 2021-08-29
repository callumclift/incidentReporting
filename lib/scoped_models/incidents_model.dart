import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity/connectivity.dart';
import 'package:path_provider/path_provider.dart';
import '../locator.dart';
import '../models/authenticated_user.dart';
import '../models/incident.dart';
import '../models/incident_type.dart';
import '../shared/global_config.dart';
import '../shared/global_functions.dart';
import '../scoped_models/users_model.dart';
import '../utils/database.dart';
import 'package:sembast/sembast.dart' as Db;
import 'package:random_string/random_string.dart' as random_string;

class IncidentsModel extends ChangeNotifier {

  UsersModel _usersModel = UsersModel();
  IncidentsModel(this._usersModel);
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Incident> _incidents = [];
  List<IncidentType> _incidentTypes = [];
  int _selIncidentId;
  int _selIncidentTypeId;
  final dateFormatDay = DateFormat("dd-MM-yyyy");

  List<Incident> get allIncidents {
    return List.from(_incidents);
  }

  List<IncidentType> get allIncidentTypes {
    return List.from(_incidentTypes);
  }

  int get selectedIncidentIndex {
    return _incidents.indexWhere((Incident incident) {
      return incident.incidentId == _selIncidentId;
    });
  }

  int get selectedIncidentTypeIndex {
    return _incidentTypes.indexWhere((IncidentType incidentType) {
      return incidentType.id == _selIncidentTypeId;
    });
  }

  int get selectedIncidentId {
    return _selIncidentId;
  }

  Incident get selectedIncident {
    if (_selIncidentId == null) {
      return null;
    }
    return _incidents.firstWhere((Incident incident) {
      return incident.incidentId == _selIncidentId;
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

  void selectIncident(int incidentId) {
    _selIncidentId = incidentId;
    if (incidentId != null) {
      notifyListeners();
    }
  }


  void clearIncidents(){
    _incidents = [];
  }

  // Sembast database settings
  static const String TEMPORARY_INCIDENTS_STORE_NAME = 'temporary_incidents';
  final _temporaryIncidentsStore = Db.intMapStoreFactory.store(TEMPORARY_INCIDENTS_STORE_NAME);

  static const String INCIDENTS_STORE_NAME = 'incidents';
  final _incidentsStore = Db.intMapStoreFactory.store(INCIDENTS_STORE_NAME);

  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;


  Future<void> setupTemporaryRecord() async {
    int count = await _temporaryIncidentsStore.count(await _db);
    if(count == 0){
      // Generate a random ID based on the date and a random string for virtual zero chance of duplicates
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _temporaryIncidentsStore.record(_id).put(await _db,
          {'user_id' : user.userId});
    }
  }

  Future<Map<String, dynamic>> getTemporaryRecord() async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals('user_id', user.userId));
    List records;
    records = await _temporaryIncidentsStore.find(
      await _db,
      finder: finder,
    );
    return records[0].value;
  }

  Future<bool> checkPendingRecordExists() async{
    bool hasRecord = false;
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals('user_id', user.userId), Db.Filter.equals('server_uploaded', false)]
    ));

    List records = await _incidentsStore.find(
      await _db,
      finder: finder,
    );

    if(records.length > 0) hasRecord = true;

    return hasRecord;
  }

  Future <List<dynamic>> getPendingRecords() async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals('user_id', user.userId), Db.Filter.equals('server_uploaded', false)]
    ));
    List records = await _incidentsStore.find(
      await _db,
      finder: finder,
    );
    return records;
  }

  Future <List<Map<String,dynamic>>> getPendingRecords1() async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals('user_id', user.userId), Db.Filter.equals('server_uploaded', false)]
    ));
    List recordsDynamic = await _incidentsStore.find(
      await _db,
      finder: finder,
    );
    print(recordsDynamic.asMap());
    List<Map<String, dynamic>> records = [];
    for(var record in recordsDynamic){
      print(record.key);
      records.add(record.value);
    }

    return records;
  }

  Future <void> deletePendingRecord(int localId) async{
    final Db.Finder finder = Db.Finder(filter: Db.Filter.and(
        [Db.Filter.equals('user_id', user.userId), Db.Filter.equals('id', localId)]
    ));

    await _incidentsStore.delete(
      await _db,
      finder: finder,
    );
  }

  Future<bool> checkRecordExists() async{

    bool hasRecord = false;

    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals('user_id', user.userId));
    List records;
      records = await _temporaryIncidentsStore.find(
        await _db,
        finder: finder,
      );
    if(records.length > 0) hasRecord = true;
    return hasRecord;
  }

  void updateTemporaryRecord(String field, var value) async {
    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals('user_id', user.userId));
    await _temporaryIncidentsStore.update(await _db, {field: value},
        finder: finder);
  }

  Future<int> getImagePathCount() async {
    int count = await _temporaryIncidentsStore.count(await _db);
    if(count == 0){
      // Generate a random ID based on the date and a random string for virtual zero chance of duplicates
      int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
      await _temporaryIncidentsStore.record(_id).put(await _db,
          {'user_id' : user.userId});
    }
  }


  Future<void> getCustomIncidents() async {

    _isLoading = true;
    String message = '';
    List<IncidentType> _incidentTypeList = [];

    try {

      var connectivityResult = await (new Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        GlobalFunctions.showToast('No data connection, unable to fetch custom incidents');
        _incidents = [];
      } else {

        //Make the POST request to the server
        final Map<String, dynamic> requestData = {
          'incidentData': {},
        };

        //Check the expiry time on the cookie before making the request
        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        bool hasSession = true;

        if (isCookieExpired) {
          hasSession = await _usersModel.getSession(
              user.username,
              user.password);
        }

        if(hasSession){

          Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
              serverUrl + 'getCustomIncidents', requestData)
              .timeout(Duration(seconds: 90));

          if (serverResponse != null) {
            if (serverResponse['error'] != null &&
                serverResponse['error'] == 'incorrect_details') {
              message = 'Incorrect username or password given';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Token missing or invalid') {
              message = 'token missing or invalid';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Access Denied.') {
              message = 'access denied, please contact system administrator';
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


              for (Map<String, dynamic> incidentTypeData in incidentTypes) {


                int customFieldCount = incidentTypeData['CustomIncidents']['custom_fields']
                    .length;


                final IncidentType incidentType = IncidentType(
                  id: int.parse(incidentTypeData['CustomIncidents']['id']),
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
                _incidentTypeList.add(incidentType);
              }
              _incidentTypes = _incidentTypeList;
            }
          } else {
            message = 'no valid session found';
          }
        }
      }
    } on TimeoutException catch (_) {
      message = 'Request timeout, unable to fetch latest incident Types';
      // A timeout occurred.
    } catch (error) {
      print(error);
      message = 'Unable to fetch latest incident types';
    }

    _isLoading = false;
    notifyListeners();
    if(message != '') GlobalFunctions.showToast(message);
  }

  Future<void> getIncidents() async {

    _isLoading = true;
    String message = '';
    List<Incident> _fetchedIncidentList = [];


    try {
      var connectivityResult = await (new Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        GlobalFunctions.showToast('No data connection, unable to fetch Incidents');
        _incidents = [];
      } else {

        //Make the POST request to the server
        final Map<String, dynamic> requestData = {
          'incidentData': {},
        };

        //Check the expiry time on the cookie before making the request
        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        bool hasSession = true;

        if (isCookieExpired) {
          hasSession = await _usersModel.getSession(
              user.username,
              user.password);
        }

        if(hasSession){

          Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
              serverUrl + 'getIncidents', requestData)
              .timeout(Duration(seconds: 90));


          if (serverResponse != null) {
            if (serverResponse['error'] != null &&
                serverResponse['error'] == 'incorrect_details') {
              message = 'Incorrect username or password given';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Token missing or invalid') {
              message = 'token missing or invalid';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Access Denied.') {
              message = 'access denied, please contact system administrator';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'terms_not_accepted') {
              message =
              'You need to accept the terms & conditions before using this app';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'change_password') {
              message = 'You are required to change your password';
            } else if (serverResponse['response']['incidents'] != null) {

              List<dynamic> incidents = serverResponse['response']['incidents'];


              if(incidents.length > 0){
                for (Map<String, dynamic> incidentData in incidents) {

                  List<dynamic> decodedCustomFields = [];
                  List<Map<String, dynamic>> customFields = [];

                  if(incidentData['Incidents']['custom_fields'] != null){
                    decodedCustomFields = jsonDecode(incidentData['Incidents']['custom_fields']);

                    for(dynamic custom in decodedCustomFields){

                      customFields.add(custom);
                    }
                  }

                  final dateFormat = DateFormat("dd/MM/yyyy HH:mm");
                  DateTime dateTime =
                  DateTime.parse(incidentData['Incidents']['incident_date']);

                  final Incident incident = Incident(
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
                  _fetchedIncidentList.add(incident);
                }


                //order by date time
                _fetchedIncidentList.sort((Incident a, Incident b) => b.incidentId.compareTo(a.incidentId));
                _incidents = _fetchedIncidentList;
              } else {
                message = 'No incidents available';
              }
            }
          } else {
            message = 'no valid session found';
          }

        }
      }
    } on TimeoutException catch (_) {

      message = 'Network Timeout communicating with the server, unable to fetch latest Incidents';

      // A timeout occurred.
    } catch (error) {
      print(error);
      message = 'Something went wrong. Please try again';
    }

    _isLoading = false;
    notifyListeners();
    if(message != '') GlobalFunctions.showToast(message);
  }



  Future<void> getIncidentImages() async {

    _isLoading = true;
    String message = '';
    List<Uint8List> _imagesList = [];


    try {

      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
          message = 'No data connection, unable to load images';

      } else {

        //Make the POST request to the server
        final Map<String, dynamic> requestData = {
          'incidentData': {
            'incident_id': selectedIncident.incidentId.toString()
          },
        };

        //Check the expiry time on the cookie before making the request
        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        bool hasSession = true;

        if (isCookieExpired) {
          hasSession = await _usersModel.getSession(
              user.username,
              user.password);
        }

        if(hasSession){

          Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
              serverUrl + 'getIncidentImages', requestData)
              .timeout(const Duration(seconds: 90));


          if (serverResponse != null) {
            if (serverResponse['error'] != null &&
                serverResponse['error'] == 'incorrect_details') {
              message = 'Incorrect username or password given';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Token missing or invalid') {
              message = 'token missing or invalied';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Access Denied.') {
              message = 'access denied, please contact system administrator';
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
                  Uint8List bytes =
                  base64Decode(imageData['IncidentImages']['image_data']);

                  _imagesList.add(bytes);
                }

              }

              selectedIncident.images = _imagesList;
            }
          } else {
            message = 'no valid session found';
          }
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

    _isLoading = false;
    notifyListeners();
    if(message != '') GlobalFunctions.showToast(message);
  }


  Future<bool> saveIncident({@required bool anonymous,
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
    notifyListeners();
    String message = 'Something went wrong!';
    bool success = false;
    Map<String, dynamic> databaseData;

    try {
      List<Map<String, dynamic>> base64Images = [];
      var encodedImagePaths;
      var connectivityResult = await (new Connectivity().checkConnectivity());

      int count = await _incidentsStore.count(await _db);

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

          Map<String, dynamic> compressedImage;
          if(imageIndex == 0) new Directory(dirPath).createSync(recursive: true);

          String path = '$dirPath/image' + imageIndex.toString() + '.jpg';
          String base64Image;

          if(connectivityResult != ConnectivityResult.none){
            List<int> imageBytes = image.readAsBytesSync();
            base64Image = await compute(GlobalFunctions.getBase64Image, imageBytes);
            base64Images.add({'image_type': 'jpg', 'image_data': base64Image});
          }

          if(compressedImage == null){

            image.copySync(path);

          }

          _imagePaths.add(path);

          imageIndex ++;
        }

        encodedImagePaths = jsonEncode(_imagePaths);

      }

      databaseData = {
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

      Map<String, dynamic> result = await _incidentsStore.record(id).put(await _db,
          databaseData);

      print(result);

      if (connectivityResult == ConnectivityResult.none) {
        message = 'No data connection, Incident has been stored locally';
        //success = true;
      } else {
        //Check the expiry time on the cookie before making the request
        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        bool hasSession = true;

        if (isCookieExpired) {
          hasSession = await _usersModel.getSession(
              user.username,
              user.password);
        }

        if(hasSession){

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
              message = 'access denied, please contact system administrator';
            } else if (serverResponse['response']['incident_id'] != null) {
              //update the local DB incident with the right id and add the created.

              databaseData['incident_id'] = serverResponse['response']['incident_id'];
              databaseData['server_uploaded'] = true;

              await _incidentsStore.record(id).put(await _db, databaseData);
              message = 'Incident uploaded successfully';
              success = true;
              await deleteTemporaryImages();
            } else {
              message = 'no valid session found';
            }
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
    GlobalFunctions.showToast(message);
    return success;
  }

  Future<void> deleteTemporaryImages() async{
    //Delete the temporary images and replace images with compressed ones
    int imagePathCount = await _usersModel.imagePathStore.count(await _db);

    if (imagePathCount == 1) {
      String imagePath = await _usersModel.getImagePath();


      if (imagePath != null) {
        Directory dir = Directory(imagePath);
        print('this is the dir');
        print(dir);

        if (dir.existsSync()) {
          print('it exsits tjis directory');
          List<FileSystemEntity> list = dir.listSync(recursive: false)
              .toList();
          print('thisis the list of the files');
          print(list);

          for (FileSystemEntity file in list) {
            if (file.path.contains('.jpg') || file.path.contains('.png')) file.deleteSync(
                recursive: false);
          }
        } else {
          print('this does not exist');
        }
      }
    }
  }


  Future<bool> uploadPendingIncidents() async {

    _isLoading = true;
    notifyListeners();
    String message = '';
    bool success = false;
    var connectivityResult = await (new Connectivity().checkConnectivity());

    if (connectivityResult == ConnectivityResult.none) {
      message = 'No data connection, unable to upload incidents';
    } else {
      try {

        List<dynamic> incidentsDynamic = await getPendingRecords();

        for (var incidentDynamic in incidentsDynamic) {
          success = false;

          Map<String, dynamic> incident = incidentDynamic.value;
          List<Map<String, dynamic>> base64Images = [];
          List<dynamic> decodedDatabaseImages = [];

          if (incident['images'] != null) {
            decodedDatabaseImages = jsonDecode(incident['images']);

            for (Map<String, dynamic> imageData in decodedDatabaseImages) {
              base64Images.add({
                'image_type': imageData['image_type'],
                'image_data': imageData['image_data']
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
              'images': base64Images
            }
          };

          //Check the expiry time on the cookie before making the request
          bool isCookieExpired = await GlobalFunctions.isCookieExpired();
          bool hasSession = true;

          if (isCookieExpired) {
            hasSession = await _usersModel.getSession(
                user.username,
                user.password);
          }

          if(hasSession){

            //Make the POST request to the server
            Map<String, dynamic> serverResponse =
            await GlobalFunctions.apiRequest(
                serverUrl + 'saveIncident', incidentData)
                .timeout(Duration(seconds: 90));

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
                message = 'access denied, please contact system administrator';
              } else if (serverResponse['response']['incident_id'] != null) {
                //update the local DB incident with the right id and add the created.

                //update the two values of the record in local DB
                var record = _incidentsStore.record(incidentDynamic.key);
                await record.update(await _db, {'incident_id': serverResponse['response']['incident_id'], 'server_uploaded' : true});
                message = 'Incident uploaded successfully';
                await deleteTemporaryImages();
                //if(Platform.isAndroid) await deleteTemporaryCachedImages();
                success = true;
              } else {
                message = 'no valid session found';
              }
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
    GlobalFunctions.showToast(message);
    return success;
  }

  Future<void> resetTemporaryRecord(int userId) async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals('user_id', user.userId));

    await _temporaryIncidentsStore.update(await _db, {
      'type': null,
      'anonymous' : false,
      'incident_date' : null,
      'location_drop' : null,
      'latitude' : null,
      'longitude' : null,
      'postcode' : null,
      'location_map': null,
      'postcode_map': null,
      'project_name' : null,
      'route' : null,
      'elr' : null,
      'mileage' : null,
      'summary' : null,
      'images' : null,
      'custom_fields': null,
      'custom_value1': null,
      'custom_value2': null,
      'custom_value3': null,
    },
        finder: finder);
    notifyListeners();
  }

}
