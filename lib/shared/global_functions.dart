import 'dart:convert';
import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';

import 'package:connectivity/connectivity.dart';
import 'package:location/location.dart' as geoLocation;
import 'package:random_string/random_string.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as imagePackage;
import 'package:encrypt/encrypt.dart' as Encrypt;

import '../shared/global_config.dart';
//import '../widgets/helpers/static_map_provider.dart';

class GlobalFunctions {
  static Future<Map<String, dynamic>> apiRequest(
      String url, Map<String, dynamic> dataMap,
      [bool requiresCookie = true]) async {

    var client = http.Client();
    Map<String, String> headers = {
      'Content-type': 'application/json',
      'Connection': 'Keep-Alive',
    };

    if(requiresCookie){
      headers.addAll({
        'Cookie' : 'CAKEPHP=' + cookie,
      });
      dataMap['incidentData']['incident_token'] = secureIncidentToken;
    }



    var response = await client.post(Uri.parse(url), headers: headers, body: utf8.encode(json.encode(dataMap)));
    client.close();
    return(jsonDecode(response.body));
  }

  // static Future<Map<String, dynamic>> apiRequest(
  //     String url, Map<String, dynamic> dataMap,
  //     [bool requiresCookie = true]) async {
  //   HttpClient httpClient = new HttpClient();
  //
  //   //httpClient.connectionTimeout = const Duration(seconds: 1);
  //   HttpClientRequest request = await httpClient.postUrl(Uri.parse("https://cryptic-shelf-82365.herokuapp.com/"+url));
  //   request.headers.set('Content-type', 'application/json');
  //   request.headers.set('Connection', 'Keep-Alive');
  //   if (requiresCookie) {
  //     request.headers.set('Cookie', 'CAKEPHP=' + cookie);
  //     dataMap['incidentData']['incident_token'] = secureIncidentToken;
  //   }
  //   request.add(utf8.encode(json.encode(dataMap)));
  //   HttpClientResponse response = await request.close();
  //
  //   if (response.statusCode != 200 && response.statusCode != 201) {
  //     return null;
  //   }
  //   String serverResponse = await response.transform(utf8.decoder).join();
  //   httpClient.close();
  //   Map<String, dynamic> decodedResponse = jsonDecode(serverResponse);
  //   return decodedResponse;
  // }

  static String encryptString(String value) {
    String encryptedValueIv;

    if (value == null || value == '' || value.isEmpty) {
      encryptedValueIv = '';
    } else {
      final Encrypt.IV initializationVector = Encrypt.IV.fromUtf8(randomAlpha(8));
      final encrypter = Encrypt.Encrypter(Encrypt.AES(encryptionKey));
      Encrypt.Encrypted encryptedValue = encrypter.encrypt(value, iv: initializationVector);
      String encryptedStringValue = encryptedValue.base16;
      encryptedValueIv = encryptedStringValue + initializationVector.base16;
    }

    return encryptedValueIv;
  }

  static String decryptString(String value) {
    String decryptedValue;

    if (value == null || value == '' || value.isEmpty) {
      decryptedValue = '';
    } else {
      int valueLength = value.length;
      int valueRequired = valueLength - 16;
      int startOfIv = valueLength - 16;
      String valueToDecrypt = value.substring(0, valueRequired);
      final Encrypt.IV initializationVector = Encrypt.IV.fromBase16(value.substring(startOfIv));
      final encrypter = Encrypt.Encrypter(Encrypt.AES(encryptionKey));
      decryptedValue = encrypter.decrypt(Encrypt.Encrypted.fromBase16(valueToDecrypt), iv: initializationVector);
    }

    return decryptedValue;
  }

  static RichText boldTitleText(String title, String field, BuildContext context){

    return RichText(
      text: TextSpan(
        text: title,
        style: TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.caption.color,),
        children: [
          TextSpan(
              text: field,
              style: TextStyle(fontFamily: 'Open Sans',
                fontWeight: FontWeight.normal,
                color: Theme.of(context).textTheme.caption.color,)
          ),
        ],
      ),
    );

  }



  static Future<SharedPreferences> getSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences;
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

  // static Future<Map<String, dynamic>> getUserLocation() async {
  //   bool success = false;
  //   double latitude;
  //   double longitude;
  //   final geoLocation.Location location = geoLocation.Location();
  //
  //   try {
  //     final Map<String, double> currentLocation = await location.getLocation();
  //     print('this is the current location');
  //     print(currentLocation);
  //
  //     if (currentLocation != null) {
  //       latitude = currentLocation['latitude'];
  //       longitude = currentLocation['longitude'];
  //       success = true;
  //     }
  //   } catch (error) {
  //     print(error);
  //   }
  //
  //   return {'success': success, 'latitude': latitude, 'longitude': longitude};
  // }

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
    BotToast.showText(text: message, align: Alignment.center, duration: Duration(milliseconds: 2500));
  }
}
