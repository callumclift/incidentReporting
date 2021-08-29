import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import '../models/authenticated_user.dart';
import '../shared/global_functions.dart';
import '../shared/global_config.dart';
import '../utils/database.dart';
import '../locator.dart';
import '../constants/route_paths.dart' as routes;
import '../services/navigation_service.dart';
import '../services/secure_storage.dart';
import 'package:sembast/sembast.dart' as Db;
import 'package:random_string/random_string.dart' as random_string;



class UsersModel extends ChangeNotifier {

  final SecureStorage _secureStorage = SecureStorage();
  final NavigationService _navigationService = locator<NavigationService>();
  bool _isLoading = false;
  bool _loadingElrs = false;
  bool _isLoadingLogin = false;
  bool isCheckingImageCrash = false;
  bool getLostImage = false;

  String _authenticationErrorMessage = '';

  String get loginErrorMessage => _authenticationErrorMessage;
  bool get isLoading => _isLoading;
  bool get loadingElrs => _loadingElrs;
  bool get isLoadingLogin => _isLoadingLogin;

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setLoadingElrs(bool value) {
    _loadingElrs = value;
    notifyListeners();
  }


  // Sembast database settings
  static const String USERS_STORE_NAME = 'users_store';
  static const String ELRS_STORE_NAME = 'elrs_store';
  static const String ROUTES_STORE_NAME = 'routes_store';
  static const String CAMERA_CRASH_STORE_NAME = 'camera_crash_store';
  static const String IMAGE_PATH_STORE_NAME = 'image_path_store';
  final _usersStore = Db.intMapStoreFactory.store(USERS_STORE_NAME);
  final _elrsStore = Db.intMapStoreFactory.store(ELRS_STORE_NAME);
  final _routesStore = Db.intMapStoreFactory.store(ROUTES_STORE_NAME);
  final _cameraCrashStore = Db.intMapStoreFactory.store(CAMERA_CRASH_STORE_NAME);
  final imagePathStore = Db.intMapStoreFactory.store(IMAGE_PATH_STORE_NAME);
  // Private getter to shorten the amount of code needed to get the
  // singleton instance of an opened database.
  Future<Db.Database> get _db async => await AppDatabase.instance.database;


  Future <List<Map<String, dynamic>>> getRoutes() async{
    List<dynamic> recordsDynamic = await _routesStore.find(
      await _db,
    );
    List<Map<String, dynamic>> records = [];

    for(var record in recordsDynamic){
      records.add(record.value);
    }
    return records;
  }

  Future <List<Map<String, dynamic>>> getElrsFromRegion(String region) async {

    final Db.Finder finder = Db.Finder(filter: Db.Filter.equals('region_code', region));
    List recordsDynamic = await _elrsStore.find(
      await _db,
      finder: finder,
    );
    List<Map<String, dynamic>> records = [];

    for(var record in recordsDynamic){
      records.add(record.value);
    }
    return records;
  }

  Future<void> updateCameraCrashTable(Map<String, dynamic> value) async {
    _cameraCrashStore.record(1).put(await _db, value);
  }

  Future<void> addImagePath(XFile image) async {
    int pathCount = await imagePathStore.count(await _db);
    if (pathCount == 0) {
      if (image.path != null) {
        String path = image.path;
        int lastIndex = path.lastIndexOf('/');
        String picturesFolder = path.substring(0, lastIndex);
        await imagePathStore.record(1).put(await _db,
            {'image_path' : picturesFolder});
      }
    }
  }

  Future<String> getImagePath() async {
    String imagePath;
    var result = await imagePathStore.record(1).get(await _db);
    if(result != null){
      print(result['image_path']);
      imagePath = result['image_path'];
    }
    return imagePath;
  }


  Future <void> login(String username, String password) async {

    _isLoadingLogin = true;
    _authenticationErrorMessage = '';
    notifyListeners();

    try {

      ConnectivityResult connectivityResult = await Connectivity().checkConnectivity();

      if(connectivityResult == ConnectivityResult.none) {
        _authenticationErrorMessage = 'No data connection, unable to login';
      } else {


        bool hasSession = await getSession(username, password);

        if(hasSession){

          int elrCount = await _elrsStore.count(await _db);
          if(elrCount == 0){
            final Map<String, dynamic> elrResult = await getElrs();

            if(!elrResult['success']){
              logout();
            }
          }
          int routeCount = await _routesStore.count(await _db);
          if(routeCount == 0){

            List<Map<String,dynamic>> routes = [
              {'route_name': 'Anglia', 'route_code': 'QT'},
              {'route_name': 'Southeast', 'route_code': 'QK'},
              {'route_name': 'London North East', 'route_code': 'QG'},
              {'route_name': 'London North West (North)', 'route_code': 'QR'},
              {'route_name': 'London North West (South)', 'route_code': 'QS'},
              {'route_name': 'East Midlands', 'route_code': 'QM'},
              {'route_name': 'Scotland', 'route_code': 'QL'},
              {'route_name': 'Wales', 'route_code': 'QC'},
              {'route_name': 'Wessex', 'route_code': 'QW'},
              {'route_name': 'Western (West)', 'route_code': 'QD'},
              {'route_name': 'Western (Thames Valley)', 'route_code': 'QV'},
            ];

            for(Map<String, dynamic> route in routes) {

              bool existingRoute = false;
              final Db.Finder finder = Db.Finder(filter: Db.Filter.equals('route_name', route['route_name']));
              List records = await _routesStore.find(
                await _db,
                finder: finder,
              );

              if(records.length > 0) existingRoute = true;

              if(existingRoute){
                await _routesStore.update(await _db, route,
                    finder: finder);

              } else {
                int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
                await _routesStore.record(_id).put(await _db,
                    route);
              }

            }
          }
          int cameraCrashCount = await _cameraCrashStore.count(await _db);
          if(cameraCrashCount == 0){
            int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
            await _cameraCrashStore.record(_id).put(await _db,
                {'has_crashed' : 0, 'image_index': 0});
          }
        }
      }
    } on TimeoutException catch (_) {

      _authenticationErrorMessage = 'Request timeout, please try again later';
      // A timeout occurred.
    } catch(error){
      _authenticationErrorMessage = 'Something went wrong';
    }
    _isLoadingLogin = false;
    notifyListeners();
  }

