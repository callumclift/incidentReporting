import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:dynamic_theme/dynamic_theme.dart';

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

import '../models/user.dart';
import '../models/authenticated_user.dart';
import '../models/auth.dart';
import '../utils/database_helper.dart';
import '../shared/global_config.dart';


class GlobalFunctions {


  static Future<Map<String,dynamic>> apiRequest(String url, Map<String,dynamic> dataMap, [bool requiresCookie = true]) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('Content-type', 'application/json');
    request.headers.set('Connection', 'Keep-Alive');
    if(requiresCookie){
      request.headers.set('Cookie', 'CAKEPHP='+cookie);
      dataMap['incidentData']['incident_token'] = secureIncidentToken;
    }
    print('this is data map');
    print(dataMap);
    print('this is the request');
    print(request.connectionInfo);
    print(request.headers);
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

  static Future<SharedPreferences> getSharedPreferences() async{

    SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences;
  }


  static void toggleDarkMode(BuildContext context){
    DynamicTheme.of(context).setThemeData(new ThemeData(
      brightness:
      Theme.of(context).brightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark,
      primaryColor:
      Theme.of(context).primaryColor == Colors.grey
          ? Colors.deepOrange
          : Colors.grey,
      buttonColor: Theme.of(context).buttonColor == Colors.grey
          ? Colors.deepOrange
          : Colors.grey,
      accentColor: Theme.of(context).buttonColor == Colors.grey
          ? Colors.grey
          : Colors.grey,
    ));
  }

  static void setLightMode(BuildContext context){

    DynamicTheme.of(context).setThemeData(new ThemeData(
        inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(width: 2.0, color: Color.fromARGB(255, 255, 147, 94))),
            labelStyle: TextStyle(color: Colors.grey)),
        //fontFamily: 'Oswald',
        primaryColor: Color.fromARGB(255, 254, 147, 94),
        //primarySwatch: Colors.deepOrange,
        accentColor: Colors.grey,
        buttonColor: Color.fromARGB(255, 254, 147, 94),
        brightness: Brightness.light),);
  }

  static void setDarkMode(BuildContext context){

    DynamicTheme.of(context).setThemeData(new ThemeData(
        inputDecorationTheme: InputDecorationTheme(
            focusedBorder: UnderlineInputBorder(
                borderSide:
                BorderSide(width: 2.0, color: Color.fromARGB(255, 255, 147, 94))),
            labelStyle: TextStyle(color: Colors.grey)),
        //fontFamily: 'Oswald',
        primaryColor: Color.fromARGB(255, 254, 147, 94),
        //primarySwatch: Colors.deepOrange,
        accentColor: Colors.grey,
        buttonColor: Color.fromARGB(255, 254, 147, 94),
        brightness: Brightness.dark),);
  }

}