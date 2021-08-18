import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:connectivity/connectivity.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart' as geoLocation;
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rxdart/subjects.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as imagePackage;
import 'package:encrypt/encrypt.dart';

import '../shared/global_config.dart';
//import '../widgets/helpers/static_map_provider.dart';

class GlobalFunctions {
  static Future<Map<String, dynamic>> apiRequest(
      String url, Map<String, dynamic> dataMap,
      [bool requiresCookie = true]) async {
    HttpClient httpClient = new HttpClient();
    //httpClient.connectionTimeout = const Duration(seconds: 1);
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('Content-type', 'application/json');
    request.headers.set('Connection', 'Keep-Alive');
    if (requiresCookie) {
      request.headers.set('Cookie', 'CAKEPHP=' + cookie);
      dataMap['incidentData']['incident_token'] = secureIncidentToken;
    }
    request.add(utf8.encode(json.encode(dataMap)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    print('here is the status code');
    print(response.statusCode);
    if (response.statusCode != 200 && response.statusCode != 201) {
      return null;
    }
    String serverResponse = await response.transform(utf8.decoder).join();
    httpClient.close();
    Map<String, dynamic> decodedResponse = jsonDecode(serverResponse);
    return decodedResponse;
  }

  static String encryptString(String value) {
    final String initializationVector = randomAlphaNumeric(8);
    String encryptedValueIv = '';

    final encrypter =
        new Encrypter(new Salsa20(encryptionKey, initializationVector));
    String encryptedValue = encrypter.encrypt(value);

    encryptedValueIv = encryptedValue + initializationVector;

    return encryptedValueIv;
  }

  static String decryptString(String value) {
    String decryptedValue = '';

    int valueLength = value.length;

    int valueRequired = valueLength - 8;
    int startOfIv = valueLength - 8;

    String valueToDecrypt = value.substring(0, valueRequired);
    final String initializationVector = value.substring(startOfIv);

    final encrypter =
        new Encrypter(new Salsa20(encryptionKey, initializationVector));

    decryptedValue = encrypter.decrypt(valueToDecrypt);

    return decryptedValue;
  }

  static Future<SharedPreferences> getSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences;
  }

  static void toggleDarkMode(BuildContext context) {
    // DynamicTheme.of(context).setThemeData(new ThemeData(
    //   brightness: Theme.of(context).brightness == Brightness.dark
    //       ? Brightness.light
    //       : Brightness.dark,
    //   primaryColor: Theme.of(context).primaryColor == Colors.grey
    //       ? Colors.deepOrange
    //       : Colors.grey,
    //   buttonColor: Theme.of(context).buttonColor == Colors.grey
    //       ? Colors.deepOrange
    //       : Colors.grey,
    //   accentColor: Theme.of(context).buttonColor == Colors.grey
    //       ? Colors.grey
    //       : Colors.grey,
    // ));
  }

  static void setLightMode(BuildContext context) {
    // DynamicTheme.of(context).setThemeData(
    //   new ThemeData(fontFamily: 'OpenSans',
    //       inputDecorationTheme: InputDecorationTheme(
    //           focusedBorder: UnderlineInputBorder(
    //               borderSide:
    //               BorderSide(width: 2.0, color: Color.fromARGB(255, 255, 147, 94))),
    //           labelStyle: TextStyle(color: Colors.grey)),
    //       //fontFamily: 'Oswald',
    //       primaryColor: Color.fromARGB(255, 254, 147, 94),
    //       //primarySwatch: Colors.deepOrange,
    //       accentColor: Colors.grey,
    //       buttonColor: Color.fromARGB(255, 254, 147, 94),
    //       brightness: Brightness.light),
    // );
  }

  static void setDarkMode(BuildContext context) {
    // DynamicTheme.of(context).setThemeData(
    //   new ThemeData(fontFamily: 'OpenSans',
    //       inputDecorationTheme: InputDecorationTheme(
    //           focusedBorder: UnderlineInputBorder(
    //               borderSide:
    //               BorderSide(width: 2.0, color: Color.fromARGB(255, 255, 147, 94))),
    //           labelStyle: TextStyle(color: Colors.grey)),
    //       //fontFamily: 'Oswald',
    //       primaryColor: Color.fromARGB(255, 254, 147, 94),
    //       //primarySwatch: Colors.deepOrange,
    //       accentColor: Colors.grey,
    //       buttonColor: Color.fromARGB(255, 254, 147, 94),
    //       brightness: Brightness.dark),
    // );
  }

  static List<int> compressImageAndroid(File image) {
    print('about to try the compression ios');

    List<int> compressedImage = imagePackage.encodeJpg(imagePackage.decodeImage(image.readAsBytesSync()), quality: 50);

    return compressedImage;
  }

  static Future<List<int>> compressImageIos(File image) async{
    // print('about to try the compression ios');
    //
    // List<int> compressedImage = await FlutterImageCompress.compressWithFile(image.absolute.path, quality: 50);
    //
    // return compressedImage;
  }

  static Future <Map<String, dynamic>> compressImage(File image, String path) async{


    // List<int> compressedImage = await FlutterImageCompress.compressWithFile(image.absolute.path, quality: 50);
    //
    // File compressedFile = await FlutterImageCompress.compressAndGetFile(image.absolute.path, path, quality: 50);
    //
    // return {'image_bytes' : compressedImage, 'compressed_file': compressedFile};
  }

  static String getBase64Image(List<int> imageBytes) {
    print('about to try the new thing');
    String base64Image = base64Encode(imageBytes);

    return base64Image;
  }

  static String encryptBase64(String value) {
    final String initializationVector = randomAlphaNumeric(8);
    String encryptedValueIv = '';

    final encrypter =
        new Encrypter(new Salsa20(encryptionKey, initializationVector));
    String encryptedValue = encrypter.encrypt(value);

    encryptedValueIv = encryptedValue + initializationVector;

    return encryptedValueIv;
  }

  static String decryptBase64(String value) {
    String decryptedValue = '';

    int valueLength = value.length;

    int valueRequired = valueLength - 8;
    int startOfIv = valueLength - 8;

    String valueToDecrypt = value.substring(0, valueRequired);
    final String initializationVector = value.substring(startOfIv);

    final encrypter =
        new Encrypter(new Salsa20(encryptionKey, initializationVector));

    decryptedValue = encrypter.decrypt(valueToDecrypt);

    return decryptedValue;
  }

  static Future<bool> isCookieExpired() async {
    bool result = false;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String cookieExpiryTime = prefs.get('cookieExpiryTime');
    final DateTime parsedExpiryTime = DateTime.parse(cookieExpiryTime);
    final DateTime now = DateTime.now();

    if (parsedExpiryTime.isBefore(now)) {
      //renew the cookie for the user
      result = true;
    }

    return result;
  }

  static Future<Widget> showLoadingDialog(
      BuildContext context, String message) async {
    return await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(32.0))),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              //mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(orangeDesign1),
                ),
                SizedBox(
                  height: 10.0,
                ),
                new Text(
                  message,
                  style: TextStyle(fontSize: 20.0),
                ),
              ],
            ),
          );
        });
  }

  static Future<Map<String, dynamic>> getStaticMap(BuildContext context,
      {String postcode, bool geocode = true, double lat, double lng}) async {
    Uri staticMapUri;
    bool success = false;
    double latitude;
    double longitude;

    if(lat != null && lng != null){
      latitude = lat;
      longitude = lng;
    }

    try {
      if (geocode) {
        print('ok its going to geocode');
        final Uri uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/geocode/json',
          {'address': postcode.toUpperCase(), 'key': browserApi},
        );
        final http.Response response = await http.get(uri);
        final decodedResponse = json.decode(response.body);
        print('here is the response');
        print(decodedResponse);
        final coordinates =
            decodedResponse['results'][0]['geometry']['location'];
        latitude = coordinates['lat'];
        longitude = coordinates['lng'];
      }

      // final StaticMapProvider staticMapViewProvider = StaticMapProvider(browserApi);
      // staticMapUri = staticMapViewProvider.getStaticUriWithMarkers(
      //     latitude: latitude,
      //     longitude: longitude,
      //     width: 500,
      //     height: 300,
      //     );
      success = true;
    } catch (error) {
      print(error);
    }

    return {'success': success, 'map': staticMapUri.toString()};
  }

  static Future<Map<String, dynamic>> getUserLocation() async {
    bool success = false;
    double latitude;
    double longitude;
    final geoLocation.Location location = geoLocation.Location();

    try {
      final Map<String, double> currentLocation = await location.getLocation();
      print('this is the current location');
      print(currentLocation);

      if (currentLocation != null) {
        latitude = currentLocation['latitude'];
        longitude = currentLocation['longitude'];
        success = true;
      }
    } catch (error) {
      print(error);
    }

    return {'success': success, 'latitude': latitude, 'longitude': longitude};
  }

  static Future<Map<String, dynamic>> geocodePostcode(String postcode) async {
    bool success = false;
    double latitude;
    double longitude;
    String message = 'Unable to load map';

    ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none)
      message = 'No data connection to fetch map';

    if (connectivityResult != ConnectivityResult.none) {
      try {
        print('ok its going to geocode');
        final Uri uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/geocode/json',
          {'address': postcode.toUpperCase(), 'key': browserApi},
        );
        final http.Response response = await http.get(uri);
        final decodedResponse = json.decode(response.body);
        final coordinates =
            decodedResponse['results'][0]['geometry']['location'];
        latitude = coordinates['lat'];
        longitude = coordinates['lng'];
        message = 'success';
        success = true;
      } catch (error) {
        print(error);
      }
    }
    return {
      'success': success,
      'latitude': latitude,
      'longitude': longitude,
      'message': message
    };
  }

  static void showToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        timeInSecForIos: 2,
        gravity: ToastGravity.CENTER,
        backgroundColor: orangeDesign1,
        textColor: Colors.black);
  }
}