  Future<bool> getSession(String username, String password) async{

    bool success = false;

    final Map<String,dynamic> authData = {
      'loginData': {'username': username, 'password': password},
    };

    try {

      //Make the POST request to the server
      Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
          serverUrl + 'login', authData, false).timeout(Duration(seconds: 90));


      if (serverResponse != null) {
        if (serverResponse['error'] != null &&
            serverResponse['error'] == 'incorrect_details') {
          _authenticationErrorMessage = 'Incorrect username or password given';
        } else if (serverResponse['error'] != null &&
            serverResponse['error'] == 'terms_not_accepted') {
          _authenticationErrorMessage =
          'You need to accept the terms & conditions before using this app';
        } else if (serverResponse['error'] != null &&
            serverResponse['error'] == 'change_password') {
          _authenticationErrorMessage = 'You are required to change your password';
        } else if (serverResponse['response']['session'] != null) {

          cookie = serverResponse['response']['session'];
          sharedPreferences.setString('cookie', GlobalFunctions.encryptString(cookie));

          final DateTime now = DateTime.now();

          final DateTime cookieExpiryTime = now.add(Duration(minutes: 28));

          user = AuthenticatedUser(
              userId: int.parse(serverResponse['response']['id']),
              firstName: serverResponse['response']['first_name'],
              lastName: serverResponse['response']['last_name'],
              username: username,
              password: password,
              suspended: serverResponse['response']['suspended'],
              organisationId: int.parse(serverResponse['response']['organisation_id']),
              organisationName: serverResponse['response']['organisation_name'],
              session: serverResponse['response']['session'],
              deleted: serverResponse['response']['deleted'],
              isClientAdmin: serverResponse['response']['is_client_admin'],
              isSuperAdmin: serverResponse['response']['is_super_admin'],
              termsAccepted: serverResponse['response']['terms_accepted'],
              forcePasswordReset: serverResponse['response']['force_password_reset']);


          String encryptedFirstName = GlobalFunctions.encryptString(user.firstName);
          String encryptedLastName = GlobalFunctions.encryptString(user.lastName);
          String encryptedUsername = GlobalFunctions.encryptString(user.username);
          String encryptedPassword = GlobalFunctions.encryptString(user.password);
          String encryptedSession = GlobalFunctions.encryptString(user.session);

          Map<String, dynamic> userData = {
            'user_id': user.userId,
            'first_name': encryptedFirstName,
            'last_name': encryptedLastName,
            'username': encryptedUsername,
            'password': encryptedPassword,
            'suspended': user.suspended,
            'organisation_id': user.organisationId,
            'organisation_name': user.organisationName,
            'session': encryptedSession,
            'deleted': user.deleted,
            'is_client_admin': user.isClientAdmin,
            'is_super_admin': user.isSuperAdmin,
            'terms_accepted': user.termsAccepted,
            'force_password_reset': user.forcePasswordReset,
            'dark_mode': false,
          };

          sharedPreferences.setInt('userId', user.userId);
          sharedPreferences.setString('firstName', encryptedFirstName);
          sharedPreferences.setString('lastName', encryptedLastName);
          sharedPreferences.setString('username', encryptedUsername);
          sharedPreferences.setString('password', encryptedPassword);
          sharedPreferences.setBool('suspended', user.suspended);
          sharedPreferences.setInt(
              'organisationId', user.organisationId);
          sharedPreferences.setString('organisationName', user.organisationName);
          sharedPreferences.setString('session', encryptedSession);
          sharedPreferences.setBool('deleted', user.deleted);
          sharedPreferences.setBool('isClientAdmin', user.isClientAdmin);
          sharedPreferences.setBool('isSuperAdmin', user.isSuperAdmin);
          sharedPreferences.setString('termsAccepted', user.termsAccepted);
          sharedPreferences.setBool('forcePasswordReset', user.forcePasswordReset);
          sharedPreferences.setBool('rememberMe', true);
          sharedPreferences.setBool('darkMode', false);
          sharedPreferences.setString('cookieExpiryTime', cookieExpiryTime.toIso8601String());


          //Sembast
          bool existingUser = false;
          final Db.Finder finder = Db.Finder(filter: Db.Filter.equals('userId', user.userId));
          List records = await _usersStore.find(
            await _db,
            finder: finder,
          );

          if(records.length > 0) existingUser = true;

          if(existingUser){
            await _usersStore.update(await _db, userData,
                finder: finder);

          } else {
            int _id = DateTime.now().millisecondsSinceEpoch + int.parse(random_string.randomNumeric(2));
            await _usersStore.record(_id).put(await _db,
                userData);
          }


          success = true;


        } else {
          _authenticationErrorMessage = 'no valid session found';
        }

      }

  } on TimeoutException catch (_) {

  _authenticationErrorMessage = 'Request timeout, please try again later';
  // A timeout occurred.
  } catch(error){
  _authenticationErrorMessage = 'Something went wrong';
  }

  return success;

  }

  Future<Map<String, dynamic>> getElrs() async {

    bool success = false;
    String message = 'Something went wrong';

    try {
      ConnectivityResult connectivityResult = await (new Connectivity().checkConnectivity());

      if (connectivityResult == ConnectivityResult.none) {
        message = 'No data connection, unable to fetch Elr Data';
      } else {

        final Map<String, dynamic> requestData = {
          'incidentData': {},
        };

        bool isCookieExpired = await GlobalFunctions.isCookieExpired();
        bool hasSession = true;

        if (isCookieExpired) {
          hasSession = await getSession(
              user.username,
              user.password);
        }

        if(hasSession){

          Map<String, dynamic> serverResponse = await GlobalFunctions.apiRequest(
              serverUrl + 'getElrs', requestData)
              .timeout(Duration(seconds: 90));

          if (serverResponse != null) {

            if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Token missing or invalid') {
              message = 'token missing or invalid';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'Access Denied.') {

              message = 'access denied';


            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'terms_not_accepted') {
              message =
              'You need to accept the terms & conditions before using this app';
            } else if (serverResponse['error'] != null &&
                serverResponse['error'] == 'change_password') {
              message = 'You are required to change your password';
            } else if (serverResponse['response']['elrs'] != null) {
              List<dynamic> elrList = serverResponse['response']['elrs'];

              for (Map<String, dynamic> elrData in elrList) {

                Map<String, dynamic> databaseData = {
                  'region_code': elrData['HdElrLookup']['region'],
                  'elr': elrData['HdElrLookup']['elr'],
                  'description': elrData['HdElrLookup']['description'],
                  'start_miles': elrData['HdElrLookup']['start_miles'],
                  'end_miles': elrData['HdElrLookup']['end_miles'],
                };

                bool existingElr = false;
                final Db.Finder finder = Db.Finder(filter: Db.Filter.equals('elr', elrData['HdElrLookup']['elr']));
                List records = await _elrsStore.find(
                  await _db,
                  finder: finder,
                );

                if(records.length > 0) existingElr = true;

                if(existingElr){
                  await _elrsStore.update(await _db, databaseData,
                      finder: finder);

                } else {
                  int count = await _elrsStore.count(await _db);
                  int id;
                  if (count == 0) {
                    id = 1;
                  } else {
                    id = count + 1;
                  }
                  await _elrsStore.record(id).put(await _db,
                      databaseData);
                }
              }

              success = true;
              message = 'successfully got ELRs';
            }
          } else {
            message = 'no valid session found';
          }


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



    autoLogin(){
    final bool rememberMe = sharedPreferences.getBool('rememberMe');

    if(rememberMe != null && rememberMe == true){
      user = AuthenticatedUser(
          userId: sharedPreferences.getInt('userId'),
          firstName: GlobalFunctions.decryptString(sharedPreferences.get('firstName')),
          lastName: GlobalFunctions.decryptString(sharedPreferences.get('lastName')),
          username: GlobalFunctions.decryptString(sharedPreferences.get('username')),
          password: GlobalFunctions.decryptString(sharedPreferences.get('password')),
          suspended: sharedPreferences.getBool('suspended'),
          organisationId: sharedPreferences.getInt('organisationId'),
          organisationName: sharedPreferences.get('organisationName'),
          session: GlobalFunctions.decryptString(sharedPreferences.get('session')),
          deleted: sharedPreferences.getBool('deleted'),
          isClientAdmin: sharedPreferences.getBool('isClientAdmin'),
          isSuperAdmin: sharedPreferences.getBool('isSuperAdmin'),
          termsAccepted: sharedPreferences.get('termsAccepted'),
          forcePasswordReset: sharedPreferences.getBool('forcePasswordReset'),
          darkMode: sharedPreferences.getBool('darkMode'));

      if(sharedPreferences.get('cookie') != null) cookie = GlobalFunctions.decryptString(sharedPreferences.get('cookie'));
      notifyListeners();

    }
  }


   void logout() {
    user = null;
    notifyListeners();
    sharedPreferences.remove('rememberMe');
  }



}
